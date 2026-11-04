// Explicit whitelist: never publish diagnostics, credentials, absolute local paths or game code.
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { resolve, basename } from 'node:path';
import { createHash } from 'node:crypto';
const root=fileURLToPath(new URL('../../',import.meta.url));
const source=resolve(root,'../Turrets & Traps/art/loot-tuner');
const target=resolve(root,'cloudflare-api/assets/admin/LootLab');
await mkdir(target,{recursive:true});
const sourceData=JSON.parse((await readFile(resolve(source,'data.js'),'utf8')).replace(/^window.LOOT_DATA=/,'').trim().replace(/;$/,''));
const baseline=sourceData.meta.baseline;
const manifest={baseline,files:[]};
for(const name of ['index.html','style.css','app.js','model.js','map-controls.js','settings-sync.js','data.js','README.md','provenance.json']) {
  let content=await readFile(resolve(source,name),'utf8');
  if(name==='index.html')content=content.replace('<div class="badges">','<div class="badges"><a class="admin-back" href="/admin/">← Owner Desk</a>');
  if(name==='README.md')content='# OMH LootLab\n\nOwner-only new-world loot simulation, based on '+baseline+' and PZ 42.21.0.\n\nPinch to zoom, drag with one finger, or use the on-map zoom buttons. Legend columns stay aligned; separate rarity markers show final expected abundance on a fixed 0–1,000+ logarithmic scale.\n\nSettings autosave to the signed-in admin account and sync across devices. Set to Default restores the '+baseline+' baseline. Wait for Saved across devices before closing. Offline edits remain a local draft until reconnection. Map navigation is not saved.\n\nRefresh spawns chooses a new seed. Each component has a fixed color and a show/hide switch. Visibility does not change rates or reroll the world. Choose Generated spawns for a sample outcome, or Container chances for probability markers. Scenario JSON preserves the seed, rates and visibility. Exported Sandbox settings must be reviewed and applied manually.\n\nThe in-page methodology describes assumptions and exclusions, including unmodelled capacity and world events. Generated dots are simulated outcomes, not predictions of a particular Zomboid save.\n';
  if(name==='provenance.json'){
    const data=JSON.parse(content);
    data.scope='Owner-only new-world SP loot simulation; no gameplay changes';
    data.sources=data.sources.map(({path,...rest})=>({file:basename(path.replaceAll('\\','/')),...rest}));
    content=JSON.stringify(data,null,2);
  }
  await writeFile(resolve(target,name),content);
  manifest.files.push({name,bytes:Buffer.byteLength(content),sha256:createHash('sha256').update(content).digest('hex')});
}
await writeFile(resolve(root,'cloudflare-api/loot-lab-manifest.json'),JSON.stringify(manifest,null,2)+'\n');
console.log('Prepared '+manifest.files.length+' private LootLab assets.');
