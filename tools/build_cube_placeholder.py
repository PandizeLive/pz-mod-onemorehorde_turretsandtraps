import base64
import json
import math
import struct
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "art" / "placeholders" / "cube_turret"


def cube_mesh():
    faces = [
        ([1, 0, 0], [[.5, -.5, -.5], [.5, .5, -.5], [.5, .5, .5], [.5, -.5, .5]]),
        ([-1, 0, 0], [[-.5, -.5, .5], [-.5, .5, .5], [-.5, .5, -.5], [-.5, -.5, -.5]]),
        ([0, 1, 0], [[-.5, .5, -.5], [-.5, .5, .5], [.5, .5, .5], [.5, .5, -.5]]),
        ([0, -1, 0], [[-.5, -.5, .5], [-.5, -.5, -.5], [.5, -.5, -.5], [.5, -.5, .5]]),
        ([0, 0, 1], [[-.5, -.5, .5], [.5, -.5, .5], [.5, .5, .5], [-.5, .5, .5]]),
        ([0, 0, -1], [[.5, -.5, -.5], [-.5, -.5, -.5], [-.5, .5, -.5], [.5, .5, -.5]]),
    ]
    positions, normals, indices = [], [], []
    for normal, vertices in faces:
        start = len(positions)
        positions.extend(vertices)
        normals.extend([normal] * 4)
        indices.extend(start + index for index in [0, 1, 2, 0, 2, 3])
    return positions, normals, indices


def build_model():
    positions, normals, indices = cube_mesh()
    document = {
        "asset": {"version": "2.0", "generator": "OMH cube-only technical placeholder"},
        "scene": 0,
        "scenes": [{"name": "Technical placeholder only", "nodes": [0]}],
        "nodes": [
            {"name": "PlaceholderRoot", "children": [1, 2]},
            {"name": "Base", "mesh": 0, "translation": [0, .4, 0], "scale": [.8] * 3},
            {"name": "HeadPivot", "translation": [0, 1.05, 0], "children": [3, 4, 5]},
            {"name": "Head", "mesh": 0, "scale": [.5] * 3},
            {"name": "AimCube", "mesh": 0, "translation": [.4, 0, 0], "scale": [.3] * 3},
            {"name": "MuzzleMarker", "translation": [.55, 0, 0]},
        ],
        "materials": [{
            "name": "PlainWhite",
            "pbrMetallicRoughness": {
                "baseColorFactor": [1, 1, 1, 1], "metallicFactor": 0, "roughnessFactor": 1
            },
        }],
        "bufferViews": [],
        "accessors": [],
        "extras": {
            "purpose": "Temporary mechanics placeholder, not visual design direction",
            "axes": "Y up, initial aim +X; game scale/orientation unverified",
            "finalArt": "Owner will source without AI; no concept art or textures included",
        },
    }
    binary = bytearray()

    def add_accessor(values, kind, component_type, format_code, target=None):
        while len(binary) % 4:
            binary.append(0)
        flat = [value for row in values for value in row] if isinstance(values[0], list) else values
        packed = struct.pack("<" + format_code * len(flat), *flat)
        view = {"buffer": 0, "byteOffset": len(binary), "byteLength": len(packed)}
        if target is not None:
            view["target"] = target
        binary.extend(packed)
        document["bufferViews"].append(view)
        accessor = {
            "bufferView": len(document["bufferViews"]) - 1,
            "componentType": component_type, "count": len(values), "type": kind,
        }
        matrix = values if isinstance(values[0], list) else [[value] for value in values]
        accessor["min"] = [min(column) for column in zip(*matrix)]
        accessor["max"] = [max(column) for column in zip(*matrix)]
        document["accessors"].append(accessor)
        return len(document["accessors"]) - 1

    position = add_accessor(positions, "VEC3", 5126, "f", 34962)
    normal = add_accessor(normals, "VEC3", 5126, "f", 34962)
    index = add_accessor(indices, "SCALAR", 5123, "H", 34963)
    document["meshes"] = [{"name": "UnitCube", "primitives": [{
        "attributes": {"POSITION": position, "NORMAL": normal}, "indices": index, "material": 0,
    }]}]
    times = add_accessor([0., 1., 2., 3., 4.], "SCALAR", 5126, "f")
    quaternions = [[0., math.sin(angle / 2), 0., math.cos(angle / 2)]
                   for angle in [0., math.pi / 2, math.pi, 3 * math.pi / 2, 2 * math.pi]]
    rotations = add_accessor(quaternions, "VEC4", 5126, "f")
    document["animations"] = [{
        "name": "HeadYawPreview",
        "samplers": [{"input": times, "output": rotations, "interpolation": "LINEAR"}],
        "channels": [{"sampler": 0, "target": {"node": 2, "path": "rotation"}}],
    }]
    document["buffers"] = [{"byteLength": len(binary)}]
    return document, bytes(binary)


