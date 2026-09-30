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
        verifyTurret(directory, mode);
        verifyHybrid(directory, mode);
        NativeVaultProbe.verify();
        NativeTurretProbe.verify();
        Object pack = Class.forName("zombie.fileSystem.TexturePackDevice").getConstructor(String.class, int.class).newInstance("OMHTT_Barriers", 0);
        Class<?> entriesType = Class.forName("zombie.fileSystem.FileSystem$TexturePackTextures");
        Object entries = entriesType.getConstructor().newInstance();
        call(pack, "getSubTextureInfo", new Class<?>[]{entriesType}, entries);
        check(((java.util.Map<?, ?>)entries).size() == 49, "Native texture pack metadata did not load");
        for (int index = 0; index < 49; index++) {
            Object entry = ((java.util.Map<?, ?>)entries).get("omhtt_barrier_01_" + index);
            String expected = index == 48 ? "OMHTT_ProbeBase" : index >= 44 ? "OMHTT_TestCube" : index >= 28 ? "OMHTT_Aim" + (index - 28)
                : index >= 20 ? "OMHTT_ReinforcedBarrier" + ((index - 20) / 2)
                : index >= 16 ? "OMHTT_Edges" : "OMHTT_Barrier" + ((index % 8) / 2);
            check(entry != null && expected.equals(entry.getClass().getField("pageName").get(entry)), "Sprite mapped to wrong tier page: " + index);
        }

        for (int page = 0; page < 26; page++) {
            String name = page < 4 ? "OMHTT_Barrier" + page : page < 8 ? "OMHTT_ReinforcedBarrier" + (page - 4)
                : page < 24 ? "OMHTT_Aim" + (page - 8) : page == 24 ? "OMHTT_TestCube" : "OMHTT_ProbeBase";
            try (var stream = (java.io.InputStream)call(pack, "createStream", new Class<?>[]{String.class, java.io.InputStream.class}, name, null)) {
                var image = javax.imageio.ImageIO.read(stream);
                check(image != null && image.getWidth() == 128 && image.getHeight() == 256, "Native texture page unreadable");
            }
        }
        try (var stream = (java.io.InputStream)call(pack, "createStream", new Class<?>[]{String.class, java.io.InputStream.class}, "OMHTT_Edges", null)) {
            var image = javax.imageio.ImageIO.read(stream);
            check(image != null && image.getWidth() == 256 && image.getHeight() == 256, "Native outline texture page unreadable");
        }
        System.out.println("[OMHTT-Smoke] native-texturepack entries=49 pages=27 png=valid");
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

    private static void verifyTurret(Path directory, String mode) throws Exception {
        Class<?> lua = Class.forName("zombie.Lua.LuaManager");
        Object env = lua.getField("env").get(null);
        Object source = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeTurret");
        check(source != null, "Native turret fixture missing");
        Files.createDirectories(directory);
        Path file = directory.resolve("turret.bin");
        Class<?> iso = Class.forName("zombie.iso.IsoObject");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> world = Class.forName("zombie.iso.IsoWorld");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(262144);
            iso.getMethod("save", ByteBuffer.class).invoke(source, output);
            Files.write(file, Arrays.copyOf(output.array(), output.position()));
        }
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(file));
        Object restored = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, input);
        iso.getMethod("setSquare", squareType).invoke(restored, get(source, "getSquare"));
        iso.getMethod("load", ByteBuffer.class, int.class).invoke(restored, input, version);
        check(!input.hasRemaining(), "Unread turret bytes");
        check(get(restored, "getHealth").equals(37), "Turret health lost");
        check("omhtt_barrier_01_28".equals(get(restored, "getSpriteName")), "Turret sprite lost");
        Object state = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTTurret");
        check(Boolean.FALSE.equals(call(state, "rawget", new Class<?>[]{Object.class}, "automatic")), "Automatic switch lost");
        check("Toughest".equals(call(state, "rawget", new Class<?>[]{Object.class}, "priority")), "Target priority lost");
        check(((Number)call(state, "rawget", new Class<?>[]{Object.class}, "baseFacing")).intValue() == 4, "Placement cone orientation lost");
        check(Double.valueOf(123456789).equals(call(state, "rawget", new Class<?>[]{Object.class}, "nextShot")), "Turret cooldown lost");
        List<?> items = (List<?>)get(get(restored, "getContainer"), "getItems");
        check(items.size() == 8, "Turret contents lost or duplicated");
        boolean battery = false, ammo = false, head = false;
        for (Object item : items) {
            if ("Base.CarBattery1".equals(get(item, "getFullType"))) {
                battery = true;
                check(Math.abs(((Number)get(item, "getCurrentUsesFloat")).doubleValue() - 0.37) < 0.00001, "Battery charge reset");
                check(((Number)get(item, "getID")).intValue() == ((Number)call(state, "rawget", new Class<?>[]{Object.class}, "fixtureBatteryId")).intValue(), "Battery identity changed");
            }
            if ("Base.Potato".equals(get(item, "getFullType"))) {
                ammo = true;
                check(((Number)get(item, "getID")).intValue() == ((Number)call(state, "rawget", new Class<?>[]{Object.class}, "fixtureAmmoId")).intValue(), "Ammo identity changed");
            }
        }
        for (Object item : items) {
            if ("Base.OMHTTPotatoHead".equals(get(item, "getFullType"))) {
                Object cycle = call(get(item, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTCycle");
                check(cycle != null && Double.valueOf(1).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "loaded")), "Head magazine lost");
                check(Double.valueOf(123456789).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "nextShot")), "Head cooldown lost");
                check(Double.valueOf(750).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "cooldownDuration")), "Modified cooldown duration lost");
                check(Double.valueOf(750).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "reloadDuration")), "Modified reload duration lost");
                head = true;
            }
        }
        int rapid = 0, reload = 0, capacity = 0;
        for (Object item : items) {
            String fullType = (String)get(item, "getFullType");
            if (fullType.equals("Base.OMHTTModuleRapidFire")) rapid++;
            if (fullType.equals("Base.OMHTTModuleReload")) reload++;
            if (fullType.equals("Base.OMHTTModuleCapacity")) capacity++;
        }
        check(rapid == 2 && reload == 2 && capacity == 1, "Stacked modules or expansion lost");
        check(battery && ammo && head, "Missing ammunition, battery or head cycle");
        Object packed = Class.forName("zombie.inventory.InventoryItemFactory").getMethod("CreateItem", String.class).invoke(null, "Base.OMHTTTurretBase");
        Object packedInventory = get(packed, "getInventory");
        Object worldInventory = get(restored, "getContainer");
        Class<?> itemType = Class.forName("zombie.inventory.InventoryItem");
        for (Object item : new java.util.ArrayList<>(items)) {
            call(worldInventory, "Remove", new Class<?>[]{itemType}, item);
            call(packedInventory, "AddItem", new Class<?>[]{itemType}, item);
        }
        call(packed, "setCondition", new Class<?>[]{int.class}, 37);
        call(get(packed, "getModData"), "rawset", new Class<?>[]{Object.class, Object.class}, "OMHTTTurret", state);
        Path packedFile = directory.resolve("packed-turret.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(262144);
            call(packed, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(packedFile, Arrays.copyOf(output.array(), output.position()));
        }
        ByteBuffer packedInput = ByteBuffer.wrap(Files.readAllBytes(packedFile));
        Object packedRestored = itemType.getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, packedInput, version);
        check(!packedInput.hasRemaining() && get(packedRestored, "getCondition").equals(37), "Portable turret condition/stream mismatch");
        List<?> packedItems = (List<?>)get(get(packedRestored, "getInventory"), "getItems");
        check(packedItems.size() == 8, "Portable turret lost contents");
        Object packedState = call(get(packedRestored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTTurret");
        check(Boolean.FALSE.equals(call(packedState, "rawget", new Class<?>[]{Object.class}, "automatic")), "Packed automatic switch lost");
        check("Toughest".equals(call(packedState, "rawget", new Class<?>[]{Object.class}, "priority")), "Packed priority lost");
        check(((Number)call(packedState, "rawget", new Class<?>[]{Object.class}, "baseFacing")).intValue() == 4, "Packed orientation lost");
        check(Double.valueOf(123456789).equals(call(packedState, "rawget", new Class<?>[]{Object.class}, "nextShot")), "Portable turret lost cooldown");
        for (Object item : packedItems) {
            if ("Base.CarBattery1".equals(get(item, "getFullType"))) {
                check(Math.abs(((Number)get(item, "getCurrentUsesFloat")).doubleValue() - 0.37) < 0.00001, "Portable battery charge reset");
                check(((Number)get(item, "getID")).intValue() == ((Number)call(packedState, "rawget", new Class<?>[]{Object.class}, "fixtureBatteryId")).intValue(), "Portable battery identity changed");
            }
        }
        double total = ((Number)get(packedRestored, "getUnequippedWeight")).doubleValue();
        double expectedWeight = ((Number)get(packedRestored, "getActualWeight")).doubleValue()
            + ((Number)get(get(packedRestored, "getInventory"), "getContentsWeight")).doubleValue();
        check(Math.abs(total - expectedWeight) < 0.001, "Portable weight double counted");
        System.out.println("[OMHTT-Smoke] native-packed-turret mode=" + mode + " items=8 charge=preserved condition=37 cooldown=preserved weight=exact");
        System.out.println("[OMHTT-Smoke] native-turret-persistence mode=" + mode + " items=8 charge=0.37 health=37 cooldown=preserved identity=exact sprite=valid");
    }

    private static void verifyHybrid(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object source = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeHybridHead");
        check(source != null, "Hybrid fixture missing");
        Class<?> iso = Class.forName("zombie.iso.IsoObject");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> world = Class.forName("zombie.iso.IsoWorld");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        Path file = directory.resolve("hybrid-head.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(65536);
            iso.getMethod("save", ByteBuffer.class).invoke(source, output);
            Files.write(file, Arrays.copyOf(output.array(), output.position()));
        }
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(file));
        Object restored = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, input);
        iso.getMethod("setSquare", squareType).invoke(restored, get(source, "getSquare"));
        iso.getMethod("load", ByteBuffer.class, int.class).invoke(restored, input, version);
        Object item = get(restored, "getItem");
        check(!input.hasRemaining(), "Unread hybrid stream bytes");
        check(((Number)get(item, "getWorldZRotation")).intValue() == 135, "Hybrid yaw not saved");
        check(Math.abs(item.getClass().getField("worldScale").getFloat(item) - 1.25f) < 0.00001, "Hybrid scale not saved");
        check(Math.abs(((Number)get(restored, "getWorldPosZ")).doubleValue() - 0.3) < 0.00001, "Hybrid height not saved");
        check(get(get(source, "getItem"), "getWorldStaticItem").equals(get(item, "getWorldStaticItem")), "Hybrid model identity not saved");
        check("native-probe".equals(call(get(item, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTHybridProbe")), "Hybrid link not saved");
        System.out.println("[OMHTT-Smoke] native-hybrid-persistence mode=" + mode + " yaw=135 scale=1.25 height=0.3 model=preserved link=preserved");
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
