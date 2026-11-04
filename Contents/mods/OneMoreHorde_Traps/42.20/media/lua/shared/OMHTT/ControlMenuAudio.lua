local M = {}

---@param player IsoPlayer Authenticated actor of a completed equipment transfer
---@return nil
function M.confirm(player)
    if isClient() then return end
    if isServer() then
        sendServerCommand(player, "OMHTTMenuAudio", "Confirmed", {})
    else
        getSoundManager():playUISound("UIActivateButton")
    end
end

---@param module string Server namespace
---@param command string Server operation
---@param args table Server payload
---@return nil
function M.receive(module, command, args)
    if not isClient() or module ~= "OMHTTMenuAudio" or command ~= "Confirmed" then return end
    getSoundManager():playUISound("UIActivateButton")
end

if not isServer() then
    Events.OnServerCommand.Add(M.receive)
end
return M
