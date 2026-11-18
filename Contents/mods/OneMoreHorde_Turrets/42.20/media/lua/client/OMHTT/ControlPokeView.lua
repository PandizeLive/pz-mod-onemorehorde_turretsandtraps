if not isClient() then return end
local Active = require("OMHTT/ActiveTime")
local Access = require("OMHTT/ControlAccess")
local P = {clock = Active.new(true), time = 0}
local previews = setmetatable({}, {__mode = "k"})
local due = setmetatable({}, {__mode = "k"})

---@param object IsoThumpable Locally indexed Poke Floor
---@param state table Replicated device view
---@return nil
function P.contact(object, state)
    if state.active or previews[object] or P.time < (due[object] or 0) then return end
    local settings = SandboxVars.OMHTurretsTraps
    if not settings or settings.Enabled == false or object:getHealth() <= 0 then return end
    local cycle = math.max(.3, math.min(60, tonumber(settings.PokeCycleSeconds) or 1.5)) * 1000
    due[object] = P.time + cycle
    previews[object] = {id=state.id, expires=getTimestampMs()+350}
    -- Local sprite only. Never mutate the replicated state or send a world update.
    object:setSpriteFromName("omhtt_barrier_01_89")
    require("OMHTT/Diagnostics").count("poke-local-preview", 1, "traps")
end

---@return nil
function P.tick()
    P.time = P.time + Active.step(P.clock)
    local now = getTimestampMs()
    for object, preview in pairs(previews) do
        local state = Access.state(object)
        if object:getObjectIndex() < 0 or not state or state.id ~= preview.id then
            previews[object], due[object] = nil, nil
        elseif state.active or now >= preview.expires then
            object:setSpriteFromName(state.sprite)
            previews[object] = nil
        end
    end
end

Events.OnTick.Add(P.tick)
return P
