const assert=require('node:assert/strict'),path=require('node:path'),fs=require('node:fs');
const site=path.resolve(__dirname,'../../art/loot-tuner');global.window={};require(path.join(site,'data.js'));
const D=window.LOOT_DATA,M=require(path.join(site,'model.js')),T=require(path.join(site,'tier-list.js'));
const modules=D.modules,weights=Object.fromEntries(modules.map(m=>[m.id,M.lootWeight(m,D.defaults.items[m.id])]));
assert.equal(new Set(Object.values(T.bands(modules,weights))).size,7);
const draft=T.create(modules,weights),reg=modules.find(m=>m.id==='Regulator');
assert.deepEqual(T.confirm(draft,modules,weights),weights);
assert(T.assign(draft,reg,3));assert.equal(draft.weights.Regulator,draft.tiers[3]);assert.equal(weights.Regulator,6);
draft.weights.Regulator=3.25;draft.custom.Regulator=true;
const next=T.confirm(draft,modules,weights);assert.equal(next.Regulator,3.25);assert.equal(next.Firing,weights.Firing);
assert.throws(()=>T.confirm(draft,modules,{...weights,Regulator:10}),/Saved weights changed/);
assert(T.assign(draft,reg,-1));assert.deepEqual(T.confirm(draft,modules,weights),weights);
draft.tiers[0]=reg.weight*20+1;assert(!T.assign(draft,reg,0));
const zero=Object.fromEntries(modules.map(m=>[m.id,0]));assert(Object.values(T.bands(modules,zero)).every(x=>x===-1));
const equal=Object.fromEntries(modules.map(m=>[m.id,2]));assert(Object.values(T.bands(modules,equal)).every(x=>x===0));
assert.deepEqual(T.colors,['#82aeff','#73ccff','#59e666','#fffa4d','#ff9433','#ff2e2e','#420d82']);
const counts=Array(7).fill(0);for(const b of Object.values(T.bands(modules,weights)))counts[b]++;
const loadedWeights=Object.fromEntries(modules.map(m=>[m.id,m.weight]));
const loadedCounts=Array(7).fill(0);for(const b of Object.values(T.bands(modules,loadedWeights)))loadedCounts[b]++;
console.log(JSON.stringify({passed:true,defaults:Object.fromEntries(T.names.map((n,i)=>[n,counts[i]])),savedAllOne:Object.fromEntries(T.names.map((n,i)=>[n,loadedCounts[i]]))},null,2));

assert.equal(draft.groups.Firing,0);
assert.equal(draft.groups.Synergy,6);
const remembered=T.create(modules,weights);remembered.tiers[3]=4.25;
assert(T.assign(remembered,reg,3));
const confirmed=T.confirm(remembered,modules,weights),reopened=T.create(modules,confirmed,remembered.tiers);
assert.equal(reopened.groups.Regulator,3);assert.equal(reopened.weights.Regulator,4.25);
assert.deepEqual(T.confirm(reopened,modules,confirmed),confirmed);
const rounding=T.create(modules,{...confirmed,Regulator:4.25+1e-13},remembered.tiers);assert.equal(rounding.groups.Regulator,3);
const duplicates=T.create(modules,equal);assert(Object.values(duplicates.groups).every(i=>i===0));
for(const tier of [0,3,6]){T.assign(reopened,reg,tier);assert.equal(T.bands(modules,reopened.weights).Regulator,tier);}
console.log('PASS reopening, matching weights, custom tier values, precision tolerance, duplicate tiers and computed rarity changes');

assert.equal(T.confirm(T.create(modules,weights),modules,{...weights,Firing:14}).Firing,14);
