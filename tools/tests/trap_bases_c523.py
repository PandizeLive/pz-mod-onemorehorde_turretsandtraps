"""Design sensitivity model, NOT PZ AI, production code, or multiplayer proof.

Four independent ten-tile fronts; corners, doors and wall-routing are excluded.
100 attackers follow fixed straight lanes. No players, turrets, repairs or corpses.
Cross arms exclusively reserve five walkable tiles; only centers damage.
Poke: 45 damage, 1.5s cooldown, 150ms admission, 200 successful-cycle endurance.
Wire: paired transverse sections, 10 damage/2s per actor, half speed, 50 hits.
Beds: 40% entry roll, 20 damage, six wear; assumed successful landing and 1s pause.
Barrier: two-tile frontage; configurable active attackers, one strike/s (assumed).
Native-inspired fractional loss min(nearby/8,1) per strike. Nearby approximated
by this barrier's queue, capped at 8; collision, neighboring queues and packet
ordering excluded. Native loss before retaliation is the conservative ordering.
All model timings are nominal active seconds. No in-game kill guarantee follows.
"""
import json
import math
import random
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DT = .05
CROSS = {(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)}
LAYOUTS = {
    "barrier_ring": (0, True, False, False),
    "shallow_cross": (3, False, False, False),
    "deep_cross": (15, False, False, False),
    "cross_barrier": (3, True, False, False),
    "wire_barrier": (0, True, True, False),
    "mixed": (3, True, True, True),
    "wire_at_barrier": (0, True, True, False),
    "mixed_at_barrier": (3, True, True, True),
    "layered_choke": (7, True, True, True),
}


