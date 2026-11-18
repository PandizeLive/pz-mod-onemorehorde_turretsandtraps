// Account identity comes exclusively from the existing Access/allowlist gate.
export const MODULES = ['Firing','MotionDetection','Filter','Detection360','Suppression','RapidFire','Reload','Velocity','Range','CapacitySmall','Capacity','CapacityLarge','Autoloader','Critical','Accuracy','Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced'];
const BASELINE = 'T&T 0.2.41';
const NEW_MODULES = ['Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced'];
type Scenario = Record<string, unknown>;
function object(value: unknown): value is Record<string, unknown> { return !!value && typeof value === 'object' && !Array.isArray(value); }
export function validateScenario(value: unknown): Scenario {
  if (!object(value) || value.version !== 1 || value.baseline !== BASELINE) throw Error('Unsupported scenario baseline.');
  const allowed = ['version','baseline','seed','global','material','rolls','retention','selected','overlay','items','visible'];
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
      if (key === 'visible' ? typeof n !== 'boolean' : typeof n !== 'number' || !Number.isFinite(n) || n < 0 || n > 20) throw Error('Invalid component value.');
      clean[id] = n;
    }
    result[key] = clean;
  }
  return result;
}
export function upgradeScenario(value: unknown): Scenario {
  if (!object(value) || !object(value.items) || !object(value.visible)) return validateScenario(value);
  const normalized = /^T&T 0\.2\.(2[6-9]|3[0-9]|40)$/.test(value.baseline as string);
  const old = ['Installed 0.2.22','T&T 0.2.23','T&T 0.2.24','T&T 0.2.25'].includes(value.baseline as string);
  if (!normalized && !old) return validateScenario(value);
  const items: Record<string, unknown> = old ? {Critical:1,Accuracy:1,...value.items} : {...value.items};
  const visible: Record<string, unknown> = old ? {Critical:true,Accuracy:true,...value.visible} : {...value.visible};
  if (old) for (const id of MODULES.filter(id=>!NEW_MODULES.includes(id))) {
    const factor=['Firing','MotionDetection','CapacitySmall','CapacityLarge','Autoloader'].includes(id)?3:2;
    if(typeof items[id]==='number')items[id]=(items[id] as number)/(value.baseline==='Installed 0.2.22'&&id==='Suppression'?1:factor);
  }
  for (const id of NEW_MODULES) { if (!(id in items)) items[id]=1; if (!(id in visible)) visible[id]=true; }
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
      body=parsed;scenario=validateScenario(body.scenario);
    } catch { return json({error:'Invalid settings or baseline.'},400); }
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
