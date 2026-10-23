"""Functional white tether geometry and approved turret state markers."""
from pathlib import Path
from PIL import Image
from build_cube_placeholder import cube_mesh

MEDIA = Path(__file__).resolve().parents[1] / "Source/42.20/media"


def build():
    vertices, normals, indices = cube_mesh()
    faces = ",\n".join("3;" + ",".join(str(v) for v in indices[i:i+3]) + ";" for i in range(0, len(indices), 3)) + ";\n"
    def rows(values):
        return ",\n".join(";".join(f"{v:.6f}" for v in row) + ";" for row in values) + ";\n"
    scripts = ["module Base {"]
    for name, size, texture in [
        ("TetherNail", (.25, .018, .018), "ProbeWhite"),
        ("TetherCable", (1, .018, .018), "ProbeWhite"),
        ("StateAmber", (.075, .035, .075), "StateAmber"),
        ("StateGreen", (.075, .035, .075), "StateGreen"),
        ("StateDark", (.075, .035, .075), "StateDark"),
    ]:
        positions = [[v[i] * size[i] for i in range(3)] for v in vertices]
        mesh = f"xof 0303txt 0032\nMesh OMHTT{name} {{\n{len(positions)};\n" + rows(positions)
        mesh += f"{len(indices)//3};\n" + faces
        mesh += f"MeshNormals {{\n{len(normals)};\n" + rows(normals) + f"{len(indices)//3};\n" + faces + "}\n"
        mesh += f"MeshTextureCoords {{\n{len(positions)};\n" + rows([[.5, .5]] * len(positions)) + "}\n}\n"
        (MEDIA / f"models_X/OMHTT_{name}.x").write_text(mesh, encoding="ascii")
        scripts.append(f"""    model OMHTT{name} {{ mesh = OMHTT_{name}, texture = OMHTT/{texture}, scale = 1.0, static = true, shader = basicEffect, }}
    item OMHTT{"Trap" if name.startswith("Tether") else "Turret"}{name}Visual {{ DisplayName = OMH {name} Visual, ItemType = base:normal, Weight = 0, Hidden = true, Icon = ElectronicsScrap, WorldStaticModel = OMHTT{name}, }}""")
    for colour in ["Green", "Red"]:
        scripts.append(f"    model OMHTTTrapLaser{colour} {{ mesh = OMHTT_TetherCable, texture = OMHTT/State{colour}, scale = 1.0, static = true, shader = OMHTTEmissive, }}")
        scripts.append(f"    item OMHTTTrapLaser{colour}Visual {{ DisplayName = OMH Laser Visual, ItemType = base:normal, Weight = 0, Hidden = true, Icon = ElectronicsScrap, WorldStaticModel = OMHTTTrapLaser{colour}, }}")
    for name, colour in [("StateRed", (255, 45, 35, 255)), ("StateAmber", (255, 180, 45, 255)), ("StateGreen", (75, 235, 95, 255)), ("StateDark", (32, 32, 32, 255))]:
        Image.new("RGBA", (4, 4), colour).save(MEDIA / f"textures/OMHTT/{name}.png")
    (MEDIA / "scripts/OMHTT_DeviceVisuals.txt").write_text("\n".join(scripts) + "\n}\n", encoding="utf-8")


if __name__ == "__main__":
    build()
