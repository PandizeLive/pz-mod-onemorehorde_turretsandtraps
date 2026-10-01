import java.lang.reflect.Method;

public final class NativeTurretProbe {
    private static Object call(Object target, String name, Class<?>[] types, Object... values) throws Exception {
        return target.getClass().getMethod(name, types).invoke(target, values);
    }
    private static void check(boolean value, String message) {
        if (!value) throw new IllegalStateException(message);
    }
    public static void verify() throws Exception {
        Class<?> sounds = Class.forName("zombie.GameSounds");
        for (String kind : new String[]{"Fire", "Impact"}) {
            Object sound = sounds.getMethod("getSound", String.class).invoke(null, "OMHTTPotato" + kind);
            java.util.List<?> clips = (java.util.List<?>)sound.getClass().getField("clips").get(sound);
            check(clips.size() == 2, "Expected two custom potato sound variants");
            for (Object clip : clips) {
                String file = (String)call(clip, "getFile", new Class<?>[0]);
                check(file.contains(kind.equals("Fire") ? "potato_thump_" : "potato_splat_"), "Wrong potato sound asset");
            }
            check(call(sound, "getRandomClip", new Class<?>[0]) != null, "Native random sound clip unavailable");
        }
        Class<?> emitter = Class.forName("zombie.audio.BaseSoundEmitter");
        emitter.getMethod("playSound", String.class);
        emitter.getMethod("setPitch", long.class, float.class);
        System.out.println("[OMHTT-Smoke] native-potato-audio clips=4 randomized=true pitch-method=verified playback=untested");
        Class<?> picker = Class.forName("zombie.inventory.ItemPickerJava");
        picker.getMethod("Parse").invoke(null);
        Object pools = picker.getField("ProceduralDistributions").get(null);
        int modules = 0;
        for (String name : new String[]{"ElectronicStoreMisc", "CrateElectronics", "MechanicShelfElectric", "ArmyStorageElectronics"}) {
            Object pool = call(pools, "get", new Class<?>[]{Object.class}, name);
            check(pool != null, "Missing native loot pool: " + name);
            Object[] items = (Object[])pool.getClass().getField("items").get(pool);
            for (Object item : items) {
                String type = (String)item.getClass().getField("itemName").get(item);
                if ((type.startsWith("Base.OMHTTModule") || type.startsWith("Base.OMHTTExpansionKit"))) {
                    modules++;
                    check(item.getClass().getField("chance").getFloat(item) > 0, "Zero native module loot weight");
                }
            }
        }
        check(modules == 48, "Native loot parser did not retain all module entries");
        System.out.println("[OMHTT-Smoke] native-module-loot-parser pools=4 items=48 weights=positive");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> movingType = Class.forName("zombie.iso.IsoMovingObject");
        Class<?> worldType = Class.forName("zombie.iso.IsoWorld");
        Object cell = worldType.getField("currentCell").get(worldType.getField("instance").get(null));
        var squares = squareType.getConstructor(cellType, Class.forName("zombie.iso.SliceY"), int.class, int.class, int.class);
        Object square = squares.newInstance(cell, null, 6, 6, 0);
        Object object = Class.forName("zombie.iso.objects.IsoThumpable").getConstructor(cellType, squareType, String.class, boolean.class)
            .newInstance(cell, square, "omhtt_barrier_01_44", false);
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
