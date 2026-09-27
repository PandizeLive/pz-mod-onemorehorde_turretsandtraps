import struct
import io
from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media"
TILEDEF_NUMBER = 7316
SHEET = "omhtt_barrier_01"


def integer(value):
    return struct.pack("<i", value)


def pack_string(value):
    data = value.encode("ascii")
    return integer(len(data)) + data


def build():
    tiles = b"tdef" + integer(1) + integer(1)
    tiles += (SHEET + "\nOMHTT_Barrier.png\n").encode("ascii")
    tiles += integer(4) + integer(5) + integer(1) + integer(20)
    tiles += integer(0) * 20
    pack = b"PZPK" + integer(1) + integer(5)
    for heading in range(4):
        pack += pack_string("OMHTT_Barrier" + str(heading)) + integer(4) + integer(1)
        for index in [heading * 2, heading * 2 + 1, heading * 2 + 8, heading * 2 + 9]:
            pack += pack_string(SHEET + "_" + str(index))
            pack += struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
        png = (MEDIA / "textures" / ("OMHTT_Barrier" + str(heading) + ".png")).read_bytes()
        pack += integer(len(png)) + png
    atlas = Image.new("RGBA", (256, 256))
    draw = ImageDraw.Draw(atlas)
    draw.line([(64, 192), (127, 224)], fill="white", width=3)
    draw.line([(192, 192), (128, 224)], fill="white", width=3)
    png_stream = io.BytesIO()
    atlas.save(png_stream, format="PNG")
    pack += pack_string("OMHTT_Edges") + integer(4) + integer(1)
    for index in range(4):
        pack += pack_string(SHEET + "_" + str(16 + index))
        pack += struct.pack("<8i", index % 2 * 128, 0, 128, 256, 0, 0, 128, 256)
    png = png_stream.getvalue()
    pack += integer(len(png)) + png
    return tiles, pack


if __name__ == "__main__":
    tiles, pack = build()
    (MEDIA / "texturepacks").mkdir(exist_ok=True)
    (MEDIA / "OMHTT_Barriers.tiles").write_bytes(tiles)
    (MEDIA / "texturepacks/OMHTT_Barriers.pack").write_bytes(pack)
    print("Packed 16 unchanged developer arrows and four white collision-edge identities; tiledef=" + str(TILEDEF_NUMBER))
