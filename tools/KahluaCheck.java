import java.io.Reader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

public final class KahluaCheck {
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
        Path root = Path.of(args[0]);
        Class<?> animNodeType = Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimNode");
        Object node = animNodeType.getMethod("Parse", String.class).invoke(null,
            root.resolve("Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media/AnimSets/zombie/thump/OMHTTBarrierClaw.xml").toString());
        if (node == null) throw new IllegalStateException("Native thump animation parser rejected node");
        var animEvents = (java.util.List<?>)animNodeType.getField("events").get(node);
        if (animEvents.size() != 4) throw new IllegalStateException("Expected two native strikes and two matching marker events");
        int strikeCount = 0, markerCount = 0;
        for (Object event : animEvents) {
            String name = (String)event.getClass().getField("eventName").get(event);
            if (name.equals("ThumpFrame")) strikeCount++;
            if (name.equals("SetVariable")) {
                if (!event.getClass().getSimpleName().equals("AnimEventSetVariable")) throw new IllegalStateException("Marker was not transformed to native variable event");
                float time = event.getClass().getField("timePc").getFloat(event);
                boolean match = false;
                for (Object candidate : animEvents) {
                    if (candidate.getClass().getField("eventName").get(candidate).equals("ThumpFrame")
                        && candidate.getClass().getField("timePc").getFloat(candidate) == time) match = true;
                }
                if (!match) throw new IllegalStateException("Marker does not align with native strike");
                markerCount++;
            }
        }
        if (strikeCount != 2 || markerCount != 2) throw new IllegalStateException("Strike/marker counts differ");
        System.out.println("Native animation parser: two strike markers matched, SetVariable bindings resolved");
        Class<?> translatorType = Class.forName("zombie.core.Translator");
        Class<?> languageType = Class.forName("zombie.core.Language");
        var languageConstructor = languageType.getDeclaredConstructor(String.class, String.class, String.class, boolean.class);
        languageConstructor.setAccessible(true);
        Object english = languageConstructor.newInstance("EN", "English", null, false);
        Method fill = translatorType.getDeclaredMethod("tryFillMapFromFile", String.class, String.class,
            java.util.Map.class, languageType, java.util.function.Function.class);
        fill.setAccessible(true);
        Method fixer = translatorType.getDeclaredMethod("formatFixer", String.class);
        fixer.setAccessible(true);
        java.util.function.Function<String, String> formatFixer = value -> {
            try { return (String)fixer.invoke(null, value); }
            catch (Exception error) { throw new IllegalStateException(error); }
        };
        Method nativeGetText = translatorType.getMethod("getText", String.class, Object[].class);
        int translated = 0;
        for (String[] category : new String[][] {{"ContextMenu", "contextMenu"}, {"UI", "ui"}, {"Sandbox", "sandbox"}, {"Recipes", "recipe"}, {"IG_UI", "igui"}, {"ItemName", "itemName"}, {"Tooltip", "tooltip"}}) {
            var nativeCategories = (java.util.Map<?, ?>)translatorType.getField("BY_NAME").get(null);
            if (!nativeCategories.containsKey(category[0])) throw new IllegalStateException("Unrecognized native translation filename: " + category[0]);
            var field = translatorType.getDeclaredField(category[1]);
            field.setAccessible(true);
            @SuppressWarnings("unchecked")
            var map = (java.util.Map<String, String>)field.get(null);
            map.clear();
            fill.invoke(null, root.resolve("Contents/mods/OneMoreHorde_TurretsAndTraps/42.20").toString(), category[0], map, english, formatFixer);
            if (map.isEmpty()) throw new IllegalStateException("Native translation category not loaded: " + category[0]);
            for (String key : map.keySet()) {
                String.format(java.util.Locale.ROOT, map.get(key), "one", "two", "three", "four");
                String rendered = category[0].equals("Recipes")
                    ? (String)translatorType.getMethod("getRecipeName", String.class).invoke(null, key)
                    : category[0].equals("ItemName") ? (String)translatorType.getMethod("getItemNameFromFullType", String.class).invoke(null, key)
                    : (String)nativeGetText.invoke(null, key, new Object[] {"one", "two", "three", "four"});
                if (rendered.equals(key) || rendered.matches(".*%[1-4].*")) throw new IllegalStateException("Unresolved translation: " + key);
            }
            translated += map.size();
        }
        System.out.println("Native JSON translation loading and substitution: " + translated + " keys passed");
        Object textFunction = Proxy.newProxyInstance(functionType.getClassLoader(), new Class<?>[] {functionType}, (proxy, method, values) -> {
            if (!method.getName().equals("call")) return null;
            Object frame = values[0];
            int argc = ((Number)values[1]).intValue();
            Method frameGet = frame.getClass().getMethod("get", int.class);
            String key = (String)frameGet.invoke(frame, 0);
            Object[] arguments = new Object[Math.max(0, argc - 1)];
            for (int i = 1; i < argc; i++) arguments[i - 1] = frameGet.invoke(frame, i);
            Object rendered = nativeGetText.invoke(null, key, arguments);
            frame.getClass().getMethod("push", Object.class).invoke(frame, rendered);
            return 1;
        });
        set.invoke(env, "nativeText", textFunction);
        List<Path> scripts;
        try (var walk = Files.walk(root.resolve("Contents"))) {
            scripts = walk.filter(path -> path.toString().endsWith(".lua")).sorted().toList();
        }
        for (Path script : scripts) {
            try (Reader reader = Files.newBufferedReader(script)) {
                compile.invoke(null, reader, script.toString(), env);
            }
        }
        System.out.println("Kahlua compilation: " + scripts.size() + " runtime/translation files passed");
        String base = "Contents/mods/OneMoreHorde_TurretsAndTraps/42.20/media/lua/";
        String[][] stages = {
            {"_", "tools/tests/bootstrap.lua"},
            {"OMHTT/Foundation", base + "shared/OMHTT/Foundation.lua"},
            {"OMHTT/Diagnostics", base + "shared/OMHTT/Diagnostics.lua"},
            {"OMHTT/BarrierGeometry", base + "shared/OMHTT/BarrierGeometry.lua"},
            {"OMHTT/BarrierOutline", base + "server/OMHTT/BarrierOutline.lua"},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/shared/ISBaseObject.lua").toString()},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/shared/TimedActions/ISBaseTimedAction.lua").toString()},
            {"_", "tools/tests/service_load_order_before.lua"},
            {"OMHTT/BarrierApproach", base + "shared/OMHTT/BarrierApproach.lua"},
            {"OMHTT/BarrierServiceAction", base + "shared/OMHTT/BarrierServiceAction.lua"},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/TimedActions/ISClimbOverFence.lua").toString()},
            {"OMHTT/BarrierVault", base + "client/OMHTT/BarrierVault.lua"},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/TimedActions/WalkToTimedAction.lua").toString()},
            {"OMHTT/BarrierApproachAction", base + "client/OMHTT/BarrierApproachAction.lua"},
            {"OMHTT/BarrierSelection", base + "client/OMHTT/BarrierSelection.lua"},
            {"_", base + "client/OMHTT/BarrierMenu.lua"},
            {"_", "tools/tests/service_load_order_after.lua"},
            {"OMHTT/Damage", base + "server/OMHTT/Damage.lua"},
            {"OMHTT/TurretCycle", base + "shared/OMHTT/TurretCycle.lua"},
            {"OMHTT/Firearms", base + "shared/OMHTT/Firearms.lua"},
            {"OMHTT/TurretReloadAudio", base + "shared/OMHTT/TurretReloadAudio.lua"},
            {"OMHTT/TurretSounds", base + "shared/OMHTT/TurretSounds.lua"},
            {"OMHTT/TurretStats", base + "shared/OMHTT/TurretStats.lua"},
            {"OMHTT/Turret", base + "shared/OMHTT/Turret.lua"},
            {"OMHTT/TargetHealth", base + "shared/OMHTT/TargetHealth.lua"},
            {"OMHTT/TurretModules", base + "shared/OMHTT/TurretModules.lua"},
            {"OMHTT/PrototypeCombat", base + "server/OMHTT/PrototypeCombat.lua"},
            {"OMHTT/FirearmCombat", base + "server/OMHTT/FirearmCombat.lua"},
            {"OMHTT/BarrierSprites", base + "shared/OMHTT/BarrierSprites.lua"},
            {"OMHTT/BarrierFootprint", base + "server/OMHTT/BarrierFootprint.lua"},
            {"OMHTT/FoundationServer", base + "server/OMHTT/FoundationServer.lua"},
            {"_", "tools/tests/server.lua"},
            {"_", base + "client/OMHTT/FoundationClient.lua"},
            {"_", "tools/tests/client.lua"},
            {"_", "tools/tests/combat.lua"},
            {"_", "tools/tests/projectile.lua"},
            {"OMHTT/PrototypeEffects", base + "client/OMHTT/PrototypeEffects.lua"},
            {"_", "tools/tests/effects.lua"},
            {"_", "tools/tests/diagnostics.lua"},
            {"_", base + "client/OMHTT/DevMarkers.lua"},
            {"_", "tools/tests/markers.lua"},
            {"_", "tools/tests/combat_patch.lua"},
            {"OMHTT/BarrierRetaliation", base + "server/OMHTT/BarrierRetaliation.lua"},
            {"_", base + "client/OMHTT/DamagePresentation.lua"},
            {"_", "tools/tests/retaliation.lua"},
            {"_", "tools/tests/footprint.lua"},
            {"OMHTT/Construction", base + "shared/OMHTT/Construction.lua"},
            {"_", "tools/tests/native_build_bootstrap.lua"},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/server/BuildingObjects/ISBuildIsoEntity.lua").toString()},
            {"_", "tools/tests/construction.lua"},
            {"_", "tools/tests/native_menu_bootstrap.lua"},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/Entity/ISUI/BuildRecipe/ISBuildPanel.lua").toString()},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/Entity/ISUI/CraftRecipe/ISWidgetRecipeCategories.lua").toString()},
            {"_", base + "client/OMHTT/ConstructionMenu.lua"},
            {"_", "tools/tests/construction_menu.lua"},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/Entity/ISUI/CraftRecipe/ISHandCraftPanel.lua").toString()},
            {"_", Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/Entity/ISUI/Controls/ISWidgetTitleHeader.lua").toString()},
            {"_", base + "client/OMHTT/CraftingMenu.lua"},
            {"_", "tools/tests/crafting_menu.lua"},
            {"_", "tools/tests/service_bootstrap.lua"},
            {"OMHTT/BarrierService", base + "server/OMHTT/BarrierService.lua"},
            {"_", "tools/tests/barrier_service.lua"},
            {"_", "tools/tests/barrier_settings.lua"},
            {"_", "tools/tests/barrier_vault.lua"},
            {"_", "tools/tests/barrier_corners.lua"},
            {"_", "tools/tests/barrier_approach_action.lua"},
            {"OMHTT/BarrierCollisionOverlay", base + "client/OMHTT/BarrierCollisionOverlay.lua"},
            {"_", "tools/tests/barrier_overlay.lua"},
            {"_", "tools/tests/barrier_outline.lua"},
            {"_", "tools/tests/barrier_reinforcement.lua"},
            {"_", "tools/tests/barrier_selection.lua"},
            {"_", "tools/tests/turret_cycle.lua"},
            {"_", "tools/tests/turret_stats.lua"},
            {"_", "tools/tests/turret_audio.lua"},
            {"_", "tools/tests/turret_manage_bootstrap.lua"},
            {"OMHTT/TurretTransfers", base + "client/OMHTT/TurretTransfers.lua"},
            {"OMHTT/TurretMagazineAction", base + "client/OMHTT/TurretMagazineAction.lua"},
            {"OMHTT/TurretSlot", base + "client/OMHTT/TurretSlot.lua"},
            {"OMHTT/TurretAim", base + "shared/OMHTT/TurretAim.lua"},
            {"OMHTT/TurretRenderer", base + "client/OMHTT/TurretRenderer.lua"},
            {"OMHTT/TurretRange", base + "client/OMHTT/TurretRange.lua"},
            {"OMHTT/TurretSearch", base + "shared/OMHTT/TurretSearch.lua"},
            {"OMHTT/TurretManage", base + "client/OMHTT/TurretManage.lua"},
            {"_", "tools/tests/turret_manage_load_order.lua"},
            {"OMHTT/TurretWorld", base + "server/OMHTT/TurretWorld.lua"},
            {"OMHTT/TurretPickupAction", base + "shared/OMHTT/TurretPickupAction.lua"},
            {"OMHTT/TurretAutomation", base + "server/OMHTT/TurretAutomation.lua"},
            {"_", "tools/tests/turret.lua"},
            {"_", "tools/tests/turret_renderer.lua"},
            {"_", "tools/tests/sandbox_ui_setup.lua"},
            {"OMHTT/SandboxUI", base + "client/OMHTT/SandboxUI.lua"},
            {"_", "tools/tests/sandbox_ui.lua"},
            {"_", "tools/tests/turret_range.lua"},
            {"_", "tools/tests/turret_automation.lua"},
            {"_", "tools/tests/turret_install_setup.lua"},
            {"OMHTT/TurretInstall", base + "client/OMHTT/TurretInstall.lua"},
            {"_", "tools/tests/turret_install.lua"},
            {"_", "tools/tests/module_loot_bootstrap.lua"},
            {"OMHTT/LootDefinitions", base + "shared/OMHTT/LootDefinitions.lua"},
            {"OMHTT/ModuleLoot", base + "server/OMHTT/ModuleLoot.lua"},
            {"_", "tools/tests/module_loot.lua"},
            {"_", "tools/tests/turret_manage.lua"},
            {"_", "tools/tests/turret_preview_bootstrap.lua"},
            {"_", base + "client/OMHTT/TurretMenu.lua"},
            {"_", "tools/tests/turret_preview.lua"},
            {"_", "tools/tests/firearms.lua"},
        };
        for (String[] stage : stages) {
            try (Reader reader = Files.newBufferedReader(root.resolve(stage[1]))) {
                if (stage[1].equals("tools/tests/effects.lua")) {
                    Path element = Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/ISUI/ISUIElement.lua");
                    String nativeLua = Files.readString(element);
                    String source = nativeLua.substring(nativeLua.indexOf("function ISUIElement:drawLine("), nativeLua.indexOf("function ISUIElement:drawLineAbsolute("));
                    source = source.replace("function ISUIElement:drawLine(", "function testNativeDrawLine(self, ");
                    Object nativeChunk = compile.invoke(null, new java.io.StringReader(source), element.toString(), env);
                    call.invoke(thread, nativeChunk, new Object[0]);
                }
                if (stage[1].equals("tools/tests/turret_manage.lua")) {
                    Path pane = Path.of(System.getenv().getOrDefault("PZ_GAME_DIR", "C:/Program Files (x86)/Steam/steamapps/common/ProjectZomboid"), "media/lua/client/ISUI/ISInventoryPane.lua");
                    String nativeLua = Files.readString(pane);
                    String source = "ipairs = table.ipairs\n";
                    source += nativeLua.substring(nativeLua.indexOf("function ISInventoryPane.getActualItems(items)"), nativeLua.indexOf("function ISInventoryPane.getActualUniqueItems(items)"));
                    source += nativeLua.substring(nativeLua.indexOf("function ISInventoryPane:onMouseUp(x, y)"), nativeLua.indexOf("function ISInventoryPane:canPutIn()"));
                    Object nativeChunk = compile.invoke(null, new java.io.StringReader(source), pane.toString(), env);
                    call.invoke(thread, nativeChunk, new Object[0]);
                }
                Object chunk = compile.invoke(null, reader, stage[1], env);
                Object result = call.invoke(thread, chunk, new Object[0]);
                if (!stage[0].equals("_")) set.invoke(get.invoke(env, "__modules"), stage[0], result);
            } catch (InvocationTargetException error) {
                Object coroutine = threadType.getMethod("getCurrentCoroutine").invoke(thread);
                System.err.println(coroutine.getClass().getField("stackTrace").get(coroutine));
                throw new IllegalStateException("Failed stage: " + stage[1], error.getCause());
            }
        }
        Object packets = get.invoke(env, "testPackets");
        int count = ((Number)tableType.getMethod("len").invoke(packets)).intValue();
        var buffer = java.nio.ByteBuffer.allocate(60000);
        Class<?> writerType = Class.forName("zombie.core.network.ByteBufferWriter");
        Object writer = writerType.getConstructor(java.nio.ByteBuffer.class).newInstance(buffer);
        Method save = Class.forName("zombie.network.TableNetworkUtils").getMethod("save", tableType, writerType);
        int maximum = 0;
        for (int i = 1; i <= count; i++) {
            buffer.clear();
            save.invoke(null, get.invoke(packets, Double.valueOf(i)), writer);
            maximum = Math.max(maximum, buffer.position());
        }
        System.out.println("Native packet serialization: " + count + " packets; largest=" + maximum + " bytes");
        System.out.println("Assertions passed: " + get.invoke(env, "testAssertions"));
        System.out.println("World/player/network/UI objects were test doubles; in-game acceptance remains pending.");
        System.exit(0);
    }
}
