import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main():
    tools = Path(__file__).resolve().parent
    powershell = Path(os.environ['SystemRoot']) / 'System32/WindowsPowerShell/v1.0/powershell.exe'
    with tempfile.TemporaryDirectory(prefix='omhtt-mirror-') as temp:
        root = Path(temp)
        (root / 'tools').mkdir()
        (root / 'Source/42.20').mkdir(parents=True)
        (root / 'Source/42.20/mod.info').write_text('modversion=0.2.30\n')
        shutil.copy2(tools / 'Mirror-Development.ps1', root / 'tools')
        config = json.loads((tools / 'github-process.json').read_text())
        (root / 'tools/github-process.json').write_text(json.dumps(config))

        def git(*args):
            return subprocess.run(['git', '-c', f'safe.directory={root.as_posix()}', '-C', str(root), *args],
                                  check=True, capture_output=True, text=True).stdout.strip()

        def check(name, success, message):
            result = subprocess.run([str(powershell), '-NoProfile', '-File', str(root / 'tools/Mirror-Development.ps1'),
                                     '-ValidateOnly'], capture_output=True, text=True)
            output = result.stdout + result.stderr
            assert (result.returncode == 0) == success, (name, output)
            assert message in output, (name, output)
            print(f'PASS: {name}')

        git('init', '-b', 'dev')
        git('config', 'user.name', 'Mirror Test')
        git('config', 'user.email', 'test@local.invalid')
        git('remote', 'add', 'origin', config['remote'])
        git('add', '.')
        git('commit', '-m', 'Fixture baseline')
        check('untagged development checkpoint', True, 'include current test tag: False')
        git('tag', '-a', 'test/v0.2.30', '-m', 'Test build')
        check('tagged development checkpoint', True, 'include current test tag: True')
        (root / 'plan.md').write_text('Approved documentation\n')
        check('untracked intended file refused', False, 'Commit intended changes')
        git('add', 'plan.md')
        git('commit', '-m', 'Document plan')
        check('documentation commit after test tag', True, 'include current test tag: True')
        (root / 'plan.md').write_text('Uncommitted change\n')
        check('dirty tracked document refused', False, 'Commit intended changes')
        git('add', 'plan.md')
        git('commit', '-m', 'Update plan')
        git('remote', 'set-url', '--push', 'origin', 'https://github.com/example/wrong.git')
        check('wrong push destination refused', False, 'Origin fetch and push URLs')
        git('remote', 'set-url', '--push', 'origin', config['remote'])
        git('switch', '-c', 'main')
        check('official branch refused', False, 'Official release branches cannot be mirrored')
        git('switch', 'dev')
        (root / 'Source/42.20/new.lua').write_text('return {}\n')
        git('add', 'Source')
        git('commit', '-m', 'Unpackaged development change')
        check('changed source does not reuse test tag', True, 'include current test tag: False')
        assert not git('for-each-ref', '--format=%(refname)', 'refs/remotes')
        print('PASS: all preflights left remote refs untouched (no network required)')


if __name__ == '__main__':
    main()
