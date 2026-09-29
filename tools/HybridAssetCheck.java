import java.util.EnumSet;
import jassimp.AiPostProcessSteps;
import jassimp.Jassimp;

public final class HybridAssetCheck {
    public static void main(String[] args) throws Exception {
        Jassimp.setLibraryLoader(new jassimp.JassimpLibraryLoader() {
            @Override public void loadLibrary() { System.loadLibrary("jassimp64"); }
        });
        var flags = EnumSet.of(AiPostProcessSteps.FIND_INSTANCES, AiPostProcessSteps.MAKE_LEFT_HANDED,
            AiPostProcessSteps.LIMIT_BONE_WEIGHTS, AiPostProcessSteps.TRIANGULATE,
            AiPostProcessSteps.OPTIMIZE_MESHES, AiPostProcessSteps.REMOVE_REDUNDANT_MATERIALS,
            AiPostProcessSteps.JOIN_IDENTICAL_VERTICES);
        var scene = Jassimp.importFile(args[0], flags);
        int faces = 0;
        int vertices = 0;
        for (var mesh : scene.getMeshes()) {
            faces += mesh.getNumFaces();
            vertices += mesh.getNumVertices();
        }
        if (scene.getNumMeshes() != 1 || faces != 24 || vertices != 48) {
            throw new IllegalStateException("Unexpected imported cube geometry: " + vertices + "/" + faces);
        }
        Class<?> paramsType = Class.forName("zombie.core.skinnedmodel.model.jassimp.ProcessedAiSceneParams");
        Object params = paramsType.getMethod("create").invoke(null);
        paramsType.getField("scene").set(params, scene);
        paramsType.getField("mode").set(params, Class.forName("zombie.core.skinnedmodel.model.jassimp.JAssImpImporter$LoadMode").getField("StaticMesh").get(null));
        if (Class.forName("zombie.core.skinnedmodel.model.jassimp.ProcessedAiScene").getMethod("process", paramsType).invoke(null, params) == null) {
            throw new IllegalStateException("Native static mesh conversion failed");
        }
        System.out.println("Native Jassimp import and PZ StaticMesh conversion passed: one mesh, 48 vertices, 24 triangles; GPU rendering remains untested.");
    }
}
