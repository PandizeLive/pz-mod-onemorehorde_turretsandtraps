import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {MODULES,validateScenario,upgradeScenario} from './loot-lab-settings.ts';
const require=createRequire(import.meta.url);
const model=require('../../../art/loot-tuner/model.js');
const data=JSON.parse(readFileSync(new URL('../../../art/loot-tuner/data.js',import.meta.url),'utf8').replace(/^window.LOOT_DATA=/,'').trim().replace(/;$/,''));
const fresh=model.defaults(data);
test('cloud schema matches all 38 local catalog controls',()=>{
 assert.deepEqual(MODULES,Object.keys(fresh.items));
 assert.deepEqual(validateScenario(fresh),fresh);
});
test('prior catalog keeps exact account weights and tiers while adding Siphon',()=>{
 const old=structuredClone(fresh);old.baseline='T&T 0.2.50';delete old.items.Siphon;delete old.visible.Siphon;
 old.items.Regulator=.375;old.items.Void=2;old.visible.Range=false;old.tierWeights.Mythic=.75;
 const saved=JSON.stringify(old),upgraded=upgradeScenario(old);
 assert.equal(upgraded.items.Siphon,1);assert.equal(upgraded.visible.Siphon,true);
 assert.equal(upgraded.items.Regulator,.375);assert.equal(upgraded.items.Void,2);
 assert.equal(upgraded.visible.Range,false);assert.equal(upgraded.tierWeights.Mythic,.75);
 assert.equal(JSON.stringify(old),saved);
 assert.deepEqual(model.validate(old,data),upgraded);
});
test('catalog rejects malformed new weights and unknown component IDs',()=>{
 assert.throws(()=>validateScenario({...fresh,items:{...fresh.items,Siphon:-1}}));
 assert.throws(()=>validateScenario({...fresh,items:{...fresh.items,Invented:1}}));
});
test('Siphon loads at Legendary weight 3 in fresh and upgraded accounts',()=>{
 const tiers=require('../../../art/loot-tuner/tier-list.js');
 const weights=Object.fromEntries(data.modules.map(m=>[m.id,m.weight*fresh.items[m.id]]));
 assert.equal(weights.Siphon,3);
 assert.equal(tiers.bands(data.modules,weights,Object.values(fresh.tierWeights)).Siphon,5);
 const prior=structuredClone(fresh);prior.baseline='T&T 0.2.54';
 assert.deepEqual(upgradeScenario(prior),fresh);
 assert.deepEqual(model.validate(prior,data),fresh);
});

test('Grid upgrades prior patch versions without changing any saved weights or tiers',()=>{
 for(const baseline of ['T&T 0.2.54.1','T&T 0.2.56','T&T 0.2.56.1']){
  const old=structuredClone(fresh);old.baseline=baseline;delete old.items.Grid;delete old.visible.Grid;
  old.items.Siphon=.234;old.items.Void=.17;old.tierWeights.Mythic=.75;
  const serialized=JSON.stringify(old),next=upgradeScenario(old);
  assert.equal(JSON.stringify(old),serialized);assert.equal(next.items.Grid,1);assert.equal(next.visible.Grid,true);
  for(const [id,value] of Object.entries(old.items))assert.equal(next.items[id],value);
  assert.deepEqual(next.tierWeights,old.tierWeights);
  assert.equal(data.modules.find(m=>m.id==='Grid').weight,1);
  assert.equal(Object.values(data.pools).filter(p=>p.modules.includes('Grid')).length,13);
 }
 const custom=structuredClone(fresh);custom.items.Grid=.625;assert.equal(upgradeScenario(custom).items.Grid,.625);
});

test('previous corrective builds preserve custom tuning while adding manuals',()=>{
 const old=structuredClone(fresh);old.baseline='T&T 0.2.64.4';old.global=1.011111111111111;old.items.Range=.47321;
 for(const key of MODULES.filter(x=>x.startsWith('Manual'))){delete old.items[key];delete old.visible[key];}
 const local=model.validate(old,data),cloud=upgradeScenario(old);
 assert.equal(local.global,old.global);assert.equal(local.items.Range,old.items.Range);
 assert.deepEqual(local,cloud);assert.equal(local.items.ManualArc,6);
});

test('new manuals inherit saved tier anchors without retuning explicit item weights',()=>{
 const old=structuredClone(fresh);old.baseline='T&T 0.2.64.4';
 old.tierWeights.Uncommon=24;old.tierWeights.Epic=8;old.items.Range=.47321;
 for(const key of MODULES.filter(x=>x.startsWith('Manual'))){delete old.items[key];delete old.visible[key];}
 old.items.ManualFirearms=.625;old.visible.ManualFirearms=false;
 const local=model.validate(old,data),cloud=upgradeScenario(old);
 assert.deepEqual(local,cloud);assert.equal(local.items.ManualBallista,24);
 assert.equal(local.items.ManualArc,8);assert.equal(local.items.ManualFirearms,.625);
 assert.equal(local.visible.ManualFirearms,false);assert.equal(local.items.Range,.47321);
});
