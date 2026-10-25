import java.util.Arrays;
import java.lang.reflect.Proxy;

public final class NativeDefenseXPProbe {
    private static Object get(Object table, Object key) throws Exception {
        return table.getClass().getMethod("rawget", Object.class).invoke(table, key);
    }

    private static float health(Object actor) throws Exception {
        return ((Number)actor.getClass().getMethod("getHealth").invoke(actor)).floatValue();
    }

    private static void verify() throws Exception {
        Object luaThread = Class.forName("zombie.Lua.LuaManager").getField("thread").get(null);
        if (luaThread.getClass().getField("debugOwnerThread").get(luaThread) != Thread.currentThread())
            throw new IllegalStateException("Probe must run on the actual Lua owner thread");
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object samples = get(env, "OMHTT_XPProbe");
        if (samples == null) throw new IllegalStateException("Lua probe did not complete");
        Object player = get(samples, "player");
        Object zombie = get(samples, "zombie");
        Object weapon = get(samples, "weapon");
        Object observations = get(samples, "observations");
        Class<?> hitType = Class.forName("zombie.network.fields.hit.WeaponHit");
        Class<?> actorType = Class.forName("zombie.characters.IsoGameCharacter");
        Class<?> weaponType = Class.forName("zombie.inventory.types.HandWeapon");
        Object hit = hitType.getConstructor().newInstance();
        hitType.getMethod("set", float.class, float.class, float.class, float.class, float.class,
            boolean.class, boolean.class, boolean.class, boolean.class)
            .invoke(hit, .2f, 1f, 0f, 1f, 0f, false, false, false, false);
        float before = health(zombie);
        hitType.getMethod("process", actorType, actorType, weaponType)
            .invoke(hit, player, zombie, weapon);
        float after = health(zombie);
        int count = ((Number)observations.getClass().getMethod("len").invoke(observations)).intValue();
        Object last = get(observations, Double.valueOf(count));
        if (!"OnWeaponHitXp".equals(get(last, "kind"))) throw new IllegalStateException("Missing native post-hit event");
        if (((Number)get(last, "health")).floatValue() != after || after >= before)
            throw new IllegalStateException("Post-hit health does not match the native result");
        System.out.println("[OMHTT-XPProbe] packetPostHit=true before=" + before + " after=" + after
            + " callbackHealth=" + get(last, "health") + " callbackInput=" + get(last, "amount")
            + " clients=0 packetTransportTested=false");
        System.out.println("[OMHTT-XPProbe] packetCompleted=true");
    }

    public static void main(String[] args) throws Exception {
        Thread dispatcher = new Thread(() -> {
            try {
                Class<?> lua = Class.forName("zombie.Lua.LuaManager");
                Object samples = null;
                long deadline = System.nanoTime() + 150_000_000_000L;
                while (samples == null && System.nanoTime() < deadline) {
                    Object env = lua.getField("env").get(null);
                    if (env != null) samples = get(env, "OMHTT_XPProbe");
                    if (samples == null) Thread.sleep(100);
                }
                if (samples == null) throw new IllegalStateException("Lua setup never completed");
                Class<?> function = Class.forName("se.krka.kahlua.vm.JavaFunction");
                Object callback = Proxy.newProxyInstance(function.getClassLoader(), new Class<?>[]{function}, (proxy, method, values) -> {
                    if (!method.getName().equals("call")) return null;
                    try { verify(); }
                    catch (Throwable error) {
                        error.printStackTrace();
                        System.out.println("[OMHTT-XPProbe] packetFailed=true");
                    }
                    return 0;
                });
                Class.forName("zombie.Lua.LuaEventManager").getMethod("triggerEvent", String.class, Object.class)
                    .invoke(null, "OnOMHTTXPProbeNative", callback);
            } catch (Throwable error) {
                error.printStackTrace();
                System.out.println("[OMHTT-XPProbe] packetFailed=true");
            }
        }, "OMHTT-isolated-xp-dispatch");
        dispatcher.setDaemon(true);
        dispatcher.start();
        Class.forName("zombie.network.GameServer").getMethod("main", String[].class)
            .invoke(null, (Object)Arrays.copyOf(args, args.length));
    }
}
