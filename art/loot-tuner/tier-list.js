(function(root){
'use strict';
const names=['Abundant','Common','Uncommon','Rare','Epic','Legendary','Mythic'];
const colors=['#82aeff','#73ccff','#59e666','#fffa4d','#ff9433','#ff2e2e','#420d82'];
function anchorError(tiers){
  if(!tiers||tiers.every(w=>w===null))return null;
  if(tiers.length!==7||tiers.some(w=>!Number.isFinite(w)||w<=0||w>1000000))return 'Set all seven tier weights above zero, or reset to automatic rarity.';
  if(tiers.some((w,i)=>i>0&&w>=tiers[i-1]))return 'Tier weights must decrease from Abundant to Mythic, with no duplicates.';
  return null;
}
function sandbox(tiers){
  const error=anchorError(tiers);if(error)throw Error(error);
  return names.map((name,i)=>`    RarityWeight${name} = ${tiers?.[i]??0},`);
}
function bands(modules,weights,tiers){
  const invalid=anchorError(tiers),custom=tiers&&tiers.every(w=>w>0)&&!invalid;
  const positive=modules.map(m=>weights[m.id]).filter(w=>w>0);
  const low=Math.min(...positive),high=Math.max(...positive);
  const result={};
  for(const m of modules){
    const w=weights[m.id];let band=0;
    if(custom)while(band<6&&w<=Math.sqrt(tiers[band]*tiers[band+1]))band++;
    result[m.id]=w<=0?-1:invalid?-2:custom?band:high===low?0:Math.max(0,Math.min(6,Math.floor(Math.log(high/w)/Math.log(high/low)*6+.5)));
  }
  return result;
}
function create(modules,weights,previousTiers){
  const positive=Object.values(weights).filter(w=>w>0),high=positive.length?Math.max(...positive):15,low=positive.length?Math.min(...positive):1;
  const savedTiers=previousTiers?[...previousTiers]:names.map(()=>null);
  const tiers=names.map((_,i)=>savedTiers[i]??Number((high*((low===high?low/64:low)/high)**(i/6)).toPrecision(12)));
  const groups={},calculated=bands(modules,weights,tiers);
  for(const m of modules){
    const matches=tiers.map((value,i)=>Math.abs(value-weights[m.id])<=1e-10*Math.max(Number.EPSILON,value,weights[m.id])?i:-1).filter(i=>i>=0);
    if(matches.length)groups[m.id]=matches.includes(calculated[m.id])?calculated[m.id]:matches[0];
  }
  return {original:{...weights},weights:{...weights},groups,custom:{},tiers,savedTiers,openingTiers:[...tiers]};
}
function assign(draft,module,tier){
  if(tier===-1){delete draft.groups[module.id];delete draft.custom[module.id];draft.weights[module.id]=draft.original[module.id];return true;}
  const weight=draft.tiers[tier];
  if(!Number.isFinite(weight)||weight<0||weight>module.weight*20)return false;
  draft.groups[module.id]=tier;draft.weights[module.id]=weight;delete draft.custom[module.id];return true;
}
function confirm(draft,modules,current){
  const out={...current};
  for(const m of modules){
    if(draft.groups[m.id]===undefined||draft.weights[m.id]===draft.original[m.id])continue;
    if(current[m.id]!==draft.original[m.id])throw Error('Saved weights changed while this draft was open. Cancel and reopen to use the latest values.');
    const value=draft.weights[m.id];
    if(!Number.isFinite(value)||value<0||value>m.weight*20)throw Error('Invalid weight for '+m.name);
    out[m.id]=value;
  }
  return out;
}
function confirmTiers(draft,current){
  const merged=draft.tiers.map((value,i)=>{
    if(!Number.isFinite(value)||value<0||value>1000000)throw Error('Invalid tier weight.');
    if(value===draft.openingTiers[i])return current[i]??value;
    if(current[i]!==draft.savedTiers[i]&&current[i]!==value)throw Error('Saved tier weights changed while this draft was open. Cancel and reopen to use the latest values.');
    return value;
  });
  const error=anchorError(merged);if(error)throw Error(error);
  return merged;
}
function mount({element,modules,read,readTiers,apply}){
  let draft=null,dragged=null;
  const el=(tag,cls,text)=>{const n=document.createElement(tag);if(cls)n.className=cls;if(text!==undefined)n.textContent=text;return n;};
  const toolbar=el('div','tier-toolbar'),open=el('button','','Plan with tiers'),summary=el('span','hint');
  open.type='button';toolbar.append(open,summary);element.append(toolbar);
  const body=el('div','tier-editor');body.hidden=true;element.append(body);
  const refreshSummary=()=>{const count=Array(7).fill(0);for(const b of Object.values(bands(modules,draft?draft.weights:read(),draft?draft.tiers:readTiers())))if(b>=0)count[b]++;summary.textContent=count.filter(n=>n>0).length+'/7 rarity colors used · '+modules.length+' components';};
  function render(){
    refreshSummary();
    body.replaceChildren();
    const description=el('p','hint','Drag modules into a tier, or use their Move to menu. Tier weights define rarity and battery cost; personal overrides stay editable. Unassigned modules keep their current weights. Matching weights are placed automatically when reopened. Confirm saves tier weights with your settings, including across refreshes. Nothing is applied until Confirm.');
    const status=el('p','tier-status');status.setAttribute('role','status');
    const band=bands(modules,draft.weights,draft.tiers),counts=Array(7).fill(0);for(const b of Object.values(band))if(b>=0)counts[b]++;
    const preview=el('div','tier-spread');preview.setAttribute('aria-label','Draft rarity distribution');
    names.forEach((name,i)=>{const badge=el('span','tier-badge',name+' '+counts[i]);badge.style.setProperty('--tier-color',colors[i]);preview.append(badge);});
    body.append(description,preview,el('p','hint','Rarity changes at proportional midpoints between tier weights. Personal overrides use the same rule. Export Sandbox settings for mod 0.2.47.4 or newer to apply these tiers in-game. Disabled items have no loot chance.'));
    const lanes=[];
    for(const tier of [6,5,4,3,2,1,0,-1]){
      const lane=el('section','tier-lane');lane.dataset.tier=tier;lane.setAttribute('aria-label',tier<0?'Unassigned':names[tier]);lane.style.setProperty('--tier-color',tier<0?'#82928a':colors[tier]);
      const heading=el('div','tier-heading'),list=el('div','tier-cards');heading.append(el('h3','',tier<0?'Unassigned':names[tier]));
      if(tier>=0){const label=el('label','','Tier weight'),input=el('input');input.type='number';input.min=0;input.max=1000000;input.step='any';input.value=Number(draft.tiers[tier].toPrecision(12));input.setAttribute('aria-label',names[tier]+' tier weight');label.append(input);heading.append(label);
        input.onchange=()=>{const value=input.value.trim()===''?NaN:Number(input.value);const members=modules.filter(m=>draft.groups[m.id]===tier&&!draft.custom[m.id]);
          if(!Number.isFinite(value)||value<0||value>1000000||members.some(m=>value>m.weight*20)){status.textContent='That tier weight is outside a member’s allowed range.';input.value=Number(draft.tiers[tier].toPrecision(12));return;}
          draft.tiers[tier]=value;for(const m of members)draft.weights[m.id]=value;render();};
      }else heading.append(el('small','','Keeps current weights'));
      lane.append(heading,list);lanes[tier+1]=list;body.append(lane);
      lane.ondragover=e=>{e.preventDefault();e.dataTransfer.dropEffect='move';};
      lane.ondrop=e=>{e.preventDefault();const id=dragged||e.dataTransfer.getData('text/plain'),m=modules.find(m=>m.id===id);if(!m)return;if(!assign(draft,m,tier)){status.textContent='Tier weight exceeds '+m.name+'’s maximum ('+(m.weight*20)+').';return;}dragged=null;render();};
    }
    for(const m of modules){
      const tier=draft.groups[m.id]??-1,card=el('article','tier-card'),b=band[m.id];card.draggable=true;card.dataset.module=m.id;
      card.style.setProperty('--rarity-color',b<0?'#82928a':colors[b]);card.dataset.rarity=b===-2?'Invalid tiers':b<0?'Disabled':names[b];
      card.ondragstart=e=>{if(['INPUT','SELECT','OPTION'].includes(e.target.tagName)){e.preventDefault();return;}dragged=m.id;e.dataTransfer.setData('text/plain',m.id);e.dataTransfer.effectAllowed='move';};card.ondragend=()=>{dragged=null;};
      card.append(el('strong','',m.name),el('small','tier-actual',(b===-2?'Invalid tiers':b<0?'Disabled':names[b])+(draft.custom[m.id]?' · custom':'')));
      const input=el('input');input.type='number';input.min=0;input.max=m.weight*20;input.step='any';input.value=Number(draft.weights[m.id].toPrecision(12));input.disabled=tier<0;input.setAttribute('aria-label',m.name+' draft weight');
      input.onchange=()=>{const value=input.value.trim()===''?NaN:Number(input.value);if(!input.validity.valid||!Number.isFinite(value)){status.textContent='Enter a weight from 0 to '+input.max;input.value=Number(draft.weights[m.id].toPrecision(12));return;}draft.weights[m.id]=value;draft.custom[m.id]=true;render();};
      const move=el('select');move.setAttribute('aria-label','Move '+m.name+' to tier');
      ['Unassigned',...names].forEach((name,i)=>{const option=el('option','',name);option.value=i-1;move.append(option);});move.value=tier;
      move.onchange=()=>{if(!assign(draft,m,Number(move.value))){status.textContent='Tier weight exceeds '+m.name+'’s maximum ('+(m.weight*20)+').';move.value=tier;return;}render();};
      card.append(input,move);lanes[tier+1].append(card);
    }
    const footer=el('div','tier-footer'),accept=el('button','primary','Confirm weights'),cancel=el('button','','Cancel draft');
    status.textContent=anchorError(draft.tiers)||'';
    accept.type=cancel.type='button';accept.onclick=()=>{try{const weights=confirm(draft,modules,read());const tiers=confirmTiers(draft,readTiers());apply(weights,tiers);draft=null;body.hidden=true;open.hidden=false;refreshSummary();}catch(error){status.textContent=error.message;}};
    cancel.onclick=()=>{draft=null;body.hidden=true;open.hidden=false;refreshSummary();};footer.append(status,accept,cancel);body.append(footer);
  }
  open.onclick=()=>{draft=create(modules,read(),readTiers());render();body.hidden=false;open.hidden=true;};
  refreshSummary();return {refresh:refreshSummary};
}
const api={names,colors,anchorError,sandbox,bands,create,assign,confirm,confirmTiers,mount};
if(typeof module==='object'&&module.exports)module.exports=api;else root.LootTiers=api;
})(typeof window==='object'?window:globalThis);
