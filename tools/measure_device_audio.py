"""Measure the installed cue mix and create a local-only balanced audition.

Native captures are diagnostic inputs, never shipped or mirrored. Gains are read
from production definitions; no normalization or source WAV editing occurs.
"""
import base64
import io
import json
import math
import re
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / 'Source/42.20/media'


def db(value):
    return round(20 * math.log10(max(value, 1e-10)), 2)


def main():
    lua = (MEDIA / 'lua/shared/OMHTT/ControlAudio.lua').read_text()
    sounds = dict(re.findall(r'(\w+)\s*=\s*"([^"]+)"', lua.split('local sounds = {', 1)[1].split('}', 1)[0]))
    gains = {key: float(value) for key, value in re.findall(r'(\w+)\s*=\s*([.\d]+)', lua.split('local gains = {', 1)[1].split('}', 1)[0])}
    script = (MEDIA / 'scripts/OMHTT_DeviceSounds.txt').read_text()
    clips = {name: float(gain) for name, gain in re.findall(r'file\s*=\s*media/sound/(\w+)\.wav,.*?volume\s*=\s*([.\d]+)', script)}
    records, cards = [], []
    for event, name in sounds.items():
        custom = name in clips
        path = MEDIA / 'sound' / (name + '.wav') if custom else ROOT / 'diagnostics/audio-audition/devices-c390' / (name + '.wav')
        gain = gains.get(event, 1) * clips.get(name, 1)
        with wave.open(str(path), 'rb') as reader:
            assert reader.getsampwidth() == 2
            rate, channels = reader.getframerate(), reader.getnchannels()
            data = np.frombuffer(reader.readframes(reader.getnframes()), '<i2').reshape(-1, channels).astype(float) / 32768
        # Fixed ungained -50 dBFS gate avoids measuring capture tail silence.
        window = int(rate * .05)
        rms = np.array([np.sqrt(np.mean(data[i:i + window] ** 2)) for i in range(0, len(data), window)])
        active = rms[rms > 10 ** (-50 / 20)]
        assert len(active), name + ' is silent'
        peak, active_rms = float(np.max(np.abs(data))), float(np.sqrt(np.mean(active ** 2)))
        assert 0 < gain <= 1 and peak * gain < .999, name
        records.append(dict(event=event, sound=name, gain=gain, attenuation_db=db(gain),
                            raw_peak_dbfs=db(peak), mixed_peak_dbfs=db(peak * gain),
                            raw_active_rms_dbfs=db(active_rms), mixed_active_rms_dbfs=db(active_rms * gain)))
        # Trim capture silence, preserve relative gains, and embed locally.
        audible = np.flatnonzero(np.max(np.abs(data), axis=1) > 10 ** (-65 / 20))
        first, last = max(0, int(audible[0]) - int(rate * .01)), min(len(data), int(audible[-1]) + int(rate * .05))
        buffer = io.BytesIO()
        with wave.open(buffer, 'wb') as writer:
            writer.setnchannels(channels)
            writer.setsampwidth(2)
            writer.setframerate(rate)
            writer.writeframes(np.rint(data[first:last] * gain * 32767).astype('<i2').tobytes())
        encoded = base64.b64encode(buffer.getvalue()).decode()
        cards.append(f'<article><h2>{event.title()}</h2><p>{name} · {db(gain):g} dB</p><audio controls preload="none" src="data:audio/wav;base64,{encoded}"></audio></article>')
    output = ROOT / 'diagnostics/v0.2.62/audio-balance.json'
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(dict(method='50 ms RMS, ungained -50 dBFS active-window gate; native capture at 1 metre, default FMOD parameters; custom raw PCM multiplied by script gain; no in-game loudness acceptance', cues=records), indent=2) + '\n')
    page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>OMH balanced device audio</title>
<style>body{background:#161616;color:#eee;font:16px/1.5 system-ui;max-width:1050px;margin:auto;padding:24px}h1{color:#ef5350}h2{font-size:18px}p{color:#bbb}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px}article{padding:16px;border:1px solid #555;background:#222}audio{width:100%}button{padding:8px 16px}label{display:block;margin:20px 0}</style>
<h1>One More Horde · Balanced device audio</h1><p>Selected cues with the patch gains applied. The reel and shutdown sit beneath the wake alert; laser transitions are balanced together. Originals are unchanged. Native captures use a 1-metre listener; actual spatial mix, simultaneous devices and player settings still need an in-game listen.</p><label>Preview volume <input id="volume" type="range" min="0" max="1" step=".01" value=".35"> <output>35%</output></label><button id="stop">Stop all</button><p>No autoplay. Only one preview plays at a time.</p><div class="grid">''' + ''.join(cards) + '''</div><script>const clips=[...document.querySelectorAll('audio')];for(const a of clips){a.volume=.35;a.onplay=()=>{for(const b of clips)if(a!==b){b.pause();b.currentTime=0}}}document.querySelector('#volume').oninput=e=>{for(const a of clips)a.volume=+e.target.value;document.querySelector('output').textContent=Math.round(e.target.value*100)+'%'};document.querySelector('#stop').onclick=()=>{for(const a of clips){a.pause();a.currentTime=0}};</script></html>'''
    (ROOT / 'art/DEVICE_AUDIO_BALANCED.html').write_text(page, encoding='utf-8')
    print(json.dumps(records, indent=2))


if __name__ == '__main__':
    main()
