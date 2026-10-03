"""Static site/provenance checks. Does not substitute for browser visual acceptance."""
from pathlib import Path
from html.parser import HTMLParser
import hashlib,json,re

root=Path(__file__).resolve().parents[2]
site=root/'art/loot-tuner'
game=Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid')
package=root/'Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media'
sources=[game/'media/maps/Muldraugh, KY/worldmap.xml',game/'media/maps/Muldraugh, KY/worldmap-annotations.lua',
    package/'lua/shared/OMHTT/LootDefinitions.lua',root/'diagnostics/loot-site/cache/Lua/loot-routes.json',
    root/'diagnostics/loot-site/cache/Lua/loot-tile-properties.txt',root/'diagnostics/loot-current-bytecode.txt',package/'sandbox-options.txt']
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
provenance={'gameVersion':'42.21.0','modBaseline':'T&T 0.2.25','scope':'New-world SP estimates matching T&T 0.2.25',
    'sources':[{'path':str(p),'sha256':sha(p),'bytes':p.stat().st_size} for p in sources],
    'dataset':{'sha256':sha(site/'data.js'),'bytes':(site/'data.js').stat().st_size},
    'extraction':json.loads((root/'diagnostics/loot-site/extraction.json').read_text())}
(site/'provenance.json').write_text(json.dumps(provenance,indent=2),encoding='utf-8')
class HTML(HTMLParser):
    def __init__(self):super().__init__();self.ids=[];self.links=[]
    def handle_starttag(self,tag,attrs):
        a=dict(attrs)
        if 'id' in a:self.ids.append(a['id'])
        for key in ['src','href']:
            if key in a:self.links.append(a[key])
p=HTML();p.feed((site/'index.html').read_text(encoding='utf-8'))
assert len(set(p.ids))==len(p.ids),'Duplicate HTML IDs'
for link in p.links:
    if link.startswith('#'):
        assert link[1:] in p.ids,f'Missing anchor: {link}'
        continue
    if link == 'https://admin.onemorehorde.com/admin/LootLab/': continue
    assert not re.match(r'https?://',link),'Unexpected network dependency'
    assert (site/link).is_file(),f'Missing local link: {link}'
app=(site/'app.js').read_text(encoding='utf-8')
for id in re.findall(r"\$\('([^']+)'\)",app):assert id in p.ids,f'Missing DOM element: {id}'
assert 'fetch(' not in app and 'XMLHttpRequest' not in app
assert '0.2.25' in (site/'README.md').read_text(encoding='utf-8')
report={'status':'passed','htmlIds':len(p.ids),'localDependencies':p.links,'sourceHashes':len(sources),'browserVisualReview':'not performed','gameplayInstalled':'0.2.25 approval; installation evidence in docs/RELEASE.md'}
(root/'diagnostics/loot-site/site-checks.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
print(json.dumps(report))
