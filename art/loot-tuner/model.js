/* Local-only model. No game files are changed. Also loadable by Node for checks. */
(function(root) {
  'use strict';
  function rng(seed) {
    let a = seed >>> 0;
    return () => { a += 0x6D2B79F5; let t=a; t=Math.imul(t^(t>>>15),t|1); t^=t+Math.imul(t^(t>>>7),t|61); return ((t^(t>>>14))>>>0)/4294967296; };
  }
  function probability(weight, global, item, material) {
    if (weight<=0 || global<=0 || item<=0 || material<=0) return 0;
    // Integer Rand.Next(10000), new-world time factor 1, zombie loot effect 0.
    return Math.min(1, Math.ceil(weight*global*item*material*100-1e-10)/10000);
  }
  function rolls(base, multiplier) { return Math.max(1, Math.floor(base*multiplier)); }
  function choose(rules, counts, forced, random) {
    if (forced.length) return forced[forced.length-1];
    let required=[], available=[];
    for (const r of rules) {
      if (r.forceForTiles) continue;
      const n=counts[r.name]||0;
      if (r.min===1 && n===0) required.push(r);
      else if (n<r.max) available.push(r);
    }
    const options=required.length?required:available;
    const weight=r=>r.weightChance>0?r.weightChance:100;
    let sum=options.reduce((n,r)=>n+weight(r),0);
    if (!sum) return null;
    let target=random()*sum;
    for(const r of options) { target-=weight(r); if(target<0) return r.name; }
    return options[options.length-1].name;
  }
  function binomial(n,p,random) {
    if(p<=0 || n<=0) return 0;
    if(p>=1) return n;
    if(p>.5) return n-binomial(n,1-p,random);
    // Exact geometric waiting times: work scales with successes, not trials.
    const log=Math.log1p(-p); let successes=0, position=-1;
    while(true) { position+=1+Math.floor(Math.log(1-random())/log); if(position>=n) return successes; successes++; }
  }
  function quantile(values,q) { const a=values.slice().sort((x,y)=>x-y); return a[Math.floor((a.length-1)*q)]||0; }
  function defaults(data) { return {version:1,baseline:data.meta.baseline,seed:24601,global:data.defaults?.global??1,material:.6,rolls:1,retention:1,selected:'all',overlay:'spawns',visible:Object.fromEntries(data.modules.map(m=>[m.id,true])),items:Object.fromEntries(data.modules.map(m=>[m.id,data.defaults?.items?.[m.id]??1]))}; }
  function migrateValue(path,value,baseline) {
    if(/^T&T 0\.2\.(2[6-9]|3[0-9]|4[0-5])$/.test(baseline))return value;
    if(path==='global')return value/4.5;
    if(path.startsWith('items.')) {
      const id=path.slice(6);
      if(['Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced','Piercing','InitialBlow','Execute','Impact','Conservation','Synergy','Martyrdom','Tack','Regulator'].includes(id))return value;
      const factor=['Firing','MotionDetection','CapacitySmall','CapacityLarge','Autoloader'].includes(id)?3:2;
      return value/(baseline==='Installed 0.2.22'&&id==='Suppression'?1:factor);
    }
    return value;
  }
  function validate(input,data) {
    if(!input || input.version!==1) throw Error('Unsupported scenario format.');
    const legacy=(data.meta.previousBaselines||[]).includes(input.baseline);
    if(input.baseline!==data.meta.baseline&&!legacy)throw Error('Unsupported loot baseline.');
    const s=defaults(data);
    for(const [key,min,max] of [['global',0,20],['material',0,10],['rolls',0,10],['retention',0,1],['seed',0,4294967295]]) {
      if(typeof input[key]!=='number' || !Number.isFinite(input[key]) || input[key]<min || input[key]>max) throw Error('Invalid '+key+'.');
      s[key]=legacy?migrateValue(key,input[key],input.baseline):input[key];
    }
    s.seed=Math.floor(s.seed);
    for(const m of data.modules) {
      const added=legacy&&['Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced','Piercing','InitialBlow','Execute','Impact','Conservation','Synergy','Martyrdom','Tack','Regulator'].includes(m.id)&&input.items?.[m.id]===undefined;
      const value=added?1:legacy&&['Critical','Accuracy'].includes(m.id)&&input.items?.[m.id]===undefined?1:input.items?.[m.id];
      if(typeof value!=='number' || !Number.isFinite(value) || value<0 || value>20) throw Error('Invalid '+m.name+' multiplier.');
      s.items[m.id]=legacy&&!added?migrateValue("items."+m.id,value,input.baseline):value;
      if(input.visible?.[m.id]!==undefined) {
        if(typeof input.visible[m.id]!=='boolean')throw Error('Invalid component visibility.');
        s.visible[m.id]=input.visible[m.id];
      }
    }
    if(input.selected==='all' || data.modules.some(m=>m.id===input.selected)) s.selected=input.selected;
    if(input.overlay==='spawns'||input.overlay==='chances')s.overlay=input.overlay;
    return s;
  }
  function regionFor(c,labels) {
    let nearest=0, distance=Infinity;
    labels.forEach((l,i)=>{let d=(c.x-l[1])**2+(c.y-l[2])**2;if(d<distance){distance=d;nearest=i;}});
    return nearest;
  }
  function keyedSeed(seed, text) {
    let value=seed>>>0;
    for(let i=0;i<text.length;i++)value=Math.imul(value^text.charCodeAt(i),16777619)>>>0;
    return value;
  }
  // One synthetic world, with shared room quotas and a stable item RNG per container/component.
  // Visibility is intentionally absent from generation. It never changes the sampled world.
  function generate(data, scenario) {
    const routeRandom=rng(scenario.seed^0x4327b01d),groups=new Map();
    data.containers.forEach((c,i)=>{if(!groups.has(c.room))groups.set(c.room,[]);groups.get(c.room).push(i);});
    const poolByContainer=new Array(data.containers.length).fill(null), spawns=[],totals=data.modules.map(()=>0);
    const probabilities=data.modules.map(m=>probability(m.weight,scenario.global,scenario.items[m.id],scenario.material)*scenario.retention);
    for(const indices of groups.values()) {
      const order=indices.slice(),counts=Object.create(null);
      for(let i=order.length-1;i>0;i--){const j=Math.floor(routeRandom()*(i+1));[order[i],order[j]]=[order[j],order[i]];}
      for(const index of order) {
        const c=data.containers[index],pool=choose(data.routes[c.route].rules,counts,c.forced,routeRandom);
        if(!pool)continue;counts[pool]=(counts[pool]||0)+1;
        if(!data.pools[pool])continue;
        poolByContainer[index]=pool;
        data.modules.forEach((m,module)=>{
          const random=rng(keyedSeed(scenario.seed,`${c.x},${c.y},${c.z},${c.tile}:${m.id}`));
          const eligible=!data.pools[pool].modules||data.pools[pool].modules.includes(m.id);
          const count=binomial(rolls(data.pools[pool].rolls,scenario.rolls),eligible?probability(m.weight*(data.pools[pool].scale??1),scenario.global,scenario.items[m.id],scenario.material)*scenario.retention:0,random);
          if(count){spawns.push({container:index,module,count});totals[module]+=count;}
        });
      }
    }
    const containerTotals=new Array(data.containers.length).fill(0);
    for(const spawn of spawns)containerTotals[spawn.container]+=spawn.count;
    return {seed:scenario.seed,spawns,totals,poolByContainer,containerTotals};
  }
  async function prepare(data, seed, progress=()=>{}, samples=256) {
    const random=rng(seed), groups=new Map(), pools=Object.keys(data.pools);
    const region=data.containers.map(c=>regionFor(c,data.labels));
    data.containers.forEach((c,i)=>{if(!groups.has(c.room))groups.set(c.room,[]);groups.get(c.room).push(i);});
    const hits=data.containers.map(()=>new Uint16Array(pools.length)), worlds=[];
    for(let w=0;w<samples;w++) {
      const totals=Array.from({length:data.labels.length},()=>new Uint32Array(pools.length));
      for(const indices of groups.values()) {
        const order=indices.slice(), counts=Object.create(null);
        for(let i=order.length-1;i>0;i--){const j=Math.floor(random()*(i+1));[order[i],order[j]]=[order[j],order[i]];}
        for(const i of order) {
          const c=data.containers[i], name=choose(data.routes[c.route].rules,counts,c.forced,random);
          if(!name)continue;
          counts[name]=(counts[name]||0)+1;
          const pi=pools.indexOf(name);
          if(pi>=0){hits[i][pi]++;totals[region[i]][pi]++;}
        }
      }
      worlds.push(totals);
      if(w%8===7){progress((w+1)/samples);await new Promise(resolve=>setTimeout(resolve,0));}
    }
    return {hits,worlds,pools,region,samples};
  }
  function haulDistribution(chances,turns) {
    let bins=[1,0,0,0,0,0];
    for(const chance of chances)for(let r=0;r<turns;r++){
      const next=bins.map(v=>v*(1-chance));next[5]+=bins[5]*chance;
      for(let n=0;n<5;n++)next[n+1]+=bins[n]*chance;
      bins=next;
    }
    return bins;
  }
  function markerRadius(overlay,total,jackpotChance) {
    return overlay==='spawns'?(total>=5?9:4.5):3+9*Math.sqrt(Math.max(0,Math.min(1,jackpotChance)));
  }
  function evaluate(data, prepared, scenario) {
    const {pools,hits,worlds,samples}=prepared;
    const turns=pools.map(p=>rolls(data.pools[p].rolls,scenario.rolls));
    const probabilities=data.modules.map(m=>probability(m.weight,scenario.global,scenario.items[m.id],scenario.material)*scenario.retention);
    const selected=data.modules.map((m,i)=>scenario.selected==='all'||m.id===scenario.selected?i:-1).filter(i=>i>=0);
    const poolProbabilities=data.modules.map((m,i)=>pools.map(p=>!data.pools[p].modules||data.pools[p].modules.includes(m.id)?probability(m.weight*(data.pools[p].scale??1),scenario.global,scenario.items[m.id],scenario.material)*scenario.retention:0));
    const trials=worlds.map(world=>world.map(region=>region.map((count,p)=>count*turns[p])));
    const meanTrials=trials.reduce((n,w)=>n+w.reduce((a,r)=>a+r.reduce((b,v)=>b+v,0),0),0)/samples;
    const itemMeans=poolProbabilities.map(probs=>trials.reduce((n,w)=>n+w.reduce((a,r)=>a+r.reduce((b,v,p)=>b+v*probs[p],0),0),0)/samples);
    const haulByPool=pools.map((p,pi)=>haulDistribution(poolProbabilities.map(v=>v[pi]),turns[pi]));
    const hauls=hits.map(h=>{
      const bins=[1,0,0,0,0,0];
      for(let p=0;p<pools.length;p++){
        const share=h[p]/samples;bins[0]-=share*(1-haulByPool[p][0]);
        for(let n=1;n<6;n++)bins[n]+=share*haulByPool[p][n];
      }
      return {presence:1-bins[0],oneOrTwo:bins[1]+bins[2],jackpot:bins[5]};
    });
    const expectations=hits.map(h=>h.reduce((n,count,p)=>n+count/samples*turns[p]*selected.reduce((a,i)=>a+poolProbabilities[i][p],0),0));
    const presence=hits.map(h=>h.reduce((n,count,p)=>n+count/samples*(1-selected.reduce((none,i)=>none*(1-poolProbabilities[i][p])**turns[p],1)),0));
    const random=rng(scenario.seed^0x69eeb351),draws=[],regional=data.labels.map(()=>[]),regionMeans=data.labels.map(()=>0);
    let zero=0;
    trials.forEach(world=>{
      let total=0,none=1;
      world.forEach((counts,r)=>{
        let count=0;
        for(const i of selected)for(let p=0;p<pools.length;p++){
          const chance=poolProbabilities[i][p],n=counts[p];
          count+=binomial(n,chance,random);none*=(1-chance)**n;regionMeans[r]+=n*chance/samples;
        }
        regional[r].push(count);total+=count;
      });
      zero+=none/samples;draws.push(total);
    });
    const regions=data.labels.map((label,r)=>({name:label[0],mean:regionMeans[r],lo:quantile(regional[r],.05),hi:quantile(regional[r],.95)}));
    const poolMeans=pools.map((name,p)=>({name,containers:worlds.reduce((n,w)=>n+w.reduce((a,r)=>a+r[p],0),0)/samples}));
    return {itemMeans,expectations,presence,regions,poolMeans,mean:selected.reduce((n,i)=>n+itemMeans[i],0),lo:quantile(draws,.05),hi:quantile(draws,.95),zero,probabilities,poolProbabilities,meanTrials,hauls,haulByPool};
  }
  root.LootModel={migrateValue,rng,probability,rolls,choose,binomial,quantile,defaults,validate,prepare,evaluate,regionFor,generate,haulDistribution,markerRadius};
  if(typeof module!=='undefined')module.exports=root.LootModel;
})(typeof window!=='undefined'?window:globalThis);
