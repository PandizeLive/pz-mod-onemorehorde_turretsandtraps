local A = require("OMHTT/TurretReloadAudio")
local S = require("OMHTT/TurretStats")
local Sounds = require("OMHTT/TurretSounds")
local oldWorld, oldRandom = getWorld, ZombRand
local played, stopped = {}, 0
local emitter = {}
function emitter:playSound(name) played[#played + 1] = name; return #played end
function emitter:setPitch(handle, pitch) check(pitch >= .95 and pitch <= 1.05, "Mechanism pitch is bounded") end
function emitter:setVolume(handle,gain) check(gain==.35,"Potato reload playback gain matches shots") end
function emitter:isPlaying(handle) return true end
function emitter:stopSound(handle) stopped = stopped + 1 end
function getWorld() return {getFreeEmitter = function() return emitter end} end
function ZombRand(n) return 50 end
local square = {getX = function() return 100 end, getY = function() return 100 end, getZ = function() return 0 end}
local object = {getSquare = function() return square end}
local potato = {getFullType = function() return "Base.OMHTTPotatoHead" end}
local stats = {reload = 2000}
A.update(object, potato, {reloadReady = 2100}, "Reloading", stats, 100)
A.update(object, potato, {reloadReady = 2100}, "Reloading", stats, 200)
check(#played == 1 and played[1] == "OMHTTPotatoReload", "Repeated feeder/UI state cannot duplicate reload cue")
A.stop(object)
check(stopped == 1 and A.entries[object] == nil, "Power/head retirement stops owned audio handles")
A.update(object, potato, {}, "Ready", {reload = 0}, 3000)
check(#played == 1, "Instant autoloader has no reload cue")
local gun = {getFullType = function() return "Base.Shotgun" end,
    getInsertAmmoStartSound = function() return "Start" end,
    getInsertAmmoSound = function() return "Insert" end,
    getInsertAmmoStopSound = function() return "Stop" end,
    getRackSound = function() return "Rack" end,
    getMagazineType = function() return nil end,
    getSwingSound = function() return "JS2000ShotgunShoot" end}
A.update(object, gun, {reloadReady = 9000}, "Reloading", {reload = 500}, 3100)
A.update(object, gun, {reloadReady = 9000}, "Reloading", {reload = 500}, 8000)
check(#played == 3 and played[3] == "Insert", "Long tick emits one insert, never a catch-up burst")
A.update(object, gun, {rackReady = 10000}, "Racking", stats, 9100)
check(played[4] == "Stop" and played[5] == "Rack", "Native loading completion and pump get separate cues")
A.update(object, gun, {rackReady = 10000}, "Racking", stats, 9200)
check(#played == 5, "Rack is not replayed on polling")
A.update(object, gun, {}, "NoMagazine", stats, 9300)
check(A.entries[object] == nil, "Invalid operating requirements cancel audio")
local plain = S.resolve({active = {}})
local one = S.resolve({active = {Suppression = 1}})
local eight = S.resolve({active = {Suppression = 8}})
check(not plain.suppressed and plain.hearingMultiplier == 1, "Last suppression removal restores normal sound and hearing")
check(one.suppressed and one.hearingMultiplier == .4, "One module reduces remaining radius by default 60 percent")
check(math.abs(eight.hearingMultiplier - .4 / 5.2) < .000001, "Suppression stacks beyond four without a bonus cap")
check(Sounds.suppressed(gun) == "OMHTTSuppressedJS2000ShotgunShoot", "Gun uses one mapped replacement")
check(Sounds.suppressed(potato) == "OMHTTPotatoSuppressed", "Potato uses its filtered owner sound")
getWorld, ZombRand = oldWorld, oldRandom
