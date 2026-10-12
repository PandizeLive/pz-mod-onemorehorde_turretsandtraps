"""Refresh only version/default metadata without re-extracting unchanged map geometry."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PACKAGE = ROOT / 'Contents/mods/OneMoreHorde_Turrets/42.20'


def apply_defaults(data, turrets_enabled=True):
    version = re.search(r'^modversion=(.+)$', (PACKAGE / 'mod.info').read_text(), re.M)[1].strip()
    script = (PACKAGE / 'media/sandbox-options.txt').read_text()
    values = dict(re.findall(r'option OMHTurretsTraps\.(\w+)\s*\{[^}]*?default\s*=\s*([\d.]+)', script))
    previous = data['meta'].get('previousBaselines', []) + [data['meta']['baseline']]
    baseline = 'T&T ' + version
    data['meta']['previousBaselines'] = list(dict.fromkeys(p for p in previous if p != baseline))
    data['meta']['baseline'] = baseline
    data['meta']['requiredModId'] = 'OneMoreHorde_Turrets'
    data['meta']['turretsEnabled'] = turrets_enabled
    data['defaults'] = {'global': float(values['ModuleLootRate']) if turrets_enabled else 0,
                        'tierWeights': {name: float(values['RarityWeight' + name]) or None for name in ['Abundant','Common','Uncommon','Rare','Epic','Legendary','Mythic']},
                        'items': {m['id']: float(values['LootRate' + m['id']]) for m in data['modules']}}
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
