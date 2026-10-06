from pathlib import Path
import math

import numpy as np
from PIL import Image, ImageDraw

from build_cube_placeholder import read_export, transformed_faces


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "Source/42.20/media/textures/OMHTT_TestCube.png"


def render(document, binary, seconds, ground_y=224):
    image = Image.new("RGBA", (128, 256), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    view = np.array([1., 1., 1.])
    view /= np.linalg.norm(view)
    faces = transformed_faces(document, binary, seconds, np.zeros(3))
    for face in sorted(faces, key=lambda value: np.dot(value.mean(axis=0), view)):
        normal = np.cross(face[1] - face[0], face[2] - face[0])
        normal /= np.linalg.norm(normal)
        if np.dot(normal, view) <= 0:
            continue
        shade = round(255 * (.76 + .24 * max(0, normal[1])))
        points = [(64 + 50 * (p[0] - p[2]), ground_y + 25 * (p[0] + p[2]) - 60 * p[1]) for p in face]
        draw.polygon(points, fill=(shade, shade, shade, 255))
    return image


def main():
    document, binary = read_export()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    render(document, binary, 0).save(OUTPUT)
    marker("TEST").save(OUTPUT.parent / "OMHTT_Foundation.png")
    for index in range(4):
        marker("BARRIER", index * 4).save(OUTPUT.parent / f"OMHTT_Barrier{index}.png")
    for index in range(16):
        sprite = render(document, binary, index / 4)
        sprite.alpha_composite(marker("POTATO", index, label_y=70))
        sprite.save(OUTPUT.parent / f"OMHTT_Aim{index}.png")
    preview = Image.new("RGBA", (128 * 6, 256), (45, 45, 45, 255))
    names = ["OMHTT_Foundation.png", "OMHTT_Aim0.png"] + [f"OMHTT_Barrier{i}.png" for i in range(4)]
    for index, name in enumerate(names):
        with Image.open(OUTPUT.parent / name) as sprite:
            preview.alpha_composite(sprite, (index * 128, 0))
    preview_path = ROOT / "art/placeholders/dev-markers-preview.png"
    preview.save(preview_path)
    print(f"22 technical sprites, including four barrier arrows; preview: {preview_path}")


def marker(label, facing=None, label_y=176):
    image = Image.new("RGBA", (128, 256), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    diamond = [(64, 195), (122, 224), (64, 253), (6, 224), (64, 195)]
    draw.line(diamond, fill="black", width=6, joint="curve")
    draw.line(diamond, fill="white", width=2, joint="curve")
    if facing is None:
        draw.line([(48, 216), (80, 232)], fill="white", width=4)
        draw.line([(48, 232), (80, 216)], fill="white", width=4)
    else:
        angle = facing * math.pi / 8
        dx, dy = math.cos(angle), -math.sin(angle)
        vx, vy = 25 * (dx - dy), 12.5 * (dx + dy)
        start, end = (64 - vx * .6, 224 - vy * .6), (64 + vx, 224 + vy)
        magnitude = math.hypot(vx, vy)
        ux, uy = vx / magnitude, vy / magnitude
        wings = [(end[0] - 12 * ux + 7 * uy, end[1] - 12 * uy - 7 * ux), end,
                 (end[0] - 12 * ux - 7 * uy, end[1] - 12 * uy + 7 * ux)]
        for color, width in [("black", 9), ("white", 5)]:
            draw.line([start, end], fill=color, width=width)
            draw.line(wings, fill=color, width=width, joint="curve")
    box = draw.textbbox((0, 0), label)
    x = (128 - (box[2] - box[0])) / 2
    draw.text((x, label_y), label, fill="white", stroke_width=2, stroke_fill="black")
    return image


if __name__ == "__main__":
    main()
