"""Owner-approved blocky ground braces; one mesh, existing neutral texture."""
from pathlib import Path
from build_cube_placeholder import cube_mesh

ROOT = Path(__file__).resolve().parents[1] / 'Source/42.20/media'


def build():
    vertices, normals, indices = cube_mesh()
    positions, directions, triangles = [], [], []
    for axis, sign in ((0,1),(0,-1),(2,1),(2,-1)):
        for center, length, width, height in ((.8,1.1,.065,.045),(1.35,.16,.18,.065)):
            size=[width,height,width];size[axis]=length
            offset=[0,height/2,0];offset[axis]=sign*center
            base=len(positions)
            positions.extend([[(v[i]*size[i]+offset[i])/1.5 for i in range(3)] for v in vertices])
            directions.extend(normals);triangles.extend(base+i for i in indices)
    def rows(values):
        return ',\n'.join(';'.join(f'{v:.6f}' for v in row)+';' for row in values)+';\n'
    faces=',\n'.join('3;'+','.join(str(v) for v in triangles[i:i+3])+';' for i in range(0,len(triangles),3))+';\n'
    mesh=f'xof 0303txt 0032\nMesh OMHTTPokeStabilizers {{\n{len(positions)};\n'+rows(positions)
    mesh+=f'{len(triangles)//3};\n'+faces+f'MeshNormals {{\n{len(directions)};\n'+rows(directions)+f'{len(triangles)//3};\n'+faces+'}\n'
    mesh+=f'MeshTextureCoords {{\n{len(positions)};\n'+rows([[.5,.5]]*len(positions))+'}\n}\n'
    (ROOT/'models_X/OMHTT_PokeStabilizers.x').write_text(mesh,encoding='ascii')
    (ROOT/'scripts/OMHTT_PokeVisuals.txt').write_text('''module Base {
    model OMHTTPokeStabilizers { mesh = OMHTT_PokeStabilizers, texture = OMHTT/ProbeWhite, scale = 1.0, static = true, shader = basicEffect, }
    item OMHTTTrapPokeStabilizersVisual { DisplayName = OMH Poke Stabilizers Visual, ItemType = base:normal, Weight = 0, Hidden = true, Icon = ElectronicsScrap, WorldStaticModel = OMHTTPokeStabilizers, }
}
''',encoding='utf-8')


if __name__=='__main__': build()
