import java.nio.*;
import java.nio.file.*;
import java.util.*;

public class BarbNativeCheck {
    static Object call(Object o, String name, Class<?>[] types, Object... args) throws Exception {
        return o.getClass().getMethod(name, types).invoke(o, args);
    }
    static Object get(Object o, String name) throws Exception { return call(o, name, new Class<?>[0]); }
    static void check(boolean ok, String message) { if (!ok) throw new IllegalStateException(message); }
    static void verify() throws Exception {
        Class<?> iso = Class.forName("zombie.iso.IsoObject"), cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> sq = Class.forName("zombie.iso.IsoGridSquare"), character = Class.forName("zombie.characters.IsoGameCharacter");
        Class<?> dir = Class.forName("zombie.iso.IsoDirections"), world = Class.forName("zombie.iso.IsoWorld");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        List<?> fixtures = (List<?>)call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_BarbFixtures");
        check(fixtures != null && fixtures.size() == 12, "Missing host fixtures");
        int version = ((Number)world.getMethod("getWorldVersion").invoke(null)).intValue();
        int mapResets = 0;
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform"), tableType = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Class<?> threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object platform = Class.forName("se.krka.kahlua.j2se.J2SEPlatform").getMethod("getInstance").invoke(null);
        Object thread = threadType.getConstructor(platformType, tableType).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        Class<?> windowType = Class.forName("zombie.iso.objects.IsoWindow");
        int windows = 0;
        for (Object host : fixtures) {
            if (windowType.isInstance(host)) {
                var open = windowType.getDeclaredField("open");
                open.setAccessible(true);
                open.setBoolean(host, true);
                Object function = call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_BarbWindowCheck");
                Object passed = threadType.getMethod("call", Object.class, Object[].class).invoke(thread, function, new Object[]{host});
                check(Boolean.TRUE.equals(passed), "Window state check failed");
                windows++;
            }
            ByteBuffer bytes = ByteBuffer.allocate(65536);
            iso.getMethod("save", ByteBuffer.class).invoke(host, bytes);
            bytes.flip();
            Object loaded = iso.getMethod("factoryFromFileInput", cellType, ByteBuffer.class).invoke(null, cell, bytes);
            iso.getMethod("setSquare", sq).invoke(loaded, get(host, "getSquare"));
            iso.getMethod("load", ByteBuffer.class, int.class).invoke(loaded, bytes, version);
            check(!bytes.hasRemaining(), "Unread host bytes");
            String metric = Class.forName("zombie.iso.IHasHealth").isInstance(host)
                || Class.forName("zombie.iso.objects.IsoWindow").isInstance(host) ? "getHealth" : "getDamage";
            boolean same = get(host, metric).equals(get(loaded, metric));
            System.out.println("[BarbProbe] roundtrip sprite=" + get(host, "getSpriteName") + " metric=" + metric + " before=" + get(host, metric) + " after=" + get(loaded, metric));
            if (metric.equals("getHealth")) check(same, "Constructed health not preserved");
            else if (!same) mapResets++;
            check(get(host, "getSpriteName").equals(get(loaded, "getSpriteName")), "Native host sprite lost");
            Object marker = call(get(loaded, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTBarbProbe");
            check(marker != null, "Attachment identity missing");
            Object attachments = call(get(loaded, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTBarbs");
            check(attachments != null, "Production attachment metadata missing");
            Object expected = call(get(host, "getModData"), "rawget", new Class<?>[]{Object.class}, "OMHTTBarbs");
            ByteBuffer a = ByteBuffer.allocate(65536), b = ByteBuffer.allocate(65536);
            call(expected, "save", new Class<?>[]{ByteBuffer.class}, a);
            call(attachments, "save", new Class<?>[]{ByteBuffer.class}, b);
            a.flip(); b.flip();
            check(a.equals(b), "Attachment health/face/id serialization changed");
        }
        System.out.println("[BarbProbe] SAVE PASS hosts=12 finiteHealth=preserved attachmentHealthAndIdentity=preserved mapCounterResets=" + mapResets);
        check(windows == 2, "Missing window checks");
        System.out.println("[BarbProbe] WINDOW PASS fixtures=2 nativeOpenFlag=controlled fixedEdge=preserved brokenPolicies=checked");
        List<?> pairs = (List<?>)call(env, "rawget", new Class<?>[]{Object.class}, "OMHTT_BarbPairs");
        Class<?> stateType = Class.forName("zombie.ai.states.ClimbOverFenceState");
        Object state = stateType.getMethod("instance").invoke(null);
        Object gameTime = Class.forName("zombie.GameTime").getMethod("getInstance").invoke(null);
        System.out.println("[BarbProbe] nativeTimeMultiplier=" + get(gameTime, "getThirtyFPSMultiplier"));
        int crossings = 0, contacts = 0;
        for (int i = 0; i < pairs.size(); i += 2) {
            Object positive = pairs.get(i), negative = pairs.get(i + 1);
            boolean north = get(positive, "getX").equals(get(negative, "getX"));
            for (int reverse = 0; reverse < 2; reverse++) {
                Object from = reverse == 0 ? negative : positive, to = reverse == 0 ? positive : negative;
                Object zombie = Class.forName("zombie.characters.IsoZombie").getConstructor(cellType).newInstance(cell);
                call(zombie, "setCurrent", new Class<?>[]{sq}, from);
                call(zombie, "setX", new Class<?>[]{float.class}, ((Number)get(from, "getX")).floatValue() + .5f);
                call(zombie, "setY", new Class<?>[]{float.class}, ((Number)get(from, "getY")).floatValue() + .5f);
                String facing = north ? (reverse == 0 ? "S" : "N") : (reverse == 0 ? "E" : "W");
                stateType.getMethod("setParams", character, dir).invoke(state, zombie, dir.getField(facing).get(null));
                Object variables = get(zombie, "getGameVariablesInternal");
                call(variables, "setVariable", new Class<?>[]{String.class, boolean.class}, "ClimbFenceStarted", false);
                call(variables, "setVariable", new Class<?>[]{String.class, String.class}, "ClimbFenceOutcome", "success");
                for (int tick = 0; tick < 10; tick++) stateType.getMethod("execute", character).invoke(state, zombie);
                check((int)Math.floor(((Number)get(zombie, "getX")).doubleValue()) == ((Number)get(from, "getX")).intValue()
                    && (int)Math.floor(((Number)get(zombie, "getY")).doubleValue()) == ((Number)get(from, "getY")).intValue(), "Unstarted vault crossed");
                call(variables, "setVariable", new Class<?>[]{String.class, boolean.class}, "ClimbFenceStarted", true);
                boolean touched = false;
                double edge = ((Number)get(positive, north ? "getY" : "getX")).doubleValue();
                double width = ((Number)get(zombie, "getWidth")).doubleValue();
                for (int tick = 0; tick < 200; tick++) {
                    stateType.getMethod("execute", character).invoke(state, zombie);
                    double coordinate = ((Number)get(zombie, north ? "getY" : "getX")).doubleValue();
                    if (Math.abs(coordinate - edge) <= width) touched = true;
                }
                System.out.println("[BarbProbe] crossing direction=" + facing + " pos=" + get(zombie, "getX") + "," + get(zombie, "getY")
                    + " edge=" + edge + " width=" + width + " started=" + call(zombie, "getVariableBoolean", new Class<?>[]{String.class}, "ClimbFenceStarted")
                    + " outcome=" + call(zombie, "getVariableString", new Class<?>[]{String.class}, "ClimbFenceOutcome"));
                check(touched, "Native crossing skipped contact band");
                check((int)Math.floor(((Number)get(zombie, "getX")).doubleValue()) == ((Number)get(to, "getX")).intValue()
                    && (int)Math.floor(((Number)get(zombie, "getY")).doubleValue()) == ((Number)get(to, "getY")).intValue(), "Native crossing failed");
                crossings++; if (touched) contacts++;
            }
        }
        System.out.println("[BarbProbe] CROSS PASS nativeZombieExecutions=" + crossings + " contactBands=" + contacts + " animationVariables=controlled");
    }
    public static void main(String[] args) throws Exception {
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            try { verify(); } catch (Throwable e) { e.printStackTrace(); }
        }, "barb-native-check"));
        Class.forName("zombie.network.GameServer").getMethod("main", String[].class).invoke(null, (Object)args);
    }
}
