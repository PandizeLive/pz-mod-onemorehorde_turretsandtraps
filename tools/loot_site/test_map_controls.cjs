const assert=require('node:assert/strict');
const {createGestures,rarityPosition}=require('../../art/loot-tuner/map-controls.js');
let view={x:1000,y:2000,scale:1},taps=[];
const input=createGestures({getView:()=>view,setView:v=>view=v,getSize:()=>({width:400,height:600}),onTap:p=>taps.push(p)});
const p=(id,x,y)=>({id,x,y,type:'touch'}),near=(a,b)=>assert(Math.abs(a-b)<1e-8,`${a} != ${b}`);
// Single-finger drag.
input.down(p(1,100,200));input.move(p(1,120,230));near(view.x,980);near(view.y,1970);input.up(p(1,120,230));assert.equal(taps.length,0);
// Centered pinch doubles scale and keeps the midpoint's world position fixed.
view={x:1000,y:2000,scale:1};input.down(p(1,150,300));input.down(p(2,250,300));input.move(p(1,100,300));input.move(p(2,300,300));near(view.scale,2);near(view.x,1000);near(view.y,2000);
// Lift a finger and continue panning without a jump or accidental tap.
input.up(p(2,300,300));input.move(p(1,100,300));near(view.x,1000);input.move(p(1,120,300));near(view.x,990);input.up(p(1,120,300));assert.equal(taps.length,0);assert.equal(input.active(),false);
// Off-center pinch: translate its midpoint while zooming, anchored to world coordinates.
view={x:1000,y:2000,scale:1};input.down(p(1,50,100));input.down(p(2,150,100));input.move(p(1,50,150));input.move(p(2,250,150));near(view.scale,2);near(view.x+(150-200)/view.scale,900);near(view.y+(150-300)/view.scale,1800);
input.up(p(1,50,150),true);input.up(p(2,250,150),true);assert.equal(taps.length,0);
// Tap permits marker details; cancellation and capture loss do not leave stuck pointers.
input.down(p(3,80,80));input.up(p(3,80,80));assert.equal(taps.length,1);
input.down(p(3,80,80));input.up(p(3,80,80),true);assert.equal(taps.length,1);assert.equal(input.active(),false);
input.down(p(4,80,80));input.reset();assert.equal(input.move(p(4,300,300)),false);
// Zoom limits and zero-distance input remain finite.
view={x:0,y:0,scale:1};input.down(p(1,0,0));input.down(p(2,1,0));input.move(p(2,10000,0));near(view.scale,18);input.move(p(2,0,0));near(view.scale,.015);assert(Number.isFinite(view.x));input.reset();
// Rarity is absolute, monotone, and based on expected abundance, with zero disabled.
assert.equal(rarityPosition(0),0);assert.equal(rarityPosition(1000),1);assert.equal(rarityPosition(100000),1);assert.equal(rarityPosition(-1),0);
assert(rarityPosition(.1)<rarityPosition(1));assert(rarityPosition(1)<rarityPosition(10));assert(rarityPosition(10)<rarityPosition(100));
console.log('Passed: pan, pinch anchoring, pinch-to-pan continuity, tap/cancel/reset, zoom limits and rarity scale.');
