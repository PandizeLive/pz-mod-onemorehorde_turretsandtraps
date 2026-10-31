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

    private static Object snapshot(Object value) throws Exception {
        Class<?> table = Class.forName("se.krka.kahlua.vm.KahluaTable");
        if (!table.isInstance(value)) return value;
        Class<?> iteratorType = Class.forName("se.krka.kahlua.vm.KahluaTableIterator");
        Object iterator = table.getMethod("iterator").invoke(value);
        java.util.Map<Object, Object> fields = new java.util.LinkedHashMap<>();
        while (Boolean.TRUE.equals(iteratorType.getMethod("advance").invoke(iterator))) {
            fields.put(iteratorType.getMethod("getKey").invoke(iterator), snapshot(iteratorType.getMethod("getValue").invoke(iterator)));
        }
        return fields;
    }

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
        Object boundaryChunk = chunkType.getConstructor(cellType).newInstance(cell);
        for (int dx = 0; dx < 2; dx++) for (int dy = -1; dy < 1; dy++) {
            Object square = squareType.getConstructor(cellType, Class.forName("zombie.iso.SliceY"), int.class, int.class, int.class)
                .newInstance(cell, null, 16384 + dx, 16384 + dy, 0);
            squareType.getField("chunk").set(square, boundaryChunk);
            squares.add(square);
        }
        for (int group = 0; group < 6; group++) {
            Object chunk = chunkType.getConstructor(cellType).newInstance(cell);
            for (int dx = -1; dx <= 0; dx++) for (int dy = -1; dy <= 0; dy++) {
                Object square = squareType.getConstructor(cellType, Class.forName("zombie.iso.SliceY"), int.class, int.class, int.class)
                    .newInstance(cell, null, 17000 + group * 4 + dx, 17000 + dy, 0);
                squareType.getField("chunk").set(square, chunk);
                squares.add(square);
            }
        }
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform"), threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object platform = Class.forName("se.krka.kahlua.j2se.J2SEPlatform").getMethod("getInstance").invoke(null);
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        Path namesFile = directory.resolve("barb-name-registry.bin");
        if (mode.equals("read")) {
            Object names = platformType.getMethod("newTable").invoke(platform);
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(namesFile));
            call(names, "load", new Class<?>[]{ByteBuffer.class, int.class}, input, version);
            check(!input.hasRemaining(), "Unread barb naming fixture registry");
            call(env, "rawset", new Class<?>[]{Object.class, Object.class}, "OMHTT_NativeBarbNames", names);
        }
        Object thread = threadType.getConstructor(platformType, table).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        Object function = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeBarbCheck");
        Class<?> playerType = Class.forName("zombie.characters.IsoPlayer");
        Object builder = playerType.getConstructor(cellType).newInstance(cell);
        Object players = playerType.getField("players").get(null);
        Object previous = java.lang.reflect.Array.get(players, 0);
        java.lang.reflect.Array.set(players, 0, builder);
        call(env, "rawset", new Class<?>[]{Object.class, Object.class}, "OMHTT_NativeBuilder", builder);
        Object result;
        try {
            result = threadType.getMethod("call", Object.class, Object[].class).invoke(thread, function, new Object[]{squares});
        } finally {
            java.lang.reflect.Array.set(players, 0, previous);
        }
        check(result instanceof List<?>, "Barb native fixture creation failed");
        @SuppressWarnings("unchecked") List<Object> fixtures = (List<Object>)result;
        check(fixtures.size() == 37, "Expected original panels/wire plus six garage supports with two faces each");
        Files.createDirectories(directory);
        if (mode.equals("write")) {
            Object names = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeBarbNames");
            ByteBuffer output = ByteBuffer.allocate(1048576);
            call(names, "save", new Class<?>[]{ByteBuffer.class}, output);
            Files.write(namesFile, Arrays.copyOf(output.array(), output.position()));
        }
        Object module = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_BarbSections");
        Object store = call(module, "rawget", new Class<?>[]{Object.class}, "store");
        Object wires = call(store, "rawget", new Class<?>[]{Object.class}, "wires");
        Path wireFile = directory.resolve("wire-records.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(65536);
            call(wires, "save", new Class<?>[]{ByteBuffer.class}, output);
            Files.write(wireFile, Arrays.copyOf(output.array(), output.position()));
        }
        Object restoredWires = platformType.getMethod("newTable").invoke(platform);
        ByteBuffer wireInput = ByteBuffer.wrap(Files.readAllBytes(wireFile));
        call(restoredWires, "load", new Class<?>[]{ByteBuffer.class, int.class}, wireInput, version);
        check(!wireInput.hasRemaining(), "Unread shared wire state");
        call(store, "rawset", new Class<?>[]{Object.class, Object.class}, "wires", restoredWires);
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
            boolean frameObject = i < 19 ? i % 2 == 0 || i >= 16 : (i - 19) % 3 != 2;
            if (frameObject) {
                check(Boolean.TRUE.equals(get(restored, "isCanPassThrough")) && Boolean.FALSE.equals(get(restored, "isThumpable")), "Barb marker became a collider or target");
            }
            String key = frameObject ? "OMHTTBarbFrame" : "OMHTTBarbs";
            Object expected = call(get(source, "getModData"), "rawget", new Class<?>[]{Object.class}, key);
            Object actual = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, key);
            check(expected != null && actual != null, "Barb metadata missing on reload");
            Object expectedFields = snapshot(expected), actualFields = snapshot(actual);
            check(expectedFields.equals(actualFields), "Barb identity/durability changed on reload: expected=" + expectedFields + " actual=" + actualFields);
            @SuppressWarnings("unchecked") List<Object> objects = (List<Object>)get(square, "getObjects");
            @SuppressWarnings("unchecked") List<Object> special = (List<Object>)get(square, "getSpecialObjects");
            objects.remove(source); special.remove(source);
            objects.add(restored); special.add(restored);
            fixtures.set(i, restored);
        }
        Object finish = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeBarbRestoredCheck");
        var serverFlag = Class.forName("zombie.network.GameServer").getField("server");
        boolean wasServer = serverFlag.getBoolean(null);
        serverFlag.setBoolean(null, false);
        try {
            check(Boolean.TRUE.equals(threadType.getMethod("call", Object.class, Object[].class).invoke(thread, finish, new Object[]{fixtures})), "Restored barbs do not resolve");
        } finally {
            serverFlag.setBoolean(null, wasServer);
        }
        System.out.println("[OMHTT-Barbs] persistence mode=" + mode + " pairs=8 wire=2 identity=valid durability=shared-preserved hostHealth=unchanged collision=passable");
    }
}
