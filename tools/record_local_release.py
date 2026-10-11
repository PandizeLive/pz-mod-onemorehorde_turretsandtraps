"""Verify tagged/source/installed package bytes and record the local release archive."""
import hashlib
import io
import json
import re
import subprocess
import zipfile
from pathlib import Path

from build_packages import ROOT, build


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    version, _ = build(check=True)
    output = ROOT / 'diagnostics' / ('v' + version)
    manifest = json.loads((output / 'manifest.json').read_text())
    install = json.loads((output / 'install.json').read_text())
    tag = 'test/v' + version
    git = ['git', '-c', 'safe.directory=' + ROOT.as_posix(), '-C', str(ROOT)]
    source_commit = subprocess.check_output(git + ['rev-parse', tag + '^{commit}'], text=True).strip()
    tagged = zipfile.ZipFile(io.BytesIO(subprocess.check_output(git + ['archive', '--format=zip', tag, 'Source', 'Contents'])))
    for name, expected in manifest['sourceFiles'].items():
        assert digest(tagged.read('Source/' + name)) == expected, 'Tagged source differs: ' + name
        assert digest((ROOT / 'Source' / name).read_bytes()) == expected, 'Working source differs: ' + name
    validation = (output / 'validation.log').read_text(encoding='utf-8')
    assertions = re.search(r'Assertions passed: (\d+)', validation)
    assert assertions, 'Missing current validation result'
    for mode in ['write', 'read']:
        native = (output / ('server-' + mode + '.log')).read_text(encoding='utf-8')
        assert '[OMHTT-Smoke] native-persistence mode=' + mode in native and 'Shutdown handling finished' in native
        if (ROOT / 'Source/42.20/media/scripts/OMHTT_BedSpikes.txt').exists():
            assert '[OMHTT-Beds] persistence mode=' + mode + ' parts=32' in native, 'Missing native bed persistence proof'
        if (ROOT / 'Source/42.20/media/scripts/OMHTT_Barbs.txt').exists():
            assert '[OMHTT-Barbs] persistence mode=' + mode + ' pairs=8' in native, 'Missing native barb persistence proof'
    for selection in ['traps', 'turrets', 'both']:
        result = json.loads((output / ('packages-' + selection + '.json')).read_text())
        assert result['version'] == version and result['passed'], 'Missing current package isolation proof'
    archive = ROOT / 'artifacts' / ('OMHTT-' + version + '.zip')
    verified = 0
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as zipped:
        for identifier, files in manifest['packages'].items():
            for name, expected in files.items():
                relative = 'Contents/mods/' + identifier + '/' + name
                data = (ROOT / relative).read_bytes()
                assert digest(data) == expected, relative
                assert digest(tagged.read(relative)) == expected, 'Tag differs: ' + relative
                assert digest((Path(install['destination']) / identifier / name).read_bytes()) == expected, 'Install differs: ' + relative
                zipped.writestr(relative, data)
                verified += 1
    with zipfile.ZipFile(archive) as zipped:
        assert len(zipped.namelist()) == verified
        for identifier, files in manifest['packages'].items():
            for name, expected in files.items():
                assert digest(zipped.read('Contents/mods/' + identifier + '/' + name)) == expected
    backups = []
    for marker in Path(install['backup']).glob('*/.omhtt-foundation-install.json'):
        saved = json.loads(marker.read_text(encoding='utf-8-sig'))
        for name, expected in saved['files'].items():
            assert digest((marker.parent / name).read_bytes()) == expected, 'Backup differs: ' + name
        backups.append({'package': marker.parent.name, 'version': saved['version'], 'filesVerified': len(saved['files'])})
    record = {'version': version, 'sourceCommit': source_commit, 'tag': tag,
              'installed': install['destination'], 'packages': {k: len(v) for k, v in manifest['packages'].items()},
              'filesVerified': verified, 'sourceFilesVerified': len(manifest['sourceFiles']),
              'backup': install['backup'], 'backupsVerified': backups,
              'archive': str(archive), 'archiveSHA256': digest(archive.read_bytes()),
              'kahluaAssertions': int(assertions[1]), 'nativeWrite': 'passed', 'nativeRead': 'passed',
              'nativeSelections': ['traps', 'turrets', 'both'],
              'clientAcceptance': 'pending focused owner test', 'savePolicy': 'fresh worlds',
              'publication': 'none', 'hostedLootLab': json.loads((output / 'lootlab-release.json').read_text()) if (output / 'lootlab-release.json').exists() else 'No hosted update recorded for this release'}
    (output / 'local-release.json').write_text(json.dumps(record, indent=2) + '\n')
    print(json.dumps(record, indent=2))


if __name__ == '__main__':
    main()
