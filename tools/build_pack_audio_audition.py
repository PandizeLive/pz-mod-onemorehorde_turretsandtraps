"""Build local pack sound choices from installed native FMOD events."""
import base64
import html
import json
import sys
from pathlib import Path
import numpy as np
from build_firearm_audio import decode, write_wave, run, FFMPEG

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / 'diagnostics/pack-polish/audio'
RAW.mkdir(parents=True, exist_ok=True)
choices = [
    ('1A', 'Tick', 'Soft highlight', 'UIHighlightMainMenuItem', 'UI/Highlight'),
    ('1B', 'Tick', 'Rotation tick', 'UIObjectMenuObjectRotate', 'UI/ObjectMenu/ObjectRotate'),
    ('1C', 'Tick', 'Button click', 'UIActivateButton', 'UI/Click'),
    ('2A', 'Selected', 'Play confirmation', 'UIActivatePlayButton', 'UI/ClickPlay'),
    ('2B', 'Selected', 'Object pickup', 'UIObjectMenuObjectPickup', 'UI/ObjectMenu/ObjectPickUp'),
    ('2C', 'Selected', 'Object placement', 'UIObjectMenuObjectPlace', 'UI/ObjectMenu/ObjectPlace'),
    ('3A', 'Rarity', 'Native level-up', 'UIAchievement', 'Game/LevelUp'),
    ('3B', 'Rarity', 'Start confirmation', 'UIClickToStart', 'UI/ClickToStart'),
]
cards, records = [], []
for code, group, title, name, event in choices:
    wave = RAW / (name + '.wav')
    if not wave.exists() or not wave.with_suffix('.json').exists():
        run(sys.executable, ROOT / 'tools/render_native_shot.py', 'event:/' + event, wave, '--updates', '3000')
    samples = decode(wave)
    active = np.flatnonzero(np.abs(samples) > 10 ** (-75 / 20))
    if not len(active):
        raise RuntimeError('Silent native candidate: ' + name)
    start, stop = max(0, int(active[0]) - 480), min(len(samples), int(active[-1]) + 2400)
    trimmed, ogg = RAW / (name + '_trim.wav'), RAW / (name + '.ogg')
    gain = min(1, .9 / float(np.abs(samples).max()))
    write_wave(trimmed, samples[start:stop] * gain)
    run(FFMPEG, '-v', 'error', '-y', '-i', trimmed, '-c:a', 'libvorbis', '-q:a', '4', ogg)
    data = base64.b64encode(ogg.read_bytes()).decode()
    records.append({'choice': code, 'sound': name, 'event': event, 'seconds': (stop-start)/48000, 'previewGain': gain})
    cards.append(f'<article><small>{group} · {code}</small><h3>{title}</h3><audio controls preload="metadata" src="data:audio/ogg;base64,{data}"></audio><label><input type="radio" name="{group}" value="{code}"> Choose {code}</label><details><summary>Native sound</summary><code>{html.escape(name)}</code></details></article>')
