local H=require("OMHTT/DefenseHorde")
local Damage=require("OMHTT/Damage")
local Motion=require("OMHTT/DefenseMotion")
local actor=makeZombie(makeSquare(14730,14730,0),1)
for _,source in pairs({"owner-turret","stranger-turret"}) do
    for _,kind in pairs({"firearm","arc","splash","fragment","tack"}) do
        check(Damage.apply(actor,.2,source,kind)==0 and actor.health==1,"Real Horde consent API prevents disabled-run damage from every source/effect")
    end
    check(not Motion.request(actor,"push",source,14728,14730,.35),"Real Horde consent prevents foreign crowd control as well as kills")
end
check(testH474.flagsApplied==0,"Rejected stranger assistance does not invalidate the receiving run")
testH474.owner.defensesEnabled=true
check(H.allowed(actor) and Damage.apply(actor,.2,"stranger-turret","arc")>.19,"Consented Horde retains ordinary defense damage")
check(testH474.flagsApplied==1,"Permitted assistance retains existing Horde score classification")
OneMoreHordeDefenseIntegration,OneMoreHordePhase3HordeEngine,__modules.OMH_RunFlags,__modules.OMH_DifficultyRuntime,testMode=
 testH474.core,testH474.engine,testH474.flags,testH474.runtime,testH474.mode
print("[C474] Real Horde integration disabled-run damage/motion prevention verified")
