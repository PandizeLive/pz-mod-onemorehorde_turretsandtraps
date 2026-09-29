import copy
from pathlib import Path

import numpy as np
from PIL import Image

from build_cube_placeholder import read_export, transformed_faces
from build_foundation_sprite import render

ROOT = Path(__file__).resolve().parents[1]
MEDIA = ROOT / "Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media"


def build():
    document, binary = read_export()
    base = copy.deepcopy(document)
    base["nodes"][0]["children"] = [1]
    render(base, binary, 0, ground_y=224).save(MEDIA / "textures/OMHTT_ProbeBase.png")
    head = copy.deepcopy(document)
    head["nodes"][0]["children"] = [2]
    head["nodes"][2]["translation"] = [0, 0, 0]
    faces = transformed_faces(head, binary, 0, np.zeros(3))
    assert len(faces) == 12
    positions = [vertex for face in faces for vertex in face]
    triangles = [(i + a, i + b, i + c) for i in range(0, len(positions), 4)
                 for a, b, c in [(0, 1, 2), (0, 2, 3)]]
    normals = []
    for face in faces:
        normal = np.cross(face[1] - face[0], face[2] - face[0])
        normals.extend([normal / np.linalg.norm(normal)] * 4)
    vector_rows = lambda values: ",\n".join(";".join(f"{v:.6f}" for v in row) + ";" for row in values) + ";\n"
    face_rows = ",\n".join("3;" + ",".join(str(i) for i in face) + ";" for face in triangles) + ";\n"
    mesh = "xof 0303txt 0032\nMesh OMHTTProbeHead {\n" + str(len(positions)) + ";\n" + vector_rows(positions)
    mesh += str(len(triangles)) + ";\n" + face_rows
    mesh += "MeshNormals {\n" + str(len(normals)) + ";\n" + vector_rows(normals) + str(len(triangles)) + ";\n" + face_rows + "}\n"
    mesh += "MeshTextureCoords {\n" + str(len(positions)) + ";\n" + vector_rows([[0.5, 0.5]] * len(positions)) + "}\n}\n"
    (MEDIA / "models_X").mkdir(exist_ok=True)
    (MEDIA / "models_X/OMHTT_ProbeHead.x").write_text(mesh, encoding="ascii")
    (MEDIA / "textures/OMHTT").mkdir(exist_ok=True)
    Image.new("RGBA", (8, 8), "white").save(MEDIA / "textures/OMHTT/ProbeWhite.png")
    print("Hybrid probe: original base tile; separate two-cube head, 48 vertices, 24 triangles.")


if __name__ == "__main__":
    build()
