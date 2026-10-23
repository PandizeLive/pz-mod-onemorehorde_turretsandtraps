local A = require("OMHTT/TurretArcAudio")
local E = require("OMHTT/DefenseEffects")
local Options = require("OMHTT/ControlOptions")
local module = require("OMHTT/Foundation").MODULE
local old = {mode = testMode, world = getWorld, time = getTimestampMs,
    settings = SandboxVars.OMHTurretsTraps, get = Options.get}
testMode, SandboxVars.OMHTurretsTraps = "client", {}
local now, sounds, localVolume = 1000, {}, 100
getTimestampMs = function() return now end
Options.get = function() return localVolume end
getWorld = function() return {getFreeEmitter = function(_, x, y, z)
    return {playSound = function(_, name) sounds[#sounds + 1] = {name = name, x = x, y = y, z = z}; return #sounds end,
        setVolume = function(_, handle, volume) sounds[handle].volume = volume end,
        setPitch = function() error("Arc must use verified native file clip pitch") end}
end} end
local facts = {x = 1, y = 2, z = 0, gain = 1, packet = 99999901}
require("OMHTT/PrototypeEffects").receive(module, "ArcShot", facts)
A.receive(module, "ArcShot", facts)
A.receive(module, "ArcShot", facts)
check(#sounds == 1 and sounds[1].name == "OMHTTArcFire" and sounds[1].volume == 1.3,
    "Arc sound survives unrelated handler and suppresses duplicate MP delivery")
facts.packet = nil
for i = 1, 8 do A.receive(module, "ArcHit", facts) end
check(#sounds == 5 and sounds[2].name == "DismantleFailed" and sounds[2].volume == .12,
    "Impact mix limits simultaneous contact bursts without changing damage")
now = 1100
A.receive(module, "ArcHit", facts)
check(#sounds == 6, "Impact budget recovers after 100 milliseconds")
facts.gain = .01
A.receive(module, "ArcShot", facts)
check(math.abs(sounds[7].volume - .13) < .000001, "Suppression respects existing audible floor")
localVolume = 0
A.receive(module, "ArcShot", facts)
check(#sounds == 7, "Local sound preference mutes Arc")
localVolume, SandboxVars.OMHTurretsTraps.DeviceSoundVolume = 100, 0
A.receive(module, "ArcHit", facts)
check(#sounds == 7, "Sandbox master mutes Arc")
SandboxVars.OMHTurretsTraps.DeviceSoundVolume = 1
facts.x = math.huge
A.receive(module, "ArcShot", facts)
check(#sounds == 7, "Malformed endpoint cannot create native emitter")
local view = require("OMHTT/TurretArcView")
view.bursts, view.cursor = {}, 1
local beam = {fromX = 0, fromY = 0, x = 2, y = 0, z = 0, packet = 99999902}
require("OMHTT/PrototypeEffects").receive(module, "Arc", beam)
view.receive(module, "Arc", beam)
view.receive(module, "Arc", beam)
check(view.cursor == 2, "Arc visual survives unrelated handler with one MP delivery")
view.bursts, view.cursor = {}, 1
A.window, A.impacts = 0, 0
testMode, getWorld, getTimestampMs = old.mode, old.world, old.time
SandboxVars.OMHTurretsTraps, Options.get = old.settings, old.get
print("[OMHTT-C422] arc sound routing, suppression, volume, burst limit and MP deduplication checked")
