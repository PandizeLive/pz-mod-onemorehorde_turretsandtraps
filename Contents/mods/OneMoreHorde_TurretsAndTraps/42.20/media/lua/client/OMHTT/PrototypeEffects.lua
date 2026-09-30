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
    local square = getCell():getGridSquare(math.floor(impact.x), math.floor(impact.y), impact.z)
    if square then
        getSoundManager():PlayWorldSound("OMHTTPotatoImpact", square, 0, 12, 1, false)
    end
    effects[#effects + 1] = {
        id = impact.id, shot = impact.shot,
        x = impact.x, y = impact.y, z = impact.z,
        fromX = impact.fromX, fromY = impact.fromY,
        start = getTimestampMs(),
    }
    Diagnostics.emit("impact-queued", {id = impact.id, shot = impact.shot, x = impact.x, y = impact.y, z = impact.z,
        fromX = impact.fromX, fromY = impact.fromY, active = #effects})
end

---@return nil
local function render()
    if #effects == 0 then return end
    local now = getTimestampMs()
    local zoom = getCore():getZoom(0)
    for i = #effects, 1, -1 do
        local effect = effects[i]
        local flight = 0
        if effect.fromX and effect.fromY then
            flight = 120
        end
        local elapsed = now - effect.start
        local age = (elapsed - flight) / 650
        local square = getCell():getGridSquare(math.floor(effect.x), math.floor(effect.y), effect.z)
        local player = getSpecificPlayer(0)
        if age >= 1 or not square or not player or math.floor(player:getZ()) ~= effect.z or not square:isCanSee(0) then
            table.remove(effects, i)
        else
            local x = (IsoUtils.XToScreen(effect.x, effect.y, effect.z, 0) - IsoCamera.getOffX(0)) / zoom
            local y = (IsoUtils.YToScreen(effect.x, effect.y, effect.z, 0) - IsoCamera.getOffY(0) - 64) / zoom
            if not effect.logged then
                effect.logged = true
                Diagnostics.emit("impact-first-render", {id = effect.id, shot = effect.shot, screenX = x, screenY = y,
                    zoom = zoom, age = age, viewport = 0})
            end
            if age < 0 then
                local fraction = elapsed / flight
                local fx = effect.fromX + (effect.x - effect.fromX) * fraction
                local fy = effect.fromY + (effect.y - effect.fromY) * fraction
                local sx = (IsoUtils.XToScreen(fx, fy, effect.z, 0) - IsoCamera.getOffX(0)) / zoom
                local sy = (IsoUtils.YToScreen(fx, fy, effect.z, 0) - IsoCamera.getOffY(0) - (96 - 32 * fraction)) / zoom
                getTextManager():DrawStringCentre(UIFont.Large, sx, sy, getText("UI_OMHTT_Particle"), 0.55, 0.32, 0.13, 1)
            else
                for n = 0, 5 do
                    local angle = n * math.pi / 3
                    local radius = (5 + age * 28) / zoom
                    getTextManager():DrawStringCentre(UIFont.Large, x + math.cos(angle) * radius,
                        y + math.sin(angle) * radius, getText("UI_OMHTT_Particle"), 0.55, 0.32, 0.13, 1 - age)
                end
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
