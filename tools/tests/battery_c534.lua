local S=require("OMHTT/TurretStats")
local E=require("OMHTT/TurretBatteryEstimate")
local G=require("OMHTT/Firearms")
local R=require("OMHTT/ControlRarity")
local saved=SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps={}
R.refresh(SandboxVars.OMHTurretsTraps)
local samples={}
do local item={}
function item:getFullType() return "Base.AssaultRifle" end
function item:getMinDamage() return 1 end
function item:getMaxDamage() return 2.75 end
function item:getRecoilDelay() return 25 end
function item:getMaxAmmo() return 30 end
function item:getMaxRange() return 25 end
function item:getHitChance() return 50 end
function item:getAimingPerkHitChanceModifier() return 7 end
function item:getProjectileCount() return 1 end
function item:getCriticalChance() return 20 end
function item:getCriticalDamageMultiplier() return 4 end
function item:getCyclicRateMultiplier() return 1.0 end
function item:isRackAfterShoot() return false end
function item:haveChamber() return true end
function item:isTwoHandWeapon() return true end
function item:getMagazineType() return "Base.556Clip" end
function item:getFireMode() return "Single" end
function item:getWeaponReloadType() return "boltaction" end
function item:getFireModePossibilities() return {size=function() return 1 end,get=function() return "Auto" end} end
function item:getScriptItem() return self end
G.PROFILES["Base.AssaultRifle"]={reload=2.7,rack=1.2}
samples[#samples+1]={"AssaultRifle",item} end
do local item={}
function item:getFullType() return "Base.M4" end
function item:getMinDamage() return 1 end
function item:getMaxDamage() return 2.75 end
function item:getRecoilDelay() return 50 end
function item:getMaxAmmo() return 30 end
function item:getMaxRange() return 25 end
function item:getHitChance() return 50 end
function item:getAimingPerkHitChanceModifier() return 7 end
function item:getProjectileCount() return 1 end
function item:getCriticalChance() return 20 end
function item:getCriticalDamageMultiplier() return 4 end
function item:getCyclicRateMultiplier() return 1.0 end
function item:isRackAfterShoot() return false end
function item:haveChamber() return true end
function item:isTwoHandWeapon() return true end
function item:getMagazineType() return "Base.556Clip" end
function item:getFireMode() return "Single" end
function item:getWeaponReloadType() return "boltaction" end
function item:getFireModePossibilities() return {size=function() return 1 end,get=function() return "Auto" end} end
function item:getScriptItem() return self end
G.PROFILES["Base.M4"]={reload=2.7,rack=1.2}
samples[#samples+1]={"M4",item} end
samples[#samples+1]={"Potato",{getFullType=function() return "Base.OMHTTTurretPotato" end}}
samples[#samples+1]={"Ballista",{getFullType=function() return "Base.OMHTTTurretBallista" end}}
samples[#samples+1]={"Scrapshot",{getFullType=function() return "Base.OMHTTTurretScrapshot" end}}
samples[#samples+1]={"Arc",{getFullType=function() return "Base.OMHTTTurretArc" end}}
samples[#samples+1]={"RotaryBat",{getFullType=function() return "Base.OMHTTTurretRotaryBat" end}}
samples[#samples+1]={"RotaryBlades",{getFullType=function() return "Base.OMHTTTurretRotaryBlades" end}}
samples[#samples+1]={"Lobber Makeshift",{getFullType=function() return "Base.OMHTTTurretLobber" end},"Base.OMHTTAmmoMakeshiftBomb"}
samples[#samples+1]={"Lobber Aerosol",{getFullType=function() return "Base.OMHTTTurretLobber" end},"Base.Aerosolbomb"}
samples[#samples+1]={"Lobber Pipe",{getFullType=function() return "Base.OMHTTTurretLobber" end},"Base.PipeBomb"}

local targets={AssaultRifle=12,M4=12,Potato=61.73,Ballista=8,Scrapshot=30,Arc=2,RotaryBat=4,RotaryBlades=3,["Lobber Makeshift"]=6}
local normal=1 -- Approved captured Testing loadout; saved loot tiers are not rewritten.
local enhanced=4
local output={}
for i=1,#samples do
    local sample=samples[i]
    for _,load in pairs({{"normal",{Firing=1,MotionDetection=1},normal},{"enhanced",{FiringEnhanced=1,MotionDetectionEnhanced=1},enhanced}}) do
        local stats=S.resolve({head=sample[2],active=load[2],powerLoad=load[3],payloadType=sample[3]})
        local shots=math.floor(100/stats.batteryPercent)
        local realHours=stats.rotary and 100/stats.motorPower/16 or E.duration(stats,sample[2],shots)/3600000
        if load[1]=="normal" and targets[sample[1]] then
            check(math.abs(realHours-targets[sample[1]])/targets[sample[1]]<.06,"C534 rounded endurance target "..sample[1].." actual="..realHours.." load="..load[3].." cost="..stats.batteryPercent.." cooldown="..stats.cooldown)
        end
        output[#output+1]=string.format("C534 battery %s %s realHours=%.2f",sample[1],load[1],realHours)
    end
end
SandboxVars.OMHTurretsTraps.RotaryBatteryHours=175
check(math.abs(S.resolve({head=samples[7][2],active={}}).motorPower-100/175)<.000001,"C534 rotary accepts approved maximum above old 100 cap")
SandboxVars.OMHTurretsTraps=saved
R.refresh(saved)

testPackAudit=table.concat(output, '\n')
