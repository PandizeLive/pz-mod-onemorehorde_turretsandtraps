import java.lang.reflect.Method;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;

public final class NativePersistenceCheck {
    private static Object call(Object target, String name, Class<?>[] types, Object... args) throws Exception {
        return target.getClass().getMethod(name, types).invoke(target, args);
    }

    private static Object get(Object target, String name) throws Exception {
        return call(target, name, new Class<?>[0]);
    }

    private static void check(boolean value, String message) {
        if (!value) throw new IllegalStateException(message);
    }

    private static void verify(Path directory, String mode) throws Exception {
        NativeVaultProbe.verify();
        Object pack = Class.forName("zombie.fileSystem.TexturePackDevice").getConstructor(String.class, int.class).newInstance("OMHTT_Barriers", 0);
        Class<?> entriesType = Class.forName("zombie.fileSystem.FileSystem$TexturePackTextures");
        Object entries = entriesType.getConstructor().newInstance();
        call(pack, "getSubTextureInfo", new Class<?>[]{entriesType}, entries);
        check(((java.util.Map<?, ?>)entries).size() == 28, "Native texture pack metadata did not load");
        for (int index = 0; index < 28; index++) {
            Object entry = ((java.util.Map<?, ?>)entries).get("omhtt_barrier_01_" + index);
            String expected = index >= 20 ? "OMHTT_ReinforcedBarrier" + ((index - 20) / 2)
                : index >= 16 ? "OMHTT_Edges" : "OMHTT_Barrier" + ((index % 8) / 2);
            check(entry != null && expected.equals(entry.getClass().getField("pageName").get(entry)), "Sprite mapped to wrong tier page: " + index);
        }

        for (int page = 0; page < 8; page++) {
            try (var stream = (java.io.InputStream)call(pack, "createStream", new Class<?>[]{String.class, java.io.InputStream.class}, (page < 4 ? "OMHTT_Barrier" + page : "OMHTT_ReinforcedBarrier" + (page - 4)), null)) {
                var image = javax.imageio.ImageIO.read(stream);
                check(image != null && image.getWidth() == 128 && image.getHeight() == 256, "Native texture page unreadable");
            }
        }
        try (var stream = (java.io.InputStream)call(pack, "createStream", new Class<?>[]{String.class, java.io.InputStream.class}, "OMHTT_Edges", null)) {
            var image = javax.imageio.ImageIO.read(stream);
            check(image != null && image.getWidth() == 256 && image.getHeight() == 256, "Native outline texture page unreadable");
        }
        System.out.println("[OMHTT-Smoke] native-texturepack entries=28 pages=9 png=valid");
        Class<?> lua = Class.forName("zombie.Lua.LuaManager");
        Object env = lua.getField("env").get(null);
        Object fixtures = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeFixtures");
        check(fixtures instanceof List<?>, "Native fixture list missing");
        List<?> objects = (List<?>) fixtures;
        check(objects.size() == 28, "Expected 24 native parts and four outline colliders");
        Class<?> iso = Class.forName("zombie.iso.IsoObject");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> worldType = Class.forName("zombie.iso.IsoWorld");
        Object cell = worldType.getField("currentCell").get(worldType.getField("instance").get(null));
        int version = ((Number)worldType.getMethod("getWorldVersion").invoke(null)).intValue();
        Files.createDirectories(directory);
        for (int i = 0; i < objects.size(); i++) {
            Object source = objects.get(i);
            Class<?> colorType = Class.forName("zombie.core.textures.ColorInfo");
            Object color = Class.forName("zombie.core.Core").getMethod("getWorldItemHighlightColor")
                .invoke(Class.forName("zombie.core.Core").getMethod("getInstance").invoke(null));
            call(source, "setHighlightColor", new Class<?>[]{int.class, colorType}, 0, color);
            call(source, "setOutlineHighlightCol", new Class<?>[]{int.class, colorType}, 0, color);
            for (boolean active : new boolean[]{true, false}) {
                call(source, "setHighlighted", new Class<?>[]{int.class, boolean.class, boolean.class}, 0, active, false);
                call(source, "setOutlineHighlight", new Class<?>[]{int.class, boolean.class}, 0, active);
                check(Boolean.valueOf(active).equals(call(source, "isHighlighted", new Class<?>[]{int.class}, 0)), "Native highlight state mismatch");
                check(Boolean.valueOf(active).equals(call(source, "isOutlineHighlight", new Class<?>[]{int.class}, 0)), "Native outline highlight state mismatch");
            }

            String sprite = (String)get(source, "getSpriteName");
            Object sourceConfig = get(source, "getSpriteConfig");
            Object square = get(source, "getSquare");
            Path file = directory.resolve("part-" + i + ".bin");
            if (mode.equals("write")) {
                ByteBuffer output = ByteBuffer.allocate(65536);
                iso.getMethod("save", ByteBuffer.class).invoke(source, output);
                Files.write(file, Arrays.copyOf(output.array(), output.position()));
            }
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(file));
            Object restored = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, input);
            check(restored != null, "Factory did not restore object type");
            iso.getMethod("setSquare", squareType).invoke(restored, square);
            iso.getMethod("load", ByteBuffer.class, int.class).invoke(restored, input, version);
            check(!input.hasRemaining(), "Unread serialized object bytes");
            check(sprite.equals(get(restored, "getSpriteName")), "Sprite identity lost: " + sprite);
            check(get(get(source, "getSprite"), "getID").equals(get(get(restored, "getSprite"), "getID")), "Tile ID changed");
            check(get(restored, "getHealth").equals(37), "Damaged health reset");
            check(get(restored, "getMaxHealth").equals(200), "Configured maximum health reset");
            check(get(source, "isBlockAllTheSquare").equals(get(restored, "isBlockAllTheSquare")), "Collision model lost");
            check(get(source, "getNorth").equals(get(restored, "getNorth")), "Native edge orientation lost");
            check(Boolean.FALSE.equals(get(restored, "isCanPassThrough")), "Pass-through changed");
            check(Boolean.FALSE.equals(get(restored, "isHoppable")), "Hopping changed");
            Object config = get(restored, "getSpriteConfig");
            if (i < 16 || i >= 20) {
                check(config != null && Boolean.TRUE.equals(get(config, "isValid")), "Native SpriteConfig invalid after load");
                check(sprite.equals(get(get(config, "getTileInfo"), "getSpriteName")), "Part identity changed");
                check(get(get(sourceConfig, "getObjectInfo"), "getName").equals(get(get(config, "getObjectInfo"), "getName")), "Entity changed");
            }
            Object data = get(restored, "getModData");
            if (i >= 20) check("reinforced".equals(call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTTier")), "Reinforced tier lost");
            check("fixture-owner".equals(call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTFixtureOwner")), "Owner marker lost");
            if (i >= 8 && i < 16) check("edge-v1".equals(call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTCollisionModel")), "Edge marker lost");
            if (i >= 16 && i < 20) {
                Object marker = call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTEdge");
                check("fixture".equals(call(marker, "rawget", new Class<?>[]{Object.class}, "id")), "Collider owner lost");
                check("1:1:0:N".equals(call(marker, "rawget", new Class<?>[]{Object.class}, "anchor")), "Collider anchor lost");
                check("cap".equals(call(marker, "rawget", new Class<?>[]{Object.class}, "role")), "Collider role lost");
                check(Boolean.FALSE.equals(get(restored, "isCanPassThrough")), "Collider passability changed");
            }
        }
        System.out.println("[OMHTT-Smoke] native-persistence mode=" + mode + " parts=28 health=37 maxHealth=200 identity=valid collision=preserved owner=preserved legacy=8 edges=8 outline=4 reinforced=8 orientation=preserved");
    }

    public static void main(String[] args) throws Exception {
        javax.imageio.ImageIO.setUseCache(false);
        Path directory = Path.of(args[0]);
        String mode = args[1];
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try { verify(directory, mode); }
            catch (Throwable error) { error.printStackTrace(); }
        }, "OMHTT-isolated-persistence-proof"));
        Method main = Class.forName("zombie.network.GameServer").getMethod("main", String[].class);
        main.invoke(null, (Object)Arrays.copyOfRange(args, 2, args.length));
    }
}
