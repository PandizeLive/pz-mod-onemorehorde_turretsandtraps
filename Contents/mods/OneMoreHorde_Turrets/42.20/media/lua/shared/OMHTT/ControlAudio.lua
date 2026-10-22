local Effects = require("OMHTT/DefenseEffects")
local Active = require("OMHTT/ActiveTime")
local A = {playing = {}, clock = Active.new(), time = 0}
local sounds = {
    launch = "MetalworkingPunchSwing", impact = "SpearCraftedHit", pull = "SpearCraftedHit",
    reel = "OMHTTReeling", reset = "CloseMetalToolbox", switch = "KnobSwitch",
    poke = "ChairLegNailsHit", detected = "OMHTTLaserDetected", cleared = "OMHTTLaserCleared",
    awake = "OMHTTTurretAlert", asleep = "OMHTTTurretDeactivate", rotary = "AxeSawBladeSwing",
}

-- Relative mix only; owner WAV levels live in OMHTT_DeviceSounds.txt.
local gains = {launch = .8, impact = .7, pull = .35, reset = 1, switch = 1, poke = .65, rotary = .65}

---@param module string Namespace
---@param command string Event
---@param facts table Server event
---@return nil
function A.receive(module, command, facts)
    if isServer() or module ~= "OMHTTDeviceAudio" or command ~= "Play" or type(facts) ~= "table" or not Effects.accept(facts) then return end
    if type(facts.id) ~= "string" or type(facts.x) ~= "number" or type(facts.y) ~= "number" or type(facts.z) ~= "number" then return end
    local previous = A.playing[facts.id]
    if facts.event == "stop" or facts.event == "reel" then
        if previous then
            previous.emitter:stopSound(previous.handle)
            A.playing[facts.id] = nil
        end
    end
    local sound = sounds[facts.event]
    if not sound then return end
    local settings = SandboxVars.OMHTurretsTraps or {}
    local gain = math.max(0, math.min(2, settings.DeviceSoundVolume or settings.TrapsDeviceSoundVolume or 1))
    gain = gain * require("OMHTT/ControlOptions").get("FeedbackVolume") / 100
    if gain == 0 then return end
    local emitter = getWorld():getFreeEmitter(facts.x, facts.y, facts.z)
    local handle = emitter:playSound(sound)
    emitter:setVolume(handle, gain * (gains[facts.event] or 1))
    if facts.event == "reel" then
        A.playing[facts.id] = {emitter = emitter, handle = handle, expires = A.time + 45000}
    end
end

---@param object IsoObject Device
---@param event string Approved cue
---@return nil
function A.emit(object, event)
    if isClient() or not object then return end
    local state = require("OMHTT/ControlWorld").state(object)
    local square = object:getSquare()
    if not state or not square then return end
    local facts = {id = state.id, event = event, x = square:getX() + .5, y = square:getY() + .5, z = square:getZ()}
    if isServer() then
        Effects.send("OMHTTDeviceAudio", "Play", facts)
    else
        A.receive("OMHTTDeviceAudio", "Play", facts)
    end
end

---@return nil
function A.tick()
    if isServer() then return end
    A.time = A.time + Active.step(A.clock)
    local now = A.time
    local settings = SandboxVars.OMHTurretsTraps or {}
    local volume = math.max(0, math.min(2, settings.DeviceSoundVolume or settings.TrapsDeviceSoundVolume or 1))
        * require("OMHTT/ControlOptions").get("FeedbackVolume") / 100
    for id, playing in pairs(A.playing) do
        playing.emitter:setVolume(playing.handle, volume)
        if now > playing.expires then
            playing.emitter:stopSound(playing.handle)
            A.playing[id] = nil
        end
    end
end

Events.OnServerCommand.Add(A.receive)
Events.OnTick.Add(A.tick)
return A
