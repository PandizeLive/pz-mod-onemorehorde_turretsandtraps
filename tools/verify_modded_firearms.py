import os
import shutil
import subprocess
import time
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid')
MOD = Path('C:/Program Files (x86)/Steam/steamapps/workshop/content/108600/2256623447/mods/Firearms')
VERSION = re.search(r'^modversion=(.+)$', (ROOT/'Source/42.20/mod.info').read_text(), re.M)[1].strip()
CACHE = ROOT / ('diagnostics/v' + VERSION) / 'modded-firearms-cache'

def main():
    CACHE.mkdir(parents=True, exist_ok=True)
    for name, source in [('Firearms', MOD), ('OneMoreHorde_Turrets', ROOT/'Contents/mods/OneMoreHorde_Turrets')]:
        dest = CACHE/'mods'/name
        for version in ['common', '42.16' if name == 'Firearms' else '42.20']:
            if (source/version).exists(): shutil.copytree(source/version, dest/version, dirs_exist_ok=True)
    probe = CACHE/'mods/OneMoreHorde_Turrets/42.20/media/lua/server/OMHTT_ModdedProbe.lua'
    shutil.copy2(ROOT/'tools/tests/modded_firearms_smoke.lua', probe)
    server = CACHE/'Server'
    server.mkdir(exist_ok=True)
    (server/'OMHTT_Modded.ini').write_text('Mods=firearmmod;OneMoreHorde_Turrets\nWorkshopItems=\nPublic=false\nPauseEmpty=true\nUPnP=false\nDefaultPort=29171\nUDPPort=29172\n', encoding='utf-8')
    log = CACHE.parent/'firearms-b42.log'
    command = [str(GAME/'jre64/bin/java.exe'), '--enable-native-access=ALL-UNNAMED', '-Xmx1536m', '-Djava.library.path=./natives/;./natives/win64/;./', '-cp', 'projectzomboid.jar;.', 'zombie.network.GameServer', '-cachedir='+str(CACHE), '-servername', 'OMHTT_Modded', '-nosteam', '-ip', '127.0.0.1', '-adminusername', 'probe', '-adminpassword', 'isolated-probe']
    with log.open('w',encoding='utf-8') as output:
        process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=output, stderr=subprocess.STDOUT, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
        try:
            deadline = time.monotonic()+180
            while process.poll() is None and time.monotonic()<deadline:
                text = log.read_text(encoding='utf-8',errors='replace')
                if '[OMHTT-Modded] PASS ' in text:
                    process.stdin.write('quit\n'); process.stdin.flush(); process.wait(timeout=45)
                    print('\n'.join(line for line in text.splitlines() if '[OMHTT-Modded]' in line))
                    return
                time.sleep(.5)
            raise RuntimeError('Modded probe did not pass; inspect '+str(log))
        finally:
            if process.poll() is None: process.terminate(); process.wait(timeout=15)
            probe.unlink(missing_ok=True)

if __name__ == '__main__': main()
