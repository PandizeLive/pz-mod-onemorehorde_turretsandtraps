const assert=require('node:assert/strict');
const fs=require('node:fs');
const vm=require('node:vm');
const path=require('node:path');
const root=path.resolve(__dirname,'../..'),site=path.join(root,'art/loot-tuner');
const source=fs.readFileSync(path.join(site,'app.js'),'utf8');
const data={};vm.runInNewContext(fs.readFileSync(path.join(site,'data.js'),'utf8'),{window:data});
const start=source.indexOf('const moduleAppearance='),end=source.indexOf('let markers=');
function palette(modules){
  const context={D:{modules},ctx:{}};vm.createContext(context);
  vm.runInContext(source.slice(start,end),context);
  return vm.runInContext('D.modules.map((m,i)=>({id:m.id,color:colors[i],shape:appearances[i][1]}))',context);
}
const modules=data.LOOT_DATA.modules,normal=palette(modules),reverse=palette([...modules].reverse());
assert.equal(normal.length,29);
assert.equal(new Set(normal.map(m=>m.color)).size,29);
for(const m of normal){
  assert.match(m.color,/^#[0-9a-f]{6}$/i);
  assert(['circle','triangle','square','diamond','hexagon'].includes(m.shape));
  assert.equal(JSON.stringify(m),JSON.stringify(reverse.find(r=>r.id===m.id)));
}
assert.equal(normal.find(m=>m.id==='Conservation').shape,'square');
assert.equal(normal.find(m=>m.id==='CapacityLarge').shape,'hexagon');
assert.equal(palette([{id:'FutureModule'}])[0].color,palette([{id:'Other'}, {id:'FutureModule'}])[1].color);
console.log('Passed: all 29 colors, family shapes, reorder stability and future-ID fallback.');