def simulate(layout, barrier_hp=40, distribution="even", speed=1, hp=100,
             active_slots=4, arrival_gap=.5, seed=0, bed_pause=1, strike_seconds=1,
             reinforced=False):
    depth, has_barriers, has_wire, has_beds = LAYOUTS[layout]
    rng = random.Random(seed)
    start = 4 if has_wire or has_beds else 1
    centers = {(x, y) for x in range(10) for y in range(start, start+depth)
               if (x + 2*(y-start+1)) % 5 == 0}
    if layout=="layered_choke":
        centers={(4,start+y) for y in (0,3,6)}
    footprints = [{(x+dx, y+dy) for dx, dy in CROSS} for x,y in centers]
    if footprints:
        assert len(set.union(*footprints)) == 5*len(centers)
    assert not any(y in (0,1,2) for f in footprints for x,y in f) if has_wire else True
    end = start + depth + 1
    wire_rows=(1,2)
    if layout in ("wire_at_barrier","mixed_at_barrier","layered_choke"):
        wire_rows=(start+depth+1,start+depth+2)
        end=start+depth+2+.8
        assert not any(y in wire_rows for f in footprints for x,y in f)
    pokes = {(f,x,y): {"health":200,"due":-1,"until":-1,"hit":set(),"worn":False}
             for f in range(4) for x,y in centers}
    wires = {(f,x,y):50 for f in range(4) for x in range(5) for y in wire_rows} if has_wire else {}
    beds = {(f,x):50 for f in range(4) for x in range(10)} if has_beds else {}
    bars = {(f,x):{"health":barrier_hp*(2 if reinforced else 1),"partial":0} for f in range(4) for x in range(5)} if has_barriers else {}
    lanes = [(f,x) for f in range(4) for x in range(10)] if distribution=="even" else [(0,4),(0,5)]
    if layout=="layered_choke":
        lanes=[(f,4) for f in range(4)] if distribution=="even" else [(0,4)]
    actors=[]
    for i in range(100):
        f,x=lanes[i%len(lanes)]
        actors.append(dict(id=i,f=f,x=x,y=-.5,hp=hp,arrival=(i//len(lanes))*arrival_gap,
                           pause=0,bed=False,wire_due=-1,strike=None,done=False))
    kills=Counter(); hit_counts=Counter(); escaped=0; first_breach=None
    def damage(a, amount, family):
        a["hp"]-=amount; hit_counts[family]+=1
        if a["hp"]<=0:
            a["done"]=True; kills[family]+=1
    for tick in range(24000):
        now=round(tick*DT,5)
        for a in actors:
            if a["done"] or a["arrival"]>now: continue
            f,x=a["f"],a["x"]
            row=math.floor(a["y"]+1e-8)
            if has_beds and row==0 and not a["bed"]:
                a["bed"]=True
                if beds[f,x]>0 and rng.random()<.4:
                    damage(a,20,"bed");beds[f,x]=max(0,beds[f,x]-6);a["pause"]=now+bed_pause
            if a["done"]: continue
            wire=(f,x//2,row)
            on_wire=wire in wires and wires[wire]>0
            if on_wire and now+1e-8>=a["wire_due"]:
                damage(a,10,"wire");wires[wire]-=1;a["wire_due"]=now+2
            if a["done"]: continue
            p=pokes.get((f,x,row))
            if p and p["health"]>0:
                if now+1e-8>=p["due"]:
                    p.update(due=now+1.5,until=now+.15,hit=set(),worn=False)
                if now<=p["until"]+1e-8 and a["id"] not in p["hit"]:
                    p["hit"].add(a["id"]);damage(a,45,"poke")
                    if not p["worn"]: p["health"]-=1;p["worn"]=True
            if a["done"]: continue
            if a["y"]>=end:
                b=bars.get((f,x//2))
                if not b or b["health"]<=0:
                    a["done"]=True;escaped+=1
                    if has_barriers and first_breach is None: first_breach=now
            elif now>=a["pause"]:
                a["y"]=min(end,a["y"]+speed*DT/(2 if on_wire else 1))
        for key,b in bars.items():
            if b["health"]<=0: continue
            waiting=[a for a in actors if not a["done"] and a["arrival"]<=now
                     and (a["f"],a["x"]//2)==key and a["y"]>=end]
            active=waiting[:active_slots]
            nearby=min(8,len(waiting))
            for a in active:
                if a["strike"] is None: a["strike"]=now+strike_seconds
                if now+1e-8<a["strike"]: continue
                a["strike"]=now+strike_seconds
                b["partial"]+=nearby/8
                loss=int(b["partial"]+1e-8);b["partial"]-=loss;b["health"]-=loss
                if b["health"]<=0: break
                damage(a,25 if reinforced else 10,"barrier")
        if all(a["done"] for a in actors): break
    assert sum(kills.values())+escaped==100, "Unresolved actors, extend model horizon"
    counts=dict(poke=len(pokes),barrier=len(bars),wire=len(wires),bed=len(beds))
    # Exact consumed ingredients; tools/skills are separate and no rarity-value conversion.
    bill=Counter()
    for name,num in counts.items():
        recipe={"poke":{"TirePump":1,"MetalBar":5,"SmallSheetMetal":2,"Screws":10},
                "barrier":{"Plank":4,"RippedSheets":4},
                "wire":{"BarbedWire":1,"Wire":2},
                "bed":{"Plank":2,"RippedSheets":2}}[name]
        for mat,qty in recipe.items(): bill[mat]+=qty*num
    if reinforced:
        bill['Plank']+=2*len(bars);bill['Nails']+=8*len(bars)
    return dict(layout=layout,barrier_hp=barrier_hp,distribution=distribution,speed=speed,
                zombie_hp=hp,active_slots=active_slots,arrival_gap=arrival_gap,seed=seed,
                bed_pause=bed_pause,strike_seconds=strike_seconds,reinforced=reinforced,kills=sum(kills.values()),
                kills_by= dict(kills),escaped=escaped,hits=dict(hit_counts),counts=counts,
                proposed_recipe_bill=dict(bill),broken_barriers=sum(b["health"]<=0 for b in bars.values()),
                first_breach_seconds=first_breach,elapsed=now,
                poke_cycles_used=sum(200-p["health"] for p in pokes.values()))


def barrier_benchmark(health, slots, nearby, zombie_hp=100, retaliation=10):
    """Maintain a fixed crowded frontage; replace kills with fresh targets."""
    victims=[zombie_hp]*slots; partial=0;kills=0;strikes=0
    while health>0:
        idx=strikes%slots;strikes+=1
        partial+=min(nearby/8,1);loss=int(partial);partial-=loss;health-=loss
        if health<=0: break
        victims[idx]-=retaliation
        if victims[idx]<=0: kills+=1;victims[idx]=zombie_hp
    return kills


def main():
    assert barrier_benchmark(40,1,1)==31
    assert barrier_benchmark(40,4,8)==3
    assert barrier_benchmark(40,8,8)==0
    results=[]
    for layout in LAYOUTS:
        for health in ([40,80,100] if LAYOUTS[layout][1] else [40]):
            for distribution in ("even","focused"):
                for speed in (1,2):
                    for hp in (100,150):
                        results.append(simulate(layout,health,distribution,speed,hp))
    # Sensitivity for the proposed mixed reference: chance, crowd frontage, timing.
    sensitivity=[]
    for seed in range(10):
        for slots in (2,4,8):
            for gap in (.5,3):
                sensitivity.append(simulate("mixed",40,"focused",active_slots=slots,arrival_gap=gap,seed=seed))
    for pause in (0,3):
        for rate in (.75,1.5):
            sensitivity.append(simulate("mixed",40,"focused",bed_pause=pause,strike_seconds=rate))
    for layout in ('mixed_at_barrier','layered_choke','deep_cross'):
        for gap in (.5,3):
            for reinforced in (False,True) if LAYOUTS[layout][1] else (False,):
                for seed in range(5):
                    sensitivity.append(simulate(layout,40,'focused',arrival_gap=gap,seed=seed,reinforced=reinforced))
    benchmarks=[dict(health=h,active_slots=s,nearby=n,kills=barrier_benchmark(h,s,n))
                for h in (20,25,30,40,50,80,100) for s,n in ((1,1),(2,8),(4,8),(8,8))]
    data=dict(scope=__doc__,recipe_proposal="Poke MetalBars 4->5, Screws 8->10; other inputs unchanged. Not an overall economic +25% claim.",
              layout_cases=results,sensitivity=sensitivity,barrier_benchmarks=benchmarks)
    target=ROOT/'docs/evidence/c523-trap-bases.json'
    target.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
    print('cases',len(results)+len(sensitivity)+len(benchmarks))
    for r in results:
        if r['speed']==1 and r['zombie_hp']==100 and r['barrier_hp']==80:
            print(r['layout'],r['distribution'],r['kills'],r['broken_barriers'],r['counts'])
    print('barrier reference', [r for r in benchmarks if r['health'] in (40,80,100)])
    print('mixed focused sensitivity kills',min(r['kills'] for r in sensitivity),max(r['kills'] for r in sensitivity))


if __name__=='__main__': main()
