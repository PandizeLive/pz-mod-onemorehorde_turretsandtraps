from pathlib import Path
import struct,json,io,shutil,re
ROOT=Path.cwd(); GAME=Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid'); CACHE=ROOT/'diagnostics/loot-site/cache'; MAP=GAME/'media/maps/Muldraugh, KY'
headers=[]; tiles=set()
for p in MAP.glob('*.lotheader'):
 f=io.BytesIO(p.read_bytes()); magic=f.read(4)
 if magic!=b'LOTH': f.seek(0)
 def i(): return struct.unpack('<i',f.read(4))[0]
 def line():return f.readline().decode('utf-8').strip()
 version=i(); assert version in [0,1]; palette=[line() for _ in range(i())];tiles.update(palette)
 if version==0:f.read(1)
 width,height=i(),i();assert(width,height)==(8,8)
 lo,hi=(0,i()-1) if version==0 else (i(),i())
 cx,cy=map(int,p.stem.split('_'));rooms=[]
 for n in range(i()):
  name=line();z=i();rects=[[i()+cx*256,i()+cy*256,i(),i()] for _ in range(i())]
  for _ in range(i()): i();i();i()
  rooms.append({'name':name,'z':z,'rects':rects,'index':n})
 # Buildings then 1024 native chunk-density bytes.
 for _ in range(i()):
  for _ in range(i()):i()
 density=list(f.read(1024));assert len(density)==1024,(p,len(density))
 headers.append({'file':p.name,'cx':cx,'cy':cy,'lo':lo,'hi':hi,'tiles':palette,'rooms':rooms,'density':density})
(ROOT/'diagnostics/loot-site/headers.json').write_text(json.dumps(headers,separators=(',',':')))
(CACHE/'Lua').mkdir(parents=True,exist_ok=True);(CACHE/'Lua/loot-tiles.txt').write_text('\n'.join(sorted(tiles)))
server=CACHE/'Server';server.mkdir(exist_ok=True)
for p in (ROOT/'diagnostics/p1c1/server-cache/Server').glob('OMHTT_P1C1*'):
 target=server/p.name.replace('OMHTT_P1C1','OMHTT_LOOT');shutil.copyfile(p,target)
ini=server/'OMHTT_LOOT.ini';text=ini.read_text();text=re.sub(r'^Mods=.*','Mods=OMHTTLootProbe',text,flags=re.M);text=re.sub(r'^DefaultPort=.*','DefaultPort=29171',text,flags=re.M);ini.write_text(text)
mod=CACHE/'mods/OMHTTLootProbe';(mod/'common').mkdir(parents=True,exist_ok=True);(mod/'42/media/lua/server').mkdir(parents=True,exist_ok=True);(mod/'42/mod.info').write_text('name=OMH Local Loot Data Probe\nid=OMHTTLootProbe\nmodversion=1.0.0\n')
print({'headers':len(headers),'rooms':sum(len(h['rooms']) for h in headers),'uniqueTiles':len(tiles),'cache':str(CACHE)})
