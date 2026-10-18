import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {MODULES,validateScenario,upgradeScenario} from './loot-lab-settings.ts';
const require=createRequire(import.meta.url);
const model=require('../../../art/loot-tuner/model.js');
const data=JSON.parse(readFileSync(new URL('../../../art/loot-tuner/data.js',import.meta.url),'utf8').replace(/^window.LOOT_DATA=/,'').trim().replace(/;$/,''));
const fresh=model.defaults(data);
test('cloud schema matches all 32 local module controls',()=>{
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
