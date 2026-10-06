from pathlib import Path
import subprocess,time,shutil
r=Path.cwd();game=Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid');cache=r/'diagnostics/loot-site/cache';log=r/'diagnostics/loot-site/export.log'
probe=cache/'mods/OMHTTLootProbe/42/media/lua/server'
(probe/'OMHTT').mkdir(parents=True,exist_ok=True)
shutil.copyfile(r/'tools/loot_site/export.lua',probe/'OMHTTLootExport.lua')
shutil.copyfile(r/'Contents/mods/OneMoreHorde_Turrets/42.20/media/lua/shared/OMHTT/LootDefinitions.lua',probe/'OMHTT/LootDefinitions.lua')
cmd=[str(game/'jre64/bin/java.exe'),'--enable-native-access=ALL-UNNAMED','--add-exports=java.base/jdk.internal.misc=ALL-UNNAMED','-Xmx1536m','-Djava.library.path=./natives/;./natives/win64/;./','-cp','projectzomboid.jar;.','zombie.network.GameServer','-cachedir='+str(cache),'-servername','OMHTT_LOOT','-nosteam','-ip','127.0.0.1','-port','29171','-adminpassword','local-loot-probe-only']
with log.open('w') as f:
 p=subprocess.Popen(cmd,cwd=game,stdin=subprocess.PIPE,stdout=f,stderr=subprocess.STDOUT,text=True,creationflags=subprocess.CREATE_NO_WINDOW)
 try:
  start=time.monotonic()
  while p.poll() is None and time.monotonic()-start<160:
   text=log.read_text(errors='replace')
   if '[OMHTT-LOOT] export-complete' in text:
    p.stdin.write('quit\n');p.stdin.flush();p.wait(timeout=40);print(text[text.index('[OMHTT-LOOT] export-complete'):].splitlines()[0]);break
   if 'OMHTTLootExport.lua:' in text: raise RuntimeError('Export failed; inspect log')
   time.sleep(.3)
  else:raise RuntimeError('Export did not complete')
 finally:
  if p.poll() is None:p.terminate();p.wait(timeout=20)
