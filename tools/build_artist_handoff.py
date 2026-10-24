"""Export owned assets and plain, labeled development markers for artist review.

Does not edit Source/Contents or install a mod. Identical payloads have one
canonical file; manifest aliases preserve their original paths and sprite IDs.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import math
import re
import struct
import zipfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

from build_cube_placeholder import cube_mesh

ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "Source/42.20/media"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def json_text(value):
    return json.dumps(value, indent=2, ensure_ascii=False) + "\n"


class Export:
    def __init__(self, destination):
        self.destination = destination
        self.records = []
        self.hashes = {}

    def add(self, data, relative, source, **metadata):
        digest = sha(data)
        canonical = self.hashes.get(digest)
        if canonical is None:
            canonical = relative
            path = self.destination / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(data)
            self.hashes[digest] = canonical
        self.records.append(dict(source=source, file=canonical, sha256=digest,
                                 bytes=len(data), **metadata))
        return canonical


def unpack_pages(path, export):
    data = path.read_bytes()
    offset = 4

    def integer():
        nonlocal offset
        result, = struct.unpack_from("<i", data, offset)
        offset += 4
        return result

    def string():
        nonlocal offset
        count = integer()
        result = data[offset:offset + count].decode("ascii")
        offset += count
        return result

    assert data[:4] == b"PZPK" and integer() == 1
    pages = []
    for _ in range(integer()):
        name, count, alpha = string(), integer(), integer()
        sprites = []
        for _ in range(count):
            sprite = string()
            geometry = [integer() for _ in range(8)]
            sprites.append(dict(name=sprite, rectangle=geometry[:4],
                                offset=geometry[4:6], originalSize=geometry[6:]))
        size = integer()
        png = data[offset:offset + size]
        offset += size
        with Image.open(io.BytesIO(png)) as image:
            dimensions = list(image.size)
            image.verify()
        file = export.add(png, f"current/unpacked_pages/{name}.png",
                          f"{path.relative_to(ROOT).as_posix()}#{name}",
                          dimensions=dimensions, role="native sprite page")
        pages.append(dict(page=name, file=file, alpha=alpha, sprites=sprites))
    assert offset == len(data), (path, offset, len(data))
    return pages


def module_markers(export):
    source = (MEDIA / "lua/shared/OMHTT/Turret.lua").read_text(encoding="utf-8")
    keys = re.findall(r"(\w+)\s*=\s*true", re.search(r"T.MODULES = \{(.*?)\}", source, re.S)[1])
    aliases = dict(re.findall(r'(\w+)\s*=\s*"([^"]+)"',
                             re.search(r"local itemTypes = \{(.*?)\}", source, re.S)[1]))
    art = (MEDIA / "lua/client/OMHTT/TurretModuleArt.lua").read_text(encoding="utf-8")
    categories = {}
    for category in ("performance", "automation", "effects", "utility"):
        body = re.search(r"local " + category + r" = \{(.*?)\}", art, re.S)[1]
        for name in re.findall(r"(\w+)\s*=\s*true", body):
            categories[name] = category
    names = json.loads((MEDIA / "lua/shared/Translate/EN/UI.json").read_text(encoding="utf-8"))
    font = ImageFont.load_default(size=13)
    small = ImageFont.load_default(size=10)
    entries = []
    for index, key in enumerate(sorted(keys), 1):
        category = "expansion" if key.startswith("Capacity") else categories[key]
        item = "Base." + aliases.get(key, "OMHTTModule" + key)
        label = names.get("UI_OMHTT_Module" + key, key)
        image = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        draw.rectangle((8, 8, 119, 119), fill=(220, 220, 220, 255), outline=(65, 65, 65, 255), width=3)
        draw.text((64, 16), f"DEV {index:02}", font=font, fill="black", anchor="mt")
        draw.text((64, 39), category.upper(), font=small, fill="black", anchor="mt")
        # A technical label, not replacement art direction or a rarity color.
        words, lines, line = label.split(), [], ""
        for word in words:
            test = (line + " " + word).strip()
            if draw.textlength(test, font=small) > 103 and line:
                lines.append(line)
                line = word
            else:
                line = test
        lines.append(line)
        for row, line in enumerate(lines):
            draw.text((64, 63 + row * 13), line, font=small, fill="black", anchor="mt")
        buffer = io.BytesIO()
        image.save(buffer, format="PNG")
        file = export.add(buffer.getvalue(), f"development/modules/{category}/{key}.png",
                          f"generated:module:{key}", role="neutral technical marker", dimensions=[128, 128])
        entries.append(dict(component=key, item=item, label=label, category=category, marker=file))
    assert len(keys) == len(set(keys)) == len(entries)
    return entries


# Y up, +X forward. Rotary entries are ONE arm: production draws two arms.
HEAD_BOXES = {
    "Ballista": [((0, 0, 0), (.8, .16, .18)), ((.23, .01, 0), (.10, .14, .95)),
                 ((-.23, -.11, 0), (.2, .16, .3)), ((.52, .02, 0), (.30, .05, .05))],
    "Scrapshot": [((0, 0, 0), (.45, .4, .4)), ((.42, .02, 0), (.46, .30, .44)),
                  ((-.14, .29, 0), (.3, .18, .3))],
    "Lobber": [((-.06, -.03, 0), (.42, .3, .34)), ((.34, .11, 0), (.48, .34, .34)),
               ((-.27, .22, 0), (.14, .16, .24))],
    "Arc": [((-.12, 0, 0), (.48, .38, .38)), ((.3, .05, -.14), (.42, .08, .08)),
            ((.3, .05, .14), (.42, .08, .08)), ((-.24, .26, 0), (.14, .12, .28))],
    "RotaryBat": [((-.22, 0, 0), (.5, .1, .1)), ((.22, 0, 0), (.5, .20, .20))],
    "RotaryBlades": [((-.18, 0, 0), (.55, .10, .10)), ((.25, 0, 0), (.42, .045, .58)),
                     ((.25, 0, 0), (.12, .12, .12))],
}


def mesh(boxes):
    verts, norms, indices = cube_mesh()
    positions, normals, faces, uvs = [], [], [], []
    for center, size in boxes:
        offset = len(positions)
        positions.extend([[vertex[i] * size[i] + center[i] for i in range(3)] for vertex in verts])
        normals.extend(norms)
        faces.extend([[offset + i for i in indices[t:t + 3]] for t in range(0, len(indices), 3)])
        uvs.extend([[0, 0], [1, 0], [1, 1], [0, 1]] * 6)
    return positions, normals, faces, uvs


def export_heads(export):
    rows = []
    for name, boxes in HEAD_BOXES.items():
        vertices, normals, faces, uvs = mesh(boxes)
        vectors = lambda values: ",\n".join(";".join(f"{v:.6f}" for v in row) + ";" for row in values) + ";\n"
        triangles = ",\n".join("3;" + ",".join(map(str, row)) + ";" for row in faces) + ";\n"
        native = f"xof 0303txt 0032\nMesh OMHTTDev{name} {{\n{len(vertices)};\n" + vectors(vertices)
        native += f"{len(faces)};\n" + triangles
        native += f"MeshNormals {{\n{len(normals)};\n" + vectors(normals) + f"{len(faces)};\n" + triangles + "}\n"
        native += f"MeshTextureCoords {{\n{len(uvs)};\n" + vectors(uvs) + "}\n}\n"
        native_file = export.add(native.encode("ascii"), f"development/heads/{name}/OMHTT_Dev{name}.x",
                                 f"generated:head:{name}:native", role="staged native mesh")
        obj = [f"# OMHTT {name} temporary box geometry. Y up; +X forward; pivot at origin.", f"o {name}"]
        obj += ["v " + " ".join(map(str, row)) for row in vertices]
        obj += ["vt " + " ".join(map(str, row)) for row in uvs]
        obj += ["vn " + " ".join(map(str, row)) for row in normals]
        obj += ["f " + " ".join(f"{i+1}/{i+1}/{i+1}" for i in row) for row in faces]
        editable = export.add(("\n".join(obj) + "\n").encode("ascii"), f"development/heads/{name}/{name}.obj",
                              f"generated:head:{name}:editable", role="editable geometry")
        assert len(vertices) == len(normals) == len(uvs) and len(faces) == len(boxes) * 12
        assert all(0 <= i < len(vertices) for face in faces for i in face)
        assert all(math.isfinite(v) for row in vertices for v in row)
        rows.append(dict(head=name, native=native_file, editable=editable, triangles=len(faces), boxes=boxes,
                         forward="+X", up="+Y", pivot=[0, 0, 0], muzzle=[max(v[0] for v in vertices), 0, 0]))
    return rows


def preview_heads(heads, output):
    sheet = Image.new("RGB", (900, 480), (36, 36, 36))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=17)
    for n, head in enumerate(heads):
        origin_x, origin_y = (n % 3) * 300 + 140, (n // 3) * 240 + 125
        vertices, normals, _, _ = mesh(head["boxes"])
        faces = [list(range(i, i + 4)) for i in range(0, len(vertices), 4)
                 if normals[i][0] * 3 + normals[i][1] * 4 + normals[i][2] * 3 > 0]
        faces.sort(key=lambda f: sum(sum(vertices[i]) for i in f))
        for face in faces:
            points = [(origin_x + (vertices[i][0] - vertices[i][2]) * 130,
                       origin_y + (vertices[i][0] + vertices[i][2]) * 55 - vertices[i][1] * 160) for i in face]
            normal = normals[face[0]]
            shade = int(190 + 40 * normal[1] - 25 * normal[0])
            draw.polygon(points, fill=(shade, shade, shade), outline=(70, 70, 70))
        draw.text((origin_x, origin_y + 73), head["head"], anchor="mt", fill="white", font=font)
        draw.text((origin_x, origin_y + 98), f'{head["triangles"]} triangles', anchor="mt", fill=(175,175,175))
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)


def build(destination):
    if destination.exists():
        raise SystemExit(f"Refusing to overwrite existing handoff: {destination}")
    export = Export(destination)
    suffixes = {".png", ".jpg", ".jpeg", ".x", ".fbx", ".obj", ".glb", ".gltf", ".pack", ".tiles"}
    for path in sorted((ROOT / "Source").rglob("*")):
        if path.is_file() and (path.suffix.lower() in suffixes or path.name == "tileGeometry.txt"):
            relative = path.relative_to(ROOT / "Source").as_posix()
            metadata = dict(role="current exported asset")
            if path.suffix.lower() == ".png":
                with Image.open(path) as image:
                    metadata["dimensions"] = list(image.size)
                    image.verify()
            export.add(path.read_bytes(), "current/" + relative, path.relative_to(ROOT).as_posix(), **metadata)
    pages = [page for pack in sorted(MEDIA.glob("texturepacks/*.pack")) for page in unpack_pages(pack, export)]
    for path in sorted((MEDIA / "scripts").glob("*.txt")):
        text = path.read_text(encoding="utf-8-sig")
        if re.search(r"\b(Icon|mesh|texture|WorldStaticModel|SpriteConfig)\s*[={]", text):
            export.add(path.read_bytes(), "reference/item_and_model_scripts/" + path.name,
                       path.relative_to(ROOT).as_posix(), role="mapping reference, not an install override")
    for name in ("TurretRenderer.lua", "TurretModuleArt.lua", "SlotHint.lua", "ControlModelDraw.lua"):
        path = MEDIA / "lua/client/OMHTT" / name
        export.add(path.read_bytes(), "reference/rendering/" + name, path.relative_to(ROOT).as_posix(), role="rendering reference")
    for name in ("Turret.lua", "TurretHeads.lua", "ControlRarity.lua"):
        path = MEDIA / "lua/shared/OMHTT" / name
        export.add(path.read_bytes(), "reference/rendering/" + name, path.relative_to(ROOT).as_posix(), role="mapping reference")
    for path in sorted((ROOT / "art/placeholders/cube_turret").glob("*.gl*")):
        export.add(path.read_bytes(), "editable_originals/potato/" + path.name,
                   path.relative_to(ROOT).as_posix(), role="original procedural potato/base scene")
    modules = module_markers(export)
    heads = export_heads(export)
    preview_heads(heads, destination / "HEAD_PREVIEW.png")
    sheet = Image.new("RGB", (768, math.ceil(len(modules) / 6) * 128), (35,35,35))
    for n, module in enumerate(modules):
        with Image.open(destination / module["marker"]) as icon:
            sheet.paste(icon, (n % 6 * 128, n // 6 * 128), icon)
    sheet.save(destination / "MODULE_PREVIEW.png")
    manifest = dict(baseline="0.2.66", status="artist handoff; staged markers, not installed",
                    assets=export.records, spritePages=pages, modules=modules, heads=heads,
                    uniquePayloads=len(export.hashes), aliases=len(export.records) - len(export.hashes))
    (destination / "manifest.json").write_text(json_text(manifest), encoding="utf-8")
    return manifest


def verify(destination):
    manifest = json.loads((destination / "manifest.json").read_text(encoding="utf-8"))
    hashes = {}
    for record in manifest["assets"]:
        path = (destination / record["file"]).resolve()
        assert path.is_relative_to(destination.resolve()) and path.is_file()
        assert sha(path.read_bytes()) == record["sha256"]
        assert record["sha256"] not in hashes or hashes[record["sha256"]] == record["file"]
        hashes[record["sha256"]] = record["file"]
    for page in manifest["spritePages"]:
        with Image.open(destination / page["file"]) as image:
            for sprite in page["sprites"]:
                x, y, width, height = sprite["rectangle"]
                assert x >= 0 and y >= 0 and x + width <= image.width and y + height <= image.height
    for head in manifest["heads"]:
        native = (destination / head["native"]).read_text(encoding="ascii")
        body = native.split("{", 1)[1].split("MeshNormals", 1)[0]
        values = [float(v) for v in re.findall(r"-?\d+(?:\.\d+)?", body)]
        count = int(values[0])
        positions = [values[1 + i * 3:4 + i * 3] for i in range(count)]
        offset = 1 + count * 3
        triangles = int(values[offset])
        assert triangles == head["triangles"]
        faces = []
        for i in range(triangles):
            start = offset + 1 + i * 4
            assert values[start] == 3
            face = [int(v) for v in values[start + 1:start + 4]]
            assert len(set(face)) == 3 and all(0 <= v < count for v in face)
            faces.append(face)
        obj = (destination / head["editable"]).read_text(encoding="ascii").splitlines()
        obj_positions = [[round(float(v), 6) for v in line.split()[1:]] for line in obj if line.startswith("v ")]
        obj_faces = [[int(v.split("/")[0]) - 1 for v in line.split()[1:]] for line in obj if line.startswith("f ")]
        assert positions == obj_positions and faces == obj_faces
    assert len(manifest["modules"]) == len({m["item"] for m in manifest["modules"]})
    return manifest


def archive(destination, output):
    verify(destination)
    output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(output, "w", zipfile.ZIP_DEFLATED) as archive:
        for file in sorted(destination.rglob("*")):
            if file.is_file():
                archive.write(file, "OMHTT-Artist-Handoff/" + file.relative_to(destination).as_posix())
    with zipfile.ZipFile(output) as archive:
        assert archive.testzip() is None
    print(json_text(dict(zip=str(output), sha256=sha(output.read_bytes()), bytes=output.stat().st_size)))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("destination", type=Path)
    parser.add_argument("--verify", action="store_true")
    parser.add_argument("--zip", type=Path)
    args = parser.parse_args()
    data = verify(args.destination) if args.verify else build(args.destination)
    verify(args.destination)
    print(json_text({key: data[key] for key in ("baseline", "uniquePayloads", "aliases")}))
    if args.zip:
        archive(args.destination, args.zip)
