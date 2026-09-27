import java.lang.reflect.Method;

public final class NativeVaultProbe {
    private static Object call(Object target, String name, Class<?>[] types, Object... values) throws Exception {
        return target.getClass().getMethod(name, types).invoke(target, values);
    }

    private static void check(boolean value, String message) {
        if (!value) throw new IllegalStateException(message);
    }

    public static void verify() throws Exception {
        Class<?> worldType = Class.forName("zombie.iso.IsoWorld");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> squareType = Class.forName("zombie.iso.IsoGridSquare");
        Class<?> movingType = Class.forName("zombie.iso.IsoMovingObject");
        Class<?> characterType = Class.forName("zombie.characters.IsoGameCharacter");
        Class<?> directionsType = Class.forName("zombie.iso.IsoDirections");
        Class<?> thumpableType = Class.forName("zombie.iso.objects.IsoThumpable");
        Class<?> stateType = Class.forName("zombie.ai.states.ClimbOverFenceState");
        Object cell = worldType.getField("currentCell").get(worldType.getField("instance").get(null));
        Object player = Class.forName("zombie.characters.IsoPlayer").getConstructor(cellType).newInstance(cell);
        Object state = stateType.getMethod("instance").invoke(null);
        var squareConstructor = squareType.getConstructor(cellType, Class.forName("zombie.iso.SliceY"), int.class, int.class, int.class);
        Method collide = thumpableType.getMethod("TestCollide", movingType, squareType, squareType);
        for (int axis = 0; axis < 2; axis++) {
            boolean north = axis == 1;
            Object positive = squareConstructor.newInstance(cell, null, 2, 2, 0);
            Object negative = squareConstructor.newInstance(cell, null, north ? 2 : 1, north ? 1 : 2, 0);
            Object object = thumpableType.getConstructor(cellType, squareType, String.class, boolean.class)
                .newInstance(cell, positive, "omhtt_barrier_01_0", north);
            call(object, "setBlockAllTheSquare", new Class<?>[]{boolean.class}, false);
            call(object, "setCanPassThrough", new Class<?>[]{boolean.class}, false);
            call(object, "setIsHoppable", new Class<?>[]{boolean.class}, false);
            check(Boolean.TRUE.equals(collide.invoke(object, null, positive, negative)), "Leaving edge did not block walking");
            check(Boolean.TRUE.equals(collide.invoke(object, null, negative, positive)), "Entering edge did not block walking");
            check(Boolean.FALSE.equals(call(object, "isHoppable", new Class<?>[0])), "Barrier became zombie-hoppable");
            check(Boolean.TRUE.equals(call(object, "TestPathfindCollide", new Class<?>[]{movingType, squareType, squareType}, null, positive, negative)), "Reverse path edge opened");
            check(Boolean.TRUE.equals(call(object, "TestPathfindCollide", new Class<?>[]{movingType, squareType, squareType}, null, negative, positive)), "Forward path edge opened");
            for (int reverse = 0; reverse < 2; reverse++) {
                Object from = reverse == 0 ? negative : positive;
                Object to = reverse == 0 ? positive : negative;
                String heading = north ? (reverse == 0 ? "S" : "N") : (reverse == 0 ? "E" : "W");
                Object direction = directionsType.getField(heading).get(null);
                int x = ((Number)call(from, "getX", new Class<?>[0])).intValue();
                int y = ((Number)call(from, "getY", new Class<?>[0])).intValue();
                int targetX = ((Number)call(to, "getX", new Class<?>[0])).intValue();
                int targetY = ((Number)call(to, "getY", new Class<?>[0])).intValue();
                call(player, "setCurrent", new Class<?>[]{squareType}, from);
                call(player, "setX", new Class<?>[]{float.class}, x + 0.5f);
                call(player, "setY", new Class<?>[]{float.class}, y + 0.5f);
                stateType.getMethod("setParams", characterType, directionsType).invoke(state, player, direction);
                call(player, "setVariable", new Class<?>[]{String.class, boolean.class}, "ClimbFenceStarted", true);
                call(player, "setVariable", new Class<?>[]{String.class, String.class}, "ClimbFenceOutcome", "success");
                for (int tick = 0; tick < 200; tick++) stateType.getMethod("execute", characterType).invoke(state, player);
                float actualX = ((Number)call(player, "getX", new Class<?>[0])).floatValue();
                float actualY = ((Number)call(player, "getY", new Class<?>[0])).floatValue();
                check((int)Math.floor(actualX) == targetX && (int)Math.floor(actualY) == targetY, "Native slide did not cross " + heading);
                check(Boolean.TRUE.equals(stateType.getMethod("isIgnoreCollide", characterType, int.class, int.class, int.class, int.class, int.class, int.class)
                    .invoke(state, player, x, y, 0, targetX, targetY, 0)), "Native collision exception missing");
                check(Boolean.FALSE.equals(stateType.getMethod("isIgnoreCollide", characterType, int.class, int.class, int.class, int.class, int.class, int.class)
                    .invoke(state, player, x, y, 0, targetX + 3, targetY + 3, 0)), "Native exception escaped the crossing");
                check(Boolean.FALSE.equals(stateType.getMethod("isIgnoreCollide", characterType, int.class, int.class, int.class, int.class, int.class, int.class)
                    .invoke(state, player, x, y, 1, targetX, targetY, 1)), "Native exception escaped the floor");
                System.out.println("[OMHTT-VaultProbe] heading=" + heading + " walking=blocked hoppable=false nativeSlide=" + actualX + "," + actualY);
            }
        }
        System.out.println("[OMHTT-VaultProbe] native-state-execute=4/4 native-edge-collision=4/4 native-path-edge=4/4 bounded-collision=true animation-events=simulated rendered-client=not-tested");
    }
}
