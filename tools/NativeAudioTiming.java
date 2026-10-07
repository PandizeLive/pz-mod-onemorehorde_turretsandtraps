import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;

public final class NativeAudioTiming {
    private static Object call(Object object, String method, Class<?>[] types, Object... args) throws Exception {
        return object.getClass().getMethod(method, types).invoke(object, args);
    }
    public static void main(String[] args) throws Exception {
        Object random = Class.forName("zombie.core.random.RandStandard").getField("INSTANCE").get(null);
        call(random, "init", new Class<?>[]{});
        Object core = Class.forName("zombie.core.Core").getMethod("getInstance").invoke(null);
        Object fs = Class.forName("zombie.ZomboidFileSystem").getField("instance").get(null);
        call(fs, "setCacheDir", new Class<?>[]{String.class}, args[1]);
        Object manager = Class.forName("fmod.fmod.FMODManager").getField("instance").get(null);
        call(manager, "init", new Class<?>[]{});
        Class<?> gs = Class.forName("zombie.audio.GameSound");
        Class<?> clipType = Class.forName("zombie.audio.GameSoundClip");
        Class<?> sounds = Class.forName("zombie.GameSounds");
        Map active = (Map)fs.getClass().getField("activeFileMap").get(fs);
        Object soundManager = Class.forName("zombie.SoundManager").getConstructor().newInstance();
        Class.forName("zombie.SoundManager").getField("instance").set(null, soundManager);
        Object emitter = Class.forName("fmod.fmod.FMODSoundEmitter").getConstructor().newInstance();
        call(emitter, "setPos", new Class<?>[]{float.class,float.class,float.class}, 10f,10f,0f);
        for (String filename : new String[]{"potato_thump_1.wav","potato_thump_2.wav","potato_splat_1.wav","potato_splat_2.wav"}) {
            String relative = "media/sound/" + filename;
            active.put(relative, Path.of(args[0], relative).toString());
            Object sound = gs.getConstructor().newInstance();
            gs.getField("name").set(sound, filename);
            Object clip = clipType.getConstructor(gs).newInstance(sound);
            clipType.getField("file").set(clip, relative);
            clipType.getField("volume").setFloat(clip, 0f);
            ((List)gs.getField("clips").get(sound)).add(clip);
            sounds.getMethod("addSound", gs).invoke(null,sound);
            for (int round=0;round<30;round++) {
                long start=System.nanoTime();
                long handle=(Long)call(emitter,"playSound",new Class<?>[]{String.class},filename);
                long played=System.nanoTime();
                call(emitter,"setPitch",new Class<?>[]{long.class,float.class},handle,1.03f);
                long pitched=System.nanoTime();
                call(emitter,"setVolume",new Class<?>[]{long.class,float.class},handle,0f);
                long volume=System.nanoTime();
                call(emitter,"stopSound",new Class<?>[]{long.class},handle);
                System.out.printf(Locale.ROOT,"sound=%s round=%d handle=%d playMs=%.3f pitchMs=%.3f volumeMs=%.3f%n",filename,round,handle,(played-start)/1e6,(pitched-played)/1e6,(volume-pitched)/1e6);
                if(handle==0) throw new IllegalStateException("Sound did not load");
            }
        }
        System.out.println("AUDIO_PROBE_PASS");
        System.exit(0);
    }
}
