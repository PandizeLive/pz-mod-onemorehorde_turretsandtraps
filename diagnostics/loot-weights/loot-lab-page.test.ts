import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';
const site=new URL('file:///C:/Users/bandi/Zomboid_Modding/OMH/Turrets%20%26%20Traps/art/loot-tuner/');
const require=createRequire(import.meta.url);
const model=require(fileURLToPath(new URL('model.js',site)));
const {create}=require(fileURLToPath(new URL('settings-sync.js',site)));

for(const local of [false,true]) test(local?'local copy is clearly marked and only writes browser storage':'actual page saves typed weights before blur and another device loads them',async()=>{
 const nodes=new Map<string,Element>();
 class Element extends EventTarget {
  _id='';value='';type='';validity={valid:true};textContent='';disabled=false;hidden=false;checked=false;files=[];style={};
  classList={toggle(){}};
  set id(id:string){this._id=id;nodes.set(id,this);} get id(){return this._id;}
  append(..._children:unknown[]){}replaceChildren(..._children:unknown[]){}setAttribute(_name:string,_value:string){}
  getContext(){return {};}getBoundingClientRect(){return {width:800,height:500,left:0,top:0};}
 }
 const html=readFileSync(new URL('index.html',site),'utf8');for(const [,id] of html.matchAll(/id="([^"]+)"/g)){const node=new Element();node.id=id;node.hidden=new RegExp('id="'+id+'"[^>]*\\bhidden\\b').test(html);}
 const document=Object.assign(new EventTarget(),{hidden:false,activeElement:null as Element|null,getElementById:(id:string)=>nodes.get(id),createElement:()=>new Element(),createDocumentFragment:()=>new Element(),querySelectorAll:()=>Array.from(nodes.values())});
 const data={meta:{baseline:'T&T 0.2.23',game:'42.21.0',headers:0,roomRecords:0,routes:0},map:[],labels:[],containers:[],modules:[{id:'Firing',name:'Firing',weight:2},{id:'MotionDetection',name:'Detection',weight:2}],pools:{}};
 const defaults=model.defaults(data);let stored:any=null,revision=0,sync:any;
 const transport=async(method:string,body:any)=>{if(method==='PUT'){stored=structuredClone(body.scenario);revision++;}return {account:'owner',revision,scenario:stored};};
 const storage=new Map<string,string>();
 const window=Object.assign(new EventTarget(),{LOOT_DATA:data,LootModel:{...model,prepare:async()=>({pools:[],hits:[],samples:1}),evaluate:()=>({poolProbabilities:[[],[]],hauls:[],mean:0,lo:0,hi:0,zero:1,itemMeans:[0,0],regions:[],poolMeans:[]}),generate:()=>({totals:[0,0],seed:24601,spawns:[]})},LootMapControls:{rarityPosition:()=>0,createGestures:()=>({reset(){}})},LootSettings:{transport,create:(options:any)=>(sync=create({...options,schedule:()=>1,cancel:()=>{}}))}});
 const context=vm.createContext({window,document,location:{protocol:local?'file:':'https:',pathname:'/admin/LootLab/'},localStorage:{getItem:(k:string)=>storage.get(k),setItem:(k:string,v:string)=>storage.set(k,v),removeItem:(k:string)=>storage.delete(k)},ResizeObserver:class{observe(){}},Path2D:class{},setTimeout:()=>1,clearTimeout(){},setInterval(){},requestAnimationFrame:()=>1,crypto,console});
 vm.runInContext(readFileSync(new URL('app.js',site),'utf8'),context);
 await new Promise(resolve=>setImmediate(resolve));
 if(local){
  assert.match(nodes.get('syncStatus')!.textContent,/Browser-only copy/);assert.equal(nodes.get('hostedLink')!.hidden,false);assert.equal(nodes.get('syncNow')!.hidden,true);
  const field=nodes.get('item-Firing')!;field.value='3';field.dispatchEvent(new Event('input'));
  assert.equal(JSON.parse(storage.get('omh-lootlab-local')!).items.Firing,1.5);assert.equal(stored,null);return;
 }
 const firing=nodes.get('item-Firing')!;document.activeElement=firing;firing.value='3';firing.dispatchEvent(new Event('input'));
 const detection=nodes.get('item-MotionDetection')!;document.activeElement=detection;detection.value='3';detection.dispatchEvent(new Event('input'));
 const global=nodes.get('global')!;global.value='4';global.dispatchEvent(new Event('input'));
 window.dispatchEvent(new Event('pagehide'));await new Promise(resolve=>setImmediate(resolve));
 assert.equal(stored.items.Firing,1.5);assert.equal(stored.items.MotionDetection,1.5);assert.equal(stored.global,4);
 const laptop=create({defaults,validate:(v:any)=>model.validate(v,data),transport,onChange(){},onStatus(){},schedule:()=>1,cancel:()=>{}});await laptop.sync();
 assert.equal(nodes.get('syncNow')!.hidden,false);assert.equal(nodes.get('hostedLink')!.hidden,true);
 assert.deepEqual(laptop.value.items,{Firing:1.5,MotionDetection:1.5});assert.equal(laptop.value.global,4);
 detection.value='';document.activeElement=detection;detection.dispatchEvent(new Event('input'));await sync.sync();
 assert.equal(detection.value,'','Background sync must not overwrite a field being edited');assert.equal(stored.items.MotionDetection,1.5,'An incomplete number is not a zero setting');
});
