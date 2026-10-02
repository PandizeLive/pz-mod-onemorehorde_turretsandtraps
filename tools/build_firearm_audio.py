import hashlib
import html
import json
import math
import re
import subprocess
import sys
import wave
import zipfile
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[1]
GAME = Path("C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid")
FFMPEG = Path("C:/Program Files/ShareX/ffmpeg.exe")
OUT = ROOT / "art/firearm-audio"
RAW = ROOT / "diagnostics/audio-audition"
LAYER = ROOT.parent / "Audio/Turrets & Traps/suppressed_shot.wav"
RATE = 48000
TIMES = [0, 0.04, 0.09, 0.18, 0.69]
WET = [0, 1, 1, 0.25, 0]
REFERENCE_RMS = None
FAMILIES = [
    ("Light handgun / SMG", "M9Shoot", "Pistol-calibre automatics and ordinary semi-auto pistols. One sample per shot; cadence stays weapon-specific."),
    ("Heavy handgun", "DesertEagleShoot", "Heavy semi-auto handguns, especially .44-class weapons."),
    ("Revolver", "M625Shoot", "Ordinary revolvers; use MagnumShoot as an exact override for heavy magnums."),
    ("Shotgun", "JS2000ShotgunShoot", "Full-length pump, semi-auto and double-barrel shotguns."),
    ("Short shotgun", "SawnOffJS2000ShotgunShoot", "Sawn-off and compact shotguns."),
    ("Assault rifle / light machine gun", "M16Shoot", "Intermediate-cartridge automatics. Looping bursts are not baked into the sample."),
    ("Battle rifle / machine gun", "M14Shoot", "Full-power rifle-cartridge automatics and semi-autos."),
    ("Bolt-action / precision rifle", "MSR788Shoot", "Full-power bolt-action and precision rifles. Reload/bolt sounds stay separate."),
    ("Lever-action / pistol-calibre carbine", "L92Shoot", "Lever actions and pistol-calibre carbines; L94Shoot is available for a rifle-calibre override."),
]


def run(*args):
    result = subprocess.run([str(x) for x in args], capture_output=True)
    if result.returncode:
        raise RuntimeError(result.stderr.decode("utf-8", errors="replace"))
    return result


def decode(path):
    layout = ["-ac", "1"] if path.suffix == ".ogg" else ["-af", "pan=mono|c0=0.5*c0+0.5*c1"]
    raw = run(FFMPEG, "-v", "error", "-i", path, *layout, "-f", "f64le", "-ar", RATE, "pipe:1").stdout
    return np.frombuffer(raw, dtype="<f8").copy()


def write_wave(path, values):
    assert np.isfinite(values).all() and np.max(np.abs(values)) < 1
    with wave.open(str(path), "wb") as stream:
        stream.setnchannels(1)
        stream.setsampwidth(2)
        stream.setframerate(RATE)
        stream.writeframes(np.rint(values * 32767).astype("<i2").tobytes())


def lowpass(values):
    result = values.copy()
    omega = 2 * math.pi * 250 / RATE
    c = math.cos(omega)
    for q in (0.5097955791, 0.6013448869, 0.8999762231, 2.5629154477):
        alpha = math.sin(omega) / (2 * q)
        a0 = 1 + alpha
        b0, b1, b2 = (1 - c) / (2 * a0), (1 - c) / a0, (1 - c) / (2 * a0)
        a1, a2 = -2 * c / a0, (1 - alpha) / a0
        z1 = z2 = 0.0
        for i, value in enumerate(result):
            output = b0 * value + z1
            z1, z2 = b1 * value - a1 * output + z2, b2 * value - a2 * output
            result[i] = output
    return result


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inventory():
    names = json.loads((GAME / "media/lua/shared/Translate/EN/ItemName.json").read_text(encoding="utf-8-sig"))
    sounds = {}
    for path in (GAME / "media/scripts/generated/sounds").rglob("*.txt"):
        for name, event in re.findall(r"\bsound\s+(\w+)\s*\{.*?\bevent\s*=\s*([^,\n]+)", path.read_text(encoding="utf-8-sig"), re.S):
            sounds[name] = {"event": "event:/" + event.strip(), "script": str(path.relative_to(GAME))}
    rows = []
    for path in (GAME / "media/scripts/generated/items").rglob("*.txt"):
        for name, body in re.findall(r"\bitem\s+(\w+)\s*\{(.*?)\n    \}", path.read_text(encoding="utf-8-sig"), re.S):
            data = dict(re.findall(r"^\s*(\w+)\s*=\s*([^,\n]+)", body, re.M))
            if data.get("IsAimedFirearm") != "true":
                continue
            sound = data["SwingSound"]
            rows.append({"item": "Base." + name, "name": names.get("Base." + name, name), "sound": sound,
                         "ammo": data.get("AmmoType"), "toy": "base:fakeweapon" in data.get("Tags", ""),
                         **sounds[sound], "item_script": str(path.relative_to(GAME))})
    return rows


