from pathlib import Path
import shutil
import subprocess
import time

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
GAME = Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid')
CACHE = OUT / 'server-cache'
mod = CACHE / 'mods/OneMoreHorde_Traps'
shutil.copytree(ROOT / 'Contents/mods/OneMoreHorde_Traps', mod, dirs_exist_ok=True)
shutil.copy2(OUT / 'BarbProbe.lua', mod / '42.20/media/lua/server/OMHTT_BarbProbe.lua')
settings = CACHE / 'Server/BarbProbe.ini'
settings.parent.mkdir(parents=True, exist_ok=True)
settings.write_text('Mods=OneMoreHorde_Traps\nPublic=false\nPauseEmpty=true\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29261\nUDPPort=29262\n')
subprocess.run(['C:/Program Files/Java/jdk-17/bin/javac.exe', '-d', str(OUT), str(OUT / 'BarbNativeCheck.java')], check=True)
command = [str(GAME / 'jre64/bin/java.exe'), '--enable-native-access=ALL-UNNAMED',
    '--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED', '-XX:-CreateCoredumpOnCrash', '-Xmx1536m',
    '-Djava.library.path=./natives/;./natives/win64/;./', '-cp', str(OUT) + ';projectzomboid.jar;.',
    'BarbNativeCheck', '-cachedir=' + str(CACHE), '-servername', 'BarbProbe', '-nosteam',
    '-ip', '127.0.0.1', '-port', '29261', '-adminusername', 'probe', '-adminpassword', 'local-probe']
log = OUT / 'native.log'
with log.open('w', encoding='utf-8') as output:
    process = subprocess.Popen(command, cwd=GAME, stdin=subprocess.PIPE, stdout=output,
        stderr=subprocess.STDOUT, text=True, creationflags=subprocess.CREATE_NO_WINDOW)
    start = time.monotonic()
    try:
        while process.poll() is None and time.monotonic() - start < 150:
            transcript = log.read_text(encoding='utf-8', errors='replace')
            if '*** SERVER STARTED' in transcript:
                process.stdin.write('quit\n')
                process.stdin.flush()
                process.wait(timeout=40)
                break
            if 'Server Terminated.' in transcript:
                break
            time.sleep(.25)
    finally:
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=15)
text = log.read_text(encoding='utf-8', errors='replace')
for line in text.splitlines():
    if '[BarbProbe]' in line or 'java.lang.IllegalStateException' in line:
        print(line)
for marker in ['[BarbProbe] LUA PASS', '[BarbProbe] SAVE PASS', '[BarbProbe] CROSS PASS', 'Shutdown handling finished']:
    assert marker in text, 'Missing ' + marker + '; inspect native.log'
print('PASS: isolated native host/contact feasibility; no rendered or autonomous AI acceptance.')
