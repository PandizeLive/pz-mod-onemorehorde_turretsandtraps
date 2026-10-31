import java.io.StringReader;
import java.lang.reflect.Array;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.nio.file.Files;
import java.nio.file.Path;

public final class NativeOwnershipProbe {
    public static void verify(Path root) throws Exception {
        Class<?> world = Class.forName("zombie.iso.IsoWorld");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> playerType = Class.forName("zombie.characters.IsoPlayer");
        Class<?> actorType = Class.forName("zombie.characters.IsoZombie");
        Class<?> connectionType = Class.forName("zombie.core.raknet.UdpConnection");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        Object owner = playerType.getConstructor(cellType).newInstance(cell);
        Object other = playerType.getConstructor(cellType).newInstance(cell);
        Object actor = actorType.getConstructor(cellType).newInstance(cell);
        actorType.getField("onlineId").setShort(actor, (short)31000);
        Object connection = connectionType.getConstructor(Class.forName("zombie.core.raknet.UdpEngine"), long.class, int.class).newInstance(null, 1L, 0);
        Array.set(connectionType.getField("players").get(connection), 0, owner);
        actorType.getMethod("setOwner", connectionType).invoke(actor, connection);
        actorType.getMethod("setOwnerPlayer", playerType).invoke(actor, owner);
        actorType.getField("realState").set(actor, Class.forName("zombie.network.NetworkVariables$ZombieState").getField("Thump").get(null));
        Class<?> table = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform");
        Class<?> threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object env = Class.forName("zombie.Lua.LuaManager").getField("env").get(null);
        Object platform = Class.forName("se.krka.kahlua.j2se.J2SEPlatform").getMethod("getInstance").invoke(null);
        Object thread = threadType.getConstructor(platformType, table).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        Method compile = Class.forName("se.krka.kahlua.luaj.compiler.LuaCompiler").getMethod("loadis", java.io.Reader.class, String.class, table);
        Method call = threadType.getMethod("call", Object.class, Object[].class);
        Object old = compile.invoke(null, new StringReader("local actor, player = ...; return actor:getOwner():havePlayer(player)"), "C511-frozen-ownership", env);
        boolean reproduced = false;
        try {
            call.invoke(thread, old, new Object[]{actor, owner});
        } catch (InvocationTargetException error) {
            reproduced = error.getCause().toString().contains("havePlayer");
        }
        if (!reproduced) throw new IllegalStateException("Old real-connection failure was not reproduced");
        Object freshThread = threadType.getConstructor(platformType, table).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(freshThread, Thread.currentThread());
        Object test = compile.invoke(null, Files.newBufferedReader(root.resolve("tools/tests/native_ownership_c512.lua")), "native_ownership_c512.lua", env);
        Object result = call.invoke(freshThread, test, new Object[]{actor, owner, other, connection});
        if (!Boolean.TRUE.equals(result)) throw new IllegalStateException("Native ownership production route failed");
        System.out.println("[OMHTT-C512] native-ownership oldCall=reproduced contact=accepted foreign=rejected handoff=validated barrier=validated clients=0");
        Object lifecycle = compile.invoke(null, Files.newBufferedReader(root.resolve(
            "Source/42.20/media/lua/client/OMHTT/DefenseCombatClient.lua")), "C536-client-lifecycle", env);
        Object client = call.invoke(freshThread, lifecycle, new Object[]{});
        actor = actorType.getConstructor(cellType).newInstance(cell);
        Object create = compile.invoke(null, new StringReader("local C,z=...; local old=isClient; isClient=function() return true end; C.created(z); isClient=old"), "C536-create-before-id", env);
        actorType.getField("onlineId").setShort(actor, (short)-1);
        call.invoke(freshThread, create, new Object[]{client, actor});
        actorType.getField("onlineId").setShort(actor, (short)31000);
        Object lookup = compile.invoke(null, new StringReader("local C,z=...; return C.find(z:getOnlineID(),require('OMHTT/DefenseCombatProtocol').outfit(z:getPersistentOutfitID()))==z"), "C536-lookup-after-id", env);
        if (!Boolean.TRUE.equals(call.invoke(freshThread, lookup, new Object[]{client, actor})))
            throw new IllegalStateException("Native client lifecycle lost the post-creation network ID");
        actorType.getField("onlineId").setShort(actor, (short)-1);
        Object removed = compile.invoke(null, new StringReader("local C,z=...; return C.find(31000,require('OMHTT/DefenseCombatProtocol').outfit(z:getPersistentOutfitID()))==nil"), "C536-unload-id", env);
        if (!Boolean.TRUE.equals(call.invoke(freshThread, removed, new Object[]{client, actor})))
            throw new IllegalStateException("Native unloaded actor remained addressable");
        System.out.println("[OMHTT-C536] native-client-lifecycle lateId=resolved unloadedId=rejected clients=0 transport=not-tested");
    }
}
