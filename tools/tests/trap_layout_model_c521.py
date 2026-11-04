"""Design model, NOT PZ runtime evidence or a proposed gameplay implementation.

100 zombies, ten identical straight lanes, 100 HP each, 45 damage/hit,
one tile/second, two seconds between arrivals per lane. Optional eight-second
dwell on the final tile represents a blocked perimeter. No AI, armor, slowdown,
trip chance, networking or player attacks. Instant strokes; no 150ms admission
window. Identical lanes are simulated once and multiplied by ten.
"""
import json
from pathlib import Path


def run(rows, mode, dwell):
    zombies = [{'health': 100, 'entry': i*2, 'dead': False} for i in range(10)]
    due, armed, bodies = [0.0]*rows, [True]*rows, [[] for _ in range(rows)]
    hits = kills = 0
    step = .05
    # All survivors have left by this time; time is an illustrative seconds clock.
    for tick in range(round((20+rows+dwell)/step)+1):
        now = round(tick*step, 4)
        occupancy = [[] for _ in range(rows)]
        for zombie in zombies:
            elapsed = now-zombie['entry']
            if zombie['dead'] or elapsed < 0 or elapsed >= rows+dwell:
                continue
            tile = min(rows-1, int(elapsed))
            occupancy[tile].append(zombie)
        for tile, occupants in enumerate(occupancy):
            blocked = mode in ('corpse_lock', 'clear_all') and bool(bodies[tile])
            if mode == 'auto_clear_6s':
                blocked = any(now-time < 6 for time in bodies[tile])
            if not occupants and not blocked:
                armed[tile] = True
            if not occupants or blocked or now < due[tile]:
                continue
            if mode in ('live_reset', 'clear_all') and not armed[tile]:
                continue
            armed[tile], due[tile] = False, now+1.5
            for zombie in occupants:
                hits += 1
                zombie['health'] -= 45
                if zombie['health'] <= 0:
                    zombie['dead'] = True
                    kills += 1
                    bodies[tile].append(now)
    return {'rows': rows, 'tiles': rows*10, 'mode': mode, 'lastTileDwellSeconds': dwell,
            'kills': kills*10, 'survivors': (10-kills)*10, 'damagingHits': hits*10,
            'corpseBlockedTilesAtEnd': sum(bool(v) for v in bodies)*10 if mode in ('corpse_lock', 'clear_all') else 0}


def main():
    records = [run(rows, mode, dwell) for dwell in [0, 8]
               for rows in [1, 3, 6, 12]
               for mode in ['repeat', 'live_reset', 'corpse_lock', 'clear_all', 'auto_clear_6s']]
    assert run(1, 'repeat', 0)['kills'] == 0
    assert run(3, 'repeat', 0)['kills'] == 100
    assert run(3, 'live_reset', 0)['kills'] == 100
    assert run(3, 'corpse_lock', 0)['kills'] == 10
    # Survivors keep damage from the first two unblocked rows. Each additional
    # row can therefore kill another zombie per lane before its corpse locks it.
    assert run(6, 'corpse_lock', 0)['kills'] == 40
    assert run(12, 'corpse_lock', 0)['kills'] == 100
    assert run(6, 'auto_clear_6s', 0)['kills'] == 100
    assert run(1, 'clear_all', 8)['kills'] == 0
    assert run(3, 'clear_all', 0)['kills'] == 10
    assert run(12, 'clear_all', 0)['kills'] == 100
    output = Path(__file__).resolve().parents[2]/'docs/evidence/c521-layout-model.json'
    output.write_text(json.dumps({'kind': 'Illustrative deterministic design model, not game simulation',
        'assumptions': __doc__, 'cases': records}, indent=2)+'\n', encoding='utf-8')
    for record in records:
        print(json.dumps(record))


if __name__ == '__main__':
    main()
