local S = require("OMHTT/TurretStats")
local R = require("OMHTT/TurretRarity")
local D = require("OMHTT/TurretHeadDescription")
local saved = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {}
local function head(name)
    return {getFullType = function() return "Base.OMHTTTurret" .. name end}
end
local schedule = {.15, .25, .5, .75, 1, 1.5, 2}
for i = 1, #schedule do
    check(R.surcharges[i] == schedule[i], "Approved direct surcharge for rarity " .. i)
end
local scrap = head("Scrapshot")
local base = S.resolve({head = scrap, active = {}, powerLoad = 0})
check(base.batteryPercent == .0025, "Scrapshot base use rises by 25 percent")
local loaded = S.resolve({head = scrap, active = {Regulator = 2, Splitter = 1}, powerLoad = 13.9})
check(math.abs(loaded.batteryPercent - .0025 * 14.9) < .00000001,
    "Additive module load, Regulator and Splitter each apply once")
SandboxVars.OMHTurretsTraps.ScrapshotBatteryPercent = .004
check(S.resolve({head = scrap, active = {}}).batteryPercent == .004, "Custom Scrapshot tuning survives")
SandboxVars.OMHTurretsTraps.ScrapshotBatteryPercent = nil
local potato = S.resolve({active = {}})
SandboxVars.OMHTurretsTraps.FirearmBatteryMultiplier = 100
check(S.resolve({active = {}}).batteryPercent == potato.batteryPercent, "Firearm change excludes Potato")
SandboxVars.OMHTurretsTraps.FirearmBatteryMultiplier = nil
local cases = {{"Ballista", "High"}, {"Scrapshot", "Low"}, {"RotaryBat", "High"}, {"RotaryBlades", "VeryHigh"}, {"Lobber", "High"}}
for i = 1, #cases do
    local item = head(cases[i][1])
    local rating, drain = D.rating(item)
    check(rating.key == "UI_OMHTT_HeadBattery" .. cases[i][2] and drain > 0, "Base sustained rating " .. cases[i][1])
    local modified = S.resolve({head = item, active = {Regulator = 10, RapidFire = 2}, powerLoad = 20})
    local plain, rich = D.get(item, false, modified), D.get(item, true, modified)
    check(string.find(plain, D.battery(item, false, D.rating(item, modified)), 1, true) ~= nil,
        "Installed tooltip rating uses its effective stats; inventory remains baseline")
    check(string.find(rich, "<RGB:1,1,1>", 1, true) ~= nil, "Rich rating restores white text")
end
local blades, bat, lobber = head("RotaryBlades"), head("RotaryBat"), head("Lobber")
check(math.abs(S.resolve({head = blades}).motorPower - 100 / 3) < .000001, "Blades doubles default draw")
check(math.abs(S.resolve({head = bat}).motorPower - 100 / 6) < .000001, "Bat remains unchanged")
check(math.abs(S.resolve({head = lobber}).batteryPercent - .03) < .000001, "Lobber increases 50 percent")
check(math.abs(S.resolve({head = lobber, payloadType = "Base.PipeBomb"}).batteryPercent - .06) < .000001, "Lobber factor applies to actual payload")
for _, sample in pairs({{0,"None"},{.9,"Minimal"},{1,"VeryLow"},{2.5,"Low"},{5,"Medium"},{15,"High"},{30,"VeryHigh"},{60,"Extreme"}}) do
    SandboxVars.OMHTurretsTraps.RotaryBladesBatteryMultiplier = sample[1] / (100 / 6)
    check(D.rating(blades).key == "UI_OMHTT_HeadBattery" .. sample[2], "Absolute band boundary " .. sample[2])
end
SandboxVars.OMHTurretsTraps.RotaryBladesBatteryMultiplier = 3
SandboxVars.OMHTurretsTraps.RotaryBatteryHours = 10
check(math.abs(S.resolve({head = blades}).motorPower - 30) < .000001, "Saved rotary hours and new head factor combine")
SandboxVars.OMHTurretsTraps.LobberBatteryMultiplier = 0
check(D.rating(lobber).key == "UI_OMHTT_HeadBatteryNone", "Zero Lobber consumption is None")
SandboxVars.OMHTurretsTraps = saved
print("C355 balance: tier schedule, family isolation, saved tuning and head-only ratings passed")