def export_model(document, binary):
    OUTPUT.mkdir(parents=True, exist_ok=True)
    json_chunk = json.dumps(document, separators=(",", ":")).encode("utf-8")
    json_chunk += b" " * (-len(json_chunk) % 4)
    binary_chunk = binary + b"\0" * (-len(binary) % 4)
    total = 12 + 8 + len(json_chunk) + 8 + len(binary_chunk)
    glb = struct.pack("<4sII", b"glTF", 2, total)
    glb += struct.pack("<I4s", len(json_chunk), b"JSON") + json_chunk
    glb += struct.pack("<I4s", len(binary_chunk), b"BIN\0") + binary_chunk
    (OUTPUT / "cube_turret.glb").write_bytes(glb)
    text_document = json.loads(json.dumps(document))
    text_document["buffers"][0]["uri"] = "data:application/octet-stream;base64," + base64.b64encode(binary).decode()
    (OUTPUT / "cube_turret.gltf").write_text(json.dumps(text_document, indent=2) + "\n", encoding="utf-8")


def read_export():
    raw = (OUTPUT / "cube_turret.glb").read_bytes()
    magic, version, size = struct.unpack_from("<4sII", raw)
    if magic != b"glTF" or version != 2 or size != len(raw):
        raise ValueError("Invalid GLB header")
    json_size, json_type = struct.unpack_from("<I4s", raw, 12)
    if json_type != b"JSON":
        raise ValueError("Missing JSON chunk")
    document = json.loads(raw[20:20 + json_size])
    offset = 20 + json_size
    binary_size, binary_type = struct.unpack_from("<I4s", raw, offset)
    binary = raw[offset + 8:offset + 8 + binary_size]
    if binary_type != b"BIN\0" or len(binary) != binary_size:
        raise ValueError("Invalid binary chunk")
    if len(raw) != offset + 8 + binary_size:
        raise ValueError("Unexpected GLB trailing bytes")
    return document, binary


def accessor_values(document, binary, accessor_index):
    accessor = document["accessors"][accessor_index]
    view = document["bufferViews"][accessor["bufferView"]]
    components = {"SCALAR": 1, "VEC3": 3, "VEC4": 4}[accessor["type"]]
    component = {5123: "H", 5126: "f"}[accessor["componentType"]]
    size = struct.calcsize(component) * components * accessor["count"]
    offset = view.get("byteOffset", 0) + accessor.get("byteOffset", 0)
    if offset + size > view.get("byteOffset", 0) + view["byteLength"] or offset + size > len(binary):
        raise ValueError("Accessor exceeds buffer bounds")
    values = struct.unpack_from("<" + component * components * accessor["count"], binary, offset)
    return np.array(values).reshape(accessor["count"], components)


def quaternion_matrix(quaternion):
    x, y, z, w = quaternion / np.linalg.norm(quaternion)
    return np.array([
        [1 - 2 * (y*y + z*z), 2 * (x*y - z*w), 2 * (x*z + y*w), 0],
        [2 * (x*y + z*w), 1 - 2 * (x*x + z*z), 2 * (y*z - x*w), 0],
        [2 * (x*z - y*w), 2 * (y*z + x*w), 1 - 2 * (x*x + y*y), 0],
        [0, 0, 0, 1],
    ])


def sampled_rotation(document, binary, seconds):
    sampler = document["animations"][0]["samplers"][0]
    times = accessor_values(document, binary, sampler["input"]).ravel()
    rotations = accessor_values(document, binary, sampler["output"])
    seconds %= times[-1]
    index = min(np.searchsorted(times, seconds, side="right") - 1, len(times) - 2)
    fraction = (seconds - times[index]) / (times[index + 1] - times[index])
    left, right = rotations[index], rotations[index + 1]
    if np.dot(left, right) < 0:
        right = -right
    dot = np.clip(np.dot(left, right), -1, 1)
    angle = math.acos(dot)
    if angle < .00001:
        return left
    return (math.sin((1 - fraction) * angle) * left + math.sin(fraction * angle) * right) / math.sin(angle)


