import java.lang.reflect.Method;

public final class NativeTurretProbe {
    private static Object call(Object target, String name, Class<?>[] types, Object... values) throws Exception {
        return target.getClass().getMethod(name, types).invoke(target, values);
    }
    private static void check(boolean value, String message) {
        if (!value) throw new IllegalStateException(message);
    }
    public static void verify() throws Exception {
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object samples = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_AccuracyProbe");
        Object manager = Class.forName("zombie.CombatManager").getMethod("getInstance").invoke(null);
        for (int i = 1; i <= 16; i++) {
            Object row = call(samples, "rawget", new Class<?>[]{Object.class}, Double.valueOf(i));
            float distance = ((Number)call(row, "rawget", new Class<?>[]{Object.class}, "distance")).floatValue();
            boolean prone = (Boolean)call(row, "rawget", new Class<?>[]{Object.class}, "prone");
            float sightless = ((Number)call(manager, "getDistanceModifierSightless", new Class<?>[]{float.class, boolean.class}, distance, prone)).floatValue();
            float sights = ((Number)call(manager, "getDistanceModifier", new Class<?>[]{float.class, float.class, float.class, boolean.class}, distance, 2f, 10f, prone)).floatValue();
            check(Math.abs(sightless - ((Number)call(row, "rawget", new Class<?>[]{Object.class}, "sightless")).floatValue()) < .001f, "Sightless distance parity failed");
            check(Math.abs(sights - ((Number)call(row, "rawget", new Class<?>[]{Object.class}, "sights")).floatValue()) < .001f, "Sight distance parity failed");
        }
        System.out.println("[OMHTT-Smoke] native-distance-parity samples=16 passed=true");
        Class<?> sounds = Class.forName("zombie.GameSounds");
        for (String tier : new String[]{"Abundant","Common","Uncommon","Rare","Epic","Legendary","Mythic"}) {
            Object sound = sounds.getMethod("getSound", String.class).invoke(null, "OMHTTPack" + tier);
            java.util.List<?> clips = (java.util.List<?>)sound.getClass().getField("clips").get(sound);
            check(clips.size() == 1, "Pack tier must have exactly one authored clip");
            check(((String)call(clips.get(0), "getFile", new Class<?>[0])).equals("media/sound/OMHTTPack" + tier + ".wav"), "Wrong rarity file");
            check(!sound.getClass().getField("is3d").getBoolean(sound), "Rarity sound must be UI-only");
        }
        System.out.println("[OMHTT-Smoke] native-rarity-sounds tiers=7 clips=7 spatial=false");
        for (String kind : new String[]{"Fire", "Impact"}) {
            Object sound = sounds.getMethod("getSound", String.class).invoke(null, "OMHTTPotato" + kind);
            java.util.List<?> clips = (java.util.List<?>)sound.getClass().getField("clips").get(sound);
            check(clips.size() == 202, "Expected two custom potato samples with 101 native pitches each");
            for (Object clip : clips) {
                String file = (String)call(clip, "getFile", new Class<?>[0]);
                check(file.contains(kind.equals("Fire") ? "potato_thump_" : "potato_splat_"), "Wrong potato sound asset");
            }
            check(call(sound, "getRandomClip", new Class<?>[0]) != null, "Native random sound clip unavailable");
        }
        for (String name : new String[]{"M9Shoot", "M1911Shoot", "DesertEagleShoot", "M36Shoot", "M625Shoot", "MagnumShoot", "JS2000ShotgunShoot", "DoubleBarrelShotgunShoot", "SawnOffJS2000ShotgunShoot", "SawnOffDoubleBarrelShotgunShoot", "JS14Shoot", "L92Shoot", "L94Shoot", "M14Shoot", "M16Shoot", "MSR700Shoot", "MSR788Shoot", "TrapperCarbineShoot"}) {
            Object sound = sounds.getMethod("getSound", String.class).invoke(null, "OMHTTSuppressed" + name);
            java.util.List<?> clips = (java.util.List<?>)sound.getClass().getField("clips").get(sound);
            check(clips.size() == 101, "Suppressed pitch clips not registered: " + name);
            check(((String)call(clips.get(0), "getFile", new Class<?>[0])).endsWith(name + "_layered.ogg"), "Wrong suppressed audio");
        }
        Object reload = sounds.getMethod("getSound", String.class).invoke(null, "OMHTTPotatoReload");
        java.util.List<?> reloadClips = (java.util.List<?>)reload.getClass().getField("clips").get(reload);
        check(reloadClips.size() == 101 && ((String)call(reloadClips.get(0), "getFile", new Class<?>[0])).endsWith("stormyShotgunInsertRound.wav"), "Potato reload pitch clips not registered");
        Object suppressed = sounds.getMethod("getSound", String.class).invoke(null, "OMHTTPotatoSuppressed");
        check(((java.util.List<?>)suppressed.getClass().getField("clips").get(suppressed)).size() == 202, "Potato suppressed pitch variations missing");
        System.out.println("[OMHTT-Smoke] native-suppression sounds=18 potato=2 reload=native");
        Class<?> emitter = Class.forName("zombie.audio.BaseSoundEmitter");
        emitter.getMethod("playSound", String.class);
        System.out.println("[OMHTT-Smoke] native-potato-audio samples=4 randomized=true pitch=clip playback=untested");
        Class<?> picker = Class.forName("zombie.inventory.ItemPickerJava");
        picker.getMethod("Parse").invoke(null);
        Object pools = picker.getField("ProceduralDistributions").get(null);
        int modules = 0, packs = 0;
        for (String name : new String[]{"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics", "ElectricianTools", "GunStoreAccessories", "ToolCabinetMechanics", "GarageTools", "CrateTools", "ToolStoreTools", "ToolStoreMisc", "MechanicShelfTools", "GarageMechanics", "CrateMechanics", "ElectronicStoreComputers", "ElectronicStoreHAMRadio"}) {
            Object pool = call(pools, "get", new Class<?>[]{Object.class}, name);
            check(pool != null, "Missing native loot pool: " + name);
            Object[] items = (Object[])pool.getClass().getField("items").get(pool);
            int poolPacks = 0;
            for (Object item : items) {
                String type = (String)item.getClass().getField("itemName").get(item);
                if (type.equals("Base.OMHTTModulePack")) {
                    packs++;
                    poolPacks++;
                    check(item.getClass().getField("chance").getFloat(item) > 0, "Zero native pack loot weight");
                } else if (type.startsWith("Base.OMHTTModule")) {
                    modules++;
                    check(item.getClass().getField("chance").getFloat(item) > 0, "Zero native module loot weight");
                }
            }
            check(poolPacks == 1, "Expected exactly one pack entry per native pool: " + name);
        }
        check(modules == 233, "Native loot parser did not retain all module entries");
        System.out.println("[OMHTT-Smoke] native-module-loot-parser pools=16 items=233 weights=positive");
        check(packs == 16, "Native loot parser did not retain all pack entries");
        System.out.println("[OMHTT-Smoke] native-pack-loot-parser pools=16 packs=16 weights=positive");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> movingType = Class.forName("zombie.iso.IsoMovingObject");
        Class<?> worldType = Class.forName("zombie.iso.IsoWorld");
        Object cell = worldType.getField("currentCell").get(worldType.getField("instance").get(null));
        var squares = squareType.getConstructor(cellType, Class.forName("zombie.iso.SliceY"), int.class, int.class, int.class);
        Object square = squares.newInstance(cell, null, 6, 6, 0);
        Object object = Class.forName("zombie.iso.objects.IsoThumpable").getConstructor(cellType, squareType, String.class, boolean.class)
            .newInstance(cell, square, "omhtt_turret_01_16", false);
        call(object, "setBlockAllTheSquare", new Class<?>[]{boolean.class}, true);
        call(object, "setCanPassThrough", new Class<?>[]{boolean.class}, true);
        call(object, "setIsThumpable", new Class<?>[]{boolean.class}, true);
        ((java.util.List<Object>)call(square, "getObjects", new Class<?>[0])).add(object);
        ((java.util.List<Object>)call(square, "getSpecialObjects", new Class<?>[0])).add(object);
        Object player = Class.forName("zombie.characters.IsoPlayer").getConstructor(cellType).newInstance(cell);
        Object zombie = Class.forName("zombie.characters.IsoZombie").getConstructor(cellType).newInstance(cell);
        for (int[] offset : new int[][]{{0,-1},{1,0},{0,1},{-1,0}}) {
            Object adjacent = squares.newInstance(cell, null, 6 + offset[0], 6 + offset[1], 0);
            for (Object actor : new Object[]{player, zombie}) {
                check(Boolean.TRUE.equals(call(object, "TestCollide", new Class<?>[]{movingType,squareType,squareType}, actor, adjacent, square)), "Turret entry did not block actor");
                check(Boolean.FALSE.equals(call(object, "TestCollide", new Class<?>[]{movingType,squareType,squareType}, actor, square, adjacent)), "Migration trapped actor inside turret");
            }
            for (Object[] pair : new Object[][]{{square,adjacent},{adjacent,square}}) {
                check("NoEffect".equals(call(object, "TestVision", new Class<?>[]{squareType,squareType}, pair).toString()), "Turret blocked sight");
                check(Boolean.FALSE.equals(call(pair[0], "isBlockedTo", new Class<?>[]{squareType}, pair[1])), "Turret blocks its own firing ray");
                check(Boolean.TRUE.equals(call(pair[0], "canReachTo", new Class<?>[]{squareType}, pair[1])), "Native adjacent container reach failed");
            }
        }
        for (String engine : new String[]{"zombie.pathfind.SquareUpdateTask", "zombie.pathfind.nativeCode.SquareUpdateTask"}) {
            Method method = Class.forName(engine).getDeclaredMethod("hasSquareThumpable", squareType);
            method.setAccessible(true);
            check(Boolean.TRUE.equals(method.invoke(null, square)), "Pathfinder does not recognize solid turret");
        }
        System.out.println("[OMHTT-Smoke] native-turret-collision sides=4 player-and-zombie=blocked vision=clear reach=clear firing=clear pathfinders=2");
    }
}
