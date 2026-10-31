import test from 'node:test';
import assert from 'node:assert/strict';
import { DatabaseSync } from 'node:sqlite';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';
import worker from '../src/index.ts';
import { MODULES, validateScenario, upgradeScenario } from '../src/loot-lab-settings.ts';
const require=createRequire(import.meta.url);
const site=new URL('../../../Turrets & Traps/art/loot-tuner/',import.meta.url);
const {create}=require(fileURLToPath(new URL('settings-sync.js',site)));
const context={window:{}};vm.runInNewContext(readFileSync(new URL('data.js',site),'utf8'),context);
const model=require(fileURLToPath(new URL('model.js',site)));
const defaults=JSON.parse(JSON.stringify(model.defaults(context.window.LOOT_DATA)));
const endpoint='https://admin.onemorehorde.com/admin/LootLab/settings';
function fixture(){
 const sql=new DatabaseSync(':memory:');sql.exec(readFileSync(new URL('../migrations/0005_loot_lab_settings.sql',import.meta.url),'utf8'));
 const session = {
  prepare(query: string) {
   return {
    bind(...values: any[]) {
     const statement = sql.prepare(query);
     return {
      async first() { return statement.get(...values) || null; },
      async run() { return {meta: {changes: Number(statement.run(...values).changes)}}; },
     };
    },
   };
  },
 };
 const env={ALLOWED_ORIGINS:'https://onemorehorde.com',ADMIN_ENABLED:'true',ADMIN_HOSTS:'admin.onemorehorde.com',ADMIN_EMAIL_ALLOWLIST:'owner@example.test,other@example.test',DB:{withSession(constraint:string){assert.equal(constraint,'first-primary');return session;}}} as unknown as Parameters<typeof worker.fetch>[1];
 const request=(method='GET',body?:unknown,owner='owner@example.test',headers:Record<string,string>={})=>worker.fetch(new Request(endpoint,{method,headers:{'Cf-Access-Authenticated-User-Email':owner,Origin:new URL(endpoint).origin,'Content-Type':'application/json',...headers},body:body===undefined?undefined:JSON.stringify(body)}),env);
 const transport=async(method:string,body?:unknown)=>{const response=await request(method,body);assert.ok([200,409].includes(response.status),await response.clone().text());return {...await response.json() as object,conflict:response.status===409};};
 return {sql,request,transport,env};
}
test('schema matches the actual T&T baseline and rejects malformed settings',()=>{
 assert.deepEqual(MODULES,Object.keys(defaults.items));assert.deepEqual(validateScenario(defaults),defaults);
 for(const change of [{global:-1},{seed:1.5},{material:11},{baseline:'wrong'},{items:{}},{visible:{}},{overlay:'bad'},{owner:'someone'}])assert.throws(()=>validateScenario({...defaults,...change}));
});
test('account saves survive new requests; stale writes conflict and owners are isolated',async()=>{
 const f=fixture();assert.equal((await (await f.request()).json() as any).revision,0);
 const save=await f.request('PUT',{revision:0,scenario:{...defaults,global:2}});assert.equal(save.status,200);
 const saved=await save.json() as any;assert.equal(saved.revision,1);assert.equal(saved.scenario.global,2);
 assert.equal((await (await f.request()).json() as any).scenario.global,2);
 assert.equal((await (await f.request('GET',undefined,'other@example.test')).json() as any).scenario,null);
 const conflict=await f.request('PUT',{revision:0,scenario:defaults});assert.equal(conflict.status,409);assert.equal((await conflict.json() as any).scenario.global,2);
 assert.equal((await f.request('PUT',{revision:1,scenario:defaults})).status,200);
 assert.equal((await (await f.request()).json() as any).revision,2);
});
test('settings use existing admin auth and reject cross-origin, invalid and oversized writes',async()=>{
 const f=fixture();assert.equal((await f.request('GET',undefined,'stranger@example.test')).status,404);
 assert.equal((await f.request('PUT',{revision:0,scenario:defaults},undefined,{Origin:'https://evil.test'})).status,403);
 assert.equal((await f.request('PUT',{revision:0,scenario:defaults},undefined,{'Content-Type':'text/plain'})).status,415);
 assert.equal((await f.request('PUT',{revision:-1,scenario:defaults})).status,400);
 assert.equal((await f.request('PUT',{revision:0,scenario:{...defaults,global:'1'}})).status,400);
 assert.equal((await f.request('PUT',{padding:'x'.repeat(17000)})).status,413);
 assert.equal(f.sql.prepare('SELECT count(*) AS n FROM loot_lab_settings').get()!.n,0);
 const req=new Request(endpoint.replace('admin.','api.'),{headers:{'Cf-Access-Authenticated-User-Email':'owner@example.test'}});assert.equal((await worker.fetch(req,f.env)).status,404);
});
function client(transport:any,storage=new Map<string,string>()){
 const statuses:string[]=[];let changes=0;
 const sync=create({defaults,previousBaselines:context.window.LOOT_DATA.meta.previousBaselines,migrateValue:model.migrateValue,validate:validateScenario,transport,storage:{getItem:(k:string)=>storage.get(k),setItem:(k:string,v:string)=>storage.set(k,v),removeItem:(k:string)=>storage.delete(k)},onChange:()=>changes++,onStatus:(s:string)=>statuses.push(s),schedule:()=>1,cancel:()=>{}});
 return {sync,statuses,storage,get changes(){return changes;}};
}
test('two devices merge unrelated changes, including nested component fields',async()=>{
 const f=fixture(),a=client(f.transport),b=client(f.transport);await a.sync.sync();await b.sync.sync();
 a.sync.edit({...a.sync.value,global:3,items:{...defaults.items,Firing:2}});
 b.sync.edit({...b.sync.value,rolls:2,items:{...defaults.items,Filter:4},visible:{...defaults.visible,Range:false}});
 await a.sync.sync();await b.sync.sync();await b.sync.sync();await a.sync.sync();
 assert.equal(a.sync.value.global,3);assert.equal(a.sync.value.rolls,2);assert.equal(a.sync.value.items.Firing,2);assert.equal(a.sync.value.items.Filter,4);assert.equal(a.sync.value.visible.Range,false);
 assert.deepEqual(a.sync.value,b.sync.value);assert.equal(b.storage.size,0);
});
test('Set to Default resets every field even against a newer remote scenario',async()=>{
 const f=fixture(),a=client(f.transport),b=client(f.transport);await a.sync.sync();await b.sync.sync();
 a.sync.edit({...defaults,seed:789,overlay:'chances',global:4,items:{...defaults.items,Range:5}});await a.sync.sync();
 b.sync.edit(defaults,true);await b.sync.sync();await b.sync.sync();await a.sync.sync();assert.deepEqual(a.sync.value,defaults);
});
test('edits made during save stay pending and offline drafts recover on reload',async()=>{
 const f=fixture();let release:()=>void=()=>{},hold=false,offline=false;
 const transport=async(method:string,body:unknown)=>{if(offline)throw Error('Offline');if(hold&&method==='PUT'){hold=false;await new Promise<void>(resolve=>{release=resolve;});}return f.transport(method,body);};
 const a=client(transport);await a.sync.sync();a.sync.edit({...defaults,global:2});hold=true;const saving=a.sync.sync();
 a.sync.edit({...a.sync.value,global:3});release();await saving;assert.equal(a.sync.value.global,3);assert.ok(a.storage.size);await a.sync.sync();assert.equal(a.storage.size,0);
 offline=true;a.sync.edit({...a.sync.value,rolls:2});await a.sync.sync();assert.match(a.statuses.at(-1)!,/Not synced/);
 offline=false;const reloaded=client(transport,a.storage);await reloaded.sync.sync();assert.equal(reloaded.sync.value.rolls,2);assert.equal(reloaded.storage.size,0);
 const phone=client(f.transport);await phone.sync.sync();assert.equal(phone.sync.value.global,3);assert.equal(phone.sync.value.rolls,2);
});
test('failed initial read never writes defaults and can retry safely',async()=>{
 let fail=true,writes=0;const f=fixture(),a=client(async(method:string,body:unknown)=>{if(method==='PUT')writes++;if(fail)throw Error('Offline');return f.transport(method,body);});
 await a.sync.sync();assert.equal(a.sync.ready,false);a.sync.edit({...defaults,global:9});assert.equal(writes,0);fail=false;await a.sync.sync();assert.equal(a.sync.ready,true);assert.equal(writes,0);
});

