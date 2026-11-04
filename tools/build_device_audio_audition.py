"""Local-only native-device sound audition; never installs game changes."""
import base64
import html
import json
import re
import subprocess
import sys
from pathlib import Path

import numpy as np

from build_firearm_audio import decode, write_wave, run, FFMPEG

ROOT = Path(__file__).resolve().parents[1]
GAME = Path('C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid')
RAW = ROOT / 'diagnostics/audio-audition/devices-c390'
OUT = ROOT / 'art/DEVICE_AUDIO.html'
GROUPS = [
    ('Tether launch', 'A quick mechanical release. These are alternatives, not four layers.', ['SpearCraftedSwing', 'CastFishingLine', 'TrapperCarbineRack', 'MetalworkingPunchSwing']),
    ('Tether impact / pull', 'Choose the impact character; pull can reuse it at lower gain.', ['SpearCraftedStab', 'SpearCraftedHit', 'MetalworkingPunchHit', 'ChairLegNailsHit']),
    ('Tether retraction', 'A phase-bound reel; stop when retraction ends. Long events are bounded excerpts.', ['ReelFishingLineFast', 'ReelFishingLineMedium', 'ReelFishingLineSlow', 'VehicleWindowHandleClose']),
    ('Mechanical reset', 'Possible short cue after the nail or spikes return.', ['M16Rack', 'MSR788Rack', 'MetalworkingPunchDrop', 'CloseMetalToolbox']),
    ('Button / Lever / Plate', 'Button and Lever currently use LightSwitch. Plate has no dedicated press/release cue.', ['LightSwitch', 'KnobSwitch', 'FarmGateLock', 'MetalDoorLock']),
    ('Poke Floor', 'An activation/impact candidate; avoid a loud sound for every nearby zombie every tick.', ['SpearCraftedStab', 'MetalworkingPunchHit', 'ChairLegNailsHit', 'MetalworkingPunchDrop']),
    ('Laser state change', 'Silence is a valid recommendation. If selected, beep on a transition, never continuously.', ['KnobSwitch', 'TrapTimerExpired', 'TelevisionTestBeep', None]),
    ('Rotary movement', 'Optional swing/motor character. Existing contact hits stay separate.', ['BaseballBatSwing', 'AxeSawBladeSwing', 'Sawing', 'VehicleWindowElectricOpen']),
]


