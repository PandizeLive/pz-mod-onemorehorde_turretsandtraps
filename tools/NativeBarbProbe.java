import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public final class NativeBarbProbe {
    private static Object call(Object object, String name, Class<?>[] types, Object... args) throws Exception {
        return object.getClass().getMethod(name, types).invoke(object, args);
    }
    private static Object get(Object object, String name) throws Exception { return call(object, name, new Class<?>[0]); }
    private static void check(boolean valid, String message) { if (!valid) throw new IllegalStateException(message); }

    public static void verify(Path directory, String mode) throws Exception {
        Class<?> cellType = Class.forName("zombie.iso.IsoCell"), squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> chunkType = Class.forName("zombie.iso.IsoChunk"), iso = Class.forName("zombie.iso.IsoObject");
        Class<?> world = Class.forName("zombie.iso.IsoWorld"), table = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        List<Object> squares = new ArrayList<>();
        for (int i = 0; i < 8; i++) {
            Object chunk = chunkType.getConstructor(cellType).newInstance(cell);
            for (int dx = 0; dx < 2; dx++) for (int dy = 0; dy < 2; dy++) {
                Object square = squareType.getConstructor(cellType, Class.forName("zombie.iso.SliceY"), int.class, int.class, int.class)
                    .newInstance(cell, null, 1000 + i * 4 + dx, 1000 + dy, 0);
                squareType.getField("chunk").set(square, chunk);
                squares.add(square);
            }
        }
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform"), threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object platform = Class.forName("se.krka.kahlua.j2se.J2SEPlatform").getMethod("getInstance").invoke(null);
        Object thread = threadType.getConstructor(platformType, table).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        Object function = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeBarbCheck");
        Object result = threadType.getMethod("call", Object.class, Object[].class).invoke(thread, function, new Object[]{squares});
        check(result instanceof List<?>, "Barb native fixture creation failed");
        @SuppressWarnings("unchecked") List<Object> fixtures = (List<Object>)result;
        check(fixtures.size() == 16, "Expected eight frame/support pairs");
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        Files.createDirectories(directory);
        for (int i = 0; i < fixtures.size(); i++) {
            Object source = fixtures.get(i);
            Path file = directory.resolve("barb-" + i + ".bin");
            if (mode.equals("write")) {
                ByteBuffer out = ByteBuffer.allocate(65536);
                iso.getMethod("save", ByteBuffer.class).invoke(source, out);
                Files.write(file, Arrays.copyOf(out.array(), out.position()));
            }
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(file));
            Object restored = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, input);
            Object square = get(source, "getSquare");
            iso.getMethod("setSquare", squareType).invoke(restored, square);
            iso.getMethod("load", ByteBuffer.class, int.class).invoke(restored, input, version);
            check(!input.hasRemaining(), "Unread barb object data");
            for (String method : new String[]{"getSpriteName", "getHealth"})
                check(get(source, method).equals(get(restored, method)), "Barb/support reload changed " + method);
            if (i % 2 == 0) {
                check(Boolean.TRUE.equals(get(restored, "isCanPassThrough")) && Boolean.FALSE.equals(get(restored, "isThumpable")), "Barb marker became a collider or target");
            }
            String key = i % 2 == 0 ? "OMHTTBarbFrame" : "OMHTTBarbs";
            Object expected = call(get(source, "getModData"), "rawget", new Class<?>[]{Object.class}, key);
            Object actual = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, key);
            check(expected != null && actual != null, "Barb metadata missing on reload");
            ByteBuffer a = ByteBuffer.allocate(65536), b = ByteBuffer.allocate(65536);
            call(expected, "save", new Class<?>[]{ByteBuffer.class}, a);
            call(actual, "save", new Class<?>[]{ByteBuffer.class}, b);
            a.flip(); b.flip();
            check(a.equals(b), "Barb identity/durability changed on reload");
            @SuppressWarnings("unchecked") List<Object> objects = (List<Object>)get(square, "getObjects");
            @SuppressWarnings("unchecked") List<Object> special = (List<Object>)get(square, "getSpecialObjects");
            objects.remove(source); special.remove(source);
            objects.add(restored); special.add(restored);
            fixtures.set(i, restored);
        }
        Object finish = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeBarbRestoredCheck");
        check(Boolean.TRUE.equals(threadType.getMethod("call", Object.class, Object[].class).invoke(thread, finish, new Object[]{fixtures})), "Restored barbs do not resolve");
        System.out.println("[OMHTT-Barbs] persistence mode=" + mode + " pairs=8 identity=valid durability=preserved hostHealth=unchanged collision=passable");
    }
}
