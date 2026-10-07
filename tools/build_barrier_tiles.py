import struct
import io
from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "Source/42.20/media"
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
    png = (MEDIA / "textures/OMHTT_ProbeBase.png").read_bytes()
    pack += integer(len(png)) + png
    pack += pack_string("OMHTT_ProbeBase") + integer(1) + integer(1)
    pack += pack_string(SHEET + "_48") + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256)
    png = (MEDIA / "textures/OMHTT_ProbeBase.png").read_bytes()
    pack += integer(len(png)) + png
    return tiles, pack


def build_component(component):
    _, original = build()
    trap = component == "traps"
    sheet = "omhtt_barrier_01" if trap else "omhtt_turret_01"
    count = 52 if trap else 21
    tiles = b"tdef" + integer(1) + integer(1)
    tiles += (sheet + "\nOMHTT_" + component.title() + ".png\n").encode("ascii")
    tiles += integer(4) + integer((count + 3) // 4) + integer(1) + integer(count) + integer(0) * count
    position = 12

    def read_int():
        nonlocal position
        value = struct.unpack_from("<i", original, position)[0]
        position += 4
        return value

    def read_string():
        nonlocal position
        size = read_int()
        value = original[position:position + size].decode("ascii")
        position += size
        return value

    pages = []
    for _ in range(struct.unpack_from("<i", original, 8)[0]):
        name, sub_count, alpha = read_string(), read_int(), read_int()
        entries = []
        for _ in range(sub_count):
            sprite = read_string()
            rectangle = original[position:position + 32]
            position += 32
            index = int(sprite.rsplit("_", 1)[1])
            if (index < 28) == trap:
                entries.append(pack_string(sheet + "_" + str(index if trap else index - 28)) + rectangle)
        size = read_int()
        png = original[position:position + size]
        position += size
        if entries:
            pages.append(pack_string(name) + integer(len(entries)) + integer(alpha) + b"".join(entries) + integer(size) + png)
    assert position == len(original)
    if trap:
        for tier in range(2):
            for heading in range(4):
                page = ("OMHTT_ReinforcedBedSpikes" if tier else "OMHTT_BedSpikes") + str(heading)
                entries = []
                for offset in ([44] if tier else [28, 36]):
                    for part in range(2):
                        entries.append(pack_string(sheet + "_" + str(offset + heading * 2 + part))
                                       + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256))
                png = (MEDIA / "textures" / (page + ".png")).read_bytes()
                pages.append(pack_string(page) + integer(len(entries)) + integer(1) + b"".join(entries) + integer(len(png)) + png)
    return tiles, b"PZPK" + integer(1) + integer(len(pages)) + b"".join(pages)


if __name__ == "__main__":
    tiles, pack = build()
    (MEDIA / "texturepacks").mkdir(exist_ok=True)
    (MEDIA / "OMHTT_Barriers.tiles").write_bytes(tiles)
    (MEDIA / "texturepacks/OMHTT_Barriers.pack").write_bytes(pack)
    print("Packed 49 stable barrier/turret/probe identities; tiledef=" + str(TILEDEF_NUMBER))
