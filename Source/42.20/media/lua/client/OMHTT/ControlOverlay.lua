if isServer() then return end
require("ISUI/ISUIElement")
local A = require("OMHTT/ControlAccess")
local O = {panels = setmetatable({}, {__mode = "k"})}
local canvas

---@param x number World X
---@param y number World Y
---@param z number Floor
---@param player number Viewport
---@return number x
---@return number y
local function screen(x, y, z, player)
    local zoom = getCore():getZoom(player)
    return (IsoUtils.XToScreen(x, y, z, 0) - IsoCamera.getOffX(player)) / zoom + getPlayerScreenLeft(player),
        (IsoUtils.YToScreen(x, y, z, 0) - IsoCamera.getOffY(player)) / zoom + getPlayerScreenTop(player)
end

---@return nil
function O.render()
    for panel in pairs(O.panels) do
        local source = panel.linkSource or panel.selected
        local state = A.state(source)
        if state and source:getObjectIndex() >= 0 and A.near(panel.player, panel.object) then
            if not canvas then
                canvas = ISUIElement:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                canvas:instantiate()
            end
            local index = panel.player:getPlayerNum()
            local x, y = screen(source:getX() + .5, source:getY() + .5, source:getZ(), index)
            for i = 1, #panel.devices.items do
                local target = panel.devices.items[i].item
                local other = A.state(target)
                if other then
                    for j = 1, #state.links do
                        if state.links[j] == other.id then
                            local tx, ty = screen(target:getX() + .5, target:getY() + .5, target:getZ(), index)
                            local active = state.active == true
                            canvas:drawLine2(x, y, tx, ty, .8, active and .4 or .55, active and 1 or .65, .9)
                        end
                    end
                end
            end
        end
    end
end

Events.OnPreUIDraw.Add(O.render)
return O
