if isServer() then return end
require("ISUI/ISUIElement")
local T = require("OMHTT/Turret")
local R = require("OMHTT/TurretRenderer")
local M = require("OMHTT/TurretModules")
local Selection = require("OMHTT/WorldHighlight")
local D = require("OMHTT/Diagnostics")
local O = {selected = {}, preview = {}}
local Options = require("OMHTT/ClientOptions")
local Stats = require("OMHTT/TurretStats")
local canvas = nil
local view = {}

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
function O.screen(x, y, z, index, projection)
    if projection then
        return (IsoUtils.XToScreen(x, y, z, 0) - projection.offX) / projection.zoom + projection.left,
            (IsoUtils.YToScreen(x, y, z, 0) - projection.offY) / projection.zoom + projection.top
    end
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

---@param entry table Per-turret presentation state
---@param key string Overlay layer
---@param x number World X
---@param y number World Y
---@param range number Layer radius
---@param heading number Locked coverage heading
---@param cone number Coverage angle
---@param aim number Current head heading
---@return table lines Reused geometry
function O.geometry(entry, key, x, y, range, heading, cone, aim)
    entry.overlays = entry.overlays or {}
    local cache = entry.overlays[key]
    if not cache or cache.x ~= x or cache.y ~= y or cache.range ~= range or cache.heading ~= heading or cache.cone ~= cone then
        cache = {x = x, y = y, range = range, heading = heading, cone = cone,
            lines = O.lines(x, y, range, heading, cone, aim)}
        entry.overlays[key] = cache
    end
    local angle = math.rad(aim)
    local dx, dy = math.cos(angle), -math.sin(angle)
    local tx, ty = x + dx * range, y + dy * range
    local lines = cache.lines
    local shaft, left, right = lines[#lines - 2], lines[#lines - 1], lines[#lines]
    shaft[1], shaft[2], shaft[3], shaft[4] = x, y, tx, ty
    left[1], left[2], left[3], left[4] = tx, ty, tx - dx * .4 + dy * .2, ty - dy * .4 - dx * .2
    right[1], right[2], right[3], right[4] = tx, ty, tx - dx * .4 - dy * .2, ty - dy * .4 + dx * .2
    return lines
end

---@param lines table World-space segments
---@param count number Visible segments
---@param z number Floor
---@param index number Viewport
---@param r number Red
---@param g number Green
---@param b number Blue
---@return nil
function O.draw(lines, count, z, index, r, g, b)
    for i = 1, count do
        local line = lines[i]
        local x, y = O.screen(line[1], line[2], z, index, view)
        local tx, ty = O.screen(line[3], line[4], z, index, view)
        canvas:drawLine2(x, y, tx, ty, 0.85, r, g, b)
    end
end

---@return nil
function O.render()
    if not T.enabled() then return end
    local started = D.enabled("turrets") and getTimestampMs()
    for index, entries in pairs(O.selected) do
        local object = entries.facing or entries.hover or entries.manage or entries.click
        local player = getSpecificPlayer(index)
        local state = T.state(object)
        local square = object and object:getSquare()
        if not player or player:isDead() or not state or not square or object:getObjectIndex() < 0
            or getCell():getGridSquare(square:getX(), square:getY(), square:getZ()) ~= square then
            O.selected[index] = nil
        elseif (entries.facing or require("OMHTT/ControlOptions").get("ShowRanges"))
            and math.floor(player:getZ()) == square:getZ() and square:isCanSee(index)
            and (player:getX() - square:getX()) ^ 2 + (player:getY() - square:getY()) ^ 2 <= 30 ^ 2 then
            local render = R.entries[object]
            if render and render.head then
                if not canvas then
                    canvas = ISUIElement:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                    canvas:instantiate()
                end
                local preview = O.preview[index]
                local profile = render.profile
                local sector = preview and preview.object == object and preview.heading or profile.heading
                local heading = preview and preview.object == object and preview.heading or R.heading(object)
                local cone = profile.cone
                if profile.omni then
                    cone = 360
                end
                local x, y, z = square:getX() + .5, square:getY() + .5, square:getZ()
                local coverage = render.hasDetector and render.automatic or profile
                local lines = O.geometry(render, "coverage", x, y, coverage.range, sector, cone, heading)
                local left, top = getPlayerScreenLeft(index), getPlayerScreenTop(index)
                view.left, view.top, view.zoom = left, top, getCore():getZoom(index)
                view.offX, view.offY = IsoCamera.getOffX(index), IsoCamera.getOffY(index)
                canvas:setStencilRect(left, top, getPlayerScreenWidth(index), getPlayerScreenHeight(index))
                local legend = render.rangeLegend
                local refreshLegend = render.legendAutomatic ~= coverage.range or render.legendManual ~= profile.range
                    or render.legendDetector ~= render.hasDetector
                if render.hasDetector then
                    O.draw(lines, #lines, z, index, .25, .85, 1)
                    if coverage.range < profile.range then
                        local manual = O.geometry(render, "manual", x, y, profile.range, sector, cone, heading)
                        O.draw(manual, #manual - 3, z, index, .65, .65, .65)
                        if refreshLegend then legend = getText("UI_OMHTT_RangeLegend", string.format("%.1f", coverage.range), string.format("%.1f", profile.range)) end
                    else
                        if refreshLegend then legend = getText("UI_OMHTT_RangeSharedLegend", string.format("%.1f", coverage.range)) end
                    end
                else
                    O.draw(lines, #lines, z, index, .65, .65, .65)
                    if refreshLegend then legend = getText("UI_OMHTT_RangeManualLegend", string.format("%.1f", profile.range)) end
                end
                if profile.rotary and not profile.omni then
                    local rear = O.geometry(render, "rear", x, y, coverage.range, sector + 180, cone, heading + 180)
                    O.draw(rear, #rear, z, index, .25, .85, 1)
                end
                render.rangeLegend, render.legendAutomatic, render.legendManual, render.legendDetector = legend, coverage.range, profile.range, render.hasDetector
                if entries.facing then
                    legend = getText("UI_OMHTT_SetFacingHint")
                end
                canvas:drawText(legend, left + 12, top + 12, 1, 1, 1, 1, UIFont.Small)
                if Options.noiseVisible() then
                    local radius = Stats.hearingRadius(render.head, profile.stats)
                    if radius > 0 then
                        local ring = O.geometry(render, "noise", x, y, radius, 0, 360, 0)
                        O.draw(ring, 64, z, index, 1, .65, .15)
                    end
                end
                canvas:clearStencilRect()
            end
        end
    end
    if started then D.measure("range-render", getTimestampMs() - started) end
end

Events.OnObjectLeftMouseButtonDown.Add(O.clicked)
Events.OnPreUIDraw.Add(O.render)
return O
