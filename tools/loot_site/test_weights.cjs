'use strict';
const assert=require('node:assert/strict'),path=require('node:path');
const site=path.resolve(__dirname,'../../art/loot-tuner');
global.window={};require(path.join(site,'data.js'));
const D=window.LOOT_DATA,M=require(path.join(site,'model.js'));
const before=M.defaults(D);
before.global=2.7;before.items.Regulator=1.5;before.items.Synergy=0;before.visible.Range=false;
const persisted=JSON.stringify(before),restored=M.validate(JSON.parse(persisted),D);
assert.equal(M.lootWeight(D.modules.find(m=>m.id==='Regulator'),restored.items.Regulator),8.25);
assert.deepEqual(M.generate(D,restored),M.generate(D,before));
assert.equal(JSON.stringify(before),persisted);
for(const m of D.modules){
  for(const multiplier of [0,.1,.3333333333333333,1,1.5,20]){
    const weight=M.lootWeight(m,multiplier),roundtrip=M.weightMultiplier(m,weight);
    assert(Math.abs(roundtrip-multiplier)<1e-12);
    for(const pool of Object.values(D.pools)){
      assert.equal(M.probability(m.weight*(pool.scale??1),2.7,roundtrip,.6),M.probability(m.weight*(pool.scale??1),2.7,multiplier,.6));
    }
  }
  for(const value of [-1,Infinity,NaN,m.weight*20+.01])assert.throws(()=>M.weightMultiplier(m,value));
}
const regulator=D.modules.find(m=>m.id==='Regulator');
assert.equal(M.weightMultiplier(regulator,11),2);
assert.equal(M.lootWeight(regulator,M.weightMultiplier(regulator,0)),0);
console.log('PASS: direct weights for 33 modules, exact seeded-world preservation, fractional/zero/max inputs, invalid input rejection and Sandbox multiplier conversion.');
