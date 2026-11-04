import java.nio.file.*;
import java.io.*;

public class AuditProbe {
    public static void main(String[] args) throws Exception {
        Class<?> table = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform");
        Class<?> platformClass = Class.forName("se.krka.kahlua.j2se.J2SEPlatform");
        Object platform = platformClass.getMethod("getInstance").invoke(null);
        Object env = platformClass.getMethod("newTable").invoke(platform);
        var set = table.getMethod("rawset", Object.class, Object.class);
        var get = table.getMethod("rawget", Object.class);
        set.invoke(env, "_G", env);
        Class.forName("se.krka.kahlua.stdlib.BaseLib").getMethod("register", table).invoke(null, env);
        for (String lib : new String[]{"stdlib.StringLib", "stdlib.TableLib", "j2se.MathLib"})
            Class.forName("se.krka.kahlua." + lib).getMethod("register", platformType, table).invoke(null, platform, env);
        Class<?> threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object thread = threadType.getConstructor(platformType, table).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        var compile = Class.forName("se.krka.kahlua.luaj.compiler.LuaCompiler").getMethod("loadis", Reader.class, String.class, table);
        var call = threadType.getMethod("call", Object.class, Object[].class);
        Path root = Path.of(args[0]);
        String base = "Source/42.20/media/lua/";
        String[][] stages = {
            {"", "diagnostics/audit-20261007/bootstrap.lua"},
            {"OMHTT/TurretScheduler", base + "shared/OMHTT/TurretScheduler.lua"},
            {"OMHTT/TurretAutomation", base + "server/OMHTT/TurretAutomation.lua"},
            {"OMHTT/TurretAim", base + "shared/OMHTT/TurretAim.lua"},
            {"", "diagnostics/audit-20261007/probe.lua"}
        };
        for (String[] stage : stages) {
            try (Reader reader = Files.newBufferedReader(root.resolve(stage[1]))) {
                Object chunk = compile.invoke(null, reader, stage[1], env);
                Object value = call.invoke(thread, chunk, new Object[0]);
                if (!stage[0].isEmpty()) set.invoke(get.invoke(env, "modules"), stage[0], value);
            } catch (java.lang.reflect.InvocationTargetException error) {
                Object coroutine = threadType.getMethod("getCurrentCoroutine").invoke(thread);
                System.err.println(stage[1]);
                System.err.println(coroutine.getClass().getField("stackTrace").get(coroutine));
                throw error;
            }
        }
        System.out.println(get.invoke(env, "auditResults"));
    }
}
