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
        int expectedFaces = args.length > 1 ? Integer.parseInt(args[1]) : 24;
        if (scene.getNumMeshes() != 1 || faces != expectedFaces || vertices != expectedFaces * 2) {
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
        // Current ItemModelRenderer: Rx(item.x) Ry(item.z) Rz(item.y), then
        // the native dropped-weapon transform and inverse world attachment.
        float[][] attachments = {{0, 0, 0}, {-180, 1, -180}, {180, 0, 180}};
        for (int gun = 0; gun < attachments.length; gun++) {
            for (int heading = 0; heading < 360; heading += 45) {
                float yaw = (float)Math.toRadians(heading);
                Object pose = matrix.getConstructor().newInstance();
                matrix.getMethod("rotateX", float.class).invoke(pose, -(float)Math.PI / 2);
                matrix.getMethod("rotateZ", float.class).invoke(pose, yaw);
                matrix.getMethod("rotateY", float.class).invoke(pose, (float)Math.PI);
                matrix.getMethod("rotateZ", float.class).invoke(pose, (float)Math.PI / 2);
                Object attachment = matrix.getConstructor().newInstance();
                matrix.getMethod("rotateXYZ", float.class, float.class, float.class).invoke(attachment,
                    (float)Math.toRadians(attachments[gun][0]), (float)Math.toRadians(attachments[gun][1]),
                    (float)Math.toRadians(attachments[gun][2]));
                matrix.getMethod("invert").invoke(attachment);
                matrix.getMethod("mul", Class.forName("org.joml.Matrix4fc")).invoke(pose, attachment);
                Object barrel = vector.getConstructor(float.class, float.class, float.class).newInstance(0f, 1f, 0f);
                Object top = vector.getConstructor(float.class, float.class, float.class).newInstance(0f, 0f, gun == 0 ? -1f : 1f);
                matrix.getMethod("transformDirection", vector).invoke(pose, barrel);
                matrix.getMethod("transformDirection", vector).invoke(pose, top);
                float bx = vector.getField("x").getFloat(barrel), bz = vector.getField("z").getFloat(barrel);
                if (bx * Math.cos(yaw) - bz * Math.sin(yaw) < .999 || vector.getField("y").getFloat(top) < .999)
                    throw new IllegalStateException("Mounted gun pose mismatch: " + gun + "/" + heading);
            }
        }
        System.out.println("Native JOML: three gun world attachments remain upright and aimed over eight headings.");
        for (int heading = 0; heading < 360; heading += 15) {
            for (int pitch = 0; pitch <= 45; pitch += 5) {
                double a = Math.toRadians(heading), p = Math.toRadians(pitch);
                float rx = (float)Math.atan2(-Math.cos(p), -Math.sin(a) * Math.sin(p));
                float rz = (float)Math.asin(Math.cos(a) * Math.sin(p));
                float ry = (float)Math.atan2(Math.sin(a), Math.cos(a) * Math.cos(p));
                Object pose = matrix.getConstructor().newInstance();
                matrix.getMethod("rotateXYZ", float.class, float.class, float.class).invoke(pose, rx, rz, ry);
                Object barrel = vector.getConstructor(float.class, float.class, float.class).newInstance(1f, 0f, 0f);
                matrix.getMethod("transformDirection", vector).invoke(pose, barrel);
                double bx = vector.getField("x").getFloat(barrel), by = vector.getField("y").getFloat(barrel), bz = vector.getField("z").getFloat(barrel);
                if (Math.abs(bx - Math.cos(a) * Math.cos(p)) > .00001
                    || Math.abs(by + Math.sin(p)) > .00001
                    || Math.abs(bz + Math.sin(a) * Math.cos(p)) > .00001)
                    throw new IllegalStateException("Standby barrel pitch mismatch " + heading + "/" + pitch);
            }
        }
        System.out.println("Native JOML: 240 standby poses pitch the barrel downward without changing its mount origin.");
        float newY = (Float)screenY.invoke(null, 0f, 0f, 0.4f - 16f / 192f, 0);
        if (Math.abs(newY - oldY - 16) > 0.001) throw new IllegalStateException("Head lowering differs from base's 16-pixel shift");
        System.out.println("Native IsoUtils / JOML projection: 8 heading vectors match; head follows 16-pixel base shift.");
        System.out.println("Native Jassimp import and PZ StaticMesh conversion passed: one mesh, " + vertices + " vertices, " + faces + " triangles; GPU rendering remains untested.");
    }
}
