"""Build the approved world-space electrical core and blue falloff."""
from pathlib import Path
from PIL import Image

MEDIA = Path(__file__).resolve().parents[1] / "Source/42.20/media"


def build():
    positions = [(-.1, -.04, 0), (.1, -.04, 0), (.1, .04, 0), (-.1, .04, 0),
                 (-.1, 0, -.04), (.1, 0, -.04), (.1, 0, .04), (-.1, 0, .04)]
    normals = [(0, 0, 1)] * 4 + [(0, 1, 0)] * 4
    uv = [(0, 0), (1, 0), (1, 1), (0, 1)] * 2
    faces = "3;0,1,2;,\n3;0,2,3;,\n3;4,5,6;,\n3;4,6,7;;\n"
    def rows(values):
        return ",\n".join(";".join(str(v) for v in row) + ";" for row in values) + ";\n"
    mesh = "xof 0303txt 0032\nMesh OMHTTArc {\n8;\n" + rows(positions) + "4;\n" + faces
    mesh += "MeshNormals {\n8;\n" + rows(normals) + "4;\n" + faces + "}\n"
    mesh += "MeshTextureCoords {\n8;\n" + rows(uv) + "}\n}\n"
    (MEDIA / "models_X/OMHTT_Arc.x").write_text(mesh, encoding="ascii")
    image = Image.new("RGBA", (8, 64))
    for y in range(64):
        distance = abs((y + .5) / 32 - 1)
        core = max(0, min(1, (0.45 - distance) / .3))
        alpha = round(255 * (1 - distance) ** 2)
        color = (round(45 + 210 * core), round(135 + 120 * core), 255, alpha)
        for x in range(8):
            image.putpixel((x, y), color)
    image.save(MEDIA / "textures/OMHTT/Arc.png")
    (MEDIA / "scripts/OMHTT_ArcVisual.txt").write_text('''module Base {
    model OMHTTArc {
        mesh = OMHTT_Arc,
        texture = OMHTT/Arc,
        scale = 1.0,
        static = true,
        shader = OMHTTEmissive,
    }
    item OMHTTTurretArcVisual {
        DisplayName = OMH Arc Visual,
        ItemType = base:normal,
        Weight = 0,
        Hidden = true,
        Icon = ElectronicsScrap,
        WorldStaticModel = OMHTTArc,
    }
}
''', encoding="utf-8")


if __name__ == "__main__":
    build()
