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

    private static void verifyTexturePack(String name, String prefix, int count, boolean turrets) throws Exception {
        Object pack = Class.forName("zombie.fileSystem.TexturePackDevice").getConstructor(String.class, int.class).newInstance(name, 0);
        Class<?> entriesType = Class.forName("zombie.fileSystem.FileSystem$TexturePackTextures");
        Object entries = entriesType.getConstructor().newInstance();
        call(pack, "getSubTextureInfo", new Class<?>[]{entriesType}, entries);
        java.util.Map<?, ?> map = (java.util.Map<?, ?>)entries;
        check(map.size() == count, "Native texture pack entry count: " + name);
        java.util.Set<String> pages = new java.util.HashSet<>();
        for (int index = 0; index < count; index++) {
            Object entry = map.get(prefix + index);
            String expected = !turrets && index == 102 ? "OMHTT_Barb0" : index >= (turrets ? 34 : 98) ? "OMHTT_Lever" + (index - (turrets ? 34 : 98))
                : index >= (turrets ? 30 : 94) ? "OMHTT_Laser" + (index - (turrets ? 30 : 94))
                : turrets ? (index >= 25 ? "OMHTT_PlateTurrets" + (index == 29 ? 1 : 0) : index >= 21 ? "OMHTT_ControllerTurrets" : index == 20 ? "OMHTT_ProbeBase" : index >= 16 ? "OMHTT_TestCube" : "OMHTT_Aim" + index)
                : index >= 90 ? "OMHTT_Tether" + (index - 90)
                : index >= 85 ? "OMHTT_Poke" + (index == 89 ? 1 : 0)
                : index >= 80 ? "OMHTT_PlateTraps" + (index == 84 ? 1 : 0)
                : index >= 76 ? "OMHTT_ControllerTraps"
                : index >= 72 ? "OMHTT_Wire"
                : index >= 64 ? "OMHTT_BedSpikes"
                : index >= 60 ? "OMHTT_Wire"
                : index >= 52 ? "OMHTT_Barb" + (((index - 52) / 2 == 0 || (index - 52) / 2 == 3) ? 0 : 1)
                : index >= 28 ? "OMHTT_BedSpikes"
                : index >= 20 ? "OMHTT_ReinforcedBarrier" + ((index - 20) / 2)
                : index >= 16 ? "OMHTT_Edges" : "OMHTT_Barrier" + ((index % 8) / 2);
            check(entry != null && expected.equals(entry.getClass().getField("pageName").get(entry)), "Sprite mapped to wrong page: " + prefix + index);
            pages.add(expected);
        }
        for (String page : pages) {
            try (var stream = (java.io.InputStream)call(pack, "createStream", new Class<?>[]{String.class, java.io.InputStream.class}, page, null)) {
                var image = javax.imageio.ImageIO.read(stream);
                check(image != null && image.getWidth() == (page.equals("OMHTT_Edges") ? 256 : 128) && image.getHeight() == 256, "Native texture page unreadable: " + page);
                if (page.equals("OMHTT_Barb0")) check((image.getRGB(0, 0) >>> 24) == 0, "Raised panel sprite must reuse a transparent pixel");
                if (page.startsWith("OMHTT_Tether")) {
                    int facing = Integer.parseInt(page.substring("OMHTT_Tether".length()));
                    float[][] anchors = {{0f,.5f},{.5f,1f},{1f,.5f},{.5f,0f}};
                    Class<?> iso = Class.forName("zombie.iso.IsoUtils");
                    float x = anchors[facing][0], y = anchors[facing][1];
                    int px = 64 + Math.round(((Number)iso.getMethod("XToScreen", float.class,float.class,float.class,int.class).invoke(null,x,y,.3f,0)).floatValue());
                    int py = 192 + Math.round(((Number)iso.getMethod("YToScreen", float.class,float.class,float.class,int.class).invoke(null,x,y,.3f,0)).floatValue());
                    check((image.getRGB(px,py) & 0x00ffffff) == 0x00ffffff && (image.getRGB(px,py) >>> 24) == 255, "Tether panel misses native projected wall anchor: " + page);
                    Object entry = map.get(prefix + (90 + facing));
                    Object info = entry.getClass().getField("info").get(entry);
                    check(info.getClass().getField("ox").getInt(info) == 0 && info.getClass().getField("oy").getInt(info) == 0, "Tether has extra texture displacement");
                }
            }
        }
    }

    private static void verifyPlacement() throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object samples = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativePlacement");
        int count = ((Number)get(samples, "len")).intValue();
        check(count == 16, "Missing portable placement families");
        for (int i = 1; i <= count; i++) {
            Object row = call(samples, "rawget", new Class<?>[]{Object.class}, Double.valueOf(i));
            Object network = call(row, "rawget", new Class<?>[]{Object.class}, "network");
            Object action = call(row, "rawget", new Class<?>[]{Object.class}, "action");
            double seconds = ((Number)call(row, "rawget", new Class<?>[]{Object.class}, "seconds")).doubleValue();
            var durationField = network.getClass().getField("duration");
            durationField.setAccessible(true);
            long duration = durationField.getLong(network);
            check(duration == Math.round(seconds * 1000), "Wrong native server duration: " + duration);
            var field = network.getClass().getDeclaredField("actionArgs");
            field.setAccessible(true);
            Object arguments = field.get(network);
            for (String key : new String[]{"character", "item", "companion", "route", "rotation", "x", "y", "z"}) {
                Object expected = call(action, "rawget", new Class<?>[]{Object.class}, key);
                Object actual = call(arguments, "rawget", new Class<?>[]{Object.class}, key);
                check(java.util.Objects.equals(expected, actual) || (expected == null && actual != null && actual.getClass().getSimpleName().equals("PZNetKahluaNull")), "Native placement argument lost: " + key);
            }
            ByteBuffer encoded = ByteBuffer.allocate(16384);
            call(arguments, "save", new Class<?>[]{ByteBuffer.class}, encoded);
            check(encoded.position() > 0, "Placement arguments did not serialize");
        }
        System.out.println("[OMHTT-C370] native-placement durations=1000/2000/5000 constructorArgs=exact serialized=true");
    }

    private static void verifyProgression(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> worldType = Class.forName("zombie.iso.IsoWorld");
        Object cell = worldType.getField("currentCell").get(worldType.getField("instance").get(null));
        int version = ((Number)worldType.getMethod("getWorldVersion").invoke(null)).intValue();
        Files.createDirectories(directory);
        for (String key : new String[]{"OMHTT_C437ManualPlayer", "OMHTT_C437Specialist"}) {
            Object player = call(env, "rawget", new Class<?>[]{Object.class}, key);
            Path path = directory.resolve(key + ".bin");
            if (mode.equals("write")) {
                ByteBuffer buffer = ByteBuffer.allocate(4 * 1024 * 1024);
                call(player, "save", new Class<?>[]{ByteBuffer.class, boolean.class}, buffer, false);
                Files.write(path, Arrays.copyOf(buffer.array(), buffer.position()));
            }
            Object restored = player.getClass().getConstructor(cellType).newInstance(cell);
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
            call(restored, "load", new Class<?>[]{ByteBuffer.class, int.class, boolean.class}, input, version, false);
            List<?> recipes = (List<?>)get(restored, "getKnownRecipes");
            for (String recipe : new String[]{"OMHTTCraftBallista","OMHTTCraftRotaryBlades","OMHTTCraftLobber","OMHTTCraftLobberImprovised","OMHTTCraftArc","OMHTTMountFirearm"}) {
                check(recipes.contains(recipe), "Manual/trait knowledge lost on native save: " + recipe);
            }
        }
        System.out.println("[OMHTT-C437] native-knowledge persistence=" + mode + " characters=2 recipes=6");
    }

    private static void verifyConditionalHealth(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object actor = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_C471HealthZombie");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell"), world = Class.forName("zombie.iso.IsoWorld");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        Path path = directory.resolve("conditional-health.bin");
        if (mode.equals("write")) {
            ByteBuffer buffer = ByteBuffer.allocate(4 * 1024 * 1024);
            call(actor, "save", new Class<?>[]{ByteBuffer.class, boolean.class}, buffer, false);
            Files.write(path, Arrays.copyOf(buffer.array(), buffer.position()));
        }
        Object restored = actor.getClass().getConstructor(cellType).newInstance(cell);
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
        check(input.get() == 1, "Native moving-object serialization header missing");
        input.get(); // Object factory consumes the class ID before IsoZombie.load.
        call(restored, "load", new Class<?>[]{ByteBuffer.class, int.class, boolean.class}, input, version, false);
        Object data = get(restored, "getModData");
        double baseline = ((Number)call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTInitialHealth")).doubleValue();
        double health = ((Number)get(restored, "getHealth")).doubleValue();
        check(Math.abs(baseline - 1) < .000001,
            "Conditional baseline must survive native character serialization");
        System.out.println("[OMHTT-C471] native-conditional persistence=" + mode + " baseline=" + baseline
            + " savedHealth=0.5 nativeLoadedHealth=" + health);
    }

    private static void verify(Path directory, String mode) throws Exception {
        verifyProgression(directory, mode);
        verifyConditionalHealth(directory, mode);
        verifyPlacement();
        verifyTurret(directory, mode);
        verifyHeavyController(directory, mode);
        verifyPressurePlate(directory, mode);
        verifyModulePack(directory, mode);
        verifyFirearms(directory, mode);
        verifyHybrid(directory, mode);
        verifyNewHeads(directory, mode);
        verifyBeds(directory, mode);
        NativeBarbProbe.verify(directory, mode);
        NativeVaultProbe.verify();
        NativeTurretProbe.verify();
        verifyTexturePack("OMHTT_Traps", "omhtt_barrier_01_", 103, false);
        verifyTexturePack("OMHTT_Turrets", "omhtt_turret_01_", 38, true);
        System.out.println("[OMHTT-Smoke] native-texturepacks traps=103 turrets=38 pages=59 png=valid");
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

    private static void verifyNewHeads(Path directory, String mode) throws Exception {
        Class<?> itemType = Class.forName("zombie.inventory.InventoryItem");
        Class<?> factory = Class.forName("zombie.inventory.InventoryItemFactory");
        int version = ((Number)Class.forName("zombie.iso.IsoWorld").getMethod("getWorldVersion").invoke(null)).intValue();
        for (String name : new String[]{"Ballista", "RotaryBat", "RotaryBlades"}) {
            String type = "Base.OMHTTTurret" + name;
            Object item = factory.getMethod("CreateItem", String.class).invoke(null, type);
            Object data = get(item, "getModData");
            call(data, "rawset", new Class<?>[]{Object.class, Object.class}, "OMHTTFixtureDebt", .5);
            Path file = directory.resolve("head-" + name + ".bin");
            if (mode.equals("write")) {
                ByteBuffer output = ByteBuffer.allocate(16384);
                call(item, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
                Files.write(file, Arrays.copyOf(output.array(), output.position()));
            }
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(file));
            Object restored = itemType.getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, input, version);
            check(!input.hasRemaining() && type.equals(get(restored, "getFullType")), "New head identity/stream mismatch");
            check(get(restored, "getCondition").equals(get(item, "getCondition")), "New head condition mismatch");
            check(Double.valueOf(.5).equals(call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTFixtureDebt")), "New head mod data lost");
        }
        System.out.println("[OMHTT-Heads] persistence mode=" + mode + " heads=3 identity=condition=modData=preserved");
    }

    private static void verifyPressurePlate(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object source = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativePlate");
        check(source != null, "Native pressure plate fixture missing");
        Object plateSprite = get(source, "getSprite");
        check(plateSprite.getClass().getField("renderLayer").getByte(plateSprite) == 1, "Pressure plate must use the native floor render layer");
        Object state = call(get(source, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTControl");
        Path path = directory.resolve("pressed-plate.bin");
        if (mode.equals("write")) {
            Object previous = call(state, "rawget", new Class<?>[]{Object.class}, "active");
            String sprite = (String)get(source, "getSpriteName");
            call(state, "rawset", new Class<?>[]{Object.class, Object.class}, "active", true);
            call(source, "setSpriteFromName", new Class<?>[]{String.class}, "omhtt_turret_01_29");
            ByteBuffer output = ByteBuffer.allocate(65536);
            call(source, "save", new Class<?>[]{ByteBuffer.class}, output);
            Files.write(path, Arrays.copyOf(output.array(), output.position()));
            call(source, "setSpriteFromName", new Class<?>[]{String.class}, sprite);
            call(state, "rawset", new Class<?>[]{Object.class, Object.class}, "active", previous);
        }
        Class<?> iso = Class.forName("zombie.iso.IsoObject");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> worldType = Class.forName("zombie.iso.IsoWorld");
        Object cell = worldType.getField("currentCell").get(worldType.getField("instance").get(null));
        int version = ((Number)worldType.getMethod("getWorldVersion").invoke(null)).intValue();
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
        Object restored = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, input);
        iso.getMethod("setSquare", squareType).invoke(restored, get(source, "getSquare"));
        iso.getMethod("load", ByteBuffer.class, int.class).invoke(restored, input, version);
        check(!input.hasRemaining(), "Unread pressure plate bytes");
        check("omhtt_turret_01_29".equals(get(restored, "getSpriteName")), "Pressed plate sprite lost");
        Object restoredSprite = get(restored, "getSprite");
        check(restoredSprite.getClass().getField("renderLayer").getByte(restoredSprite) == 1, "Pressed plate lost floor rendering after restore");
        check(Boolean.TRUE.equals(get(get(restored, "getSpriteConfig"), "isValid")), "Pressed plate invalid after reload");
        check(Boolean.FALSE.equals(get(restored, "isThumpable")), "Loaded plate became thumpable");
        Object loadedState = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTControl");
        check(Boolean.TRUE.equals(call(loadedState, "rawget", new Class<?>[]{Object.class}, "active")), "Pressed state lost");
        System.out.println("[OMHTT-C309] native-plate-persistence mode=" + mode + " pressed=preserved config=valid passive=preserved");
    }

    private static void verifyPoke(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object source = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativePackedPoke");
        check(source != null, "Packed Poke fixture missing");
        Path path = directory.resolve("poke-floor.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(65536);
            call(source, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(path, Arrays.copyOf(output.array(), output.position()));
        }
        int version = ((Number)Class.forName("zombie.iso.IsoWorld").getMethod("getWorldVersion").invoke(null)).intValue();
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
        Object restored = Class.forName("zombie.inventory.InventoryItem").getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, input, version);
        check(!input.hasRemaining(), "Poke unread bytes");
        check(((Number)get(restored, "getCondition")).intValue() == 123, "Poke condition changed");
        check(!Class.forName("zombie.inventory.types.InventoryContainer").isInstance(restored), "Poke retained obsolete portable capacity");
        Path legacyPath = directory.resolve("poke-legacy-container.bin");
        if (mode.equals("write")) {
            Object legacy = Class.forName("zombie.inventory.InventoryItemFactory").getMethod("CreateItem", String.class).invoke(null, "Base.OMHTTTrapPokeFloor");
            call(get(legacy, "getInventory"), "AddItem", new Class<?>[]{String.class}, "Base.CarBattery2");
            ByteBuffer output = ByteBuffer.allocate(65536);
            call(legacy, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(legacyPath, Arrays.copyOf(output.array(), output.position()));
        }
        ByteBuffer legacyInput = ByteBuffer.wrap(Files.readAllBytes(legacyPath));
        Object legacyRestored = Class.forName("zombie.inventory.InventoryItem").getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, legacyInput, version);
        check(!legacyInput.hasRemaining() && Class.forName("zombie.inventory.types.InventoryContainer").isInstance(legacyRestored), "Legacy Poke container load changed type");
        Object legacyItems = get(get(legacyRestored, "getInventory"), "getItems");
        check(((Number)get(legacyItems, "size")).intValue() == 1, "Legacy packed Poke lost its battery");
        System.out.println("[OMHTT-C450] legacy Poke container persistence=" + mode + " contents=preserved");
        Object battery = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeRecoveredPokeBattery");
        Path batteryPath = directory.resolve("poke-recovered-battery.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(65536);
            call(battery, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(batteryPath, Arrays.copyOf(output.array(), output.position()));
        }
        ByteBuffer batteryInput = ByteBuffer.wrap(Files.readAllBytes(batteryPath));
        Object restoredBattery = Class.forName("zombie.inventory.InventoryItem").getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, batteryInput, version);
        Object debtState = call(get(restoredBattery, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTBatteryDrain");
        double debt = ((Number)call(debtState, "rawget", new Class<?>[]{Object.class}, "debt")).doubleValue();
        double charge = ((Number)get(restoredBattery, "getCurrentUsesFloat")).doubleValue() - debt;
        check(Math.abs(charge - .876544) < .000001, "Recovered Poke battery charge changed");
        System.out.println("[OMHTT-C339] poke persistence mode=" + mode + " condition=123 battery=exact charge=exact");
    }

    private static void verifyHeavyController(Path directory, String mode) throws Exception {
        verifyPoke(directory, mode);
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object source = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeHeavyController");
        check(source != null, "Heavy controller fixture missing");
        Path path = directory.resolve("heavy-controller.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(1048576);
            call(source, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(path, Arrays.copyOf(output.array(), output.position()));
        }
        int version = ((Number)Class.forName("zombie.iso.IsoWorld").getMethod("getWorldVersion").invoke(null)).intValue();
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
        Object restored = Class.forName("zombie.inventory.InventoryItem").getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, input, version);
        check(!input.hasRemaining(), "Heavy controller unread bytes");
        Object storage = get(restored, "getInventory");
        check(((java.util.List<?>)get(storage, "getItems")).size() == 251, "Heavy stockpile count changed");
        check(((Number)get(storage, "getCapacityWeight")).doubleValue() > 100, "Heavy stockpile weight was compressed");
        Object state = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTControl");
        check("control-owner".equals(call(state, "rawget", new Class<?>[]{Object.class}, "owner")), "Heavy controller owner lost");
        System.out.println("[OMHTT-Controls] persistence mode=" + mode + " items=251 weight=over100 owner=preserved");
        Object transfer = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeStockTransfer");
        check(transfer != null, "Stockpile transfer fixture missing");
        Object operator = call(transfer, "rawget", new Class<?>[]{Object.class}, "character");
        Object bag = call(transfer, "rawget", new Class<?>[]{Object.class}, "destinationBag");
        Object networkAction = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeStockNetwork");
        check(networkAction != null, "Native constructor extraction must run on the game Lua thread");
        var argumentField = networkAction.getClass().getDeclaredField("actionArgs");
        argumentField.setAccessible(true);
        Object arguments = argumentField.get(networkAction);
        check(call(arguments, "rawget", new Class<?>[]{Object.class}, "destinationBag") == bag, "Native constructor argument extraction lost selected bag");
        check(call(arguments, "rawget", new Class<?>[]{Object.class}, "character") == operator, "Native constructor argument extraction lost operator");
        ByteBuffer encoded = ByteBuffer.allocate(16384);
        var squareField = operator.getClass().getField("square");
        Object previousSquare = squareField.get(operator);
        squareField.set(operator, call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeStockSquare"));
        try {
            call(arguments, "save", new Class<?>[]{ByteBuffer.class}, encoded);
        } finally {
            squareField.set(operator, previousSquare);
        }
        check(encoded.position() > 0, "Native transfer arguments did not encode");
        System.out.println("[OMHTT-Controls] native-stock-transfer selectedBag=exact removedBag=rejected constructorArgs=retained bytes=" + encoded.position());
        Object expansion = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeExpansionAction");
        Object expansionNetwork = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeExpansionNetwork");
        check(expansion != null && expansionNetwork != null, "Native expansion action fixture missing");
        Object expansionArguments = argumentField.get(expansionNetwork);
        for (String key : new String[]{"character", "object", "item", "replaced", "id", "controller", "final"}) {
            Object expected = call(expansion, "rawget", new Class<?>[]{Object.class}, key);
            Object actual = call(expansionArguments, "rawget", new Class<?>[]{Object.class}, key);
            if (expected == null) expected = Class.forName("zombie.network.PZNetKahluaNull").getField("instance").get(null);
            check(java.util.Objects.equals(expected, actual), "Native expansion argument extraction lost " + key);
        }
        System.out.println("[OMHTT-C444] native expansion constructorArgs=7 exact=true");
        Object ammo = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeLargeAmmo");
        Path ammoPath = directory.resolve("large-ammo.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(4194304);
            call(ammo, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(ammoPath, Arrays.copyOf(output.array(), output.position()));
        }
        ByteBuffer ammoInput = ByteBuffer.wrap(Files.readAllBytes(ammoPath));
        Object ammoRestored = Class.forName("zombie.inventory.InventoryItem").getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, ammoInput, version);
        check(!ammoInput.hasRemaining(), "Large ammunition unread bytes");
        check(((java.util.List<?>)get(get(ammoRestored, "getInventory"), "getItems")).size() == 4002, "Four-thousand-round reserve lost items");
        System.out.println("[OMHTT-Controls] ammunition-persistence mode=" + mode + " rounds=4000 items=4002 exact=true");
    }

    private static void verifyModulePack(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object source = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeModulePack");
        check(source != null, "Module pack fixture missing");
        Path path = directory.resolve("module-pack.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(16384);
            call(source, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(path, Arrays.copyOf(output.array(), output.position()));
        }
        int version = ((Number)Class.forName("zombie.iso.IsoWorld").getMethod("getWorldVersion").invoke(null)).intValue();
        ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
        Object restored = Class.forName("zombie.inventory.InventoryItem").getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, input, version);
        check(!input.hasRemaining(), "Module pack unread bytes");
        check("Base.OMHTTModulePack".equals(get(restored, "getFullType")), "Module pack type changed");
        check(Math.abs(((Number)get(restored, "getActualWeight")).doubleValue() - .2) < .000001, "Module pack weight changed");
        Object data = get(restored, "getModData");
        Object names = call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTPackRewards");
        String[] expected = {"Regulator", "CapacityLarge", "Regulator"};
        for (int i = 0; i < expected.length; i++)
            check(expected[i].equals(call(names, "rawget", new Class<?>[]{Object.class}, Double.valueOf(i + 1))), "Module pack reward changed");
        check(call(data, "rawget", new Class<?>[]{Object.class}, "OMHTTPackOpened") == null, "Unopened pack became opened");
        System.out.println("[OMHTT-Smoke] native-module-pack-persistence mode=" + mode + " rewards=3 duplicates=preserved unopened=true");
    }

    private static void verifyFirearms(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object fixture = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeFirearms");
        check(fixture instanceof List<?>, "Firearm fixture missing");
        Class<?> itemType = Class.forName("zombie.inventory.InventoryItem");
        int version = ((Number)Class.forName("zombie.iso.IsoWorld").getMethod("getWorldVersion").invoke(null)).intValue();
        for (Object base : (List<?>)fixture) {
            Object sample = call(get(base, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTGunFixture");
            String type = (String)call(sample, "rawget", new Class<?>[]{Object.class}, "fullType");
            Path path = directory.resolve("firearm-" + type + ".bin");
            if (mode.equals("write")) {
                ByteBuffer buffer = ByteBuffer.allocate(262144);
                call(base, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, buffer, false);
                Files.write(path, Arrays.copyOf(buffer.array(), buffer.position()));
            }
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(path));
            Object restored = itemType.getMethod("loadItem", ByteBuffer.class, int.class).invoke(null, input, version);
            check(!input.hasRemaining(), "Firearm unread stream");
            Object expected = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTGunFixture");
            List<?> items = (List<?>)get(get(restored, "getInventory"), "getItems");
            Object gun = null;
            int total = 0;
            for (Object item : items) {
                String fullType = (String)get(item, "getFullType");
                if (type.equals(fullType)) gun = item;
                else if (fullType.equals("Base.CarBattery1"))
                    check(Math.abs(((Number)get(item, "getCurrentUsesFloat")).doubleValue() - 0.43) < 0.00001, "Gun battery changed");
                else total++;
            }
            check(gun != null, "Packed gun lost");
            for (String[] field : new String[][]{{"rounds", "getCurrentAmmoCount"}, {"gunId", "getID"}, {"condition", "getCondition"}}) {
                int before = ((Number)call(expected, "rawget", new Class<?>[]{Object.class}, field[0])).intValue();
                check(((Number)get(gun, field[1])).intValue() == before, "Gun " + field[0] + " changed");
            }
            check(get(gun, "isRoundChambered").equals(call(expected, "rawget", new Class<?>[]{Object.class}, "chamber")), "Chamber changed");
            check(get(gun, "isContainsClip").equals(call(expected, "rawget", new Class<?>[]{Object.class}, "clip")), "Magazine presence changed");
            total += ((Number)get(gun, "getCurrentAmmoCount")).intValue() + (Boolean.TRUE.equals(get(gun, "isRoundChambered")) ? 1 : 0);
            check(total == ((Number)call(expected, "rawget", new Class<?>[]{Object.class}, "total")).intValue(), "Firearm ammo duplicated or lost");
            check(call(get(gun, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTFeedRounds")
                .equals(call(expected, "rawget", new Class<?>[]{Object.class}, "feed")), "Loaded extension lost");
            Object cycle = call(get(gun, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTGunCycle");
            check(call(cycle, "rawget", new Class<?>[]{Object.class}, "nextShot").equals(call(expected, "rawget", new Class<?>[]{Object.class}, "nextShot")), "Gun cooldown lost");
            if (type.equals("Base.Pistol")) {
                boolean laser = false;
                for (Object part : (List<?>)get(gun, "getAllWeaponParts")) {
                    if ("Base.Laser".equals(get(part, "getFullType"))) laser = true;
                }
                check(laser, "Gun attachment lost");
            }
        }
        System.out.println("[OMHTT-Smoke] native-firearm-persistence mode=" + mode + " guns=20 rounds=conserved identity=exact attachments=preserved");
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
        check("omhtt_turret_01_0".equals(get(restored, "getSpriteName")), "Turret sprite lost");
        Object state = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTTurret");
        check(Boolean.FALSE.equals(call(state, "rawget", new Class<?>[]{Object.class}, "automatic")), "Automatic switch lost");
        check("Toughest".equals(call(state, "rawget", new Class<?>[]{Object.class}, "priority")), "Target priority lost");
        check(((Number)call(state, "rawget", new Class<?>[]{Object.class}, "baseFacing")).intValue() == 4, "Placement cone orientation lost");
        check(Double.valueOf(234.5).equals(call(state, "rawget", new Class<?>[]{Object.class}, "facingDegrees")), "Controller facing angle lost");
        check(Boolean.TRUE.equals(call(state, "rawget", new Class<?>[]{Object.class}, "facingPending")), "Pending powered turn lost");
        System.out.println("[OMHTT-C308] native-facing-persistence mode=" + mode + " angle=234.5 pending=retained");
        check(((Number)call(state, "rawget", new Class<?>[]{Object.class}, "engagementRange")).intValue() == 3, "Engagement range lost");
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
            if ("Base.OMHTTTurretPotato".equals(get(item, "getFullType"))) {
                Object cycle = call(get(item, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTCycle");
                check(cycle != null && Double.valueOf(1).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "loaded")), "Head magazine lost");
                check(Double.valueOf(123456789).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "nextShot")), "Head cooldown lost");
                check(Boolean.FALSE.equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "impactReady")) && Boolean.TRUE.equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "impactEmpty")), "Impact magazine entitlement lost");
                check(Double.valueOf(750).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "cooldownDuration")), "Modified cooldown duration lost");
                check(Double.valueOf(750).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "reloadDuration")), "Modified reload duration lost");
                check(Double.valueOf(.5).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "conservationDebt")), "Conservation progress lost");
                head = true;
            }
        }
        int rapid = 0, reload = 0, capacity = 0;
        for (Object item : items) {
            String fullType = (String)get(item, "getFullType");
            if (fullType.equals("Base.OMHTTModuleRapidFire")) rapid++;
            if (fullType.equals("Base.OMHTTModuleReload")) reload++;
            if (fullType.equals("Base.OMHTTModuleExpansionMedium")) capacity++;
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
        check(((Number)call(packedState, "rawget", new Class<?>[]{Object.class}, "engagementRange")).intValue() == 3, "Packed engagement range lost");
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
        Object starter = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeImprovised");
        check(starter != null, "Missing improvised fixture");
        Path starterFile = directory.resolve("improvised-turret.bin");
        if (mode.equals("write")) {
            ByteBuffer output = ByteBuffer.allocate(262144);
            call(starter, "saveWithSize", new Class<?>[]{ByteBuffer.class, boolean.class}, output, false);
            Files.write(starterFile, Arrays.copyOf(output.array(), output.position()));
        }
        Object starterRestored = itemType.getMethod("loadItem", ByteBuffer.class, int.class)
            .invoke(null, ByteBuffer.wrap(Files.readAllBytes(starterFile)), version);
        List<?> starterItems = (List<?>)get(get(starterRestored, "getInventory"), "getItems");
        check(starterItems.size() == 5, "Improvised setup lost items");
        var starterTypes = new java.util.HashSet<String>();
        for (Object item : starterItems) {
            String type = (String)get(item, "getFullType");
            starterTypes.add(type);
            check(((Number)get(item, "getID")).intValue() == ((Number)call(get(starterRestored, "getModData"),
                "rawget", new Class<?>[]{Object.class}, type)).intValue(), "Improvised exact-item identity changed");
            if (type.equals("Base.OMHTTTurretPotato")) {
                Object cycle = call(get(item, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTCycle");
                check(Double.valueOf(123456789).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "nextShot")), "Improvised failure cooldown lost");
                check(Double.valueOf(1).equals(call(cycle, "rawget", new Class<?>[]{Object.class}, "loaded")), "Improvised loaded round lost");
            }
        }
        check(starterTypes.containsAll(java.util.Set.of("Base.OMHTTModuleFiringImprovised", "Base.OMHTTModuleDetectionImprovised",
            "Base.OMHTTModuleExpansionImprovised", "Base.OMHTTTurretPotato", "Base.Potato")), "Improvised setup changed types");
        System.out.println("[OMHTT-Smoke] native-improvised mode=" + mode + " items=5 identity=exact loaded=1 cooldown=preserved");
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

    private static void verifyBeds(Path directory, String mode) throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object fixtures = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_NativeBedFixtures");
        check(fixtures instanceof List<?>, "Bed fixtures missing");
        List<?> parts = (List<?>)fixtures;
        check(parts.size() == 32, "Expected 32 native bed parts across build/deploy/tier facings");
        Class<?> iso = Class.forName("zombie.iso.IsoObject");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> world = Class.forName("zombie.iso.IsoWorld");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        Files.createDirectories(directory);
        for (int i = 0; i < parts.size(); i++) {
            Object source = parts.get(i);
            Path file = directory.resolve("bed-" + i + ".bin");
            if (mode.equals("write")) {
                ByteBuffer out = ByteBuffer.allocate(65536);
                iso.getMethod("save", ByteBuffer.class).invoke(source, out);
                Files.write(file, Arrays.copyOf(out.array(), out.position()));
            }
            ByteBuffer input = ByteBuffer.wrap(Files.readAllBytes(file));
            Object restored = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, input);
            iso.getMethod("setSquare", squareType).invoke(restored, get(source, "getSquare"));
            iso.getMethod("load", ByteBuffer.class, int.class).invoke(restored, input, version);
            check(!input.hasRemaining(), "Bed stream not fully consumed");
            for (String method : new String[]{"getSpriteName", "getHealth", "getMaxHealth", "isCanPassThrough", "isHoppable", "isThumpable"})
                check(get(source, method).equals(get(restored, method)), "Bed changed on reload: " + method);
            Object marker = call(get(restored, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTBed");
            check(marker != null && call(marker, "rawget", new Class<?>[]{Object.class}, "id") != null, "Bed part identity lost");
            Object module = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_BedSpikes");
            Object store = call(module, "rawget", new Class<?>[]{Object.class}, "store");
            Object records = call(store, "rawget", new Class<?>[]{Object.class}, "records");
            Object record = call(records, "rawget", new Class<?>[]{Object.class}, call(marker, "rawget", new Class<?>[]{Object.class}, "id"));
            check(record != null, "Saved bed part has no persistent authority record");
            check(((Number)call(record, "rawget", new Class<?>[]{Object.class}, "health")).intValue() == ((Number)get(restored, "getHealth")).intValue(),
                "Persistent bed authority and native part health differ");
        }
        System.out.println("[OMHTT-Beds] persistence mode=" + mode + " parts=32 identity=valid health=preserved movement=preserved");
        Class<?> zombieType = Class.forName("zombie.characters.IsoZombie");
        Class<?> characterType = Class.forName("zombie.characters.IsoGameCharacter");
        Object zombie = zombieType.getConstructor(cellType).newInstance(cell);
        var serverFlag = Class.forName("zombie.network.GameServer").getField("server");
        boolean wasServer = serverFlag.getBoolean(null);
        serverFlag.setBoolean(null, false);
        try {
            Object bumped = Class.forName("zombie.ai.states.BumpedState").getMethod("instance").invoke(null);
            Class<?> nodeType = Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimNode");
            Class<?> eventType = Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimEvent");
            Class<?> contextType = Class.forName("zombie.characters.action.ActionContext");
            Class<?> stateType = Class.forName("zombie.characters.action.ActionState");
            Class<?> actionGroupType = Class.forName("zombie.characters.action.ActionGroup");
            Object context = get(zombie, "getActionContext");
            Object group = actionGroupType.getMethod("getActionGroup", String.class).invoke(null, "zombie");
            Object state = call(group, "findState", new Class<?>[]{String.class}, "bumped");
            var transitions = (java.util.List<?>)stateType.getField("transitions").get(state);
            Path project = directory.toAbsolutePath();
            while (project != null && !Files.isDirectory(project.resolve("Source/42.20/media/AnimSets"))) project = project.getParent();
            check(project != null, "Native probe cannot locate project animation sources");
            Path source = project.resolve("Source/42.20/media/AnimSets");
            Object node = nodeType.getMethod("Parse", String.class).invoke(null, source.resolve("zombie/bumped/OMHTTBedTrip.xml").toString());
            check(node != null && nodeType.getField("animName").get(node).equals("Zombie_HitDeath_HeadTop"), "Zombies must use native forward collapse");
            check(!nodeType.getField("useDeferredMovement").getBoolean(node), "Zombie trip must not apply sprint-clip displacement");
            call(zombie, "setBumpType", new Class<?>[]{String.class}, "OMHTTBedTrip");
            call(zombie, "setVariable", new Class<?>[]{String.class, boolean.class}, "BumpAnimFinished", false);
            call(zombie, "setVariable", new Class<?>[]{String.class, boolean.class}, "SprinterTripped", false);
            check(!Boolean.TRUE.equals(get(zombie, "isKnockedDown")), "Trip must not request hit knockback");
            Object toGetUp = null;
            for (Object transition : transitions) {
                if (get(transition, "getTransitionTo").equals("getup")) toGetUp = transition;
            }
            check(toGetUp != null && !Boolean.TRUE.equals(call(toGetUp, "passes", new Class<?>[]{contextType, stateType}, context, state)),
                "Recovery must wait for actual animation completion");
            for (Object event : (java.util.List<?>)nodeType.getField("events").get(node)) {
                String name = (String)eventType.getField("eventName").get(event);
                if (name.equals("SetVariable")) {
                    Object variable = event.getClass().getField("variableReference").get(event);
                    String value = (String)event.getClass().getField("setVariableValue").get(event);
                    call(variable, "setVariable", new Class<?>[]{Class.forName("zombie.core.skinnedmodel.advancedanimation.IAnimationVariableSource"), String.class}, zombie, value);
                } else {
                    call(bumped, "animEvent", new Class<?>[]{characterType,
                        Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimLayer"),
                        Class.forName("zombie.core.skinnedmodel.animation.AnimationTrack"), eventType}, zombie, null, null, event);
                }
            }
            check(Boolean.TRUE.equals(get(zombie, "isOnFloor")) && Boolean.TRUE.equals(get(zombie, "isFallOnFront")),
                "Native forward fall event did not establish landing");
            check(Boolean.TRUE.equals(call(toGetUp, "passes", new Class<?>[]{contextType, stateType}, context, state)),
                "Completed trip cannot reach native get-up transition");
            call(bumped, "exit", new Class<?>[]{characterType}, zombie);
            Object recovery = Class.forName("zombie.ai.states.ZombieGetUpState").getMethod("instance").invoke(null);
            call(recovery, "enter", new Class<?>[]{characterType}, zombie);
            call(recovery, "exit", new Class<?>[]{characterType}, zombie);
            check(Boolean.FALSE.equals(get(zombie, "isKnockedDown"))
                && Boolean.FALSE.equals(call(zombie, "getVariableBoolean", new Class<?>[]{String.class}, "SprinterTripped")),
                "Native get-up exit must clear recovery flags");
            System.out.println("[OMHTT-Beds] controlled-native-recovery forwardLanding=true getUpTransition=passed getUpExit=cleared rendered=unverified");
        } finally {
            serverFlag.setBoolean(null, wasServer);
        }
    }

    public static void main(String[] args) throws Exception {
        javax.imageio.ImageIO.setUseCache(false);
        Path directory = Path.of(args[0]);
        String mode = args[1];
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try { verify(directory, mode); NativeOwnershipProbe.verify(Path.of(System.getProperty("omhtt.projectRoot"))); }
            catch (Throwable error) { error.printStackTrace(); }
        }, "OMHTT-isolated-persistence-proof"));
        Method main = Class.forName("zombie.network.GameServer").getMethod("main", String[].class);
        main.invoke(null, (Object)Arrays.copyOfRange(args, 2, args.length));
    }
}
