local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local S = require("OMHTT/TurretStandby")
local Clock = require("OMHTT/TurretClock")
local Audio = require("OMHTT/ControlAudio")
local Authority = require("OMHTT/TurretAuthority")
local old = {state = T.state, config = T.cycleConfig, on = T.isOn, valid = W.valid,
    power = W.power, clock = Clock.now, target = S.valid, publish = Authority.publish,
    sound = Audio.emit, settings = SandboxVars.OMHTurretsTraps}
local state, now, powered, targetValid, cues = {standby = "active"}, 0, true, true, {}
local object, target, contents = {}, {}, {active = {MotionDetection = 1}}
SandboxVars.OMHTurretsTraps = {}
T.state = function() return state end
T.isOn = function() return state.on ~= false end
T.cycleConfig = function() return {} end
W.valid = function() return true end
W.power = function() return powered end
Clock.now = function() return now end
S.valid = function() return targetValid end
Authority.publish = function() end
Audio.emit = function(_, cue) cues[#cues + 1] = cue end
check(S.step(object, contents) and state.standby == "active", "New detector starts active")
now = 6999
check(S.step(object, contents), "Standby does not start before seven active seconds")
now = 7000
check(not S.step(object, contents) and state.standby == "asleep", "Seven seconds enters standby")
check(#cues == 1 and cues[1] == "asleep", "One deactivate cue on transition")
for i = 1, 20 do S.step(object, contents) end
check(#cues == 1, "Idle ticks never repeat deactivate cue")
check(not S.step(object, contents, target) and state.standby == "waking", "Target starts one-second wake")
now = 7999
check(not S.step(object, contents, target) and #cues == 1, "No early fire or alert during wake")
now = 8000
check(not S.step(object, contents, target) and state.standby == "active" and cues[2] == "awake", "Alert starts a quarter-second firing delay")
now = 8249
check(not S.step(object, contents, target), "No firing before alert delay")
now = 8250
check(S.step(object, contents, target), "Firing resumes after alert delay")
now = 15250
S.step(object, contents)
S.step(object, contents, target)
targetValid = false
check(not S.step(object, contents) and state.standby == "asleep", "Invalid target immediately aborts wake")
check(#cues == 3, "Aborted wake does not play acquisition sound")
targetValid = true
contents.active.MotionDetection = nil
check(S.step(object, contents, target) and state.standby == "active", "Manual/trigger-only turret bypasses standby")
contents.active.MotionDetection = 1
now = 25000
check(S.step(object, contents, nil, true), "Busy action cannot enter standby")
now = 31999
check(S.step(object, contents), "Busy action resets idle deadline")
now = 32000
check(not S.step(object, contents), "Completed action can subsequently sleep")
powered = false
check(not S.step(object, contents, target) and state.standby == "disabled", "No power disables marker and firing")
powered = true
now = 40000
check(not S.step(object, contents, target) and state.standby == "waking", "Power-on requires initial detector wake")
now = 41000
local beforeWake = #cues
check(not S.step(object, contents, target) and #cues == beforeWake + 1 and cues[#cues] == "awake", "Initial wake plays alert before firing")
targetValid = false
now = 41100
check(not S.step(object, contents, target) and state.standby == "asleep", "Target lost during alert delay cancels firing")
targetValid = true
SandboxVars.OMHTurretsTraps.TurretStandbyEnabled = false
check(S.step(object, contents) and state.standby == "active", "Sandbox can disable standby")
S.entries[object] = nil
T.state, T.cycleConfig, T.isOn = old.state, old.config, old.on
W.valid, W.power, Clock.now, S.valid = old.valid, old.power, old.clock, old.target
Authority.publish, Audio.emit = old.publish, old.sound

local A = require("OMHTT/ControlAccess")
SandboxVars.OMHTurretsTraps = {}
check(A.radius() == 10 and A.laserRange() == 10, "New default Controller and fixed laser ranges")
SandboxVars.OMHTurretsTraps = {TrapsControllerRange = 55, TrapsLaserRange = 17}
check(A.radius() == 55 and A.laserRange() == 17, "Independent Traps Sandbox fallback")
SandboxVars.OMHTurretsTraps.ControllerRange = 1000
SandboxVars.OMHTurretsTraps.LaserRange = 1000
check(A.radius() == 100 and A.laserRange() == 32, "Malformed ranges remain bounded")

local C = require("OMHTT/TetherCycle")
local cycle = C.new(10, 10, 0, 1, 0, {range = 6, speed = 30, returnSpeed = 4, resetTime = .7, holdTime = .75})
check(C.start(cycle, true, false), "Automatic tether starts without external input")
cycle.phase, cycle.distance, cycle.backTime = "back", 3, .5
local facts = C.snapshot(cycle, "control-123", 1, "123")
check(facts.height == .025 and C.accept(nil, facts), "Retracting nail falls to floor in bounded server snapshot")
facts.height = -1
check(not C.accept(nil, facts), "Negative visual height rejected")
facts.height = 0 / 0
check(not C.accept(nil, facts), "NaN visual height rejected")

local Art = require("OMHTT/TurretModuleArt")
local R = require("OMHTT/TurretRarity")
local oldComponent, oldRarity, oldTexture = T.component, R.get, getTexture
local oldTextures = Art.textures
Art.textures = {}
local band, writes = 1, 0
T.component = function() return "RapidFire" end
R.get = function() return {band = band} end
getTexture = function(path) return path end
local item = {getFullType = function() return "Base.Test" end,
    setTexture = function(self, texture) self.texture = texture; writes = writes + 1 end,
    setIcon = function(self, texture) self.icon = texture end}
Art.apply(item)
check(item.icon == item.texture and writes == 1, "Existing module gets matching icon and texture")
Art.apply(item)
check(writes == 1, "Unchanged rarity does not rewrite native item every frame")
band = 7
Art.apply(item)
check(writes == 2 and string.find(item.texture, "mythic", 1, true), "Changed effective rarity refreshes existing item artwork")
T.component = function() return "CapacityLarge" end
item.getFullType = function() return "Base.OMHTTModuleExpansionLarge" end
require("OMHTT/ControlExpansionArt").apply(item)
check(string.find(item.texture, "expansion", 1, true), "Expansion kit uses its own category art")
T.component = function() return "Detection" end
Art.apply(item)
check(writes == 3, "Categories without supplied artwork retain their icons")
for _, component in pairs({"Grid", "Siphon", "Lure", "Void"}) do
    T.component = function() return component end
    for tier = 1, 7 do
        band = tier
        Art.apply(item)
        check(item.texture == "media/textures/OMHTT/Modules/utility_" .. string.lower(R.names[tier]) .. ".png",
            "Utility artwork follows effective rarity for " .. component)
    end
end
for _, component in pairs({"Piercing", "InitialBlow", "Execute", "Impact", "Splitter", "Fragment", "Synergy", "Martyrdom", "Tack"}) do
    T.component = function() return component end
    for tier = 1, 7 do
        band = tier
        Art.apply(item)
        check(item.texture == "media/textures/OMHTT/Modules/effects_" .. string.lower(R.names[tier]) .. ".png",
            "Effects artwork follows effective rarity for " .. component)
    end
end
for _, component in pairs({"FiringEnhanced", "MotionDetectionEnhanced", "Firing", "Filter",
    "MotionDetection", "Detection360", "MotionDetectionImprovised", "FiringImprovised"}) do
    T.component = function() return component end
    for tier = 1, 7 do
        band = tier
        Art.apply(item)
        check(item.texture == "media/textures/OMHTT/Modules/automation_" .. string.lower(R.names[tier]) .. ".png",
            "Automation artwork follows effective rarity for " .. component)
    end
end
Art.textures = oldTextures
T.component, R.get, getTexture = oldComponent, oldRarity, oldTexture
SandboxVars.OMHTurretsTraps = old.settings

-- Compact device tips must cover every serviceable family, including Poke Floor.
local D = require("OMHTT/ControlItemDescription")
local savedText, savedItemName = getText, getItemNameFromFullType
getText = function(key, ...) return key end
getItemNameFromFullType = function(name) return name end
for _, kind in pairs({"SpikeBarrier", "SpikeBarrierReinforced", "BedSpikes", "BedSpikesReinforced", "BarbedPanel", "ConcertinaWire", "PokeFloor", "TetherDart", "Controller", "Button", "PressurePlate", "Lever", "Laser"}) do
    local tip = D.get({getFullType = function() return "Base.OMHTTTrap" .. kind end})
    check(tip and not string.find(tip, "UI_OMHTT_DeviceRepair", 1, true) and string.find(tip, "UI_OMHTT_DeviceHealth", 1, true), "Compact purpose/repair/service tip: " .. kind)
end
getText, getItemNameFromFullType = savedText, savedItemName

-- Mix gain follows the player's master setting; mute also stops an existing reel.
local soundWorld, soundServer, soundSettings = getWorld, isServer, SandboxVars.OMHTurretsTraps
local played, volume, stopped = 0, 0, 0
local soundEmitter = {
    playSound = function(self, sound) played = played + 1; return played end,
    setVolume = function(self, handle, gain) volume = gain end,
    stopSound = function(self, handle) stopped = stopped + 1 end,
}
getWorld = function() return {getFreeEmitter = function() return soundEmitter end} end
isServer = function() return false end
SandboxVars.OMHTurretsTraps = {DeviceSoundVolume = .5}
Audio.receive("OMHTTDeviceAudio", "Play", {id = "mix-test", event = "impact", x = 0, y = 0, z = 0})
check(math.abs(volume - .35) < .0001, "Native impact gain respects half master volume")
Audio.receive("OMHTTDeviceAudio", "Play", {id = "mix-test", event = "pull", x = 0, y = 0, z = 0})
check(math.abs(volume - .175) < .0001, "Repeated pull cue is quieter than impact")
Audio.receive("OMHTTDeviceAudio", "Play", {id = "mix-test", event = "reel", x = 0, y = 0, z = 0})
check(volume == .5 and Audio.playing["mix-test"], "Custom WAV uses script mix once, then master gain")
SandboxVars.OMHTurretsTraps.DeviceSoundVolume = 0
Audio.receive("OMHTTDeviceAudio", "Play", {id = "mix-test", event = "reel", x = 0, y = 0, z = 0})
check(played == 3 and stopped == 1 and not Audio.playing["mix-test"], "Muted replacement stops old reel without starting another")
getWorld, isServer, SandboxVars.OMHTurretsTraps = soundWorld, soundServer, soundSettings
