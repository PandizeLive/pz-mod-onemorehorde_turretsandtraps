from pathlib import Path
import subprocess,time
p=Path(__file__).resolve().parent
game=Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid')
classes=p/'classes';classes.mkdir(exist_ok=True)
subprocess.run(['C:/Program Files/Java/jdk-17/bin/javac.exe','-d',str(classes),str(p/'ExplosionDamageProbe.java')],check=True)
cache=p/'cache';(cache/'Server').mkdir(parents=True,exist_ok=True)
(cache/'Server/ExplosionProbe.ini').write_text('Public=false\nPauseEmpty=true\nUPnP=false\nMap=Muldraugh, KY\nDefaultPort=29261\nUDPPort=29262\n',encoding='utf-8')
cmd=[str(game/'jre64/bin/java.exe'),'--enable-native-access=ALL-UNNAMED','--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED','-XX:-CreateCoredumpOnCrash','-Xmx1536m','-Djava.library.path=./natives/;./natives/win64/;./','-cp',str(classes)+';projectzomboid.jar;.','ExplosionDamageProbe','-cachedir='+str(cache),'-servername','ExplosionProbe','-nosteam','-ip','127.0.0.1','-port','29261','-adminusername','probe','-adminpassword','local-probe']
log=p/'native.log'
with log.open('w',encoding='utf-8') as out:
 proc=subprocess.Popen(cmd,cwd=game,stdin=subprocess.PIPE,stdout=out,stderr=subprocess.STDOUT,text=True,creationflags=subprocess.CREATE_NO_WINDOW)
 started=time.monotonic()
 try:
  while proc.poll() is None and time.monotonic()-started<300:
   text=log.read_text(encoding='utf-8',errors='replace')
   if '*** SERVER STARTED' in text:
    proc.stdin.write('quit\n');proc.stdin.flush();proc.wait(timeout=40);break
   time.sleep(.5)
 finally:
  if proc.poll() is None:proc.terminate();proc.wait(timeout=15)
text=log.read_text(encoding='utf-8',errors='replace')
print('\n'.join(x for x in text.splitlines() if '[ExplosionProbe]' in x or 'version=' in x))
assert '[ExplosionProbe] PASS' in text, 'Native probe failed; inspect native.log'
