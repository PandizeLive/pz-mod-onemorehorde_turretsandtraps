'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const site=path.resolve(__dirname,'../../art/loot-tuner');
global.window={};require(path.join(site,'data.js'));
const D=window.LOOT_DATA,M=require(path.join(site,'model.js'));
async function run(){
  assert.equal(D.containers.length,18630);assert.equal(D.routes.length,79);assert.equal(D.modules.length,20);
  assert.equal(D.modules.find(m=>m.id==='Suppression').weight,2.5);
  assert(D.modules.some(m=>m.id==='Critical')&&D.modules.some(m=>m.id==='Accuracy'));
  assert.equal(Object.keys(D.pools).length,16);
  assert.equal(M.probability(.5,1,1,.6),.003);
  assert.equal(M.probability(.25,1,1,.6),.0015);
  assert.equal(M.probability(.1,1,.05,.6),.0001);
  assert.equal(M.probability(.5,0,1,.6),0);
  assert.equal(M.probability(.5,1,0,.6),0);
  assert.equal(M.probability(.5,1,1,0),0);
  assert.equal(M.probability(2,20,20,10),1);
  assert.equal(M.rolls(4,0),1);assert.equal(M.rolls(4,.49),1);assert.equal(M.rolls(4,1),4);
  const rules=[{name:'Required',min:1,max:1,weightChance:1},{name:'Other',min:0,max:99,weightChance:100}];
  assert.equal(M.choose(rules,{},[],()=>.9),'Required');
  assert.equal(M.choose(rules,{Required:1},[],()=>0),'Other');
  assert.equal(M.choose(rules,{Required:1,Other:99},[],()=>0),null);
  assert.equal(M.choose(rules,{},['Forced'],()=>0),'Forced');
  assert.equal(M.choose([{name:'TileOnly',min:0,max:99,forceForTiles:'sprite'}],{},[],()=>0),null);
  const random=M.rng(23),draws=Array.from({length:20000},()=>M.binomial(100,.13,random));
  const mean=draws.reduce((a,b)=>a+b)/draws.length;
  assert(Math.abs(mean-13)<.12,'Binomial mean');
  assert.equal(M.binomial(100,1,random),100);assert.equal(M.binomial(100,0,random),0);
  assert.equal(M.binomial(0,.5,random),0);
  assert.deepEqual(M.haulDistribution([0],4),[1,0,0,0,0,0]);
  assert.deepEqual(M.haulDistribution([1],5),[0,0,0,0,0,1]);
  assert.deepEqual(M.haulDistribution([.5],2),[.25,.5,.25,0,0,0]);
  assert(M.markerRadius('spawns',5,0)>M.markerRadius('spawns',4,0));
  assert(M.markerRadius('chances',0,.5)>M.markerRadius('chances',0,.01));
  const s=M.defaults(D);assert.deepEqual(M.validate(s,D),s);assert.equal(s.global,1);assert.equal(s.items.Firing,1);assert.equal(s.items.Filter,1);
  const added=['Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced'];
  const factors=Object.fromEntries(D.modules.map(m=>[m.id,added.includes(m.id)?1:['Firing','MotionDetection','CapacitySmall','CapacityLarge','Autoloader'].includes(m.id)?3:2]));
  const saved={...s,baseline:'T&T 0.2.28',global:2.7,seed:348,items:{...s.items,Firing:0},visible:{...s.visible,Range:false}};
  for(const id of added){delete saved.items[id];delete saved.visible[id];}
  const refreshed=M.validate(saved,D);
  assert.equal(refreshed.global,2.7);assert.equal(refreshed.seed,348);assert.equal(refreshed.items.Firing,0);assert.equal(refreshed.visible.Range,false);
  for(const id of added){assert.equal(refreshed.items[id],1);assert.equal(refreshed.visible[id],true);}
  for(const id of ['FiringEnhanced','MotionDetectionEnhanced']) {
    assert.equal(D.modules.find(m=>m.id===id).weight,D.modules.find(m=>m.id==='CapacityLarge').weight);
    for(const pool of Object.values(D.pools))assert.equal(pool.modules.includes(id),pool.modules.includes('CapacityLarge'));
  }
  const approved={...s,baseline:'T&T 0.2.25',global:4.5,items:factors};
  assert.deepEqual(M.validate(approved,D),s,'Approved old multipliers normalize exactly to all ones');
  const oldData={...D,modules:D.modules.map(m=>({...m,weight:m.weight/4.5/factors[m.id]}))};
  assert.deepEqual(M.generate(oldData,approved),M.generate(D,s),'Normalization preserves every seeded container and count');
  const prior={...s,baseline:'T&T 0.2.26',global:1.7,items:{...s.items,Firing:3}};
  assert.deepEqual(M.validate(prior,D),{...prior,baseline:D.meta.baseline},'Already-normalized tuning survives without double division');
  const generated=M.generate(D,s);
  assert.equal(generated.containerTotals.reduce((a,b)=>a+b,0),generated.totals.reduce((a,b)=>a+b,0));
  assert(generated.spawns.length>0);
  assert.deepEqual(M.generate(D,s),generated,'Same seed and settings reproduce exact containers/items');
  assert.deepEqual(M.generate(D,{...s,visible:Object.fromEntries(D.modules.map(m=>[m.id,false]))}),generated,'Hiding components must never change rolls');
  assert.notDeepEqual(M.generate(D,{...s,seed:s.seed+1}).spawns,generated.spawns,'New seed rerolls world');
  assert.equal(M.generate(D,{...s,global:0}).spawns.length,0);
  const withoutFiring=M.generate(D,{...s,items:{...s.items,Firing:0}});
  assert.deepEqual(withoutFiring.spawns,generated.spawns.filter(v=>D.modules[v.module].id!=='Firing'),'Changing one rate must not reroll other components');
  assert.equal(generated.totals.reduce((a,b)=>a+b,0),generated.spawns.reduce((n,v)=>n+v.count,0));
  for(const spawn of generated.spawns){assert(D.containers[spawn.container]);assert(D.pools[generated.poolByContainer[spawn.container]]);assert(spawn.count>0&&spawn.count<=4);assert(D.pools[generated.poolByContainer[spawn.container]].modules.includes(D.modules[spawn.module].id));}
  const high=M.generate(D,{...s,global:s.global*2});
  assert(generated.spawns.every(a=>(high.spawns.find(b=>a.container===b.container&&a.module===b.module)?.count||0)>=a.count),'Increasing probability preserves lower-threshold successes');
  assert.throws(()=>M.validate({...s,visible:{Firing:'false'}},D));
  const legacy={...s};delete legacy.visible;delete legacy.overlay;
  assert(M.validate(legacy,D).visible.Firing,'Old scenario imports retain visible defaults');
  assert.throws(()=>M.validate({...s,global:Infinity},D));
  assert.throws(()=>M.validate({...s,items:{...s.items,Firing:-1}},D));
  const fixture={...D,containers:D.containers.slice(0,20)};
  assert.deepEqual(await M.prepare(fixture,5,()=>{},8),await M.prepare(fixture,5,()=>{},8));
  for(const c of D.containers){assert(D.routes[c.route]);assert.equal(typeof c.capacity,'string');assert(c.x>=0&&c.y>=0);assert(Array.isArray(c.forced));}
  const old={...s,baseline:'Installed 0.2.22',items:{...s.items},visible:{...s.visible},global:2.5};delete old.items.Critical;delete old.items.Accuracy;delete old.visible.Critical;delete old.visible.Accuracy;
  const upgraded=M.validate(old,D);assert.equal(upgraded.global,2.5/4.5);assert.equal(upgraded.items.Critical,.5);assert.equal(upgraded.baseline,D.meta.baseline);
  assert.deepEqual(D.pools.ElectricianTools.modules.slice().sort(),['Firing','MotionDetection','Filter','Detection360'].sort());
  const small={...D,containers:[{...D.containers[0],route:0,room:'only',forced:['GunStoreAccessories']}],routes:[{rules:[{name:'GunStoreAccessories',min:0,max:99}]}]};
  const certain={...s,global:20,material:10,items:Object.fromEntries(D.modules.map(m=>[m.id,20]))};
  const one=M.generate(small,certain),mini=M.evaluate(small,await M.prepare(small,1,()=>{},8),certain);
  for(let i=0;i<D.modules.length;i++){const eligible=D.pools.GunStoreAccessories.modules.includes(D.modules[i].id);assert.equal(one.totals[i],eligible?4:0);assert.equal(mini.itemMeans[i],eligible?4:0);}
  const start=Date.now(),p=await M.prepare(D,s.seed),a=M.evaluate(D,p,s);
  assert(a.mean>0);assert(a.lo<=a.mean&&a.mean<=a.hi);
  assert(Math.abs(a.regions.reduce((n,r)=>n+r.mean,0)-a.mean)<1e-8);
  assert(Math.abs(a.expectations.reduce((n,v)=>n+v,0)-a.mean)<1e-8);
  assert(a.presence.every(v=>v>=0&&v<=1));
  const zero=M.evaluate(D,p,{...s,global:0});assert.equal(zero.mean,0);assert.equal(zero.hi,0);assert.equal(zero.zero,1);
  const noRetention=M.evaluate(D,p,{...s,retention:0});assert.equal(noRetention.mean,0);
  const double=M.evaluate(D,p,{...s,global:s.global*2});assert(double.mean>a.mean);assert(Math.abs(double.mean-2*a.mean)<=a.meanTrials*D.modules.length*.0001,"Integer probability rounding bounds nonlinearity");
  const half=M.evaluate(D,p,{...s,retention:.5});assert(Math.abs(half.mean-.5*a.mean)<1e-8);
  const all=M.evaluate(D,p,{...s,selected:'all'});assert(Math.abs(all.mean-all.itemMeans.reduce((n,v)=>n+v,0))<1e-8);
  const finds=a.hauls.reduce((n,h)=>n+h.presence,0);
  const smallShare=a.hauls.reduce((n,h)=>n+h.oneOrTwo,0)/finds,jackpotShare=a.hauls.reduce((n,h)=>n+h.jackpot,0)/finds;
  assert(smallShare>.7&&jackpotShare>.01&&jackpotShare<.1,'Ordinary finds dominate while jackpots remain uncommon');
  const report={haul:{expectedSuccessfulContainers:finds,oneOrTwoShare:smallShare,jackpotShare},status:'passed',scope:'Numerical model, seeded per-container spawning and extracted-data integrity; no in-game spawn certification',generatedItems:generated.totals.reduce((a,b)=>a+b,0),elapsedMs:Date.now()-start,candidates:D.containers.length,worldSamples:p.samples,baseline:s,selectedEstimate:{mean:a.mean,lo:a.lo,hi:a.hi},allComponentsMean:all.mean,pools:a.poolMeans,regions:a.regions};
  fs.writeFileSync(path.resolve(__dirname,'../../diagnostics/loot-site/model-checks.json'),JSON.stringify(report,null,2));
  console.log(JSON.stringify(report,null,2));
}
run().catch(e=>{console.error(e);process.exitCode=1;});
