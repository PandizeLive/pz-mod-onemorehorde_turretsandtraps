"""Refresh only version/default metadata without re-extracting unchanged map geometry."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PACKAGE = ROOT / 'Contents/mods/OneMoreHorde_Turrets/42.20'


def apply_defaults(data, turrets_enabled=True):
    version = re.search(r'^modversion=(.+)$', (PACKAGE / 'mod.info').read_text(), re.M)[1].strip()
    script = (PACKAGE / 'media/sandbox-options.txt').read_text()
    values = dict(re.findall(r'option OMHTurretsTraps\.(\w+)\s*\{[^}]*?default\s*=\s*([-\d.]+)', script))
    manuals = [('ManualBallista','Ballista Manual'), ('ManualRotaryBlades','Rotary Blade Manual'), ('ManualLobber','Lobber Manual'), ('ManualArc','Arc Emitter Manual'), ('ManualFirearms','Firearms Manual')]
    if turrets_enabled:
        existing = {m['id'] for m in data['modules']}
        for key, name in manuals:
            if key not in existing:
                data['modules'].append({'id':key,'name':name,'weight':1,'category':'Manuals','packEligible':False})
        literature = {'LibraryBooks','BookstoreBlueCollar','BookstoreScience','LivingRoomShelf','MagazineRackMixed'}
        for name, pool in data['pools'].items():
            eligible = [] if name in literature else pool.get('modules', [m['id'] for m in data['modules'] if not m['id'].startswith('Manual')])
            pool['modules'] = list(dict.fromkeys(eligible + [key for key, _ in manuals]))
    previous = data['meta'].get('previousBaselines', []) + [data['meta']['baseline']] + [f'T&T 0.2.{i}' for i in range(26,65)] + [f'T&T 0.2.64.{i}' for i in range(1,5)]
    baseline = 'T&T ' + version
    data['meta']['previousBaselines'] = list(dict.fromkeys(p for p in previous if p != baseline))
    data['meta']['baseline'] = baseline
    data['meta']['requiredModId'] = 'OneMoreHorde_Turrets' if turrets_enabled else 'OneMoreHorde_Traps'
    data['meta']['turretsEnabled'] = turrets_enabled
    if not turrets_enabled:
        data['modules'] = [m for m in data['modules'] if m['id'] in {'CapacitySmall', 'Capacity', 'CapacityLarge'}]
    data['defaults'] = {'global': float(values['ModuleLootRate']),
                        'tierWeights': {name: float(values['RarityWeight' + name]) or None for name in ['Abundant','Common','Uncommon','Rare','Epic','Legendary','Mythic']},
                        'items': {m['id']: float(values['LootRate' + m['id']]) for m in data['modules']}}
    manual_tiers = {'ManualBallista':'Uncommon','ManualRotaryBlades':'Uncommon','ManualLobber':'Rare','ManualArc':'Epic','ManualFirearms':'Rare'}
    for key, tier in manual_tiers.items():
        if data['defaults']['items'].get(key) == -1:
            data['defaults']['items'][key] = data['defaults']['tierWeights'][tier]
    return data


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--traps-only', action='store_true')
    args = parser.parse_args()
    path = ROOT / 'art/loot-tuner/data.js'
    data = json.loads(path.read_text().removeprefix('window.LOOT_DATA=').strip().removesuffix(';'))
    apply_defaults(data, turrets_enabled=not args.traps_only)
    path.write_text('window.LOOT_DATA=' + json.dumps(data, separators=(',', ':')) + ';\n', encoding='utf-8')
    print(json.dumps({'baseline': data['meta']['baseline'], 'defaults': data['defaults']}))
