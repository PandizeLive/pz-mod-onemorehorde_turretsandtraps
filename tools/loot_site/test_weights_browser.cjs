'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),{pathToFileURL}=require('node:url');
const {chromium}=require('C:/Users/bandi/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.resolve(__dirname,'../..'),site=path.join(root,'art/loot-tuner'),out=path.join(root,'diagnostics/v0.2.48/loot-browser');
global.window={};require(path.join(site,'data.js'));const D=window.LOOT_DATA,M=require(path.join(site,'model.js'));
(async()=>{
  fs.mkdirSync(out,{recursive:true});
  const saved=M.defaults(D);saved.items.Regulator=1.5;saved.global=2.7;saved.visible.Range=false;
  const browser=await chromium.launch({channel:'msedge',headless:true});
  try{
    const page=await browser.newPage({viewport:{width:1360,height:900}}),errors=[];
    page.on('pageerror',error=>errors.push(error.message));
    await page.addInitScript(value=>localStorage.setItem('omh-lootlab-local',JSON.stringify(value)),saved);
    await page.goto(pathToFileURL(path.join(site,'index.html')).href);
    await page.waitForFunction(()=>document.querySelector('#loading').hidden,{timeout:60000});
    const input=page.locator('#item-Regulator');
    assert.match(await input.getAttribute('aria-label'),/Regulator.* loot weight$/);
    assert.equal(await input.inputValue(),'8.25');
    assert.deepEqual(await page.evaluate(()=>JSON.parse(localStorage.getItem('omh-lootlab-local'))),saved);
    await input.fill('11');await input.blur();
    await page.waitForFunction(()=>JSON.parse(localStorage.getItem('omh-lootlab-local')).items.Regulator===2);
    const [download]=await Promise.all([page.waitForEvent('download'),page.locator('#lua').click()]);
    const exported=fs.readFileSync(await download.path(),'utf8');assert.match(exported,/LootRateRegulator = 2,/);assert.match(exported,/ModuleLootRate = 2.7,/);
    await input.fill('0');await input.blur();
    await page.waitForFunction(()=>document.querySelector('#estimate-Regulator').textContent.startsWith('0 generated · 0 expected'));
    await input.fill('111');await input.blur();assert.equal(await input.inputValue(),'0');
    const imported={...saved,items:{...saved.items,Regulator:.5}};
    await page.locator('#file').setInputFiles({name:'existing-scenario.json',mimeType:'application/json',buffer:Buffer.from(JSON.stringify(imported))});
    await page.waitForFunction(()=>document.querySelector('#item-Regulator').value==='2.75');
    await page.locator('#reset').click();await page.waitForFunction(()=>document.querySelector('#item-Regulator').value==='20');
    await input.scrollIntoViewIfNeeded();await page.screenshot({path:path.join(out,'desktop.png')});
    await page.locator('#hideAll').click();assert.equal(await page.locator('.component.is-hidden').count(),32);
    await page.locator('#showAll').click();assert.equal(await page.locator('.component.is-hidden').count(),0);
    await page.setViewportSize({width:390,height:844});await input.scrollIntoViewIfNeeded();
    const bounds=await input.boundingBox();assert(bounds.x>=0&&bounds.x+bounds.width<=391);
    await page.screenshot({path:path.join(out,'mobile.png')});assert.deepEqual(errors,[]);
    console.log('PASS: saved tuning unchanged on load; direct/fractional/zero/invalid weights; correct Sandbox export; legacy scenario import; reset; sticky visibility; desktop/mobile bounds; zero page errors.');
  }finally{await browser.close();}
})().catch(error=>{console.error(error);process.exitCode=1;});
