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
        Class<?> iso = Class.forName("zombie.iso.IsoUtils");
        var screenX = iso.getMethod("XToScreen", float.class, float.class, float.class, int.class);
        var screenY = iso.getMethod("YToScreen", float.class, float.class, float.class, int.class);
        Class<?> matrix = Class.forName("org.joml.Matrix4f"), vector = Class.forName("org.joml.Vector3f");
        for (int heading = 0; heading < 360; heading += 45) {
            float radians = (float)Math.toRadians(heading);
            float dx = (float)Math.cos(radians), dy = -(float)Math.sin(radians);
            float yaw = (float)Math.toRadians((360 - heading) % 360);
            Object view = matrix.getConstructor().newInstance();
            matrix.getMethod("rotateX", float.class).invoke(view, (float)Math.PI / 6);
            var rotateY = matrix.getMethod("rotateY", float.class);
            rotateY.invoke(view, (float)Math.PI * 3 / 4);
            matrix.getMethod("scale", float.class, float.class, float.class).invoke(view, -1.5f, 1.5f, 1.5f);
            rotateY.invoke(view, (float)Math.PI);
            rotateY.invoke(view, -(float)Math.PI);
            rotateY.invoke(view, yaw);
            Object aim = vector.getConstructor(float.class, float.class, float.class).newInstance(1f, 0f, 0f);
            matrix.getMethod("transformDirection", vector).invoke(view, aim);
            float ax = vector.getField("x").getFloat(aim), ay = vector.getField("y").getFloat(aim);
            float sx = (Float)screenX.invoke(null, dx, dy, 0f, 0);
            float sy = (Float)screenY.invoke(null, dx, dy, 0f, 0);
            double dot = (ax * sx - ay * sy) / Math.hypot(ax, ay) / Math.hypot(sx, sy);
            if (dot < 0.99999) throw new IllegalStateException("Model/world heading mismatch: " + heading + " dot=" + dot);
        }
        float oldY = (Float)screenY.invoke(null, 0f, 0f, 0.4f, 0);
        float newY = (Float)screenY.invoke(null, 0f, 0f, 0.4f - 16f / 192f, 0);
        if (Math.abs(newY - oldY - 16) > 0.001) throw new IllegalStateException("Head lowering differs from base's 16-pixel shift");
        System.out.println("Native IsoUtils / JOML projection: 8 heading vectors match; head follows 16-pixel base shift.");
        System.out.println("Native Jassimp import and PZ StaticMesh conversion passed: one mesh, 48 vertices, 24 triangles; GPU rendering remains untested.");
    }
}
