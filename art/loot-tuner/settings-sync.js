(function(root){
  'use strict';
  const copy=value=>JSON.parse(JSON.stringify(value));
  function flatten(value){const out={};for(const [key,v] of Object.entries(value)){if(v&&typeof v==='object')for(const [id,n] of Object.entries(v))out[key+'.'+id]=n;else out[key]=v;}return out;}
  function overlay(base,patch){const value=copy(base);for(const [path,entry] of Object.entries(patch)){const [key,id]=path.split('.');if(id)value[key][id]=entry.value;else value[key]=entry.value;}return value;}
  function create({defaults,previousBaselines=[],migrateValue=(path,value)=>value,validate,transport,storage,onChange,onStatus,schedule=setTimeout,cancel=clearTimeout}){
    let base=copy(defaults),value=copy(defaults),pending={},revision=0,sequence=0,account=null,ready=false,busy=false,timer=null;
    const key=()=> 'omh-lootlab-draft:'+account;
    function draft(){if(!account)return;try{if(Object.keys(pending).length)storage?.setItem(key(),JSON.stringify({baseline:defaults.baseline,pending}));else storage?.removeItem(key());}catch{/* Server saves still work when browser storage is unavailable. */}}
    function apply(){value=validate(overlay(base,pending));onChange(copy(value));}
    function queue(){cancel(timer);timer=schedule(()=>{void sync();},450);}
    function edit(next,replace=false){
      if(!ready)return;
      const clean=validate(next),before=flatten(value);
      for(const [path,v] of Object.entries(flatten(clean)))if(replace||v!==before[path])pending[path]={value:v,sequence:++sequence};
      value=copy(clean);draft();onStatus('Saving…');queue();
    }
    async function sync(){
      if(busy)return;busy=true;
      try{
        if(!ready){
          const remote=await transport('GET');account=remote.account;revision=remote.revision;base=validate(remote.scenario||defaults);
          try{const stored=JSON.parse(storage?.getItem(key())||'null');if(stored&&(stored.baseline===defaults.baseline||previousBaselines.includes(stored.baseline))){
            // Only recover known leaf paths, and validate the entire resulting scenario.
            const allowed=flatten(defaults),recovered={};for(const [path,entry] of Object.entries(stored.pending||{}))if(path!=='baseline'&&path!=='version'&&Object.hasOwn(allowed,path)&&entry&&Object.hasOwn(entry,'value'))recovered[path]={value:migrateValue(path,entry.value,stored.baseline),sequence:++sequence};
            validate(overlay(base,recovered));pending=recovered;
          }}catch{/* Ignore corrupt or obsolete local drafts. */}
          ready=true;apply();
        }
        if(Object.keys(pending).length){
          onStatus('Saving…');const sent=copy(pending),snapshot=validate(overlay(base,sent));
          const remote=await transport('PUT',{revision,scenario:snapshot});
          revision=remote.revision;base=validate(remote.scenario||defaults);
          if(!remote.conflict)for(const [path,entry] of Object.entries(sent))if(pending[path]?.sequence===entry.sequence)delete pending[path];
          apply();draft();
          if(Object.keys(pending).length){onStatus('Saving…');queue();}else onStatus('Saved across devices');
        }else{
          const remote=await transport('GET');
          if(remote.account!==account)throw Error('Your login changed. Reload this page.');
          if(remote.revision>=revision){revision=remote.revision;base=validate(remote.scenario||defaults);apply();}
          // Edits can arrive while the refresh request is in flight.
          if(Object.keys(pending).length){onStatus('Saving…');queue();}else onStatus('Saved across devices');
        }
      }catch(error){onStatus((ready?'Not synced—changes kept on this device. ':'Settings not loaded. ')+(error.message||'Retrying…'));}
      finally{busy=false;}
    }
    return {edit,sync,get ready(){return ready;},get value(){return copy(value);}};
  }
  async function transport(method,body){
    const response=await fetch('/admin/LootLab/settings',{method,signal:AbortSignal.timeout(15000),credentials:'same-origin',cache:'no-store',redirect:'error',keepalive:method==='PUT',headers:body?{'Content-Type':'application/json'}:{},body:body?JSON.stringify(body):undefined});
    if(![200,409].includes(response.status)||!response.headers.get('Content-Type')?.includes('application/json'))throw Error('Reconnect or sign in again.');
    const data=await response.json();return {...data,conflict:response.status===409};
  }
  const api={create,transport};if(typeof module!=='undefined')module.exports=api;else root.LootSettings=api;
})(typeof window!=='undefined'?window:globalThis);