def build_asset(sound, event, layer, source=None):
    raw = source or RAW / (sound + ".wav")
    meta = raw.with_suffix(".json")
    if source is None and (not raw.exists() or not meta.exists()):
        run(sys.executable, "-X", "utf8", ROOT / "tools/render_native_shot.py", event, raw)
    capture = decode(raw)
    active = np.flatnonzero(np.abs(capture) > 10 ** (-80 / 20))
    if len(active) == 0 or (source is None and active[-1] > len(capture) - RATE // 4):
        raise RuntimeError(f"Silent or truncated event: {sound}")
    first = max(0, int(active[0]) - 96)
    last = min(len(capture), int(active[-1]) + 960)
    dry = capture[first:last].copy()
    dry[-240:] *= np.linspace(1, 0, 240)
    if len(dry) < len(layer):
        dry = np.pad(dry, (0, len(layer) - len(dry)))
    wet = np.interp(np.arange(len(dry)) / RATE, TIMES, WET)
    filtered = dry * (1 - wet) + lowpass(dry) * wet
    level = float(np.sqrt(np.mean(filtered[:len(layer)] ** 2)))
    layer_gain = level / REFERENCE_RMS
    overlay = np.pad(layer * layer_gain, (0, len(dry) - len(layer)))
    combined = filtered + overlay
    originals = {"dry": dry, "filtered": filtered, "layered": combined}
    gain = min(1.0, 0.95 / max(float(np.max(np.abs(v))) for v in originals.values()))
    for attempt in range(4):
        variants = {kind: values * gain for kind, values in originals.items()}
        assert np.max(np.abs((variants["layered"] - variants["filtered"]) - overlay * gain)) < 1e-12
        files = {}
        for kind, values in variants.items():
            wav_path = OUT / f"{sound}_{kind}.wav" if kind == "layered" else RAW / f"{sound}_{kind}.wav"
            ogg_path = OUT / f"{sound}_{kind}.ogg"
            write_wave(wav_path, values)
            run(FFMPEG, "-v", "error", "-y", "-i", wav_path, "-c:a", "libvorbis", "-q:a", "4", ogg_path)
            decoded = decode(ogg_path)
            peak = float(np.max(np.abs(decoded)))
            if abs(len(decoded) - len(values)) > 1024:
                raise RuntimeError(f"Encoded duration mismatch: {ogg_path.name}")
            files[kind] = {"file": ogg_path.name, "bytes": ogg_path.stat().st_size, "sha256": sha(ogg_path), "decoded_peak": peak}
        maximum = max(record["decoded_peak"] for record in files.values())
        if maximum < 0.99:
            break
        gain *= 0.90 / maximum
    else:
        raise RuntimeError(f"Unable to encode without clipping: {sound}")
    if gain < 1:
        print(f"{sound}: common clipping-prevention gain {gain:.4f}", flush=True)
    return {"sound": sound, "event": event, "seconds": len(dry) / RATE, "leading_trim_seconds": first / RATE,
            "common_headroom_gain": gain, "layer_gain": layer_gain, "layer_gain_db": 20 * math.log10(layer_gain),
            "raw_sha256": sha(raw), "render": json.loads(meta.read_text()) if source is None else {"owner_source": str(source)}, "files": files,
            "wav": sound + "_layered.wav", "wav_sha256": sha(OUT / (sound + "_layered.wav"))}


def build_page(manifest):
    escape = html.escape
    assets = manifest["assets"]
    families = []
    for title, sound, note in FAMILIES:
        source_name = next(row["name"] for row in manifest["weapons"] if row["sound"] == sound)
        families.append(f'<tr><td>{escape(title)}</td><td><a href="#{sound}">{escape(source_name)}</a></td><td>{escape(note)}</td>'
                        f'<td><button data-play="firearm-audio/{sound}_layered.ogg">Play</button></td></tr>')
    cards = []
    for asset in sorted(assets, key=lambda a: (all(w["toy"] for w in manifest["weapons"] if w["sound"] == a["sound"]), a["sound"])):
        sound = asset["sound"]
        weapons = [row for row in manifest["weapons"] if row["sound"] == sound]
        title = " / ".join(row["name"] for row in weapons)
        ids = ", ".join(row["item"] for row in weapons)
        tag = "Toy · completeness only" if all(row["toy"] for row in weapons) else "Native firearm"
        size = asset["files"]["layered"]["bytes"] / 1024
        controls = "".join(f'<button data-play="firearm-audio/{sound}_{mode}.ogg">{label}</button>'
                           for mode, label in [("dry", "Original"), ("filtered", "Filtered"), ("layered", "Filtered + layer")])
        gain = asset["common_headroom_gain"]
        gain_note = f" · layer {asset['layer_gain_db']:+.1f} dB"
        if gain < 1:
            gain_note += f" · common headroom gain {gain:.3f}"
        cards.append(f'<article id="{sound}" data-search="{escape((title + ids + sound).lower())}"><span class="tag">{tag}</span>'
                     f'<h3>{escape(title)}</h3><p class="technical">{escape(ids)}<br>{escape(asset["event"])}</p>'
                     f'<p>{asset["seconds"]:.2f}s · {size:.1f} KiB OGG{gain_note}</p><div>{controls}</div>'
                     f'<p><a download href="firearm-audio/{sound}_layered.ogg">Download OGG</a> · '
                     f'<a download href="firearm-audio/{sound}_layered.wav">Download WAV</a></p></article>')
    real_assets = [a for a in assets if any(not w["toy"] and w["sound"] == a["sound"] for w in manifest["weapons"])]
    payload = sum(a["files"]["layered"]["bytes"] for a in real_assets)
    template = (ROOT / "tools/firearm_audio_template.html").read_text()
    replacements = {"{{FAMILIES}}": "".join(families), "{{CARDS}}": "".join(cards),
                    "{{PAYLOAD}}": f"{payload / 1024:.1f} KiB", "{{TOTAL}}": f"{sum(a['files']['layered']['bytes'] for a in assets) / 1024:.1f} KiB"}
    for key, value in replacements.items():
        template = template.replace(key, value)
    (ROOT / "art/FIREARM_AUDIO.html").write_text(template, encoding="utf-8")
    return payload


def build_download(manifest):
    mapping = {"weapons": manifest["weapons"], "families": manifest["families"],
               "files": {a["sound"]: a["files"]["layered"]["file"] for a in manifest["assets"]},
               "status": "Audio library used by 0.2.22; firearm adapters remain limited to the three supported heads"}
    with zipfile.ZipFile(ROOT / "art/firearm-audio-layered.zip", "w", zipfile.ZIP_DEFLATED) as archive:
        for asset in manifest["assets"]:
            path = OUT / asset["files"]["layered"]["file"]
            archive.write(path, path.name)
        archive.writestr("mappings.json", json.dumps(mapping, indent=2))
        archive.writestr("README.txt", "Local audition set. Current installed native events, filtered plus the owner's unfiltered overlay.\nMono 48kHz OGG Vorbis quality 4. Includes 18 firearm events and 2 cap-gun events.\nFamily recommendations reuse these files; no duplicated family files. Not an installable mod.\n")


def main():
    global REFERENCE_RMS
    OUT.mkdir(exist_ok=True)
    RAW.mkdir(parents=True, exist_ok=True)
    weapons = inventory()
    layer = decode(LAYER)
    reference_path = RAW / "JS14Shoot.wav"
    if not reference_path.exists() or not reference_path.with_suffix(".json").exists():
        reference_event = next(row["event"] for row in weapons if row["sound"] == "JS14Shoot")
        run(sys.executable, "-X", "utf8", ROOT / "tools/render_native_shot.py", reference_event, reference_path)
    reference = decode(reference_path)
    active = np.flatnonzero(np.abs(reference) > 0.0001)
    reference = reference[max(0, int(active[0]) - 96):]
    wet = np.interp(np.arange(len(reference)) / RATE, TIMES, WET)
    reference = reference * (1 - wet) + lowpass(reference) * wet
    REFERENCE_RMS = float(np.sqrt(np.mean(reference[:len(layer)] ** 2)))
    assets = []
    for sound in sorted({row["sound"] for row in weapons}):
        event = next(row["event"] for row in weapons if row["sound"] == sound)
        assets.append(build_asset(sound, event, layer))
        print(sound + " ready", flush=True)
    manifest = {"status": "Approved 0.2.22 audio library; player playback acceptance pending", "game_build": "42.21.0",
                "source": str(GAME), "bank_sha256": sha(GAME / "media/sound/banks/Desktop/ZomboidSound.bank"),
                "overlay": str(LAYER), "overlay_sha256": sha(LAYER), "rate": RATE, "channels": 1,
                "layer_balance": {"reference": "JS14Shoot", "window_seconds": len(layer) / RATE, "filtered_rms": REFERENCE_RMS},
                "filter": {"cutoff_hz": 250, "slope_db_per_octave": 48, "times": TIMES, "wet": WET},
                "encoding": "OGG Vorbis quality 4; mono 48 kHz; PCM16 WAV masters",
                "weapons": weapons, "assets": assets, "families": FAMILIES}
    manifest["proposed_real_firearm_payload_bytes"] = build_page(manifest)
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    build_download(manifest)
    potatoes = [build_asset("OMHTTPotato" + str(i), "owner", layer, LAYER.parent / ("potato_thump_" + str(i) + ".wav")) for i in (1, 2)]
    (OUT / "potato-balanced.json").write_text(json.dumps(potatoes, indent=2), encoding="utf-8")
    print(json.dumps({"weapons": len(weapons), "unique_events": len(assets),
                      "proposed_real_firearm_payload_bytes": manifest["proposed_real_firearm_payload_bytes"]}))


if __name__ == "__main__":
    main()
