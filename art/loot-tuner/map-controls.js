(function(root){
  'use strict';
  const clampScale=value=>Math.max(.015,Math.min(18,value));
  // Fixed logarithmic scale: off at left, 1,000+ expected items at right.
  // Unlike a relative rank, changing a different component cannot move this marker.
  function rarityPosition(expected){return Math.max(0,Math.min(1,Math.log1p(Math.max(0,expected))/Math.log(1001)));}
  function createGestures({getView,setView,getSize,onTap=()=>{}}){
    const pointers=new Map();let start=null,hadMultiple=false,moved=false;
    function rebase(){
      const points=[...pointers.values()].slice(0,2),view={...getView()};
      if(!points.length){start=null;return;}
      const x=points.reduce((n,p)=>n+p.x,0)/points.length,y=points.reduce((n,p)=>n+p.y,0)/points.length;
      start={view,x,y,distance:points.length===2?Math.max(1,Math.hypot(points[0].x-points[1].x,points[0].y-points[1].y)):0};
    }
    function down(point){
      if(!pointers.size){hadMultiple=false;moved=false;}
      pointers.set(point.id,point);if(pointers.size>1)hadMultiple=true;rebase();
    }
    function move(point){
      if(!pointers.has(point.id)||!start)return false;
      pointers.set(point.id,point);const points=[...pointers.values()].slice(0,2),size=getSize();
      const x=points.reduce((n,p)=>n+p.x,0)/points.length,y=points.reduce((n,p)=>n+p.y,0)/points.length;
      if(Math.hypot(x-start.x,y-start.y)>6||points.length>1)moved=true;
      let scale=start.view.scale;
      if(points.length===2&&start.distance)scale=clampScale(scale*Math.hypot(points[0].x-points[1].x,points[0].y-points[1].y)/start.distance);
      const anchorX=start.view.x+(start.x-size.width/2)/start.view.scale;
      const anchorY=start.view.y+(start.y-size.height/2)/start.view.scale;
      setView({x:anchorX-(x-size.width/2)/scale,y:anchorY-(y-size.height/2)/scale,scale});
      return true;
    }
    function up(point,cancelled=false){
      if(!pointers.has(point.id))return;
      const tap=!cancelled&&!hadMultiple&&!moved&&start&&Math.hypot(point.x-start.x,point.y-start.y)<=6;
      pointers.delete(point.id);rebase();if(tap)onTap(point);
    }
    return {down,move,up,active:()=>pointers.size>0,reset:()=>{pointers.clear();start=null;hadMultiple=false;moved=false;}};
  }
  root.LootMapControls={createGestures,rarityPosition};
  if(typeof module!=='undefined')module.exports=root.LootMapControls;
})(typeof window!=='undefined'?window:globalThis);
