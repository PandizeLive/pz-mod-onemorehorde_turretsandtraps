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


def plate_image(pressed):
    image = Image.new("RGBA", (128, 256))
    draw = ImageDraw.Draw(image)
    height = 1 if pressed else 6
    ground = [(64, 197), (118, 224), (64, 251), (10, 224)]
    top = [(x, y - height) for x, y in ground]
    draw.polygon([top[1], top[2], ground[2], ground[1]], fill=(150, 150, 150), outline=(100, 100, 100))
    draw.polygon([top[2], top[3], ground[3], ground[2]], fill=(185, 185, 185), outline=(100, 100, 100))
    draw.polygon(top, fill=(225, 225, 225), outline=(110, 110, 110))
    return image


def build_component(component):
    _, original = build()
    trap = component == "traps"
    sheet = "omhtt_barrier_01" if trap else "omhtt_turret_01"
    count = 90 if trap else 30
    tiles = b"tdef" + integer(1) + integer(1)
    tiles += (sheet + "\nOMHTT_" + component.title() + ".png\n").encode("ascii")
    tiles += integer(4) + integer((count + 3) // 4) + integer(1) + integer(count)
    plate_first = 80 if trap else 25
    for index in range(count):
        tiles += integer(1) + b"RenderLayer\nFloor\n" if index >= plate_first else integer(0)
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
        entries = [pack_string(sheet + "_" + str(index)) + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256) for index in list(range(28, 52)) + list(range(64, 72))]
        png = (MEDIA / "textures/OMHTT_BedSpikes.png").read_bytes()
        pages.append(pack_string("OMHTT_BedSpikes") + integer(32) + integer(1) + b"".join(entries) + integer(len(png)) + png)
        for axis in range(2):
            marker = Image.new("RGBA", (128, 256))
            draw = ImageDraw.Draw(marker)
            draw.line([(64, 192), (127 if axis == 0 else 1, 224)], fill="white", width=4)
            draw.text((45, 174), "BARB", fill="white")
            stream = io.BytesIO()
            marker.save(stream, format="PNG")
            png = stream.getvalue()
            entries = []
            for edge in ([0, 3] if axis == 0 else [1, 2]):
                dx, dy = ((0, 0) if edge < 2 else ((63, 32) if edge == 2 else (-63, 32)))
                for side in range(2):
                    entries.append(pack_string(sheet + "_" + str(52 + edge * 2 + side))
                                   + struct.pack("<8i", 0, 0, 128, 256, dx, dy, 128, 256))
            pages.append(pack_string("OMHTT_Barb" + str(axis)) + integer(4) + integer(1) + b"".join(entries) + integer(len(png)) + png)
        marker = Image.new("RGBA", (128, 256))
        draw = ImageDraw.Draw(marker)
        draw.polygon([(64, 190), (126, 222), (64, 254), (2, 222)], outline="white", width=3)
        draw.text((48, 215), "WIRE", fill="white")
        stream = io.BytesIO()
        marker.save(stream, format="PNG")
        png = stream.getvalue()
        entry = b"".join(pack_string(sheet + "_" + str(i)) + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256) for i in list(range(60, 64)) + list(range(72, 76)))
        pages.append(pack_string("OMHTT_Wire") + integer(8) + integer(1) + entry + integer(len(png)) + png)
    first = 76 if trap else 21
    png = (MEDIA / "textures/OMHTT_ProbeBase.png").read_bytes()
    entry = b"".join(pack_string(sheet + "_" + str(first + facing)) + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256) for facing in range(4))
    pages.append(pack_string("OMHTT_Controller" + component.title()) + integer(4) + integer(1) + entry + integer(len(png)) + png)
    first = 80 if trap else 25
    for pressed in range(2):
        stream = io.BytesIO()
        plate_image(pressed).save(stream, format="PNG")
        png = stream.getvalue()
        indices = [4] if pressed else range(4)
        entry = b"".join(pack_string(sheet + "_" + str(first + index)) + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256) for index in indices)
        pages.append(pack_string("OMHTT_Plate" + component.title() + str(pressed)) + integer(len(indices)) + integer(1) + entry + integer(len(png)) + png)
    if trap:
        for raised in range(2):
            stream = io.BytesIO()
            marker = plate_image(False)
            if raised:
                marker = marker.transform(marker.size, Image.Transform.AFFINE, (1, 0, 0, 0, 1, 12))
            marker.save(stream, format="PNG")
            png = stream.getvalue()
            indices = [89] if raised else range(85, 89)
            entry = b"".join(pack_string(sheet + "_" + str(index)) + struct.pack("<8i", 0, 0, 128, 256, 0, 0, 128, 256) for index in indices)
            pages.append(pack_string("OMHTT_Poke" + str(raised)) + integer(len(indices)) + integer(1) + entry + integer(len(png)) + png)
    return tiles, b"PZPK" + integer(1) + integer(len(pages)) + b"".join(pages)


if __name__ == "__main__":
    tiles, pack = build()
    (MEDIA / "texturepacks").mkdir(exist_ok=True)
    (MEDIA / "OMHTT_Barriers.tiles").write_bytes(tiles)
    (MEDIA / "texturepacks/OMHTT_Barriers.pack").write_bytes(pack)
    print("Packed 49 stable barrier/turret/probe identities; tiledef=" + str(TILEDEF_NUMBER))