page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Module Pack · Sound choices</title><style>
*{box-sizing:border-box}body{margin:0;background:#111717;color:#e9eeeb;font:15px/1.5 system-ui}main{max-width:1120px;margin:auto;padding:28px}h1{margin:0}h2{margin-top:30px}p{color:#b7c4be}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}article{border:1px solid #46524c;background:#1c2521;padding:16px}h3{margin:6px 0}small{color:#97c5ac}audio{width:100%;margin:10px 0}button{border:1px solid #719681;background:#235836;color:white;padding:12px 22px;cursor:pointer}label{cursor:pointer}pre{white-space:pre-wrap}.choices{position:sticky;bottom:0;background:#142019f5;border:1px solid #53675b;padding:12px;margin-top:24px;display:flex;justify-content:space-between;align-items:center;gap:12px}.preview{max-width:550px;margin:20px auto;border:1px solid #606060;padding:12px;background:#1b1b1b;font:13px Arial}.preview h3{font-size:16px;margin:0 0 12px}.well{padding:8px;background:#0e0e0e;border:1px solid #444}.reward{position:relative;display:flex;align-items:center;gap:14px;padding:15px;margin:6px 0;border:1px solid color-mix(in srgb,var(--c) 45%,#444);background:color-mix(in srgb,var(--c) 12%,#111);color:color-mix(in srgb,var(--c) 45%,white);overflow:hidden}.cube{font-size:25px;color:#ddd}.reward small{margin-left:auto;color:inherit}.collect{width:100%;margin-top:10px;background:#175b2a;border-color:#729c7b}.pulse{animation:pulse 4s linear}.spark{position:absolute;width:3px;height:3px;left:50%;top:50%;background:var(--c);animation:spark .65s ease-out forwards;pointer-events:none}@keyframes pulse{from{box-shadow:inset 0 0 18px var(--c)}to{box-shadow:none}}@keyframes spark{to{transform:translate(var(--x),var(--y));opacity:0}}@media(max-width:760px){.grid{grid-template-columns:1fr}main{padding:16px}}
</style><main><h1>Module Pack sound choices</h1><p>Native captures from the installed game. Preview only: selecting a sound does not install it. Recommendations: 1A for ticks, 2A for a settled card, and 3C for your own rarity sounds.</p><label>Preview volume <input id="volume" type="range" min="0" max="1" step=".05" value=".35"></label><section class="grid">''' + ''.join(cards) + '''<article><small>Rarity · 3C</small><h3>Custom rarity reveals</h3><p>Your own one-shot sounds, ideally one per tier. Native level-up can feel like an XP reward; custom sounds will distinguish the pack.</p><label><input type="radio" name="Rarity" value="3C"> Choose 3C</label><p>Until supplied: selected cue only.</p></article></section>
<h2>Manage-style layout preview</h2><p>Inset dark panels, restrained rarity tint, and one full-width green Collect button. This previews the settled result, using text placeholders for existing module icons.</p>
<div class="preview"><h3>Module Pack</h3><div class="well"><div class="reward" style="--c:#73ccff"><span class="cube">▣</span><strong>Detection Module</strong><small>Common</small></div><div class="reward" style="--c:#ff9433"><span class="cube">▣</span><strong>Critical Module</strong><small>Epic</small></div><div class="reward" style="--c:#420d82"><span class="cube">▣</span><strong>Synergy Module</strong><small>Mythic</small></div></div><button class="collect" id="collect">Collect</button></div>
<p><button id="particles">Preview four-second rarity pulse</button></p><p>Approved: native rotation ticks (1B), native pickup selection (2B), custom rarity audio pending (3C), pulse only with a four-second fade (4B). One shared tick stream and one selection cue for the pack; no particles. Collect can finish and close early; rewards are already secured before the animation.</p>
<div class="choices"><pre id="selection">Choose 1A–C, 2A–C, and 3A–C.</pre><button id="copy">Copy choices</button></div></main><script>
const tracks=[...document.querySelectorAll('audio')];for(const a of tracks){a.volume=.35;a.onplay=()=>{for(const b of tracks)if(a!==b)b.pause()}}document.querySelector('#volume').oninput=e=>{for(const a of tracks)a.volume=+e.target.value};for(const r of document.querySelectorAll('input[type=radio]'))r.onchange=()=>{document.querySelector('#selection').textContent=[...document.querySelectorAll('input[type=radio]:checked')].map(x=>x.name+': '+x.value).join('\\n')};document.querySelector('#copy').onclick=async()=>{try{await navigator.clipboard.writeText(document.querySelector('#selection').textContent)}catch{document.querySelector('#selection').focus()}};document.querySelector('#collect').onclick=e=>{e.target.textContent='Collected · preview only';setTimeout(()=>e.target.textContent='Collect',1300)};
document.querySelector('#particles').onclick=()=>{for(const row of document.querySelectorAll('.reward')){row.classList.remove('pulse');void row.offsetWidth;if(!matchMedia('(prefers-reduced-motion: reduce)').matches)row.classList.add('pulse')}};
</script></html>'''
(ROOT / 'art/PACK_AUDIO.html').write_text(page, encoding='utf-8')
(RAW.parent / 'audio-evidence.json').write_text(json.dumps(records, indent=2), encoding='utf-8')
print(json.dumps(records, indent=2))
