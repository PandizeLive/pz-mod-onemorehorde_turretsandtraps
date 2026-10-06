import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;


public final class BuildBaseDepth {
 public static void main(String[] args) throws Exception {
  Class.forName("zombie.core.Core").getField("tileScale").setInt(null,2);
  BufferedImage mask=ImageIO.read(new File(args[0]));
  BufferedImage out=new BufferedImage(1024,768,BufferedImage.TYPE_INT_ARGB);
  Class<?> vec=Class.forName("org.joml.Vector3f");
  var ctor=vec.getConstructor(float.class,float.class,float.class);
  Object zero=ctor.newInstance(0f,0f,0f), min=ctor.newInstance(-.3125f,0f,-.3125f), max=ctor.newInstance(.3125f,.6123724f,.3125f);
  var depth=Class.forName("zombie.tileDepth.TileGeometryUtils").getMethod("getNormalizedDepthOnBoxAt",float.class,float.class,vec,vec,vec,vec);
  int count=0, missing=0;
  for(int y=0;y<256;y++) for(int x=0;x<128;x++) {
   if((mask.getRGB(x,y)>>>24)==0) continue;
   float d=(Float)depth.invoke(null,x+.5f,y+.5f,zero,zero,min,max);
   if(d<0 || d>1) {
    // Antialiased edge pixels extend at most two pixels beyond the geometric box.
    outer: for(int r=1;r<=2;r++) for(int dy=-r;dy<=r;dy++) for(int dx=-r;dx<=r;dx++) {
     float edge=(Float)depth.invoke(null,x+.5f+dx,y+.5f+dy,zero,zero,min,max);
     if(edge>=0 && edge<=1) {d=edge; break outer;}
    }
    if(d<0 || d>1) {missing++; continue;}
   }
   int v=Math.round(d*255); int rgba=0xff000000|v<<16|v<<8|v;
   for(int index=16;index<=19;index++) out.setRGB((index%8)*128+x,(index/8)*256+y,rgba);
   count++;
  }
  if(missing!=0) throw new IllegalStateException("Unmapped visible pixels: "+missing);
  ImageIO.write(out,"png",new File(args[1]));
  System.out.println("Depth pixels="+count+" outside="+missing);
  if(args.length>2) {
   Class<?> geometry=Class.forName("zombie.tileDepth.TileGeometryFile");
   Object file=geometry.getConstructor().newInstance();
   var parse=geometry.getDeclaredMethod("parseFile",String.class); parse.setAccessible(true);
   parse.invoke(file,java.nio.file.Files.readString(java.nio.file.Path.of(args[2],"tileGeometry.txt")));
   var sets=geometry.getDeclaredField("tilesets"); sets.setAccessible(true);
   if(((java.util.List<?>)sets.get(file)).size()!=1) throw new IllegalStateException("Native geometry parse failed");
   System.out.println("Native depth geometry parser and generated mask passed; GPU texture loading remains a client check.");
  }
 }
}