test('0.2.22 account settings migrate without losing tuning or rewriting the stored row',async()=>{
 const f=fixture(),old=structuredClone(defaults);old.baseline='Installed 0.2.22';old.global=3;old.items.Range=7;old.visible.Filter=false;
 for(const id of ['Critical','Accuracy']){delete old.items[id];delete old.visible[id];}
 f.sql.prepare('INSERT INTO loot_lab_settings(owner,revision,scenario_json) VALUES(?,?,?)').run('owner@example.test',5,JSON.stringify(old));
 const remote=await f.transport('GET');assert.equal(remote.revision,5);assert.equal(remote.scenario.baseline,defaults.baseline);
 assert.equal(remote.scenario.global,3/4.5);assert.equal(remote.scenario.items.Range,3.5);assert.equal(remote.scenario.visible.Filter,false);
 assert.equal(remote.scenario.items.Critical,.5);assert.equal(remote.scenario.visible.Accuracy,true);
 assert.equal(JSON.parse(f.sql.prepare('SELECT scenario_json FROM loot_lab_settings').get()!.scenario_json as string).baseline,old.baseline);
 assert.equal((await f.request('PUT',{revision:5,scenario:old})).status,400,'Old tab cannot erase the new component fields');
 const a=client(f.transport);await a.sync.sync();a.sync.edit({...a.sync.value,rolls:2});await a.sync.sync();
 const phone=client(f.transport);await phone.sync.sync();assert.equal(phone.sync.value.global,3/4.5);assert.equal(phone.sync.value.rolls,2);assert.equal(phone.sync.value.items.Accuracy,.5);
});

