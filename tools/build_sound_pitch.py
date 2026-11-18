import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOUND = re.compile(r'(\bsound\s+\w+\s*\{)((?:[^{}]|\bclip\s*\{[^{}]*\})*)(\})')
CLIP = re.compile(r'clip\s*\{([^{}]*)\}')


def expand(text):
    def sound(match):
        seen = set()

        def clip(found):
            fields = [field.strip() for field in found[1].split(',') if field.strip()]
            fields = tuple(field for field in fields if field.split('=', 1)[0].strip() != 'pitch')
            if fields in seen:
                return ''
            seen.add(fields)
            body = ', '.join(fields)
            return '\n        '.join(f'clip {{ {body}, pitch = {pitch / 1000:.3f}, }}' for pitch in range(950, 1051))

        body = CLIP.sub(clip, match[2])
        body = re.sub(r'\n(?:[ \t]*\n)+', '\n', body)
        return match[1] + body + match[3]

    return SOUND.sub(sound, text)


def build(check=False):
    for filename in ('OMHTT_Sounds.txt', 'OMHTT_SuppressionSounds.txt'):
        path = ROOT / 'Source/42.20/media/scripts' / filename
        original = path.read_text(encoding='utf-8')
        result = expand(original)
        if check:
            assert result == original, f'Stale native pitch clips: {filename}'
        else:
            path.write_text(result, encoding='utf-8', newline='\n')


if __name__ == '__main__':
    build()
