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
    tiles += integer(4) + integer(13) + integer(1) + integer(49)
    tiles += integer(0) * 49
    pack = b"PZPK" + integer(1) + integer(27)
    for heading in range(4):
        pack += pack_string("OMHTT_Barrier" + str(heading)) + integer(4) + integer(1)
        for index in [heading * 2, heading * 2 + 1, heading * 2 + 8, heading * 2 + 9]:
            pack += pack_string(SHEET + "_" + str(index))
            pack += struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
        png = (MEDIA / "textures" / ("OMHTT_Barrier" + str(heading) + ".png")).read_bytes()
        pack += integer(len(png)) + png
    for heading in range(4):
        pack += pack_string("OMHTT_ReinforcedBarrier" + str(heading)) + integer(2) + integer(1)
        for index in [heading * 2 + 20, heading * 2 + 21]:
            pack += pack_string(SHEET + "_" + str(index))
            pack += struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
        png = (MEDIA / "textures" / ("OMHTT_ReinforcedBarrier" + str(heading) + ".png")).read_bytes()
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
    for facing in range(16):
        page = "OMHTT_Aim" + str(facing)
        pack += pack_string(page) + integer(1) + integer(1)
        pack += pack_string(SHEET + "_" + str(28 + facing))
        pack += struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
        png = (MEDIA / "textures" / (page + ".png")).read_bytes()
        pack += integer(len(png)) + png
    pack += pack_string("OMHTT_TestCube") + integer(4) + integer(1)
    for facing in range(4):
        pack += pack_string(SHEET + "_" + str(44 + facing))
        pack += struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
    png = (MEDIA / "textures/OMHTT_TestCube.png").read_bytes()
    pack += integer(len(png)) + png
    pack += pack_string("OMHTT_ProbeBase") + integer(1) + integer(1)
    pack += pack_string(SHEET + "_48") + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
    png = (MEDIA / "textures/OMHTT_ProbeBase.png").read_bytes()
    pack += integer(len(png)) + png
    return tiles, pack


if __name__ == "__main__":
    tiles, pack = build()
    (MEDIA / "texturepacks").mkdir(exist_ok=True)
    (MEDIA / "OMHTT_Barriers.tiles").write_bytes(tiles)
    (MEDIA / "texturepacks/OMHTT_Barriers.pack").write_bytes(pack)
    print("Packed 49 stable barrier/turret/probe identities; tiledef=" + str(TILEDEF_NUMBER))
