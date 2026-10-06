"""Verify split-package metadata without altering the published LootLab dataset."""
import copy
import json
from sync_defaults import ROOT, apply_defaults


def main():
    text = (ROOT / 'art/loot-tuner/data.js').read_text()
    original = json.loads(text.removeprefix('window.LOOT_DATA=').strip().removesuffix(';'))
    enabled = apply_defaults(copy.deepcopy(original))
    disabled = apply_defaults(copy.deepcopy(original), turrets_enabled=False)
    assert enabled['defaults'] == original['defaults'], 'The split must not change loot tuning'
    assert enabled['meta']['requiredModId'] == 'OneMoreHorde_Turrets'
    assert enabled['meta']['turretsEnabled'] is True
    assert disabled['meta']['turretsEnabled'] is False
    assert disabled['defaults']['global'] == 0
    assert disabled['defaults']['items'] == enabled['defaults']['items']
    for key in original:
        if key not in {'defaults', 'meta'}:
            assert enabled[key] == original[key] == disabled[key], key
    print('LootLab: unchanged loot tuning/data; turret ownership and traps-only zero-loot defaults verified.')


if __name__ == '__main__':
    main()
