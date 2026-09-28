import java.lang.reflect.Method;

public final class NativeVaultProbe {
    private static Object call(Object target, String name, Class<?>[] types, Object... values) throws Exception {
        return target.getClass().getMethod(name, types).invoke(target, values);
    }

    private static void check(boolean value, String message) {
        if (!value) throw new IllegalStateException(message);
    }

    private static void verifyVision(Object object, Object a, Object b) throws Exception {
        Class<?> square = Class.forName("zombie.iso.IsoGridSquare");
        for (Object[] pair : new Object[][]{{a, b}, {b, a}}) {
            check("Unblocked".equals(call(object, "TestVision", new Class<?>[]{square, square}, pair).toString()), "Object vision blocked");
            call(pair[0], "RecalcProperties", new Class<?>[0]);
            call(pair[1], "RecalcProperties", new Class<?>[0]);
            check(Boolean.FALSE.equals(call(pair[0], "CalculateVisionBlocked", new Class<?>[]{square}, pair[1])), "Grid vision blocked");
        }
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
                .newInstance(cell, positive, north ? "omhtt_barrier_01_16" : "omhtt_barrier_01_17", north);
            call(object, "setBlockAllTheSquare", new Class<?>[]{boolean.class}, false);
            call(object, "setCanPassThrough", new Class<?>[]{boolean.class}, false);
            call(object, "setIsHoppable", new Class<?>[]{boolean.class}, false);
            call(object, "setIsThumpable", new Class<?>[]{boolean.class}, true);
            ((java.util.List<Object>)call(positive, "getObjects", new Class<?>[0])).add(object);
            ((java.util.List<Object>)call(positive, "getSpecialObjects", new Class<?>[0])).add(object);
            Object n = directionsType.getField(north ? "N" : "W").get(null);
            Object s = directionsType.getField(north ? "S" : "E").get(null);
            call(positive, "setAdjacentSquare", new Class<?>[]{directionsType, squareType}, n, negative);
            call(negative, "setAdjacentSquare", new Class<?>[]{directionsType, squareType}, s, positive);
            for (String engine : new String[]{"zombie.pathfind.SquareUpdateTask", "zombie.pathfind.nativeCode.SquareUpdateTask"}) {
                Method wall = Class.forName(engine).getDeclaredMethod(north ? "hasWallThumpableN" : "hasWallThumpableW", squareType);
                wall.setAccessible(true);
                check(Boolean.TRUE.equals(wall.invoke(null, positive)), "Pathfinder did not recognize thumpable edge: " + engine);
            }
            check(Boolean.TRUE.equals(collide.invoke(object, null, positive, negative)), "Leaving edge did not block walking");
            check(Boolean.TRUE.equals(collide.invoke(object, null, negative, positive)), "Entering edge did not block walking");
            check(Boolean.FALSE.equals(call(object, "isHoppable", new Class<?>[0])), "Barrier became zombie-hoppable");
            verifyVision(object, positive, negative);
            Class<?> flagType = Class.forName("zombie.iso.SpriteDetails.IsoFlagType");
            Object properties = call(call(object, "getSprite", new Class<?>[0]), "getProperties", new Class<?>[0]);
            Object otherTransparency = flagType.getField(north ? "transparentW" : "transparentN").get(null);
            check(Boolean.FALSE.equals(call(properties, "has", new Class<?>[]{flagType}, otherTransparency)), "Helper opens vision through unrelated perpendicular walls");
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
                Class<?> paramType = Class.forName("zombie.ai.State$Param");
                for (int movement = 0; movement < 3; movement++) {
                    call(player, "setRunning", new Class<?>[]{boolean.class}, movement == 1);
                    call(player, "setSprinting", new Class<?>[]{boolean.class}, movement == 2);
                    stateType.getMethod("setParams", characterType, directionsType).invoke(state, player, direction);
                    check(Boolean.valueOf(movement == 1).equals(call(player, "get", new Class<?>[]{paramType}, stateType.getField("RUN").get(null))), "Native run state lost");
                    check(Boolean.valueOf(movement == 2).equals(call(player, "get", new Class<?>[]{paramType}, stateType.getField("SPRINT").get(null))), "Native sprint state lost");
                }
                call(player, "setRunning", new Class<?>[]{boolean.class}, false);
                call(player, "setSprinting", new Class<?>[]{boolean.class}, false);
                Object context = call(player, "getActionContext", new Class<?>[0]);
                call(context, "clearActionContextEvents", new Class<?>[0]);
                check(Boolean.FALSE.equals(call(player, "canClimbOverWall", new Class<?>[]{directionsType}, direction)), "Ungated wall climb route opened");
                call(player, "climbOverFence", new Class<?>[]{directionsType}, direction);
                check(Boolean.TRUE.equals(call(context, "hasEventOccurred", new Class<?>[]{String.class}, "EventClimbFence")), "Public native entry rejected " + heading);
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
        for (int order = 0; order < 2; order++) {
            Object square = squareConstructor.newInstance(cell, null, 4, 4, 0);
            Object nSquare = squareConstructor.newInstance(cell, null, 4, 3, 0);
            Object wSquare = squareConstructor.newInstance(cell, null, 3, 4, 0);
            Object n = directionsType.getField("N").get(null);
            Object w = directionsType.getField("W").get(null);
            call(square, "setAdjacentSquare", new Class<?>[]{directionsType, squareType}, n, nSquare);
            call(square, "setAdjacentSquare", new Class<?>[]{directionsType, squareType}, w, wSquare);
            Object[] edges = new Object[2];
            for (int i = 0; i < 2; i++) {
                boolean north = (i + order) % 2 == 0;
                Object object = thumpableType.getConstructor(cellType, squareType, String.class, boolean.class)
                    .newInstance(cell, square, north ? "omhtt_barrier_01_18" : "omhtt_barrier_01_19", north);
                call(object, "setBlockAllTheSquare", new Class<?>[]{boolean.class}, false);
                call(object, "setCanPassThrough", new Class<?>[]{boolean.class}, false);
                call(object, "setIsHoppable", new Class<?>[]{boolean.class}, false);
                call(object, "setIsThumpable", new Class<?>[]{boolean.class}, true);
                ((java.util.List<Object>)call(square, "getObjects", new Class<?>[0])).add(object);
                ((java.util.List<Object>)call(square, "getSpecialObjects", new Class<?>[0])).add(object);
                edges[north ? 0 : 1] = object;
            }
            for (String engine : new String[]{"zombie.pathfind.SquareUpdateTask", "zombie.pathfind.nativeCode.SquareUpdateTask"}) {
                for (String method : new String[]{"hasWallThumpableN", "hasWallThumpableW"}) {
                    Method wall = Class.forName(engine).getDeclaredMethod(method, squareType);
                    wall.setAccessible(true);
                    check(Boolean.TRUE.equals(wall.invoke(null, square)), "Corner lost an edge: " + engine + "/" + method);
                }
            }
            check(call(square, "getThumpableWallOrHoppable", new Class<?>[]{boolean.class}, true) == edges[0], "North corner thump target changed owner");
            check(call(square, "getThumpableWallOrHoppable", new Class<?>[]{boolean.class}, false) == edges[1], "West corner thump target changed owner");
            verifyVision(edges[0], square, nSquare);
            verifyVision(edges[1], square, wSquare);
            check(Boolean.TRUE.equals(collide.invoke(edges[0], null, square, nSquare)), "Corner N collision open");
            check(Boolean.FALSE.equals(collide.invoke(edges[0], null, square, wSquare)), "Corner N object steals W collision");
            check(Boolean.TRUE.equals(collide.invoke(edges[1], null, square, wSquare)), "Corner W collision open");
            check(Boolean.FALSE.equals(collide.invoke(edges[1], null, square, nSquare)), "Corner W object steals N collision");
        }
        System.out.println("[OMHTT-VaultProbe] native-vision=12/12 object-and-grid=true collision-preserved=true");
        System.out.println("[OMHTT-VaultProbe] native-corners=2/2 both-pathfinders=true directional-thump-ownership=true");
        System.out.println("[OMHTT-VaultProbe] native-movement-params=12/12 running-and-sprinting-distinct=true");
        System.out.println("[OMHTT-VaultProbe] native-state-execute=4/4 native-edge-collision=4/4 native-path-edge=4/4 native-pathfinder=2/2 public-entry=4/4 bounded-collision=true animation-events=simulated rendered-client=not-tested");
    }
}
