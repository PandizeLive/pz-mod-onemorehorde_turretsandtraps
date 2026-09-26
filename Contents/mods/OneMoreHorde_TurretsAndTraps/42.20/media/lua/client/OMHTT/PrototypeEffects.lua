if isServer() then return end

local Foundation = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
local effects = {}

---@param module string Event namespace
---@param command string Effect command
---@param impact table Numeric shot facts
---@return nil
local function onImpact(module, command, impact)
    if module ~= Foundation.MODULE or command ~= "Impact" then return end
    for i = 1, #effects do
        if effects[i].id == impact.id and effects[i].shot == impact.shot then return end
    end
    if #effects >= 8 then table.remove(effects, 1) end
    effects[#effects + 1] = {
        id = impact.id, shot = impact.shot,
        x = impact.x, y = impact.y, z = impact.z,
        start = getTimestampMs(),
    }
    Diagnostics.emit("impact-queued", {id = impact.id, shot = impact.shot, x = impact.x, y = impact.y, z = impact.z, active = #effects})
end

---@return nil
local function render()
    if #effects == 0 then return end
    local now = getTimestampMs()
    local zoom = getCore():getZoom(0)
    for i = #effects, 1, -1 do
        local effect = effects[i]
        local age = (now - effect.start) / 650
        if age >= 1 then
            table.remove(effects, i)
        else
            local x = (IsoUtils.XToScreen(effect.x, effect.y, effect.z, 0) - IsoCamera.getOffX(0)) / zoom
            local y = (IsoUtils.YToScreen(effect.x, effect.y, effect.z, 0) - IsoCamera.getOffY(0) - 48) / zoom
            if not effect.logged then
                effect.logged = true
                Diagnostics.emit("impact-first-render", {id = effect.id, shot = effect.shot, screenX = x, screenY = y,
                    zoom = zoom, age = age, viewport = 0})
            end
            for n = 0, 5 do
                local angle = n * math.pi / 3
                local radius = (3 + age * 18) / zoom
                getTextManager():DrawStringCentre(UIFont.Small, x + math.cos(angle) * radius,
                    y + math.sin(angle) * radius, getText("UI_OMHTT_Particle"), 1, 1, 1, 1 - age)
            end
        end
    end
end

---@return nil
local function reset()
    effects = {}
end

Events.OnServerCommand.Add(onImpact)
Events.OnPostRender.Add(render)
Events.OnGameStart.Add(reset)
