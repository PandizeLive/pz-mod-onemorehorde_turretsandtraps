import hashlib
import json
from pathlib import Path

import numpy as np

from build_firearm_audio import decode, run, FFMPEG
from build_sound_pitch import expand

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / 'diagnostics/audio-audition/arc-c421'
OUTPUT = ROOT / 'Source/42.20/media/sound/OMHTT_ArcFire.ogg'


def main():
    source = RAW / 'RadioZap_preview.wav'
    meta = json.loads((RAW / 'RadioZap.json').read_text())
    assert meta['event'] == 'event:/Object/Radio/Zap' and meta['playback_state'] in (2, 4)
    run(FFMPEG, '-v', 'error', '-y', '-i', source, '-af', 'volume=14dB', '-c:a', 'libvorbis', '-q:a', '4', OUTPUT)
    sample = decode(OUTPUT)
    assert 0 < len(sample) < 48000 * 3 and 0 < np.abs(sample).max() < 1
    script = ROOT / 'Source/42.20/media/scripts/OMHTT_Sounds.txt'
    text = script.read_text(encoding='utf-8')
    if 'sound OMHTTArcFire' not in text:
        end = text.rfind('}')
        entry = '''    sound OMHTTArcFire
    {
        category = Item,
        maxInstancesPerEmitter = 1,
        clip { file = media/sound/OMHTT_ArcFire.ogg, distanceMax = 35, volume = 1, }
    }
'''
        script.write_text(text[:end] + expand(entry) + text[end:], encoding='utf-8', newline='\n')
    record = dict(selection='S1B', event=meta['event'], game='42.21.0',
                  source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                  output_sha256=hashlib.sha256(OUTPUT.read_bytes()).hexdigest(),
                  seconds=len(sample) / 48000, peak=float(np.abs(sample).max()),
                  rms=float(np.sqrt(np.mean(sample ** 2))), bytes=OUTPUT.stat().st_size,
                  pitch=[.95, 1.05], normalization_db=14, playback_gain=1.3, impact='DismantleFailed', impact_gain=2,
                  impact_limit='Four starts per 100 wall-clock milliseconds per client')
    (ROOT / 'art/ARC_AUDIO_SELECTED.json').write_text(json.dumps(record, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(record))


if __name__ == '__main__':
    main()
