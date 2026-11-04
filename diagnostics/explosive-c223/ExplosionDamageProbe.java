import java.lang.reflect.*;
import java.util.Arrays;
public class ExplosionDamageProbe {
 static Object call(Object o,String n,Class<?>[] t,Object...a)throws Exception{return o.getClass().getMethod(n,t).invoke(o,a);}
 static Object get(Object o,String n)throws Exception{return call(o,n,new Class<?>[0]);}
 static void verify()throws Exception{
  Class<?> ct=Class.forName("zombie.characters.IsoGameCharacter"), wt=Class.forName("zombie.inventory.types.HandWeapon"), cellt=Class.forName("zombie.iso.IsoCell");
  Object world=Class.forName("zombie.iso.IsoWorld").getField("instance").get(null), cell=world.getClass().getField("currentCell").get(world);
  Object victim=Class.forName("zombie.characters.IsoZombie").getConstructor(cellt).newInstance(cell);
  Object attacker=get(cell,"getFakeZombieForHit"), manager=Class.forName("zombie.CombatManager").getMethod("getInstance").invoke(null);
  for(String name:new String[]{"Base.Aerosolbomb","Base.PipeBomb"}){
   Object w=Class.forName("zombie.inventory.InventoryItemFactory").getMethod("CreateItem",String.class).invoke(null,name);
   int power=(Integer)get(w,"getExplosionPower"); float extra=(Float)get(w,"getExtraDamage");
   if(!(Boolean)get(w,"isExplosive")||(Boolean)get(w,"isMelee")||extra!=0)throw new AssertionError("Unexpected weapon metadata");
   System.out.println("[ExplosionProbe] "+name+" power="+power+" range="+get(w,"getExplosionRange")+" extra="+extra+" explosive=true melee=false");
   for(float raw:new float[]{Math.min(power,100)/20f,Math.min(power,100)/10f}){
    call(victim,"setHealth",new Class<?>[]{float.class},100f);
    float processed=(Float)call(victim,"processHitDamage",new Class<?>[]{wt,ct,float.class,boolean.class,float.class},w,attacker,raw,false,1f);
    float reduced=(Float)call(manager,"applyGlobalDamageReductionMultipliers",new Class<?>[]{wt,float.class},w,processed);
    call(manager,"applyDamage",new Class<?>[]{ct,float.class},victim,reduced);
    float delta=100f-(Float)get(victim,"getHealth");
    if(Math.abs(delta-raw)>.0001f)throw new AssertionError("Unexpected damage reduction");
    System.out.println("[ExplosionProbe] raw="+raw+" processed="+processed+" delta="+delta+" omhDamage="+(delta*100));
   }
  }
  System.out.println("[ExplosionProbe] PASS native processing and health subtraction; full blast scene not exercised");
 }
 public static void main(String[]args)throws Exception{
  Runtime.getRuntime().addShutdownHook(new Thread(()->{try{verify();}catch(Throwable t){t.printStackTrace();}},"damage-probe"));
  Class.forName("zombie.network.GameServer").getMethod("main",String[].class).invoke(null,(Object)args);
 }
}