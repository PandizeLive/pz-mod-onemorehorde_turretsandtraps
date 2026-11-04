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
    assert disabled['defaults']['global'] == enabled['defaults']['global'] == 1
    assert set(disabled['defaults']['items']) == {'CapacitySmall', 'Capacity', 'CapacityLarge'}
    assert disabled['meta']['requiredModId'] == 'OneMoreHorde_Traps'
    for key in original:
        if key not in {'defaults', 'meta', 'modules'}:
            assert enabled[key] == original[key] == disabled[key], key
    print('LootLab: global 1.00 and independent Traps expansion-kit defaults verified.')


if __name__ == '__main__':
    main()