test('an unsynced 0.2.22 browser draft keeps its edits on the new baseline',async()=>{
 const f=fixture(),remote=await f.transport('GET'),storage=new Map<string,string>();
 storage.set('omh-lootlab-draft:'+remote.account,JSON.stringify({baseline:'Installed 0.2.22',pending:{baseline:{value:'Installed 0.2.22',sequence:1},global:{value:4,sequence:2},'items.Range':{value:6,sequence:3}}}));
 const a=client(f.transport,storage);await a.sync.sync();assert.equal(a.sync.value.baseline,defaults.baseline);assert.equal(a.sync.value.global,4/4.5);assert.equal(a.sync.value.items.Range,3);assert.equal(a.sync.value.items.Critical,defaults.items.Critical);assert.equal(storage.size,0);
});

test('0.2.24 tuning survives the new defaults; explicit reset adopts approved rates',async()=>{
 const f=fixture(),old=structuredClone(defaults);old.baseline='T&T 0.2.24';old.global=4;old.items.Filter=1;
 f.sql.prepare('INSERT INTO loot_lab_settings(owner,revision,scenario_json) VALUES(?,?,?)').run('owner@example.test',84,JSON.stringify(old));
 const a=client(f.transport);await a.sync.sync();assert.equal(a.sync.value.global,4/4.5);assert.equal(a.sync.value.items.Filter,.5);
 a.sync.edit(defaults,true);await a.sync.sync();const b=client(f.transport);await b.sync.sync();
 assert.equal(b.sync.value.global,1);assert.equal(b.sync.value.items.Firing,1);assert.equal(b.sync.value.items.Filter,1);assert.equal(b.sync.value.items.Autoloader,1);
});

 test('normalized 0.2.26 scenario migrates without changing owner tuning',()=>{
 const before={...defaults,baseline:'T&T 0.2.26',global:1.7,items:{...defaults.items,Firing:3},seed:4285447834};
 assert.deepEqual(upgradeScenario(before),{...before,baseline:defaults.baseline});
 assert.throws(()=>validateScenario(before));
 });

test('catalog upgrade preserves stored tuning without writing or incrementing revision',async()=>{
 const old=structuredClone(defaults);old.baseline='T&T 0.2.28';old.global=2.7;old.seed=348;old.items.Firing=0;old.visible.Range=false;
 for(const id of ['Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced']){delete old.items[id];delete old.visible[id];}
 const expected=model.validate(old,context.window.LOOT_DATA);assert.deepEqual(upgradeScenario(old),expected);
 const f=fixture(),encoded=JSON.stringify(old);
 f.sql.prepare('INSERT INTO loot_lab_settings(owner,revision,scenario_json) VALUES(?,?,?)').run('owner@example.test',91,encoded);
 const read=await (await f.request()).json() as any;assert.equal(read.revision,91);assert.deepEqual(read.scenario,expected);
 assert.equal(f.sql.prepare('SELECT scenario_json FROM loot_lab_settings').get()!.scenario_json,encoded);
 assert.throws(()=>validateScenario({...old,baseline:defaults.baseline}));
});
