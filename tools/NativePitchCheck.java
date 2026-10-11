import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;

public final class NativePitchCheck {
    private static Object call(Object object, String method, Class<?>[] types, Object... args) throws Exception {
        return object.getClass().getMethod(method, types).invoke(object, args);
    }
    private static void check(boolean value, String message) {
        if (!value) throw new IllegalStateException(message);
    }
    public static void main(String[] args) throws Exception {
        Object random = Class.forName("zombie.core.random.RandStandard").getField("INSTANCE").get(null);
        call(random, "init", new Class<?>[]{});
        Class.forName("zombie.core.Core").getMethod("getInstance").invoke(null);
        Object fs = Class.forName("zombie.ZomboidFileSystem").getField("instance").get(null);
        call(fs, "setCacheDir", new Class<?>[]{String.class}, args[1]);
        Object manager = Class.forName("fmod.fmod.FMODManager").getField("instance").get(null);
        call(manager, "init", new Class<?>[]{});
        Class<?> gs = Class.forName("zombie.audio.GameSound");
        Class<?> sounds = Class.forName("zombie.GameSounds");
        Class<?> scriptType = Class.forName("zombie.scripting.objects.GameSoundScript");
        Map active = (Map)fs.getClass().getField("activeFileMap").get(fs);
        Object soundManager = Class.forName("zombie.SoundManager").getConstructor().newInstance();
        Class.forName("zombie.SoundManager").getField("instance").set(null, soundManager);
        Class<?> emitterType = Class.forName("fmod.fmod.FMODSoundEmitter");
        Object emitter = emitterType.getConstructor().newInstance();
        call(emitter, "setPos", new Class<?>[]{float.class,float.class,float.class}, 10f,10f,0f);
        Field pending = emitterType.getDeclaredField("toStart");
        pending.setAccessible(true);
        Field pitchField = Class.forName("fmod.fmod.FMODSoundEmitter$Sound").getDeclaredField("pitch");
        pitchField.setAccessible(true);
        Pattern pattern = Pattern.compile("sound\\s+(\\w+)\\s*\\{");
        int definitions = 0, clipsChecked = 0, plays = 0;
        double maximum = 0;
        for (String filename : new String[]{"OMHTT_Sounds.txt", "OMHTT_SuppressionSounds.txt"}) {
            String text = Files.readString(Path.of(args[0], "media/scripts", filename));
            Matcher match = pattern.matcher(text);
            while (match.find()) {
                int finish = match.end(), depth = 1;
                while (depth > 0 && finish < text.length()) {
                    char token = text.charAt(finish++);
                    if (token == '{') depth++;
                    if (token == '}') depth--;
                }
                check(depth == 0, "Unbalanced sound definition");
                Object script = scriptType.getConstructor().newInstance();
                call(script, "Load", new Class<?>[]{String.class, String.class}, match.group(1), text.substring(match.start(), finish));
                Object sound = scriptType.getField("gameSound").get(script);
                List<?> clips = (List<?>)gs.getField("clips").get(sound);
                Map<String,Set<Integer>> pitches = new HashMap<>();
                for (Object clip : clips) {
                    String file = (String)call(clip, "getFile", new Class<?>[]{});
                    int pitch = Math.round(((Number)call(clip,"getPitch",new Class<?>[]{})).floatValue() * 1000);
                    check(pitch >= 950 && pitch <= 1050, "Out-of-range native pitch");
                    check(pitches.computeIfAbsent(file, key -> new HashSet<>()).add(pitch), "Duplicate clip weighting");
                    Path asset = Path.of(args[0], file);
                    if (!Files.exists(asset)) asset = Path.of(args[2], file);
                    check(Files.exists(asset), "Missing audio asset: " + file);
                    active.put(file.toLowerCase(Locale.ROOT), asset.toString());
                    clip.getClass().getField("volume").setFloat(clip, 0f);
                    clipsChecked++;
                }
                for (Set<Integer> values : pitches.values()) check(values.size() == 101, "Lost native pitch resolution");
                sounds.getMethod("addSound", gs).invoke(null, sound);
                Set<Integer> observed = new HashSet<>();
                for (int round = 0; round < 30; round++) {
                    long started = System.nanoTime();
                    long handle = (Long)call(emitter,"playSound",new Class<?>[]{String.class}, match.group(1));
                    maximum = Math.max(maximum, (System.nanoTime() - started) / 1e6);
                    check(handle != 0, "Native sound failed to load: " + match.group(1));
                    List<?> queue = (List<?>)pending.get(emitter);
                    Object queued = queue.get(queue.size() - 1);
                    int actualPitch = Math.round(pitchField.getFloat(queued) * 1000);
                    check(actualPitch >= 950 && actualPitch <= 1050, "FileSound failed to inherit clip pitch");
                    observed.add(actualPitch);
                    call(emitter,"stopSound",new Class<?>[]{long.class},handle);
                    plays++;
                }
                check(observed.size() > 1, "Native selection did not vary pitch: " + match.group(1));
                definitions++;
            }
        }
        check(definitions == 23 && clipsChecked == 2626 && plays == 690, "Incomplete source sound coverage");
        System.out.printf(Locale.ROOT,"NATIVE_PITCH_PASS definitions=%d clips=%d plays=%d range=0.950-1.050 steps=101 queued-pitch=verified maxPlayMs=%.3f%n", definitions, clipsChecked, plays, maximum);
        System.exit(0);
    }
}
