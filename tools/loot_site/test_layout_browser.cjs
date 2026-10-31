'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path'),{pathToFileURL}=require('node:url');
const {chromium}=require('C:/Users/bandi/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright');
const root=path.resolve(__dirname,'../..'),out=path.join(root,'diagnostics/loot-layout');
(async()=>{
  fs.mkdirSync(out,{recursive:true});const browser=await chromium.launch({channel:'msedge',headless:true});
  try{
    const page=await browser.newPage({viewport:{width:1360,height:900}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto(pathToFileURL(path.join(root,'art/loot-tuner/index.html')).href);
    await page.waitForFunction(()=>document.querySelector('#loading').hidden,{timeout:60000});
    const initial=await page.locator('#sampleSummary').innerText();
    for(const size of [{width:1360,height:900},{width:1024,height:600}]){
      await page.setViewportSize(size);
      for(const id of ['Piercing','Regulator']){
        await page.locator('#component-'+id).scrollIntoViewIfNeeded();
        await page.waitForFunction(()=>document.querySelector('#mapArea').getBoundingClientRect().top<=document.querySelector('#syncBanner').getBoundingClientRect().bottom+1);
        const area=await page.locator('#mapArea').boundingBox(),map=await page.locator('.map-wrap').boundingBox(),banner=await page.locator('#syncBanner').boundingBox();
        const boundary=await page.locator('.tuning-layout').evaluate(e=>e.getBoundingClientRect().bottom);
        if(boundary>=size.height)assert(area.y>=banner.y+banner.height-1);
        else assert(area.y+area.height<=boundary+1,'Map releases at the end of tuning');
        assert(map.height>=160);assert(map.y+map.height<=size.height+1);assert(map.y+map.height>banner.y+banner.height+160);
      }
      await page.screenshot({path:path.join(out,`scroll-${size.width}.png`)});
    }
    assert.equal(await page.locator('#sampleSummary').innerText(),initial,'Scrolling must not reroll loot');
    const ordering=await page.evaluate(()=>{const tuning=document.querySelector('#tuning').getBoundingClientRect(),stats=document.querySelector('#statistics').getBoundingClientRect();return {below:stats.top>=tuning.bottom-1,metricCount:document.querySelector('#statistics').querySelectorAll('.metrics').length};});
    assert(ordering.below);assert.equal(ordering.metricCount,2);
    await page.locator('.stats-jump').click();
    const mapBottom=await page.locator('#mapArea').evaluate(e=>e.getBoundingClientRect().bottom),statsTop=await page.locator('#statistics').evaluate(e=>e.getBoundingClientRect().top);
    assert(mapBottom<=statsTop+1,'Sticky map must release before statistics');
    await page.screenshot({path:path.join(out,'statistics.png')});
    await page.setViewportSize({width:390,height:844});await page.locator('#component-Regulator').scrollIntoViewIfNeeded();
    assert.equal(await page.locator('#mapArea').evaluate(e=>getComputedStyle(e).position),'static');
    assert(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));
    const mobile=await page.evaluate(()=>{const a=document.querySelector('#tuning').getBoundingClientRect(),s=document.querySelector('#statistics').getBoundingClientRect();return s.top>=a.bottom-1;});assert(mobile);
    await page.screenshot({path:path.join(out,'mobile.png')});assert.deepEqual(errors,[]);
    console.log('PASS: sticky map at middle/end of modules on desktop and short tablet viewport; map releases before full-width bottom statistics; no scroll reroll; mobile order/overflow; no page errors.');
  }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
