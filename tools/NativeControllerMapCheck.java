public final class NativeControllerMapCheck {
    public static void main(String[] args) throws Exception {
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