def main():
    RAW.mkdir(parents=True, exist_ok=True)
    sounds = {}
    for path in (GAME / 'media/scripts/generated/sounds').rglob('*.txt'):
        text = path.read_text(encoding='utf-8-sig')
        for match in re.finditer(r'\bsound\s+(\w+)\s*\{(.*?)(?=\bsound\s+\w+\s*\{|\Z)', text, re.S):
            event = re.search(r'\bevent\s*=\s*([^,\r\n]+)', match[2])
            if event:
                sounds[match[1]] = ('event:/' + event[1].strip().removeprefix('event:/'), str(path.relative_to(GAME)))
    renderer = (ROOT / 'tools/render_native_shot.py').read_text()
    renderer = renderer.replace('if state.value not in (2, 4):', 'if state.value not in (0, 1, 2, 3, 4):')
    capture = RAW / 'capture_excerpt.py'
    capture.write_text(renderer, encoding='utf-8')
    records, media = [], {}
    names = list(dict.fromkeys(n for _, _, names in GROUPS for n in names if n))
    for name in names:
        event, source = sounds[name]
        wav = RAW / (name + '.wav')
        if not wav.exists() or not wav.with_suffix('.json').exists():
            result = subprocess.run([sys.executable, str(capture), event, str(wav), '--updates', '400'], capture_output=True, text=True)
            if result.returncode:
                raise RuntimeError(name + ': ' + result.stderr)
        data = decode(wav)
        active = np.flatnonzero(np.abs(data) > 10 ** (-65 / 20))
        if not len(active):
            raise RuntimeError('Silent capture: ' + name)
        first, last = max(0, int(active[0]) - 480), min(len(data), int(active[-1]) + 2400)
        last = min(last, first + 48000 * 3)
        gain = min(1, .85 / float(np.abs(data).max()))
        trimmed = data[first:last] * gain
        fade = min(960, len(trimmed) // 4)
        trimmed[-fade:] *= np.linspace(1, 0, fade)
        preview = RAW / (name + '_preview.wav')
        ogg = RAW / (name + '.ogg')
        write_wave(preview, trimmed)
        run(FFMPEG, '-v', 'error', '-y', '-i', preview, '-c:a', 'libvorbis', '-q:a', '4', ogg)
        meta = json.loads(wav.with_suffix('.json').read_text())
        record = dict(name=name, event=event, source=source, seconds=round(len(trimmed) / 48000, 3), gain=gain,
                      parameters=meta['parameters'], ended=meta['playback_state'] in (2, 4))
        records.append(record)
        media[name] = (base64.b64encode(ogg.read_bytes()).decode(), record)
        print(name + ' captured', flush=True)
    sections = []
    for i, (title, note, choices) in enumerate(GROUPS, 1):
        cards = []
        for j, name in enumerate(choices):
            code = 'S' + str(i) + chr(65 + j)
            if name:
                data, record = media[name]
                audio = '<audio controls preload="none" src="data:audio/ogg;base64,' + data + '"></audio>'
                detail = '<details><summary>Native source</summary><code>' + html.escape(record['event']) + '</code><p>' + str(record['seconds']) + ' s preview · ' + ('one-shot' if record['ended'] else 'bounded excerpt; phase/parameters matter') + '</p></details>'
            else:
                name, audio, detail = 'No sound', '<p>Quiet operation with visual feedback.</p>', ''
            cards.append(f'<article><h3>{code} · {name}</h3>{audio}<label><input type="radio" name="g{i}" value="{code} — {title}: {name}"> Select {code}</label>{detail}</article>')
        sections.append(f'<section><h2>{i}. {title}</h2><p>{note}</p><div class="grid">' + ''.join(cards) + '</div></section>')
    page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OMH · Native sound audition</title>
<style>*{box-sizing:border-box}body{margin:0;background:#141414;color:#eee;font:16px/1.5 system-ui}main{max-width:1180px;padding:28px 20px;margin:auto}h1{margin:0}h2{font-size:22px}h3{font-size:16px;overflow-wrap:anywhere}p{color:#bbb}header,.selection{background:#222;border:1px solid #555;padding:20px}strong.brand{color:#ef5350}.grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px}article{background:#202020;border:1px solid #484848;padding:14px}audio{width:100%;height:40px;margin:10px 0}label{cursor:pointer}code{font-size:12px;overflow-wrap:anywhere}details{margin-top:14px;color:#aaa}button{background:#303030;color:white;border:1px solid #888;padding:10px 16px;cursor:pointer}button:focus-visible,input:focus-visible{outline:3px solid #80bfff}section{margin:28px 0}pre{white-space:pre-wrap}textarea{width:100%;background:#141414;color:white;border:1px solid #666;padding:10px}#volume{vertical-align:middle}@media(max-width:850px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:500px){.grid{grid-template-columns:1fr}}</style>
<main><header><strong class="brand">One More Horde</strong><h1>Native sound audition</h1><p>Captured from your installed Zomboid FMOD bank. Local preview only; no game sounds have been changed. Choose any options you like—no choice is required for an optional cue.</p><p>Preview: 1 metre, default event parameters, up to 3 seconds, peak-limited only if necessary. Spatialisation, game volume and event parameters will affect the installed result. No autoplay.</p><label>Volume <input id="volume" type="range" min="0" max="1" step=".05" value=".35"><output id="volumeLabel">35%</output></label> <button id="stop">Stop all</button></header>
''' + ''.join(sections) + '''<section class="selection"><h2>Your choices</h2><pre id="choices">No selections yet.</pre><label>Notes<textarea id="notes" rows="3" placeholder="For example: S3B for retraction, quieter than the impact."></textarea></label><button id="copy">Copy choices</button> <button id="download">Download choices</button><span id="status" role="status"></span></section><p>Existing coverage: firearms and reloads, Potato, Ballista, Scrapshot, Lobber, rotary contacts, Bed Spikes, barbed contact, Lure and secondary effects already have cues. Tether and Poke cycles, Plate transitions and optional rotary motion need review. Laser can remain silent. This page contains native preview audio for local use only.</p></main>
<script>const audio=[...document.querySelectorAll('audio')], radios=[...document.querySelectorAll('input[type=radio]')], notes=document.querySelector('#notes'), output=document.querySelector('#choices');
for(const a of audio){a.volume=.35;a.addEventListener('play',()=>{for(const b of audio)if(a!==b){b.pause();b.currentTime=0}});a.addEventListener('error',()=>{document.querySelector('#status').textContent='Playback failed. Open the downloaded HTML in a browser.'})}
document.querySelector('#volume').oninput=e=>{for(const a of audio)a.volume=Number(e.target.value);document.querySelector('#volumeLabel').textContent=Math.round(e.target.value*100)+'%'};
document.querySelector('#stop').onclick=()=>{for(const a of audio){a.pause();a.currentTime=0}};
function result(){return radios.filter(r=>r.checked).map(r=>r.value).join('\\n')+(notes.value?'\\nNotes: '+notes.value:'')}
function update(){output.textContent=result()||'No selections yet.';try{localStorage.setItem('omhtt-c390-audio',JSON.stringify({choices:radios.filter(r=>r.checked).map(r=>r.value),notes:notes.value}))}catch{}}
try{const saved=JSON.parse(localStorage.getItem('omhtt-c390-audio')||'{}');for(const r of radios)r.checked=(saved.choices||[]).includes(r.value);notes.value=saved.notes||''}catch{}
for(const r of radios)r.onchange=update;notes.oninput=update;update();
document.querySelector('#copy').onclick=async()=>{try{await navigator.clipboard.writeText(result());document.querySelector('#status').textContent=' Copied.'}catch{document.querySelector('#status').textContent=' Select and copy the choices above.'}};
document.querySelector('#download').onclick=()=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([result()],{type:'text/plain'}));a.download='OMH-sound-choices.txt';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000)};
</script></html>'''
    OUT.write_text(page, encoding='utf-8')
    (RAW / 'validation.json').write_text(json.dumps(records, indent=2), encoding='utf-8')
    print(json.dumps(dict(page=str(OUT), candidates=len(records), options=sum(len(x[2]) for x in GROUPS), bytes=OUT.stat().st_size)))


if __name__ == '__main__':
    main()
