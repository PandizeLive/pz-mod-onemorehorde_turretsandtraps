"""Three white boxes for mounting tests; no final art or design direction."""
from pathlib import Path
from build_cube_placeholder import cube_mesh

MEDIA = Path(__file__).resolve().parents[1] / "Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media"


def build():
    vertices, normals, indices = cube_mesh()
    positions, directions, triangles = [], [], []
    for center, size in [((0, .02, 0), (.24, .04, .20)),
                         ((0, .09, -.085), (.20, .14, .03)),
                         ((0, .09, .085), (.20, .14, .03))]:
        offset = len(positions)
        positions.extend([[v[i] * size[i] + center[i] for i in range(3)] for v in vertices])
        directions.extend(normals)
        triangles.extend([[offset + v for v in indices[i:i+3]] for i in range(0, len(indices), 3)])
    def rows(values):
        return ",\n".join(";".join(f"{v:.6f}" for v in row) + ";" for row in values) + ";\n"
    faces = ",\n".join("3;" + ",".join(str(v) for v in row) + ";" for row in triangles) + ";\n"
    mesh = f"xof 0303txt 0032\nMesh OMHTTGunSupport {{\n{len(positions)};\n" + rows(positions)
    mesh += f"{len(triangles)};\n" + faces
    mesh += f"MeshNormals {{\n{len(directions)};\n" + rows(directions) + f"{len(triangles)};\n" + faces + "}\n"
    mesh += f"MeshTextureCoords {{\n{len(positions)};\n" + rows([[.5, .5]] * len(positions)) + "}\n}\n"
    (MEDIA / "models_X/OMHTT_GunSupport.x").write_text(mesh, encoding="ascii")


if __name__ == "__main__":
    build()
