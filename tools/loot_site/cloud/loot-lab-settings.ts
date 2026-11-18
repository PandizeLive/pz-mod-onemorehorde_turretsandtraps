// Account identity comes exclusively from the existing Access/allowlist gate.
export const MODULES = ["Firing","MotionDetection","Filter","Detection360","Suppression","RapidFire","Reload","Velocity","Range","CapacitySmall","Capacity","CapacityLarge","Autoloader","Critical","Accuracy","Magazine","Splitter","Fragment","FiringEnhanced","MotionDetectionEnhanced","Piercing","InitialBlow","Execute","Impact","Conservation","Synergy","Martyrdom","Tack","Regulator","Siphon","Lure","Void","Grid","ManualBallista","ManualRotaryBlades","ManualLobber","ManualArc","ManualFirearms"];
const TIERS = ['Abundant','Common','Uncommon','Rare','Epic','Legendary','Mythic'];
const BASELINE = 'T&T 0.2.65';
const NEW_MODULES = ['Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced','Piercing','InitialBlow','Execute','Impact','Conservation','Synergy','Martyrdom','Tack','Regulator','Lure','Void','Siphon','Grid'];
type Scenario = Record<string, unknown>;
function object(value: unknown): value is Record<string, unknown> { return !!value && typeof value === 'object' && !Array.isArray(value); }
export function validateScenario(value: unknown): Scenario {
  if (!object(value) || value.version !== 1 || value.baseline !== BASELINE) throw Error('Unsupported scenario baseline.');
  const allowed = ['version','baseline','seed','global','material','rolls','retention','selected','overlay','items','visible','tierWeights'];
  if (Object.keys(value).some(key => !allowed.includes(key))) throw Error('Unknown setting.');
  const result: Scenario = { version: 1, baseline: BASELINE };
  for (const [key,max] of [['seed',4294967295],['global',20],['material',10],['rolls',10],['retention',1]] as const) {
    const n = value[key];
    if (typeof n !== 'number' || !Number.isFinite(n) || n < 0 || n > max || (key === 'seed' && !Number.isInteger(n))) throw Error('Invalid ' + key + '.');
    result[key] = n;
  }
  if (value.selected !== 'all' && !MODULES.includes(value.selected as string)) throw Error('Invalid selection.');
  if (!['spawns','chances'].includes(value.overlay as string)) throw Error('Invalid overlay.');
  result.selected = value.selected; result.overlay = value.overlay;
  for (const key of ['items','visible']) {
    const values = value[key];
    if (!object(values) || Object.keys(values).length !== MODULES.length || Object.keys(values).some(id => !MODULES.includes(id))) throw Error('Invalid components.');
    const clean: Record<string, unknown> = {};
    for (const id of MODULES) {
      const n = values[id];
      if (key === 'visible' ? typeof n !== 'boolean' : typeof n !== 'number' || !Number.isFinite(n) || n < 0 || n > 1000000) throw Error('Invalid component value.');
      clean[id] = n;
    }
    result[key] = clean;
  }
  const tiers=value.tierWeights;
  if(tiers!==undefined&&(!object(tiers)||Object.keys(tiers).length!==TIERS.length||Object.keys(tiers).some(k=>!TIERS.includes(k))))throw Error('Invalid tier weights.');
  const cleanTiers: Record<string, number|null> = {};
  for(const name of TIERS){
    const n=tiers===undefined?null:(tiers as Record<string, unknown>)[name];
    if(n!==null&&(typeof n!=='number'||!Number.isFinite(n)||n<0||n>1000000))throw Error('Invalid tier weight.');
    cleanTiers[name]=n as number|null;
  }
  result.tierWeights=cleanTiers;
  return result;
}
export function upgradeScenario(value: unknown): Scenario {
  if (!object(value) || !object(value.items) || !object(value.visible)) return validateScenario(value);
  const normalized = /^T&T 0\.2\.(2[6-9]|[3-5][0-9]|6[0-5])(?:\.\d+)?$/.test(value.baseline as string);
  const old = ['Installed 0.2.22','T&T 0.2.23','T&T 0.2.24','T&T 0.2.25'].includes(value.baseline as string);
  if (!normalized && !old) return validateScenario(value);
  const items: Record<string, unknown> = old ? {Critical:1,Accuracy:1,...value.items} : {...value.items};
  const visible: Record<string, unknown> = old ? {Critical:true,Accuracy:true,...value.visible} : {...value.visible};
  if (old) for (const id of MODULES.filter(id=>!NEW_MODULES.includes(id))) {
    const factor=['Firing','MotionDetection','CapacitySmall','CapacityLarge','Autoloader'].includes(id)?3:2;
    if(typeof items[id]==='number')items[id]=(items[id] as number)/(value.baseline==='Installed 0.2.22'&&id==='Suppression'?1:factor);
  }
  for (const id of NEW_MODULES) { if (!(id in items)) items[id]=1; if (!(id in visible)) visible[id]=true; }
  const manualDefaults: Record<string,number>={ManualBallista:14,ManualRotaryBlades:14,ManualLobber:10,ManualArc:6,ManualFirearms:10};
  const manualTiers: Record<string,string>={ManualBallista:'Uncommon',ManualRotaryBlades:'Uncommon',ManualLobber:'Rare',ManualArc:'Epic',ManualFirearms:'Rare'};
  for(const [id,weight] of Object.entries(manualDefaults)){
    const anchor=object(value.tierWeights)?value.tierWeights[manualTiers[id]]:null;
    if(!(id in items))items[id]=typeof anchor==='number'&&anchor>0?anchor:weight;
    if(!(id in visible))visible[id]=true;
  }
  if(typeof value.global!=='number')throw Error('Invalid global multiplier.');
  return validateScenario({...value,baseline:BASELINE,global:old?value.global/4.5:value.global,items,visible});
}
function json(value: unknown, status = 200) { return Response.json(value, {status, headers: {'Cache-Control':'private, no-store','X-Content-Type-Options':'nosniff'}}); }
export async function lootLabSettings(request: Request, db: D1Database, owner: string): Promise<Response> {
  if (!['GET','PUT'].includes(request.method)) return new Response('Method not allowed', {status:405,headers:{Allow:'GET, PUT'}});
  if (request.method === 'PUT' && request.headers.get('Origin') !== new URL(request.url).origin) return json({error:'Same-origin request required.'},403);
  // Start on primary even if read replication is enabled later.
  const session = db.withSession('first-primary');
  const hash = await crypto.subtle.digest('SHA-256',new TextEncoder().encode(owner));
  const account = Array.from(new Uint8Array(hash),v=>v.toString(16).padStart(2,'0')).join('');
  const current = async () => {
    const row = await session.prepare('SELECT revision, scenario_json, updated_at FROM loot_lab_settings WHERE owner = ?').bind(owner).first<{revision:number;scenario_json:string;updated_at:string}>();
    return {account,revision:row?.revision ?? 0,scenario:row ? upgradeScenario(JSON.parse(row.scenario_json)) : null,updatedAt:row?.updated_at ?? null};
  };
  try {
    if (request.method === 'GET') return json(await current());
    if (request.headers.get('Content-Type')?.split(';')[0].trim() !== 'application/json') return json({error:'JSON required.'},415);
    const reader = request.body?.getReader();
    if (!reader) return json({error:'Missing settings.'},400);
    const chunks: Uint8Array[] = []; let length = 0;
    while (true) { const {done,value} = await reader.read(); if(done)break;length+=value.length;if(length>16384){await reader.cancel();return json({error:'Settings too large.'},413);}chunks.push(value); }
    const bytes = new Uint8Array(length); let offset=0;for(const chunk of chunks){bytes.set(chunk,offset);offset+=chunk.length;}
    let body: Record<string, unknown>, scenario: Scenario;
    try {
      const parsed: unknown = JSON.parse(new TextDecoder().decode(bytes));
      if (!object(parsed) || !Number.isSafeInteger(parsed.revision) || (parsed.revision as number)<0 || Object.keys(parsed).some(k=>!['revision','scenario'].includes(k))) throw Error('Invalid revision.');
      body=parsed;scenario=validateScenario(object(body.scenario)&&body.scenario.baseline==='T&T 0.2.47'?{...body.scenario,baseline:BASELINE}:body.scenario);
    } catch { return json({error:'Invalid settings or baseline.'},400); }
    if(!Object.hasOwn(body.scenario as object,'tierWeights')){
      const prior=await current();
      if(prior.scenario)scenario.tierWeights=prior.scenario.tierWeights;
    }
    const revision = body.revision as number;
    const statement = revision === 0
      ? session.prepare('INSERT INTO loot_lab_settings (owner, revision, scenario_json) VALUES (?, 1, ?) ON CONFLICT(owner) DO NOTHING').bind(owner,JSON.stringify(scenario))
      : session.prepare('UPDATE loot_lab_settings SET scenario_json = ?, revision = revision + 1, updated_at = CURRENT_TIMESTAMP WHERE owner = ? AND revision = ?').bind(JSON.stringify(scenario),owner,revision);
    const saved = await statement.run();
    if (!saved.meta.changes) return json(await current(),409);
    // Return the acknowledged snapshot; another device may write immediately afterwards.
    return json({account,revision:revision+1,scenario});
  } catch { return json({error:'Settings unavailable. Please retry.'},503); }
}
