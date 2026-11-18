"""Build a local-only sound picker from verified native captures and approved audio."""
import base64
import html
import json
import sys
from pathlib import Path

import numpy as np

from build_firearm_audio import decode, write_wave, run, FFMPEG

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "diagnostics/audio-audition/secondary-effects"
choices = [
    ("4D", "Martyrdom", "Bare-hand impact", "BareHandsHit", "Recommended audition: a compact native hit rather than an explosion."),
    ("4E", "Martyrdom", "Plunger impact", "PlungerHit", "A small melee-impact alternative; judge its character in the preview."),
    ("4F", "Martyrdom", "Wine cork pop", "CorkPopWine", "An alternative small native cork sound."),
    ("4G", "Martyrdom", "Stomp impact", "AttackStomp", "A physical impact candidate."),
    ("4H", "Martyrdom", "Cloth rip", "ZombieRipClothing", "A tearing candidate instead of a blast."),
    ("5B", "Tack", "Metal punch drop", "MetalworkingPunchDrop", "Selected for Tack. Kept here as a reference."),
]
cards = []
records = []
events = {
    "BareHandsHit": "Weapon/Melee/BareHands/Hit",
    "PlungerHit": "Weapon/Melee/BluntShort/Plunger/Hit",
    "CorkPopWine": "Character/Survival/Cooking/CorkPop/Wine",
    "AttackStomp": "Character/Combat/AttackStomp",
    "ZombieRipClothing": "Character/Combat/RipCloth",
    "BloodSplatter": "Character/Combat/BloodSplatter",
    "AerosolBombExplode": "Weapon/Throwable/AerosolBomb/Explode",
    "PipeBombExplode": "Weapon/Throwable/PipeBomb/Explode",
    "BoxOfShellsPlaceAll": "Weapon/Firearm/BoxOfShells/PlaceAll",
    "MetalworkingPunchDrop": "Weapon/Melee/BluntShort/MetalworkingPunch/Drop",
    "DropSoilFromGravelBag": "Character/Survival/Farming/Soil/Drop/FromGravelBag",
}
for code, group, title, name, note in choices:
    if not (RAW / (name + ".wav")).exists() or not (RAW / (name + ".json")).exists():
        run(sys.executable, ROOT / "tools/render_native_shot.py", "event:/" + events[name], RAW / (name + ".wav"))
    samples = decode(RAW / (name + ".wav"))
    active = np.flatnonzero(np.abs(samples) > 10 ** (-75 / 20))
    if not len(active):
        raise RuntimeError("Silent native candidate: " + name)
    first, last = max(0, int(active[0]) - 480), min(len(samples), int(active[-1]) + 2400)
    wave = RAW / (name + "_trim.wav")
    ogg = RAW / (name + ".ogg")
    gain = min(1, .9 / float(np.abs(samples).max()))
    write_wave(wave, samples[first:last] * gain)
    run(FFMPEG, "-v", "error", "-y", "-i", wave, "-c:a", "libvorbis", "-q:a", "4", ogg)
    data = base64.b64encode(ogg.read_bytes()).decode()
    meta = json.loads((RAW / (name + ".json")).read_text())
    records.append({"code": code, "name": name, "event": meta["event"], "seconds": (last-first)/48000, "peak": float(np.abs(samples).max()), "previewGain": gain})
    selection = '<p><strong>Selected: 5B</strong></p>' if group == "Tack" else f'<label><input type="radio" name="{group}" value="{code} — {title}"> Choose {code}</label>'
    cards.append(f'''<article><small>{group} · {code}</small><h2>{title}</h2><p>{note}</p>
<audio controls preload="metadata" src="data:audio/ogg;base64,{data}"></audio>
{selection}<details><summary>Native event</summary><code>{html.escape(meta['event'])}</code></details></article>''')

fragment = base64.b64encode((ROOT / "art/firearm-audio/M9Shoot_layered.ogg").read_bytes()).decode()
page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>OMH — Secondary effect sounds</title><style>
*{box-sizing:border-box}body{margin:0;background:#121515;color:#e5e9e7;font:16px/1.5 system-ui}main{max-width:1100px;margin:auto;padding:32px 24px}h1{font-size:28px;margin:0}h2{font-size:19px;margin:8px 0}p{color:#aebbb5}small{color:#91d4b1}section{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px;margin:22px 0}article,.selection{background:#1d2421;border:1px solid #44594d;border-radius:9px;padding:18px}audio{width:100%;margin:12px 0}label{display:block;cursor:pointer}code{overflow-wrap:anywhere;font-size:12px}details{margin-top:12px;color:#aebbb5}button{padding:10px 14px;border:1px solid #729f83;border-radius:5px;background:#274035;color:white;cursor:pointer}pre{white-space:pre-wrap}#copied{margin-left:10px}input[type=range]{vertical-align:middle} .fragment{max-width:520px}@media(max-width:720px){section{grid-template-columns:1fr}}
</style><main><h1>Secondary effect sounds</h1><p>Five smaller native candidates for Martyrdom. Tack is already selected: 5B, metal punch drop. Previous 4A–4C choices were rejected as too extreme. Playback starts only when you press Play; these are local auditions, not installed changes.</p>
<label>Preview volume <input id="volume" type="range" min="0" max="1" step=".05" value=".5"> <span id="volumeValue">50%</span></label>
<section>''' + "".join(cards) + '''</section>
<article class="fragment"><small>Fragment · requested suppressed pistol</small><h2>Existing suppressed M9 mix</h2><p>Reference for the requested 0.25-second delayed Fragment effect.</p><audio controls preload="metadata" src="data:audio/ogg;base64,''' + fragment + '''"></audio></article>
<p>Timing plan: Martyrdom 0.75 s after death · Tack 0.5 s after impact · Fragment 0.25 s after reaching its endpoint. Playback buttons audition the sound alone. Loud native captures are reduced to prevent preview clipping; final in-game volume is separate.</p>
<div class="selection"><h2>Your selections</h2><pre id="result">Choose one Martyrdom sound above. Tack: 5B.</pre><button id="copy">Copy choices</button><span id="copied" role="status"></span></div>
</main><script>
const tracks=[...document.querySelectorAll('audio')],volume=document.querySelector('#volume');
for(const a of tracks){a.volume=.5;a.addEventListener('play',()=>{for(const b of tracks)if(a!==b)b.pause()})}
volume.oninput=()=>{for(const a of tracks)a.volume=Number(volume.value);document.querySelector('#volumeValue').textContent=Math.round(volume.value*100)+'%'};
function update(){const rows=[...document.querySelectorAll('input[type=radio]:checked')].map(x=>x.value);rows.push('5B — Metal punch drop (Tack)');document.querySelector('#result').textContent=rows.join('\\n')}
for(const radio of document.querySelectorAll('input[type=radio]'))radio.onchange=update;
document.querySelector('#copy').onclick=async()=>{try{await navigator.clipboard.writeText(document.querySelector('#result').textContent);document.querySelector('#copied').textContent='Copied'}catch{document.querySelector('#copied').textContent='Select and copy the text above.'}};
</script></html>'''
(ROOT / "art/EFFECT_AUDIO.html").write_text(page, encoding="utf-8")
(RAW / "audition-validation.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
print(json.dumps(records, indent=2))
