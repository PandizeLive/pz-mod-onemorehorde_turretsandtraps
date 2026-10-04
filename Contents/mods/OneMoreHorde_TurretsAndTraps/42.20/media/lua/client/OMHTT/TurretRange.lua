if isClient() or isServer() then return end
require("ISUI/ISUIElement")
local T = require("OMHTT/Turret")
local R = require("OMHTT/TurretRenderer")
local M = require("OMHTT/TurretModules")
local Selection = require("OMHTT/BarrierSelection")
local D = require("OMHTT/Diagnostics")
local O = {selected = {}}
local Options = require("OMHTT/ClientOptions")
local Stats = require("OMHTT/TurretStats")
local canvas = nil

---@param index number Local viewport
---@param source string Selection source
---@param object IsoObject? Selected turret
---@param enabled boolean Selected
---@return nil
function O.focus(index, source, object, enabled)
    local entries = O.selected[index]
    if not entries then entries = {}; O.selected[index] = entries end
    if enabled then
        local state = T.state(object)
        if not state then return end
        entries[source] = object
        D.emit("turret-range-selected", {id = state.id, source = source, range = R.entries[object] and R.entries[object].profile and R.entries[object].profile.range})
    elseif entries[source] == object then
        entries[source] = nil
    end
end

---@param object IsoObject Native mouse pick, primary mouse player
---@return nil
function O.clicked(object)
    local entries = O.selected[0]
    if entries then entries.click = nil end
    if T.state(object) then O.focus(0, "click", object, true) end
end

---@param option table Menu option
---@param menu ISContextMenu Owning menu
---@param enabled boolean Hover state
---@param parts table Picked object
---@return nil
function O.highlight(option, menu, enabled, parts)
    Selection.highlight(option, menu, enabled, parts)
    O.focus(menu.player, "hover", parts[1], enabled)
end

---@param option table Menu option
---@param parts table Exact objects
---@return nil
function O.bind(option, parts)
    option.onHighlight, option.onHighlightParams = O.highlight, {parts}
end

---@param x number World X
---@param y number World Y
---@param z number Floor
---@param index number Viewport
---@return number screenX
---@return number screenY
function O.screen(x, y, z, index)
    local zoom = getCore():getZoom(index)
    return (IsoUtils.XToScreen(x, y, z, 0) - IsoCamera.getOffX(index)) / zoom + getPlayerScreenLeft(index),
        (IsoUtils.YToScreen(x, y, z, 0) - IsoCamera.getOffY(index)) / zoom + getPlayerScreenTop(index)
end

---@param x number Origin X
---@param y number Origin Y
---@param range number Tile radius
---@param heading number World heading in degrees
---@param cone number Full angle in degrees
---@param aim number? Independent head heading
---@return table lines Ground-plane segment endpoints
function O.lines(x, y, range, heading, cone, aim)
    local lines = {}
    local start = math.rad(heading - cone / 2)
    local px, py = x + math.cos(start) * range, y - math.sin(start) * range
    if cone < 360 then lines[#lines + 1] = {x, y, px, py} end
    for i = 1, 64 do
        local angle = start + math.rad(cone) * i / 64
        local tx, ty = x + math.cos(angle) * range, y - math.sin(angle) * range
        lines[#lines + 1] = {px, py, tx, ty}
        px, py = tx, ty
    end
    if cone < 360 then lines[#lines + 1] = {px, py, x, y} end
    local angle = math.rad(aim or heading)
    local dx, dy = math.cos(angle), -math.sin(angle)
    local tx, ty = x + dx * range, y + dy * range
    lines[#lines + 1] = {x, y, tx, ty}
    lines[#lines + 1] = {tx, ty, tx - dx * 0.4 + dy * 0.2, ty - dy * 0.4 - dx * 0.2}
    lines[#lines + 1] = {tx, ty, tx - dx * 0.4 - dy * 0.2, ty - dy * 0.4 + dx * 0.2}
    return lines
end

---@return nil
function O.render()
    if not T.enabled() or SandboxVars.OMHTurretsTraps.ShowTurretRange == false then return end
    for index, entries in pairs(O.selected) do
        local object = entries.hover or entries.manage or entries.click
        local player = getSpecificPlayer(index)
        local state = T.state(object)
        local square = object and object:getSquare()
        if not player or player:isDead() or not state or not square or object:getObjectIndex() < 0
            or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then
            O.selected[index] = nil
        elseif math.floor(player:getZ()) == square:getZ() and square:isCanSee(index)
            and (player:getX() - square:getX()) ^ 2 + (player:getY() - square:getY()) ^ 2 <= 30 ^ 2 then
            local render = R.entries[object]
            if render and render.head then
                if not canvas then
                    canvas = ISUIElement:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                    canvas:instantiate()
                end
                local heading = R.heading(object)
                local profile = render.profile
                local cone = M.option("ForwardCone", 90, 10, 360)
                if profile.omni then
                    cone = 360
                end
                local lines = O.lines(square:getX() + 0.5, square:getY() + 0.5,
                    profile.range, profile.heading, cone, heading)
                local left, top = getPlayerScreenLeft(index), getPlayerScreenTop(index)
                canvas:setStencilRect(left, top, getPlayerScreenWidth(index), getPlayerScreenHeight(index))
                for i = 1, #lines do
                    local line = lines[i]
                    local x, y = O.screen(line[1], line[2], square:getZ(), index)
                    local tx, ty = O.screen(line[3], line[4], square:getZ(), index)
                    canvas:drawLine2(x, y, tx, ty, 0.85, 0.25, 0.85, 1)
                end
                if Options.noiseVisible() then
                    local radius = Stats.hearingRadius(render.head, profile.stats)
                    if radius > 0 then
                        local ring = O.lines(square:getX() + 0.5, square:getY() + 0.5, radius, 0, 360)
                        for i = 1, 64 do
                            local line = ring[i]
                            local x, y = O.screen(line[1], line[2], square:getZ(), index)
                            local tx, ty = O.screen(line[3], line[4], square:getZ(), index)
                            canvas:drawLine2(x, y, tx, ty, 0.8, 1, 0.65, 0.15)
                        end
                    end
                end
                canvas:clearStencilRect()
            end
        end
    end
end

Events.OnObjectLeftMouseButtonDown.Add(O.clicked)
Events.OnPreUIDraw.Add(O.render)
return O