def transformed_faces(document, binary, seconds, offset):
    primitive = document["meshes"][0]["primitives"][0]
    vertices = accessor_values(document, binary, primitive["attributes"]["POSITION"])
    vertices = np.column_stack([vertices, np.ones(len(vertices))])
    rotation_node = document["animations"][0]["channels"][0]["target"]["node"]
    root = np.eye(4)
    root[:3, 3] = offset
    result = []

    def visit(node_index, parent):
        node = document["nodes"][node_index]
        local = np.eye(4)
        local[:3, 3] = node.get("translation", [0, 0, 0])
        rotation = sampled_rotation(document, binary, seconds) if node_index == rotation_node else np.array(node.get("rotation", [0, 0, 0, 1]))
        scale = np.diag([*node.get("scale", [1, 1, 1]), 1])
        transform = parent @ local @ quaternion_matrix(rotation) @ scale
        if "mesh" in node:
            world = (transform @ vertices.T).T[:, :3]
            result.extend(world[start:start + 4] for start in range(0, len(world), 4))
        for child in node.get("children", []):
            visit(child, transform)

    for node_index in document["scenes"][document["scene"]]["nodes"]:
        visit(node_index, root)
    return result


def render_preview(document, binary, seconds):
    size = (800, 450)
    image = Image.new("RGB", size, (42, 44, 48))
    draw = ImageDraw.Draw(image)
    view = np.array([5., 4., 6.])
    view /= np.linalg.norm(view)
    right = np.cross([0., 1., 0.], view)
    right /= np.linalg.norm(right)
    up = np.cross(view, right)
    light = np.array([-2., 5., 4.])
    light /= np.linalg.norm(light)

    def project(point):
        return (400 + 165 * np.dot(point, right), 320 - 165 * np.dot(point, up))

    faces = transformed_faces(document, binary, seconds, -1.05 * right)
    faces += transformed_faces(document, binary, 4 - seconds + .8, 1.05 * right)
    for face in sorted(faces, key=lambda face: np.dot(face.mean(axis=0), view)):
        normal = np.cross(face[1] - face[0], face[2] - face[0])
        normal /= np.linalg.norm(normal)
        if np.dot(normal, view) <= 0:
            continue
        shade = round(255 * (.66 + .34 * max(0, np.dot(normal, light))))
        draw.polygon([project(point) for point in face], fill=(shade, shade, shade))
    draw.text((24, 20), "WHITE CUBE PLACEHOLDER | NOT ART DIRECTION", fill=(238, 238, 238), font_size=18)
    draw.text((24, 47), "Two instances | fixed bases | independently turning heads", fill=(193, 195, 200), font_size=15)
    draw.text((155, 383), "INSTANCE A", fill=(225, 225, 225), font_size=16)
    draw.text((515, 383), "INSTANCE B", fill=(225, 225, 225), font_size=16)
    draw.text((24, 424), "Mesh/animation preview only. Project Zomboid integration is not yet tested.", fill=(171, 174, 179), font_size=13)
    return image


def validate_export(document, binary):
    for index in range(len(document["accessors"])):
        values = accessor_values(document, binary, index)
        if not np.isfinite(values).all():
            raise ValueError("Non-finite accessor data")
    primitive = document["meshes"][0]["primitives"][0]
    positions = accessor_values(document, binary, primitive["attributes"]["POSITION"])
    normals = accessor_values(document, binary, primitive["attributes"]["NORMAL"])
    indices = accessor_values(document, binary, primitive["indices"]).ravel().astype(int)
    for a, b, c in indices.reshape(-1, 3):
        if np.dot(np.cross(positions[b] - positions[a], positions[c] - positions[a]), normals[a]) <= 0:
            raise ValueError("Inconsistent triangle winding")
    if any(len(set(node["scale"])) != 1 for node in document["nodes"] if "scale" in node):
        raise ValueError("Placeholder must contain cubes, not stretched boxes")
    if len([node for node in document["nodes"] if "mesh" in node]) != 3:
        raise ValueError("Expected exactly three cubes")
    if document.get("images") or document.get("textures"):
        raise ValueError("Placeholder must not contain textures")
    if document["materials"][0]["pbrMetallicRoughness"]["baseColorFactor"] != [1, 1, 1, 1]:
        raise ValueError("Placeholder material must be white")
    still = transformed_faces(document, binary, 0, [0, 0, 0])
    turned = transformed_faces(document, binary, 1, [0, 0, 0])
    if not np.allclose(still[:6], turned[:6]) or np.allclose(still[12:], turned[12:]):
        raise ValueError("Base must stay fixed while aim cube turns")


def main():
    export_model(*build_model())
    document, binary = read_export()
    validate_export(document, binary)
    frames = [render_preview(document, binary, index / 20) for index in range(80)]
    frames[10].save(OUTPUT / "preview.png")
    frames[0].save(OUTPUT / "rotation_preview.gif", save_all=True, append_images=frames[1:], duration=50, loop=0, disposal=2)
    print(json.dumps({"output": str(OUTPUT), "cubes": 3, "trianglesPerInstance": 36,
                      "material": "plain white, no textures", "animation": "HeadYawPreview",
                      "checks": "GLB bounds, finite data, winding, cube geometry, fixed base, moving aim cube",
                      "pzIntegration": "not tested"}, indent=2))


if __name__ == "__main__":
    main()
