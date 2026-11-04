public final class NativeControllerMapCheck {
    private static void scrollbarResize(boolean anchored) throws Exception {
        Class<?> ui = Class.forName("zombie.ui.UIElement");
        Object parent = ui.getConstructor().newInstance();
        Object bar = ui.getConstructor().newInstance();
        ui.getMethod("setWidth", double.class).invoke(parent, 400.0);
        ui.getMethod("setHeight", double.class).invoke(parent, 300.0);
        ui.getMethod("setAnchorLeft", boolean.class).invoke(bar, false);
        ui.getMethod("setAnchorRight", boolean.class).invoke(bar, anchored);
        ui.getMethod("setAnchorBottom", boolean.class).invoke(bar, anchored);
        ui.getMethod("AddChild", ui).invoke(parent, bar);
        for (int width : new int[] {400, 270, 540, 310}) {
            ui.getMethod("setWidth", double.class).invoke(parent, (double)width);
            ui.getMethod("setHeight", double.class).invoke(parent, (double)width);
            ui.getMethod("setX", double.class).invoke(bar, width - 17.0);
            ui.getMethod("setY", double.class).invoke(bar, 0.0);
            ui.getMethod("setWidth", double.class).invoke(bar, 17.0);
            ui.getMethod("setHeight", double.class).invoke(bar, (double)width);
            ui.getMethod("update").invoke(parent);
            double x = ((Number)ui.getMethod("getX").invoke(bar)).doubleValue();
            double height = ((Number)ui.getMethod("getHeight").invoke(bar)).doubleValue();
            if (anchored) {
                System.out.println("Native anchored scrollbar after explicit reflow: width=" + width + " x=" + x + " height=" + height);
            } else if (x != width - 17.0 || height != width) {
                throw new IllegalStateException("Explicit scrollbar escaped its panel after deferred resize");
            }
        }
    }
    private static void rightClickDispatch() throws Exception {
        Class<?> platformType = Class.forName("se.krka.kahlua.vm.Platform");
        Class<?> platformImpl = Class.forName("se.krka.kahlua.j2se.J2SEPlatform");
        Class<?> tableType = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Class<?> threadType = Class.forName("se.krka.kahlua.vm.KahluaThread");
        Object platform = platformImpl.getMethod("getInstance").invoke(null);
        Object environment = platformImpl.getMethod("newTable").invoke(platform);
        Object thread = threadType.getConstructor(platformType, tableType).newInstance(platform, environment);
        threadType.getField("debugOwnerThread").set(thread, Thread.currentThread());
        Class<?> manager = Class.forName("zombie.Lua.LuaManager");
        manager.getField("thread").set(null, thread);
        Class.forName("zombie.ui.UIManager").getField("defaultthread").set(null, thread);
        Class<?> converters = Class.forName("se.krka.kahlua.converter.KahluaConverterManager");
        manager.getField("caller").set(null, Class.forName("se.krka.kahlua.integration.LuaCaller")
            .getConstructor(converters).newInstance(converters.getConstructor().newInstance()));
        Object parentTable = platformImpl.getMethod("newTable").invoke(platform);
        Object childTable = platformImpl.getMethod("newTable").invoke(platform);
        Class<?> functionType = Class.forName("se.krka.kahlua.vm.JavaFunction");
        int[] calls = new int[2];
        for (int side=0; side<2; side++) {
            final int index = side;
            Object callback = java.lang.reflect.Proxy.newProxyInstance(functionType.getClassLoader(), new Class<?>[]{functionType}, (proxy, method, values) -> {
                if (!method.getName().equals("call")) return null;
                calls[index]++;
                values[0].getClass().getMethod("push", Object.class).invoke(values[0], true);
                return 1;
            });
            for (String event : new String[]{"onRightMouseDown", "onRightMouseUp"})
                tableType.getMethod("rawset", Object.class, Object.class).invoke(side==0 ? parentTable : childTable, event, callback);
        }
        Class<?> ui = Class.forName("zombie.ui.UIElement");
        Object parent = ui.getConstructor(tableType).newInstance(parentTable);
        Object child = Class.forName("zombie.worldMap.UIWorldMap").getConstructor(tableType).newInstance(childTable);
        ui.getMethod("setWidth", double.class).invoke(parent, 500.0);
        ui.getMethod("setHeight", double.class).invoke(parent, 300.0);
        ui.getMethod("setWidth", double.class).invoke(child, 400.0);
        ui.getMethod("setHeight", double.class).invoke(child, 200.0);
        ui.getMethod("setConsumeMouseEvents", boolean.class).invoke(child, false);
        ui.getMethod("AddChild", ui).invoke(parent, child);
        for (String event : new String[]{"onRightMouseDown", "onRightMouseUp"}) {
            Object handled = ui.getMethod(event, double.class, double.class).invoke(parent, 30.0, 30.0);
            if (!Boolean.TRUE.equals(handled)) throw new IllegalStateException("Native map did not consume " + event);
        }
        if (calls[0] != 0 || calls[1] != 2) throw new IllegalStateException("Right click leaked or dispatched twice: " + calls[0] + "/" + calls[1]);
        System.out.println("Native UIWorldMap right-button pair: child handlers consume exactly once without parent click-through");
    }
    public static void main(String[] args) throws Exception {
        rightClickDispatch();
        scrollbarResize(true);
        scrollbarResize(false);
        Class<?> ui = Class.forName("zombie.ui.UIElement");
        Object window = ui.getConstructor().newInstance();
        Object grip = ui.getConstructor().newInstance();
        ui.getMethod("setAnchorRight", boolean.class).invoke(grip, false);
        ui.getMethod("setAnchorBottom", boolean.class).invoke(grip, false);
        ui.getMethod("setAnchorLeft", boolean.class).invoke(grip, false);
        ui.getMethod("setAnchorTop", boolean.class).invoke(grip, false);
        ui.getMethod("AddChild", ui).invoke(window, grip);
        for (int size : new int[] {1000, 850, 1250, 900}) {
            ui.getMethod("setWidth", double.class).invoke(window, (double)size);
            ui.getMethod("setHeight", double.class).invoke(window, size - 200.0);
            ui.getMethod("setX", double.class).invoke(grip, size - 18.0);
            ui.getMethod("setY", double.class).invoke(grip, size - 218.0);
            ui.getMethod("setWidth", double.class).invoke(grip, 18.0);
            ui.getMethod("setHeight", double.class).invoke(grip, 18.0);
            for (int tick = 0; tick < 10; tick++) ui.getMethod("update").invoke(window);
            if (((Number)ui.getMethod("getX").invoke(grip)).doubleValue() != size - 18.0
                || ((Number)ui.getMethod("getY").invoke(grip)).doubleValue() != size - 218.0)
                throw new IllegalStateException("Native resize grip drifted after explicit layout");
        }
        System.out.println("Native resize grip: repeated deferred updates preserve bottom-right position");
        System.out.println("Native deferred resize: explicitly positioned scrollbars stay within each panel");
        Class<?> table = Class.forName("se.krka.kahlua.vm.KahluaTable");
        Class<?> platform = Class.forName("se.krka.kahlua.j2se.J2SEPlatform");
        Object instance = platform.getMethod("getInstance").invoke(null);
        Object lua = platform.getMethod("newTable").invoke(instance);
        Class<?> mapClass = Class.forName("zombie.worldMap.UIWorldMap");
        Object map = mapClass.getConstructor(table).newInstance(lua);
        Object api = mapClass.getMethod("getAPIv3").invoke(map);
        Class<?> type = api.getClass();
        mapClass.getMethod("setWidth", double.class).invoke(map, 400.0);
        mapClass.getMethod("setHeight", double.class).invoke(map, 240.0);
        Object renderer = type.getMethod("getRenderer").invoke(api);
        Object world = mapClass.getMethod("getWorldMap").invoke(map);
        // Native addData/addImages bind the renderer to this world before setZoom.
        renderer.getClass().getMethod("setMap", world.getClass(), int.class, int.class, int.class, int.class)
            .invoke(renderer, world, 0, 0, 400, 240);
        type.getMethod("setMaxZoom", float.class).invoke(api, 22f);
        if (((Number)type.getMethod("getMaxZoom").invoke(api)).floatValue() != 22f)
            throw new IllegalStateException("Native map zoom configuration was not retained");
        type.getMethod("setZoom", float.class).invoke(api, 20f);
        type.getMethod("setBoolean", String.class, boolean.class).invoke(api, "Isometric", false);
        type.getMethod("setBoolean", String.class, boolean.class).invoke(api, "HideUnvisited", true);
        type.getMethod("centerOn", float.class, float.class).invoke(api, 1950.5f, 1950.5f);
        for (String name : new String[] {"worldToUIX", "worldToUIY", "uiToWorldX", "uiToWorldY"})
            type.getMethod(name, float.class, float.class);
        type.getMethod("zoomAt", float.class, float.class, float.class);
        type.getMethod("setMapItem", Class.forName("zombie.inventory.types.MapItem"));
        type.getMethod("addData", String.class);
        type.getMethod("addImages", String.class);
        type.getMethod("endDirectoryData");
        type.getMethod("setBoundsFromWorld");
        mapClass.getMethod("setConsumeMouseEvents", boolean.class).invoke(map, false);
        System.out.println("Native Controller map: construction, zoom/visibility configuration and v3 method signatures passed; rendered map acceptance pending");
    }
}
