const assert=require('node:assert/strict'),path=require('node:path'),fs=require('node:fs');
const site=path.resolve(__dirname,'../../art/loot-tuner');global.window={};require(path.join(site,'data.js'));
const D=window.LOOT_DATA,M=require(path.join(site,'model.js')),T=require(path.join(site,'tier-list.js'));
const modules=D.modules,weights=Object.fromEntries(modules.map(m=>[m.id,M.lootWeight(m,D.defaults.items[m.id])]));
const defaultAnchors=T.names.map(n=>D.defaults.tierWeights[n]);
assert.equal(new Set(Object.values(T.bands(modules,weights,defaultAnchors))).size,7);
const draft=T.create(modules,weights,defaultAnchors),reg=modules.find(m=>m.id==='Regulator');
assert.deepEqual(T.confirm(draft,modules,weights),weights);
assert(T.assign(draft,reg,3));assert.equal(draft.weights.Regulator,draft.tiers[3]);assert.equal(weights.Regulator,20);
draft.weights.Regulator=3.25;draft.custom.Regulator=true;
const next=T.confirm(draft,modules,weights);assert.equal(next.Regulator,3.25);assert.equal(next.Firing,weights.Firing);
assert.throws(()=>T.confirm(draft,modules,{...weights,Regulator:10}),/Saved weights changed/);
assert(T.assign(draft,reg,-1));assert.deepEqual(T.confirm(draft,modules,weights),weights);
draft.tiers[0]=reg.weight*20+1;assert(!T.assign(draft,reg,0));
const zero=Object.fromEntries(modules.map(m=>[m.id,0]));assert(Object.values(T.bands(modules,zero)).every(x=>x===-1));
const equal=Object.fromEntries(modules.map(m=>[m.id,2]));assert(Object.values(T.bands(modules,equal)).every(x=>x===0));
assert.deepEqual(T.colors,['#82aeff','#73ccff','#59e666','#fffa4d','#ff9433','#ff2e2e','#420d82']);
const counts=Array(7).fill(0);for(const b of Object.values(T.bands(modules,weights,defaultAnchors)))counts[b]++;
const loadedWeights=Object.fromEntries(modules.map(m=>[m.id,m.weight]));
const loadedCounts=Array(7).fill(0);for(const b of Object.values(T.bands(modules,loadedWeights)))loadedCounts[b]++;
console.log(JSON.stringify({passed:true,defaults:Object.fromEntries(T.names.map((n,i)=>[n,counts[i]])),savedAllOne:Object.fromEntries(T.names.map((n,i)=>[n,loadedCounts[i]]))},null,2));

assert.equal(draft.groups.Firing,2);
assert.equal(draft.groups.Synergy,6);
const remembered=T.create(modules,weights,defaultAnchors);remembered.tiers[3]=7;
assert(T.assign(remembered,reg,3));
const confirmed=T.confirm(remembered,modules,weights),reopened=T.create(modules,confirmed,remembered.tiers);
assert.equal(reopened.groups.Regulator,3);assert.equal(reopened.weights.Regulator,7);
assert.deepEqual(T.confirm(reopened,modules,confirmed),confirmed);
const rounding=T.create(modules,{...confirmed,Regulator:7+1e-13},remembered.tiers);assert.equal(rounding.groups.Regulator,3);
const duplicates=T.create(modules,equal);assert(Object.values(duplicates.groups).every(i=>i===0));
for(const tier of [0,3,6]){T.assign(reopened,reg,tier);assert.equal(T.bands(modules,reopened.weights,reopened.tiers).Regulator,tier);}
console.log('PASS reopening, matching weights, custom tier values, precision tolerance, duplicate tiers and computed rarity changes');

assert.equal(T.confirm(T.create(modules,weights),modules,{...weights,Firing:14}).Firing,14);

const unset=T.names.map(()=>null),initial=T.create(modules,weights,unset);
initial.tiers[3]=7;
const tierSave=T.confirmTiers(initial,unset);assert.equal(tierSave[3],7);
assert.throws(()=>T.confirmTiers(initial,unset.map((v,i)=>i===3?5:v)),/Saved tier weights changed/);
assert.equal(T.confirmTiers(initial,unset.map((v,i)=>i===4?2:v))[4],2);
const roundTrip=M.validate(JSON.parse(JSON.stringify({...M.defaults(D),tierWeights:Object.fromEntries(T.names.map((name,i)=>[name,tierSave[i]]))})),D);
assert.equal(roundTrip.tierWeights.Rare,7);
console.log('PASS tier snapshot conflict and scenario persistence');

const anchors=[20,16,12,8,5,2,1];
assert.equal(T.anchorError(anchors),null);
for(let i=0;i<7;i++){
 const actual=T.bands(modules,{...weights,Regulator:anchors[i]},anchors).Regulator;
 assert.equal(actual,i,`exact anchor ${T.names[i]}`);
}
for(let i=0;i<6;i++){
 const boundary=Math.sqrt(anchors[i]*anchors[i+1]);
 assert.equal(T.bands(modules,{...weights,Regulator:boundary},anchors).Regulator,i+1);
 assert.equal(T.bands(modules,{...weights,Regulator:boundary*1.00001},anchors).Regulator,i);
}
assert.equal(T.bands(modules,{...weights,Regulator:0},anchors).Regulator,-1);
assert.deepEqual(T.bands(modules,weights,unset),T.bands(modules,weights));
for(const invalid of [[20,16,12,8,5,2,2],[20,16,12,8,5,2,0],[20,16,12,8,5,2,null]]){
 assert(T.anchorError(invalid));assert.throws(()=>T.sandbox(invalid));
 assert.equal(T.bands(modules,weights,invalid).Regulator,-2);
}
assert(T.sandbox(anchors).includes('    RarityWeightRare = 8,'));
assert(T.sandbox(unset).every(line=>line.endsWith(' = 0,')));
assert.equal(T.bands(modules,{...weights,Regulator:8,Firing:200},anchors).Regulator,3);
console.log('PASS custom anchors, proportional boundaries, tie toward rarer, no extreme drift, invalid/export guards and automatic compatibility');
