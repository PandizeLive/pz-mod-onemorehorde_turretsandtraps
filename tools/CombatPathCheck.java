import java.io.Reader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public final class CombatPathCheck {
    public static void main(String[] args) throws Exception {
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform");
        Class<?> platformImpl = Class.forName("se.krka.kahlua.j2se.J2SEPlatform");
        Class<?> tableType = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Class<?> threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object platform = platformImpl.getMethod("getInstance").invoke(null);
        Object env = platformImpl.getMethod("newTable").invoke(platform);
        Method set = tableType.getMethod("rawset", Object.class, Object.class);
        Method get = tableType.getMethod("rawget", Object.class);
        set.invoke(env, "_G", env);
        Class.forName("se.krka.kahlua.stdlib.BaseLib").getMethod("register", tableType).invoke(null, env);
        for (String library : new String[] {"stdlib.StringLib", "stdlib.TableLib", "j2se.MathLib"}) {
            Class.forName("se.krka.kahlua." + library).getMethod("register", platformType, tableType).invoke(null, platform, env);
        }
        Object thread = threadType.getConstructor(platformType, tableType).newInstance(platform, env);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        Method compile = Class.forName("se.krka.kahlua.luaj.compiler.LuaCompiler")
            .getMethod("loadis", Reader.class, String.class, tableType);
        Method call = threadType.getMethod("call", Object.class, Object[].class);
        Class<?> functionType = Class.forName("se.krka.kahlua.vm.JavaFunction");
        Object roundTrip = Proxy.newProxyInstance(functionType.getClassLoader(), new Class<?>[] {functionType}, (proxy, method, values) -> {
            if (!method.getName().equals("call")) return null;
            Object frame = values[0];
            Object source = frame.getClass().getMethod("get", int.class).invoke(frame, 0);
            var bytes = new java.io.ByteArrayOutputStream();
            tableType.getMethod("save", java.io.DataOutputStream.class).invoke(source, new java.io.DataOutputStream(bytes));
            Object restored = platformImpl.getMethod("newTable").invoke(platform);
            tableType.getMethod("load", java.io.DataInputStream.class, int.class).invoke(restored,
                new java.io.DataInputStream(new java.io.ByteArrayInputStream(bytes.toByteArray())), 249);
            frame.getClass().getMethod("push", Object.class).invoke(frame, restored);
            return 1;
        });
        set.invoke(env, "nativeRoundTrip", roundTrip);
        Object realMillis = Proxy.newProxyInstance(functionType.getClassLoader(), new Class<?>[] {functionType}, (proxy, method, values) -> {
            if (!method.getName().equals("call")) return null;
            values[0].getClass().getMethod("push", Object.class).invoke(values[0], System.nanoTime() / 1000000.0);
            return 1;
        });
        set.invoke(env, "realMillis", realMillis);
        set.invoke(env, "testDelayMs", Double.valueOf(System.getenv().getOrDefault("OMHTT_TEST_DELAY_MS", "50")));
        Path root = Path.of(args[0]);
        for (int i=1; i<args.length; i++) {
            String[] stage=args[i].split("=",2);
            try (Reader reader=Files.newBufferedReader(root.resolve(stage[1]))) {
                Object closure=compile.invoke(null,reader,stage[1],env);
                Object result=call.invoke(thread,closure,new Object[0]);
                if (!stage[0].equals("_")) {
                    Object modules=get.invoke(env,"__modules");
                    set.invoke(modules,"OMHTT/"+stage[0],result);
                }
            } catch (InvocationTargetException e) { throw new RuntimeException(stage[1],e.getCause()); }
        }
        System.out.println(get.invoke(env,"scenarioResult")); System.out.println("SCENARIO_PASS assertions="+get.invoke(env,"testAssertions"));
    }
}
