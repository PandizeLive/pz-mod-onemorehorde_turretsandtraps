"""Compare captured native shots with current Arc gain; diagnostic, no asset edits."""
import json,math,re
from pathlib import Path
import numpy as np
from build_firearm_audio import decode
ROOT=Path(__file__).resolve().parents[1]
def main():
    media=ROOT/'Source/42.20/media'
    samples=[('Arc Shot',media/'sound/OMHTT_ArcFire.ogg',1.3),('Arc Impact',ROOT/'diagnostics/audio-audition/arc-c421/DismantleFailed_preview.wav',2),('M9 Shot',ROOT/'diagnostics/audio-audition/M9Shoot.wav',1),('M16 Shot',ROOT/'diagnostics/audio-audition/M16Shoot.wav',1),('Ballista Shot',ROOT/'diagnostics/audio-audition/devices-c390/SpearCraftedSwing.wav',1)]
    rows=[]
    for name,path,gain in samples:
        samples=decode(path)
        windows=np.array([np.sqrt(np.mean(samples[i:i+2400]**2)) for i in range(0,len(samples),2400)])
        active=windows[windows>10**(-50/20)]
        peak=float(np.max(np.abs(samples)))*gain
        rms=float(np.sqrt(np.mean(active**2)))*gain
        rows.append({'cue':name,'gain':gain,'peakDbFS':round(20*math.log10(peak),2),'activeRmsDbFS':round(20*math.log10(rms),2)})
    version=re.search(r'modversion=(.+)',(ROOT/'Source/42.20/mod.info').read_text())[1].strip()
    result={'method':'Captured native cues, 50ms active RMS above -50dBFS; current playback gains. Spatial perception requires owner listening.','cues':rows}
    (ROOT/f'diagnostics/v{version}/audio-balance.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result))
if __name__=='__main__':main()
