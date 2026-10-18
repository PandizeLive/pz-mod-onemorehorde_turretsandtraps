from pathlib import Path
from sync_defaults import apply_defaults
import json,struct,collections,xml.etree.ElementTree as ET,re,hashlib
r=Path.cwd(); game=Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid'); mp=game/'media/maps/Muldraugh, KY'
headers=json.loads((r/'diagnostics/loot-site/headers.json').read_text()); source=json.loads((r/'diagnostics/loot-site/cache/Lua/loot-routes.json').read_text());props={}
for line in (r/'diagnostics/loot-site/cache/Lua/loot-tile-properties.txt').read_text().splitlines():
 tile,kind,capacity=line.split('\t');props[tile]=(kind,capacity)
bytecode=(r/'diagnostics/loot-current-bytecode.txt').read_text()
banblock=bytecode.split('initNoGenericLootContainers();')[1].split('public static')[0]
banned={name.lower().replace('_','') for name in re.findall(r'ContainerType\.([A-Z_]+):',banblock)}
routes=source['routes'];lookup={(route['room'],route['container']):n for n,route in enumerate(routes)};roomNames=set(x[0] for x in lookup);containers=[];failed=[];scanned=0
for h in headers:
 eligible=[room for room in h['rooms'] if room['name'] in roomNames]
 if not eligible:continue
 if not any(tile in props for tile in h['tiles']):continue
 p=mp/f"world_{h['cx']}_{h['cy']}.lotpack";data=p.read_bytes();version=struct.unpack_from('<i',data,4)[0] if data[:4]==b'LOTP' else 0
 assert version in [0,1]
 chunks=set();rectgrid={}
 for room in eligible:
  for x,y,w,hh in room['rects']:
   for cx in range(x//8,(x+w-1)//8+1):
    for cy in range(y//8,(y+hh-1)//8+1):
     chunks.add((cx,cy));rectgrid.setdefault((cx,cy,room['z']),[]).append(room)
 for cx,cy in chunks:
  lx,ly=cx-h['cx']*32,cy-h['cy']*32
  if not(0<=lx<32 and 0<=ly<32):continue
  offset=struct.unpack_from('<i',data,(8 if version else 0)+4+(lx*32+ly)*8)[0]
  if offset<=0:continue
  pos=offset;skip=0;scanned+=1
  for z in range(max(-32,h['lo']),min(31,h['hi'])+1):
   for dx in range(8):
    for dy in range(8):
     if skip:skip-=1;continue
     count=struct.unpack_from('<i',data,pos)[0];pos+=4
     if count==-1:
      skip=struct.unpack_from('<i',data,pos)[0];pos+=4
      if skip:skip-=1;continue
     if count<=1:continue
     roomIndex=struct.unpack_from('<i',data,pos)[0];pos+=4
     ids=struct.unpack_from('<'+'i'*(count-1),data,pos);pos+=(count-1)*4
     x,y=cx*8+dx,cy*8+dy
     candidates=rectgrid.get((cx,cy,z),[])
     if not candidates:continue
     room=next((v for v in candidates if any(rx<=x<rx+w and ry<=y<ry+hh for rx,ry,w,hh in v['rects'])),None)
     if room is None:continue
     names=[]
     for idx in ids:
      assert 0<=idx<len(h['tiles']),(p,idx,len(h['tiles']))
      names.append(h['tiles'][idx])
     for tile in names:
      if tile not in props:continue
      kind,cap=props[tile];route=lookup.get((room['name'],kind))
      if route is None and kind not in banned and kind not in source['explicit'].get(room['name'],{}):route=lookup.get((room['name'],'other'))
      if route is None:continue
      forced=[]
      for rule in routes[route]['rules']:
       if rule.get('forceForTiles') and any(t in rule['forceForTiles'].split(';') for t in names):forced=[rule['name']]
      containers.append({'x':x,'y':y,'z':z,'route':route,'room':f"{h['cx']}_{h['cy']}_{room['index']}",'tile':tile,'type':kind,'capacity':cap,'density':h['density'][lx+ly*32],'forced':forced})
# Repeated room rectangles overlap; a physical sprite on a square is counted once.
unique={ (c['x'],c['y'],c['z'],c['tile']):c for c in containers};containers=list(unique.values())
geometry=[];bounds=[1e9,1e9,-1e9,-1e9]
for cell in ET.parse(mp/'worldmap.xml').getroot().findall('cell'):
 cx,cy=int(cell.get('x'))*300,int(cell.get('y'))*300
 for f in cell.findall('feature'):
  tags={p.get('name'):p.get('value') for p in f.findall('properties/property')}
  kind='water' if 'water' in tags else 'road' if 'highway' in tags else 'building' if 'building' in tags else None
  if kind is None:continue
  coords=[]
  for ring in f.findall('geometry/coordinates'):
   points=[[int(p.get('x'))+cx,int(p.get('y'))+cy] for p in ring.findall('point')]
   for x,y in points:bounds=[min(bounds[0],x),min(bounds[1],y),max(bounds[2],x),max(bounds[3],y)]
   if points:coords.append(points)
  if coords:geometry.append([kind,coords])
labels=[];texts={}
for f in (game/'media/lua/shared/Translate/EN').glob('*.json'):
 if f.name in ['IG_UI.json','UI.json','IGUI.json']:
  texts.update(json.loads(f.read_text(encoding='utf-8-sig')))
for key,style,x,y in re.findall(r'addUntranslatedText\("([^"]+)", "([^"]+)", (\d+), (\d+)\)',(mp/'worldmap-annotations.lua').read_text()):
 if 'town' in style or 'city' in style:labels.append([texts.get(key,key.replace('MapLabel_','')),int(x),int(y)])
package=r/'Contents/mods/OneMoreHorde_Turrets/42.20'
version=re.search(r'^modversion=(.+)$',(package/'mod.info').read_text(),re.M)[1].strip()
weights=source['definitions']['WEIGHTS']
for pool in source['pools']:
 subset=source['definitions']['SUBSETS'].get(pool)
 source['pools'][pool]['scale']=source['definitions']['SCALES'][pool]
 source['pools'][pool]['modules']=[k for k in weights if subset is None or subset.get(k)]
names={'MotionDetection':'Detection','Detection360':'360','RapidFire':'Rapid-Fire','CapacitySmall':'Small Expansion Kit','Capacity':'Medium Expansion Kit','CapacityLarge':'Large Expansion Kit','InitialBlow':'Initial Blow','FiringEnhanced':'Enhanced Firing','MotionDetectionEnhanced':'Enhanced Detection'}
order=['Firing','MotionDetection','Filter','Detection360','Suppression','RapidFire','Reload','Velocity','Range','CapacitySmall','Capacity','CapacityLarge','Autoloader','Critical','Accuracy','Magazine','Splitter','Fragment','FiringEnhanced','MotionDetectionEnhanced','Piercing','InitialBlow','Execute','Impact','Conservation','Synergy','Martyrdom','Tack','Regulator','Siphon','Lure','Void']
assert set(order)==set(weights)
modules=[{'id':k,'name':names.get(k,k),'weight':weights[k]} for k in order]
report={'game':'42.21.0','baseline':'T&T '+version,'previousBaselines':['Installed 0.2.22','T&T 0.2.23','T&T 0.2.24','T&T 0.2.25',*[f'T&T 0.2.{i}' for i in range(26,54)]],'headers':len(headers),'roomRecords':sum(len(h['rooms']) for h in headers),'routes':len(routes),'containerSprites':len(props),'chunksScanned':scanned,'eligibleContainers':len(containers),'mapFeatures':len(geometry),'genericExclusions':sorted(banned),'byRoom':dict(collections.Counter(routes[c['route']]['room'] for c in containers)),'byContainer':dict(collections.Counter(c['type'] for c in containers))}
out={'meta':report,'routes':routes,'pools':source['pools'],'containers':containers,'map':geometry,'bounds':bounds,'labels':labels,'modules':modules}
apply_defaults(out)
(r/'art/loot-tuner/data.js').write_text('window.LOOT_DATA='+json.dumps(out,separators=(',',':'))+';\n')
(r/'diagnostics/loot-site/extraction.json').write_text(json.dumps(report,indent=2));print(json.dumps(report))
