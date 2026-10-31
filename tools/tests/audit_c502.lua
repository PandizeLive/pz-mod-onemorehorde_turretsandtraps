-- Diagnostic reproductions against unmodified 0.2.70.5, not acceptance tests.
-- Run as KahluaCheck's optional audit after the existing suite.
local W = require("OMHTT/ControlWorld")
local P = require("OMHTT/ControlPoke")
local H = require("OMHTT/DefenseHorde")
local D = require("OMHTT/Damage")
local U = require("OMHTT/ControlClient")
local Access = require("OMHTT/ControlAccess")
local saved = {mode = testMode, visual = P.visual, state = W.state, publish = W.publish,
    allowed = H.allowed, resolve = D.resolve, emit = require("OMHTT/ControlAudio").emit,
    settings = SandboxVars.OMHTurretsTraps, access = Access.state}
testMode = "server"
SandboxVars.OMHTurretsTraps = {Enabled = true, PokeDamage = 45, PokeCycleSeconds = 1.5}
local square = makeSquare(3900, 3900, 0)
local zombie = {kind = "IsoZombie", isDead = function() return false end}
local object = {getSquare = function() return square end, getHealth = function() return 200 end}
local state = {id = "c502-poke", kind = "Poke"}
local hits = 0
P.visual = function(_, s, active) s.active = active end
W.state = function() return state end
W.publish = function() end
H.allowed = function() return true end
require("OMHTT/ControlAudio").emit = function() end
D.resolve = function() hits = hits + 1; return true end

-- A newly observed occupied trap ignores its first second.
P.time = 0
square.moving = {zombie}
P.step(object, state)
check(not state.active and hits == 0, "C502 reproduction: initial one-second Poke delay")
square.moving = {}
P.time = 500
P.step(object, state)
P.time = 1000
P.step(object, state)
check(hits == 0 and not state.active, "C502 reproduction: crossing during initial delay is lost")

-- The next visit after an entire cycle discards a pending strike first.
square.moving = {zombie}
P.step(object, state)
check(state.active and hits == 0, "C502 setup: Poke arms with a pending strike")
P.time = 2600
P.step(object, state)
check(hits == 0 and state.active, "C502 reproduction: overdue strike replaced without damage")
P.time = 2750
P.step(object, state)
check(hits == 1, "C502 control: ordinary scheduled strike reaches damage")
P.entries[object] = nil
P.visual, W.state, W.publish, H.allowed, D.resolve = saved.visual, saved.state, saved.publish, saved.allowed, saved.resolve
require("OMHTT/ControlAudio").emit = saved.emit
SandboxVars.OMHTurretsTraps = saved.settings

-- Persisted automatic labels bypass localization, even when the key exists.
Access.state = function() return {kind = "Poke", number = 3, displayName = "UI_OMHTT_ControlPoke #3"} end
check(U.name({}) == "UI_OMHTT_ControlPoke #3", "C502 reproduction: raw persisted label reaches UI")
Access.state = saved.access

-- The existing adapter deliberately ignores multiplayer damage notifications.
local popups = 0
local oldIndicator, oldPlayer = PixelStrikeIndicator, getSpecificPlayer
PixelStrikeIndicator = {Config = {showDamageDealt = true, showOrdinaryHits = true, scale = 100},
    spawn = function() popups = popups + 1 end}
getSpecificPlayer = function() return {getZ = function() return 0 end} end
local victim = {getSquare = function() return square end}
testMode = "sp"
triggerEvent("OnOMHTTDamage", victim, .2, "c502", "tack")
check(popups == 1, "C502 control: SP adapter produces damage popup")
testMode = "client"
triggerEvent("OnOMHTTDamage", victim, .2, "c502", "tack")
check(popups == 1, "C502 reproduction: MP adapter suppresses same popup")
PixelStrikeIndicator, getSpecificPlayer, testMode = oldIndicator, oldPlayer, saved.mode

-- Without a first server zombie update, the deferred maximum becomes first-hit HP.
testMode = "server"
local Health = require("OMHTT/TargetHealth")
local Conditional = require("OMHTT/TurretConditionalHit")
local wounded = {kind = "IsoZombie", hp = 1, getHealth = function(self) return self.hp end}
Health.created(wounded)
wounded.hp = .15
local result = Conditional.snapshot(wounded, {initialBlow = .3, initialThreshold = .9, execute = .18})
check(Health.maximum(wounded) == .15 and result.bonus == 1.3 and not result.execute,
    "C502 reproduction: delayed server baseline classifies previously wounded target as full health")
testMode = saved.mode
testPackAudit = "C502: Poke initial-crossing/overdue-strike, raw label, MP popup, delayed conditional-health failures reproduced; unchanged production code"
