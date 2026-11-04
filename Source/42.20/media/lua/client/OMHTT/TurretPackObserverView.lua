if isServer() then return end
require("ISUI/ISUIElement")
local P = require("OMHTT/DefenseCombatProtocol")
local V = {entries = {}, serials = {}}
local canvas, texture

---@param module string Namespace
---@param command string Presentation command
---@param facts table Server-validated opening state; no reward information
---@return nil
function V.receive(module, command, facts)
    if not isClient() or module ~= "OMHTT_PackView" or command ~= "Opening" or type(facts) ~= "table" then return end
    if not P.identity(facts.player) or not P.number(facts.serial, 1, 1000000000000)
        or type(facts.active) ~= "boolean" then return end
    if facts.player < 0 or facts.player > 32767 then return end
    if (V.serials[facts.player] or 0) >= facts.serial then return end
    V.serials[facts.player] = facts.serial
    V.entries[facts.player] = {serial = facts.serial, active = facts.active, expires = getTimestampMs() + 2000}
end

---@param actor IsoPlayer Remote opener
---@param viewer IsoPlayer Local viewer
---@param index number Local viewport
---@return boolean visible
function V.visible(actor, viewer, index)
    if actor == viewer or actor:isDead() or actor:isInvisible() or viewer:isDead()
        or math.floor(actor:getZ()) ~= math.floor(viewer:getZ()) then return false end
    local dx, dy = actor:getX() - viewer:getX(), actor:getY() - viewer:getY()
    local square = actor:getSquare()
    return dx * dx + dy * dy <= 64 and square ~= nil and square:isCanSee(index)
end

---@return nil
function V.render()
    if not isClient() then return end
    local now = getTimestampMs()
    for id, entry in pairs(V.entries) do
        if now >= entry.expires then
            V.entries[id] = nil
        elseif entry.active then
            local actor = getPlayerByOnlineID(id)
            for i = 0, getNumActivePlayers() - 1 do
                local viewer = getSpecificPlayer(i)
                if actor and viewer and V.visible(actor, viewer, i) then
                    if not canvas then
                        canvas = ISUIElement:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                        canvas:instantiate()
                        texture = instanceItem("Base.OMHTTModulePack"):getTex()
                    end
                    local zoom = getCore():getZoom(i)
                    local x = (IsoUtils.XToScreen(actor:getX(), actor:getY(), actor:getZ(), 0) - IsoCamera.getOffX(i)) / zoom + getPlayerScreenLeft(i)
                    local y = (IsoUtils.YToScreen(actor:getX(), actor:getY(), actor:getZ(), 0) - IsoCamera.getOffY(i) - 100) / zoom + getPlayerScreenTop(i)
                    canvas:setStencilRect(getPlayerScreenLeft(i), getPlayerScreenTop(i), getPlayerScreenWidth(i), getPlayerScreenHeight(i))
                    canvas:drawTextureScaled(texture, x - 12, y - 24, 24, 24, 1, 1, 1, 1)
                    canvas:clearStencilRect()
                end
            end
        end
    end
end

Events.OnGameStart.Add(function() V.entries, V.serials = {}, {} end)
Events.OnServerCommand.Add(V.receive)
Events.OnPreUIDraw.Add(V.render)
return V
