import java.io.File;
import java.lang.reflect.Method;

public class NativeWorkshopCheck {
    public static void main(String[] args) throws Exception {
        Class<?> filesystemClass = Class.forName("zombie.ZomboidFileSystem");
        Object filesystem = filesystemClass.getField("instance").get(null);
        filesystemClass.getMethod("setCacheDir", String.class).invoke(filesystem, args[1]);
        Object base = filesystemClass.getField("base").get(filesystem);
        base.getClass().getMethod("set", File.class).invoke(base, new File(args[0]));
        filesystemClass.getMethod("setModFoldersOrder", String.class).invoke(filesystem, "mods");
        Class<?> itemClass = Class.forName("zombie.core.znet.SteamWorkshopItem");
        Object item = itemClass.getConstructor(String.class).newInstance(args[0]);
        if (!Boolean.TRUE.equals(itemClass.getMethod("readWorkshopTxt").invoke(item))) {
            throw new AssertionError("Workshop metadata read failed");
        }
        Method validate = itemClass.getMethod("validateContents");
        Object error = validate.invoke(item);
        if (error != null) { throw new AssertionError("Native Workshop validation: " + error); }
        if (!Integer.valueOf(3).equals(itemClass.getMethod("getVisibilityInteger").invoke(item))) {
            throw new AssertionError("Expected unlisted visibility");
        }
        System.out.println("PASS: installed-game Workshop validation, PNG and unlisted visibility. No Steam upload.");
    }
}
