import java.lang.reflect.Field;
import java.nio.file.Path;
import java.util.List;

/** Real game packet, condition selector and event dispatcher; no Lua marker injection. */
public final class NativeBarrierAnimationProbe {
    private static Object field(Object object, String name) throws Exception {
        Field field = object.getClass().getDeclaredField(name);
        field.setAccessible(true);
        return field.get(object);
    }
    public static void verify(Path root) throws Exception {
        Class<?> actorType = Class.forName("zombie.characters.IsoZombie");
        Class<?> character = Class.forName("zombie.characters.IsoGameCharacter");
        Class<?> cellType = Class.forName("zombie.iso.IsoCell");
        Class<?> world = Class.forName("zombie.iso.IsoWorld");
        Object cell = world.getField("currentCell").get(world.getField("instance").get(null));
        Field server = Class.forName("zombie.network.GameServer").getField("server");
        boolean wasServer = server.getBoolean(null);
        server.setBoolean(null, false);
        try {
            Object actor = actorType.getConstructor(cellType).newInstance(cell);
            var setString = character.getMethod("setVariable", String.class, String.class);
            var setBool = character.getMethod("setVariable", String.class, boolean.class);
            setString.invoke(actor, "ThumpType", "OMHTTBarrierClaw");
            setBool.invoke(actor, "OMHTTBarrierContact", true);
            Class<?> nodeType = Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimNode");
            var matches = nodeType.getMethod("checkConditions", Class.forName("zombie.core.skinnedmodel.advancedanimation.IAnimationVariableSource"));
            Object oldNode = nodeType.getMethod("Parse", String.class).invoke(null,
                root.resolve("tools/tests/fixtures/BarrierClaw_preC515.xml").toString());
            if (!Boolean.TRUE.equals(matches.invoke(oldNode, actor))) throw new IllegalStateException("Frozen Barrier node was not initially selected");
            Class<?> packetType = Class.forName("zombie.network.packets.character.ThumpPacket");
            Object packet = packetType.getConstructor().newInstance();
            Object zombieId = field(packet, "zombie");
            zombieId.getClass().getMethod("set", actorType).invoke(zombieId, actor);
            Field type = packetType.getDeclaredField("type");
            type.setAccessible(true);
            type.set(packet, "Door");
            packetType.getMethod("processClient", Class.forName("zombie.core.raknet.UdpConnection")).invoke(packet, new Object[]{null});
            if (!"Door".equals(character.getMethod("getVariableString", String.class).invoke(actor, "ThumpType")))
                throw new IllegalStateException("Native echoed packet did not reproduce custom ThumpType overwrite");
            if (Boolean.TRUE.equals(matches.invoke(oldNode, actor))) throw new IllegalStateException("Frozen Barrier unexpectedly survived native echo");
            Object node = nodeType.getMethod("Parse", String.class).invoke(null,
                root.resolve("Source/42.20/media/AnimSets/zombie/thump/OMHTTBarrierClaw.xml").toString());
            if (!Boolean.TRUE.equals(matches.invoke(node, actor)))
                throw new IllegalStateException("Barrier animation lost selection after native Thump echo");
            Class<?> stateType = Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimState");
            Object state = stateType.getConstructor().newInstance();
            Path vanilla = Path.of(System.getProperty("user.dir"), "media/AnimSets/zombie/thump");
            for (String name : new String[]{"Door.xml", "DoorBang.xml", "DoorClaw.xml"}) {
                Object stock = nodeType.getMethod("Parse", String.class).invoke(null, vanilla.resolve(name).toString());
                stateType.getMethod("addNode", nodeType).invoke(state, stock);
            }
            stateType.getMethod("addNode", nodeType).invoke(state, node);
            List<?> selected = (List<?>)stateType.getMethod("getAnimNodes",
                Class.forName("zombie.core.skinnedmodel.advancedanimation.IAnimationVariableSource"), List.class)
                .invoke(state, actor, new java.util.ArrayList<>());
            if (selected.size() != 1 || selected.get(0) != node)
                throw new IllegalStateException("Native selector blends a stock thump over Barrier markers");
            Object broadcaster = character.getMethod("getAnimEventBroadcaster").invoke(actor);
            Class<?> eventType = Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimEvent");
            var deliver = broadcaster.getClass().getMethod("animEvent", character,
                Class.forName("zombie.core.skinnedmodel.advancedanimation.AnimLayer"),
                Class.forName("zombie.core.skinnedmodel.animation.AnimationTrack"), eventType);
            int markers = 0;
            for (Object event : (List<?>)nodeType.getField("events").get(node)) {
                if (!"SetVariable".equals(eventType.getField("eventName").get(event))) continue;
                deliver.invoke(broadcaster, actor, null, null, event);
                String expected = markers++ == 0 ? "left" : "right";
                if (!expected.equals(character.getMethod("getVariableString", String.class).invoke(actor, "OMHTTBarrierStrike")))
                    throw new IllegalStateException("Native parsed strike event did not set " + expected);
            }
            if (markers != 2) throw new IllegalStateException("Two native strike events required");
            setBool.invoke(actor, "OMHTTBarrierContact", false);
            if (Boolean.TRUE.equals(matches.invoke(node, actor))) throw new IllegalStateException("Released Barrier remains selected");
            System.out.println("[OMHTT-C515] native-barrier packetOverwrite=reproduced newCondition=survives parsedMarkers=2 release=passed rendered=false clients=0");
        } finally { server.setBoolean(null, wasServer); }
    }
}
