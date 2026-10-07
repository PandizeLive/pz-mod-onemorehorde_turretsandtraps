from pathlib import Path
from PIL import Image, ImageDraw

MEDIA = Path(__file__).resolve().parents[1] / "Source/42.20/media/textures"


def build():
    for reinforced in (False, True):
        prefix = "OMHTT_ReinforcedBedSpikes" if reinforced else "OMHTT_BedSpikes"
        for heading, direction in enumerate(((24, 12), (24, -12), (-24, -12), (-24, 12))):
            image = Image.new("RGBA", (128, 256))
            draw = ImageDraw.Draw(image)
            draw.polygon(((8, 214), (64, 186), (120, 214), (64, 242)), fill=(230, 230, 230, 255), outline="white")
            draw.polygon(((8, 214), (64, 242), (64, 247), (8, 219)), fill=(155, 155, 155, 255))
            draw.polygon(((64, 242), (120, 214), (120, 219), (64, 247)), fill=(190, 190, 190, 255))
            dx, dy = direction
            end = (64 + dx, 213 + dy)
            draw.line(((64 - dx / 2, 213 - dy / 2), end), fill="black", width=3)
            draw.line((end, (end[0] - dx / 3 - dy / 3, end[1] - dy / 3 + dx / 3)), fill="black", width=2)
            draw.line((end, (end[0] - dx / 3 + dy / 3, end[1] - dy / 3 - dx / 3)), fill="black", width=2)
            draw.text((42, 191), "BED R" if reinforced else "BED", fill="black")
            image.save(MEDIA / f"{prefix}{heading}.png")
            if heading == 0:
                image.crop((4, 180, 124, 252)).resize((60, 36)).save(MEDIA / f"Item_{prefix}.png")


if __name__ == "__main__":
    build()
