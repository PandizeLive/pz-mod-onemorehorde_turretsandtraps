'use strict';
const D=window.LOOT_DATA, M=window.LootModel, $=id=>document.getElementById(id);
let scenario=M.defaults(D), prepared=null, result=null, sample=null, generation=0, redrawPending=false;
const moduleAppearance={
  Firing:['#f2bd62','circle'],MotionDetection:['#56b4e9','circle'],Filter:['#ed648c','circle'],Detection360:['#b888f5','circle'],Suppression:['#47ce88','circle'],
  RapidFire:['#ff7959','triangle'],Reload:['#e0dc66','square'],Velocity:['#74dedc','triangle'],Range:['#bd97dc','triangle'],
  CapacitySmall:['#8ca756','hexagon'],Capacity:['#f69ed0','hexagon'],CapacityLarge:['#d09a75','hexagon'],Autoloader:['#bbc9da','square'],
  Critical:['#eea577','triangle'],Accuracy:['#93d6b5','triangle'],Magazine:['#a3b8ff','square'],Splitter:['#dc9f49','diamond'],Fragment:['#ce82a9','diamond'],
  FiringEnhanced:['#e9d6a0','circle'],MotionDetectionEnhanced:['#64aab0','circle'],Piercing:['#8edbff','diamond'],InitialBlow:['#ffb4a2','diamond'],
  Execute:['#e96969','diamond'],Impact:['#c4db72','diamond'],Conservation:['#70d4ac','square'],Regulator:['#a1c7ff','square'],Synergy:['#d4a6ff','diamond'],Martyrdom:['#ff934f','diamond'],Tack:['#f5db84','diamond']
};
const familyNames={circle:'Control',triangle:'Ballistics',square:'Ammo & reload',diamond:'Hit effects',hexagon:'Expansion'};
function appearance(id){
  if(moduleAppearance[id])return moduleAppearance[id];
  let hash=0;for(const ch of id)hash=(hash*31+ch.charCodeAt(0))>>>0;
  return [`hsl(${hash%360} 65% 70%)`,'circle'];
}
const appearances=D.modules.map(m=>appearance(m.id)),colors=appearances.map(a=>a[0]);
const shapePoints={triangle:[[0,-1],[.866,.5],[-.866,.5]],square:[[-.707,-.707],[.707,-.707],[.707,.707],[-.707,.707]],diamond:[[0,-1],[1,0],[0,1],[-1,0]],hexagon:[[0,-1],[.866,-.5],[.866,.5],[0,1],[-.866,.5],[-.866,-.5]]};
function drawMarker(x,y,r,module){
  const points=shapePoints[appearances[module][1]];ctx.beginPath();
  if(points){points.forEach(([px,py],i)=>i?ctx.lineTo(x+px*r,y+py*r):ctx.moveTo(x+px*r,y+py*r));ctx.closePath();}
  else ctx.arc(x,y,r,0,Math.PI*2);
  ctx.fill();
}
let markers=[],chanceCache=[];
const number=n=>n.toLocaleString(undefined,{maximumFractionDigits:1});
const pretty=s=>s.replace(/([a-z])([A-Z])/g,'$1 $2');
const canvas=$('map'), ctx=canvas.getContext('2d');
let width=1,height=1,view={x:9900,y:7848,scale:.04};
const geometry=D.map.map(([kind,rings])=>{
  const path=new Path2D(), bounds=[Infinity,Infinity,-Infinity,-Infinity];
  for(const ring of rings){ring.forEach(([x,y],i)=>{i?path.lineTo(x,y):path.moveTo(x,y);bounds[0]=Math.min(bounds[0],x);bounds[1]=Math.min(bounds[1],y);bounds[2]=Math.max(bounds[2],x);bounds[3]=Math.max(bounds[3],y);});if(kind!=='road')path.closePath();}
  return {kind,path,bounds};
});
$('baseline').textContent=`PZ ${D.meta.game} · ${D.meta.baseline}`;
$('count').textContent=D.containers.length.toLocaleString();
$('methodMeta').textContent=`Extracted ${D.meta.headers.toLocaleString()} map cells, ${D.meta.roomRecords.toLocaleString()} room records and ${D.meta.routes} eligible routing rules.`;
for(const [i,l] of D.labels.entries()){const o=document.createElement('option');o.value=i;o.textContent=pretty(l[0]);$('town').append(o);}
for(const m of [{id:'all',name:'All components'},...D.modules]){const o=document.createElement('option');o.value=m.id;o.textContent=m.name;$('selected').append(o);}
for(const [i,m] of D.modules.entries()){
  const div=document.createElement('div');div.className='component';div.id='component-'+m.id;
  const top=document.createElement('div'),label=document.createElement('label'),swatch=document.createElement('span'),span=document.createElement('span'),show=document.createElement('input'),input=document.createElement('input'),small=document.createElement('small');
  top.className='component-top';label.className='component-name';swatch.className='swatch shape-'+appearances[i][1];swatch.style.backgroundColor=colors[i];swatch.title=familyNames[appearances[i][1]];
  show.type='checkbox';show.id='show-'+m.id;show.setAttribute('aria-label','Show '+m.name+' on map');
  show.addEventListener('change',()=>{scenario.visible[m.id]=show.checked;controls();updateSampleSummary();scheduleDraw();saveSettings();});
  span.textContent=m.name;input.type='number';input.min=0;input.max=20;input.step=.05;input.id='item-'+m.id;input.className='rate';input.setAttribute('aria-label',m.name+' loot multiplier');
  const changeRate=()=>{if(input.value.trim()===''||!Number.isFinite(Number(input.value)))return;scenario.items[m.id]=bounded(input.value,0,20,1);saveSettings();scheduleUpdate();};
  input.addEventListener('input',changeRate);
  input.addEventListener('change',()=>{changeRate();input.value=scenario.items[m.id];});
  small.id='estimate-'+m.id;label.append(show,swatch,span);top.append(label,input);
  const rarity=document.createElement('div'),track=document.createElement('div'),marker=document.createElement('span'),ends=document.createElement('div');
  rarity.className='rarity';track.className='rarity-track';track.id='rarity-'+m.id;track.setAttribute('role','meter');track.setAttribute('aria-label',m.name+' estimated abundance');track.setAttribute('aria-valuemin','0');track.setAttribute('aria-valuemax','1000');
  marker.className='rarity-marker shape-'+appearances[i][1];marker.id='rarity-marker-'+m.id;marker.style.backgroundColor=colors[i];track.append(marker);
  ends.className='rarity-ends';for(const text of ['Rare','Common']){const end=document.createElement('span');end.textContent=text;ends.append(end);}rarity.append(track,ends);
  div.append(top,rarity,small);$('components').append(div);
}
function bounded(value,min,max,fallback){const n=Number(value);return Number.isFinite(n)?Math.min(max,Math.max(min,n)):fallback;}
let updateTimer=null;
function scheduleUpdate(){clearTimeout(updateTimer);updateTimer=setTimeout(()=>{updateTimer=null;update();},150);}
function fieldValue(id,value){const input=$(id);if(document.activeElement!==input)input.value=value;}
function controls(){
  for(const key of ['global','material','rolls','retention']){fieldValue(key,scenario[key]);$(key+'Out').textContent=key==='retention'?Math.round(scenario[key]*100)+'%':scenario[key].toFixed(2)+'×';}
  for(const m of D.modules){fieldValue('item-'+m.id,scenario.items[m.id]);$('show-'+m.id).checked=scenario.visible[m.id];$('component-'+m.id).classList.toggle('is-hidden',!scenario.visible[m.id]);}
  $('overlay').value=scenario.overlay;$('seedBadge').textContent='Seed '+scenario.seed;
  fieldValue('seed',scenario.seed);$('selected').value=scenario.selected;
}
function fillTable(id,rows){
  const fragment=document.createDocumentFragment();
  for(const row of rows){const tr=document.createElement('tr');for(const text of row){const td=document.createElement('td');td.textContent=text;tr.append(td);}fragment.append(tr);}
  $(id).replaceChildren(fragment);
}
function update(){
  controls();if(!prepared)return;
  result=M.evaluate(D,prepared,scenario);sample=M.generate(D,scenario);
  // Cache probabilities on settings changes, never recompute powers during a touch frame.
  chanceCache=D.modules.map((m,module)=>{
    const poolChances=prepared.pools.map((p,pi)=>1-(1-result.poolProbabilities[module][pi])**M.rolls(D.pools[p].rolls,scenario.rolls));
    return Float64Array.from(prepared.hits,hits=>hits.reduce((n,count,p)=>n+count/prepared.samples*poolChances[p],0));
  });
  const positive=result.hauls.reduce((n,h)=>n+h.presence,0),oneTwo=result.hauls.reduce((n,h)=>n+h.oneOrTwo,0),jackpots=result.hauls.reduce((n,h)=>n+h.jackpot,0);
  $('findCount').textContent=number(positive);
  $('findChance').textContent=(100*positive/D.containers.length).toFixed(1)+'%';
  $('smallHaul').textContent=positive?(100*oneTwo/positive).toFixed(1)+'%':'—';
  $('jackpotChance').textContent=positive?(100*jackpots/positive).toFixed(1)+'%':'—';
  $('mean').textContent=number(result.mean);$('range').textContent=`${number(result.lo)}–${number(result.hi)}`;
  $('zero').textContent=result.zero===0?'0%':result.zero<.0001?'<0.01%':(100*result.zero).toFixed(2)+'%';
  D.modules.forEach((m,i)=>{
    const expected=result.itemMeans[i],track=$('rarity-'+m.id);
    $('estimate-'+m.id).textContent=`${sample.totals[i]} generated · ${number(expected)} expected · weight ${m.weight}`;
    $('rarity-marker-'+m.id).style.left=(window.LootMapControls.rarityPosition(expected)*100)+'%';
    track.setAttribute('aria-valuenow',String(Math.min(1000,expected)));track.setAttribute('aria-valuetext',expected===0?'Disabled':number(expected)+' expected items countywide');
    track.title=expected===0?'Disabled':number(expected)+' expected items countywide; fixed 0–1,000+ log scale';
  });
  fillTable('regions',result.regions.slice().sort((a,b)=>b.mean-a.mean).map(r=>[pretty(r.name),number(r.mean),`${r.lo}–${r.hi}`]));
  fillTable('pools',result.poolMeans.map(p=>[pretty(p.name),number(p.containers)]));
  updateSampleSummary();$('feedback').textContent='Scenario updated. Game settings unchanged.';scheduleDraw();
}
function updateSampleSummary(){
  if(!sample)return;
  const total=sample.totals.reduce((a,b)=>a+b,0),visible=sample.totals.reduce((n,count,i)=>n+(scenario.visible[D.modules[i].id]?count:0),0);
  $('sampleSummary').textContent=`Sample world: ${number(total)} items generated · ${number(visible)} visible · seed ${sample.seed}`;
}
async function prepare(){
  const token=++generation;$('loading').hidden=false;$('refresh').disabled=true;prepared=null;
  const value=await M.prepare(D,scenario.seed,p=>{if(token===generation)$('loading').textContent=`Modelling room loot routes… ${Math.round(p*100)}%`;});
  if(token!==generation)return;prepared=value;$('loading').hidden=true;$('refresh').disabled=false;update();
}
$('refresh').addEventListener('click',()=>{
  const seed=crypto.getRandomValues(new Uint32Array(1))[0];scenario.seed=seed===scenario.seed?(seed+1)>>>0:seed;controls();saveSettings();prepare();
});
$('overlay').addEventListener('change',()=>{scenario.overlay=$('overlay').value;scheduleDraw();saveSettings();});
for(const [id,visible] of [['showAll',true],['hideAll',false]])$(id).addEventListener('click',()=>{for(const m of D.modules)scenario.visible[m.id]=visible;controls();updateSampleSummary();scheduleDraw();saveSettings();});
for(const key of ['global','material','rolls','retention'])$(key).addEventListener('input',()=>{scenario[key]=Number($(key).value);saveSettings();scheduleUpdate();});
$('selected').addEventListener('change',()=>{scenario.selected=$('selected').value;update();saveSettings();});
let seedTimer=null;
$('seed').addEventListener('input',()=>{const raw=$('seed').value;if(raw.trim()===''||!Number.isFinite(Number(raw)))return;scenario.seed=Math.floor(bounded(raw,0,4294967295,24601));saveSettings();clearTimeout(seedTimer);seedTimer=setTimeout(()=>prepare().catch(modelError),150);});
$('seed').addEventListener('change',()=>{$('seed').value=scenario.seed;});
$('reset').addEventListener('click',()=>{const old=scenario.seed;scenario=M.defaults(D);controls();saveSettings(true);old===scenario.seed&&prepared?update():prepare();});
function download(name,text,type){const a=document.createElement('a'),url=URL.createObjectURL(new Blob([text],{type}));a.href=url;a.download=name;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);$('feedback').textContent='Exported '+name+'.';}
$('save').addEventListener('click',()=>download('omh-loot-scenario.json',JSON.stringify(scenario,null,2),'application/json'));
$('lua').addEventListener('click',()=>{
  const lines=[`-- OMH loot tuning: ${D.meta.baseline} keys. Merge into your SandboxVars table.`,
    '-- Do not replace an entire save configuration with this excerpt.',
    '-- Retention and model seed are estimates only; not game settings.',
    '-- Assumes ZombiePopLootEffect = 0 and a new-world time multiplier of 1.',
    `MaterialLootNew = ${scenario.material},`,`RollsMultiplier = ${scenario.rolls},`,'OMHTurretsTraps = {',`    ModuleLootRate = ${scenario.global},`,
    ...D.modules.map(m=>`    LootRate${m.id} = ${scenario.items[m.id]},`),'}'];
  download('omh-loot-sandbox-excerpt.lua',lines.join('\n')+'\n','text/plain');
});
$('load').addEventListener('click',()=>$('file').click());
$('file').addEventListener('change',async()=>{try{const f=$('file').files[0];if(!f)return;if(f.size>100000)throw Error('Scenario is too large.');const raw=JSON.parse(await f.text());const old=scenario.seed;scenario=M.validate(raw,D);controls();saveSettings(true);old===scenario.seed&&prepared?update():await prepare();$('feedback').textContent='Scenario loaded. Game settings unchanged.';}catch(e){$('feedback').textContent='Could not load: '+e.message;}finally{$('file').value='';}});
function fit(){const b=D.bounds;view.x=(b[0]+b[2])/2;view.y=(b[1]+b[3])/2;view.scale=Math.min(width/(b[2]-b[0]+600),height/(b[3]-b[1]+600));scheduleDraw();}
function zoom(factor,x=width/2,y=height/2){const wx=(x-width/2)/view.scale+view.x,wy=(y-height/2)/view.scale+view.y;view.scale=Math.max(.015,Math.min(18,view.scale*factor));view.x=wx-(x-width/2)/view.scale;view.y=wy-(y-height/2)/view.scale;scheduleDraw();}
$('fit').addEventListener('click',()=>{$('town').value='';fit();});$('zoomIn').addEventListener('click',()=>zoom(1.7));$('zoomOut').addEventListener('click',()=>zoom(1/1.7));
$('town').addEventListener('change',()=>{if($('town').value==='')return fit();const l=D.labels[Number($('town').value)];view.x=l[1];view.y=l[2];view.scale=Math.min(width,height)/2200;scheduleDraw();});
canvas.addEventListener('wheel',e=>{e.preventDefault();const b=canvas.getBoundingClientRect();zoom(Math.exp(-e.deltaY*.0015),e.clientX-b.left,e.clientY-b.top);$('tooltip').hidden=true;},{passive:false});
function pointerPoint(e){const b=canvas.getBoundingClientRect();return {id:e.pointerId,x:e.clientX-b.left,y:e.clientY-b.top,type:e.pointerType};}
const gestures=window.LootMapControls.createGestures({getView:()=>view,getSize:()=>({width,height}),setView:value=>{view=value;$('tooltip').hidden=true;scheduleDraw();},onTap:point=>showTooltip(point.x,point.y,point.type==='touch'?24:10)});
canvas.addEventListener('pointerdown',e=>{if(e.pointerType==='mouse'&&e.button!==0)return;gestures.down(pointerPoint(e));canvas.setPointerCapture(e.pointerId);canvas.style.cursor='grabbing';$('tooltip').hidden=true;});
canvas.addEventListener('pointerup',e=>{gestures.up(pointerPoint(e));if(!gestures.active())canvas.style.cursor='grab';});
canvas.addEventListener('pointercancel',e=>{gestures.up(pointerPoint(e),true);canvas.style.cursor='grab';});
canvas.addEventListener('lostpointercapture',e=>{gestures.up(pointerPoint(e),true);canvas.style.cursor='grab';});
canvas.addEventListener('pointerleave',e=>{if(e.pointerType==='mouse')$('tooltip').hidden=true;});
canvas.addEventListener('pointermove',e=>{const point=pointerPoint(e);if(gestures.move(point))return;if(e.pointerType!=='touch')showTooltip(point.x,point.y,10);});
window.addEventListener('blur',()=>gestures.reset());
function showTooltip(mx,my,radius){
  if(!result || !prepared || view.scale<.4){$('tooltip').hidden=true;return;}
  let nearest=null,dist=radius*radius;
  for(const marker of markers){const d=(marker.x-mx)**2+(marker.y-my)**2;if(d<Math.max(dist,(marker.radius||0)**2)&&(!nearest||d<dist)){dist=d;nearest=marker;}}
  if(!nearest){$('tooltip').hidden=true;return;}
  const index=nearest.container,c=D.containers[index],r=D.routes[c.route];
  const lines=D.modules.flatMap((m,i)=>{
    if(!scenario.visible[m.id])return [];
    const count=sample.spawns.find(s=>s.container===index&&s.module===i)?.count||0;
    const chance=containerChance(index,i);
    return chance>0||count>0?[`${m.name}: ${count} generated · ${(chance*100).toFixed(2)}% chance`]:[];
  });
  $('tooltip').textContent=`${pretty(r.room)} · ${c.type}\n${sample.containerTotals[index]>=5?"JACKPOT · ":""}${sample.containerTotals[index]} total components generated\nAny component: ${(result.hauls[index].presence*100).toFixed(2)}% · 5+ haul: ${(result.hauls[index].jackpot*100).toFixed(2)}%\nTile ${c.x}, ${c.y} · floor ${c.z}\n${lines.join('\n')}\nSample pool: ${sample.poolByContainer[index]||'No component pool'}\nSimulated outcome, not a guaranteed drop.`;
  $('tooltip').hidden=false;$('tooltip').style.left=Math.max(5,Math.min(width-$('tooltip').offsetWidth-8,mx+15))+'px';$('tooltip').style.top=Math.max(5,Math.min(height-$('tooltip').offsetHeight-8,my+15))+'px';
}
function containerChance(index,module){return chanceCache[module]?.[index]||0;}
function screen(x,y){return [(x-view.x)*view.scale+width/2,(y-view.y)*view.scale+height/2];}
function scheduleDraw(){if(redrawPending)return;redrawPending=true;requestAnimationFrame(()=>{redrawPending=false;draw();});}
function draw(){
  const dpr=window.devicePixelRatio||1;ctx.setTransform(dpr,0,0,dpr,0,0);ctx.fillStyle='#26342e';ctx.fillRect(0,0,width,height);
  const left=view.x-width/2/view.scale,right=view.x+width/2/view.scale,top=view.y-height/2/view.scale,bottom=view.y+height/2/view.scale;
  ctx.save();ctx.translate(width/2,height/2);ctx.scale(view.scale,view.scale);ctx.translate(-view.x,-view.y);
  for(const g of geometry){const b=g.bounds;if(b[2]<left||b[0]>right||b[3]<top||b[1]>bottom)continue;if(g.kind==='building'&&view.scale<.07)continue;
    if(g.kind==='road'){ctx.strokeStyle='#718078';ctx.lineWidth=Math.max(2,1/view.scale);ctx.stroke(g.path);}
    else{ctx.fillStyle=g.kind==='water'?'#294955':'#617168';ctx.fill(g.path,'evenodd');}
  }ctx.restore();
  markers=[];
  if(result&&sample&&prepared){
    const bins=new Map();
    const dot=(index,module,value,count)=>{
      const c=D.containers[index];if(!scenario.visible[D.modules[module].id]||c.x<left||c.x>right||c.y<top||c.y>bottom)return;
      let[x,y]=screen(c.x,c.y);
      if(view.scale>=.4){
        // Small screen-space separation makes co-located components visible without inventing tiles.
        const angle=module/D.modules.length*Math.PI*2;x+=Math.cos(angle)*6;y+=Math.sin(angle)*6;
        ctx.globalAlpha=scenario.overlay==='spawns'?.95:Math.min(.85,.16+Math.sqrt(value)*.7);ctx.fillStyle=colors[module];
        drawMarker(x,y,M.markerRadius(scenario.overlay,sample.containerTotals[index],result.hauls[index].jackpot),module);ctx.globalAlpha=1;
        markers.push({x,y,container:index,module,radius:M.markerRadius(scenario.overlay,sample.containerTotals[index],result.hauls[index].jackpot)});
      }else{
        const key=Math.floor(x/18)+','+Math.floor(y/18)+','+module;
        const bin=bins.get(key)||{x:0,y:0,n:0,value:0,module};bin.x+=x;bin.y+=y;bin.n++;bin.jackpot=bin.jackpot||sample.containerTotals[index]>=5;bin.value+=scenario.overlay==='spawns'?count:value;bins.set(key,bin);
      }
    };
    if(scenario.overlay==='spawns')for(const spawn of sample.spawns)dot(spawn.container,spawn.module,1,spawn.count);
    else D.containers.forEach((c,index)=>{if(c.x<left||c.x>right||c.y<top||c.y>bottom)return;for(let i=0;i<D.modules.length;i++){if(!scenario.visible[D.modules[i].id])continue;const chance=containerChance(index,i);if(chance>0)dot(index,i,chance,0);}});
    for(const b of bins.values()){
      const angle=b.module/D.modules.length*Math.PI*2;
      ctx.globalAlpha=scenario.overlay==='spawns'?.85:.45;ctx.fillStyle=colors[b.module];drawMarker(b.x/b.n+Math.cos(angle)*5,b.y/b.n+Math.sin(angle)*5,Math.min(b.jackpot&&scenario.overlay==='spawns'?13:9,2+Math.sqrt(b.value)*1.5+(b.jackpot&&scenario.overlay==='spawns'?4:0)),b.module);ctx.globalAlpha=1;
    }
  }
  ctx.textAlign='center';ctx.textBaseline='middle';ctx.font='600 12px system-ui';
  for(const l of D.labels){const[x,y]=screen(l[1],l[2]);if(x<0||y<0||x>width||y>height)continue;const name=pretty(l[0]);ctx.lineWidth=4;ctx.strokeStyle='#172522';ctx.strokeText(name,x,y);ctx.fillStyle='#eff4e9';ctx.fillText(name,x,y);}
  let tiles=10**Math.floor(Math.log10(100/view.scale));if(tiles*view.scale<40)tiles*=5;
  ctx.textAlign='right';ctx.font='11px system-ui';ctx.fillStyle='#edf0e8';ctx.fillText(number(tiles)+' tiles',width-17,height-34);ctx.strokeStyle='#edf0e8';ctx.lineWidth=2;ctx.beginPath();ctx.moveTo(width-17-tiles*view.scale,height-24);ctx.lineTo(width-17,height-24);ctx.stroke();
}
new ResizeObserver(()=>{$('visibilityActions').style.top=Math.ceil($('syncBanner').getBoundingClientRect().height)+'px';}).observe($('syncBanner'));
let firstResize=true;
new ResizeObserver(()=>{gestures.reset();const rect=canvas.getBoundingClientRect();width=rect.width;height=rect.height;const dpr=window.devicePixelRatio||1;canvas.width=Math.round(width*dpr);canvas.height=Math.round(height*dpr);firstResize?(fit(),firstResize=false):scheduleDraw();}).observe(canvas);
let settingsSync=null;
function syncStatus(text){$('syncStatus').textContent=text;$('syncBanner').classList.toggle('sync-error',/Not synced|not loaded|unavailable/i.test(text));$('syncNow').disabled=false;}
$('syncNow').addEventListener('click',()=>settingsSync?.sync());
function saveSettings(replace=false){if(settingsSync)settingsSync.edit(scenario,replace);else{try{localStorage.setItem('omh-lootlab-local',JSON.stringify(scenario));$('syncStatus').textContent='Saved in this browser only';}catch{$('syncStatus').textContent='Browser storage unavailable';}}}
function acceptSettings(next){const changed=JSON.stringify(next)!==JSON.stringify(scenario),seedChanged=next.seed!==scenario.seed;scenario=next;for(const input of document.querySelectorAll('input,select,button'))input.disabled=false;$('refresh').disabled=!prepared&&generation>0;if(seedChanged||!prepared){if(changed||generation===0)prepare().catch(modelError);}else if(changed)update();controls();}
function modelError(e){$('loading').textContent='Model failed: '+e.message;$('feedback').textContent='The tool could not finish its estimate.';}
if(location.protocol==='https:'&&location.pathname.startsWith('/admin/LootLab')){
  for(const input of document.querySelectorAll('input,select,button'))input.disabled=true;
  let storage;try{storage=localStorage;}catch{}
  settingsSync=window.LootSettings.create({defaults:M.defaults(D),previousBaselines:D.meta.previousBaselines,migrateValue:M.migrateValue,validate:value=>M.validate(value,D),transport:window.LootSettings.transport,storage,onChange:acceptSettings,onStatus:syncStatus});
  $('syncNow').hidden=false;settingsSync.sync();
  window.addEventListener('online',()=>settingsSync.sync());window.addEventListener('focus',()=>settingsSync.sync());
  document.addEventListener('visibilitychange',()=>settingsSync.sync());
  window.addEventListener('pagehide',()=>settingsSync.sync());
  setInterval(()=>{if(!document.hidden)settingsSync.sync();},15000);
}else{
  try{const saved=JSON.parse(localStorage.getItem('omh-lootlab-local'));if(saved)scenario=M.validate(saved,D);}catch{}
  $('hostedLink').hidden=false;syncStatus('Browser-only copy — changes do not sync between devices.');controls();prepare().catch(modelError);
}
