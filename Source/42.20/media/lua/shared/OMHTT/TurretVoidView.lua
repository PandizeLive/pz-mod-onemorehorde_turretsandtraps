local V = require("OMHTT/TurretVoid")
local T = require("OMHTT/Turret")
local Access = require("OMHTT/TurretAccess")
local P = require("OMHTT/DefenseCombatProtocol")
local View = {serial = 0, pending = {}}
local limits = setmetatable({}, {__mode = "k"})
local catalogs = setmetatable({}, {__mode = "k"})

---@param module string Command namespace
---@param command string Read-only request
---@param player IsoPlayer Native authenticated sender
---@param message table Coordinates, exact IDs and bounded offset
---@return nil
function View.request(module, command, player, message)
    if not isServer() or module ~= "OMHTT_VoidView" or command ~= "Read" or type(message) ~= "table" then return end
    if not P.number(message.x, -1000000, 1000000) or not P.number(message.y, -1000000, 1000000)
        or not P.number(message.z, -32, 31) or not P.number(message.item, 0, 9007199254740991)
        or not P.number(message.offset, 0, 1000000) or message.offset % 1 ~= 0
        or not P.number(message.serial, 1, 1000000000) or type(message.id) ~= "string" then return end
    local now = getTimestampMs()
    if limits[player] and now < limits[player] then return end
    limits[player] = now + 200
    if player:isDead() or math.abs(player:getX() - message.x) > 2 or math.abs(player:getY() - message.y) > 2
        or math.floor(player:getZ()) ~= message.z then return end
    local square = getCell():getGridSquare(message.x, message.y, message.z)
    if not square then return end
    local objects = square:getObjects()
    local turret
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        if Access.near(player, object, message.id) then
            turret = object
            break
        end
    end
    if not turret or not turret:getContainer() then return end
    local item = turret:getContainer():getItemById(message.item)
    if not item or item:getFullType() ~= V.TYPE then return end
    local data = V.data(item)
    if not data then return end
    local totals = V.totals(data)
    local catalog = catalogs[item]
    if not catalog or catalog.revision ~= data.revision then
        catalog = {revision = data.revision, keys = {}}
        for fullType in pairs(totals) do catalog.keys[#catalog.keys + 1] = fullType end
        table.sort(catalog.keys)
        catalogs[item] = catalog
    end
    local rows = {}
    for i = message.offset + 1, math.min(#catalog.keys, message.offset + 20) do
        rows[#rows + 1] = {type = catalog.keys[i], count = totals[catalog.keys[i]]}
    end
    sendServerCommand(player, "OMHTT_VoidView", "Page", {serial = message.serial, item = message.item,
        revision = data.revision, offset = message.offset, total = #catalog.keys, rows = rows})
end

---@param player IsoPlayer Local operator
---@param object IsoObject Adjacent turret
---@param item InventoryItem Exact installed module
---@param offset number First type index
---@param callback function Page receiver
---@return nil
function View.read(player, object, item, offset, callback)
    if not isClient() then return end
    View.serial = View.serial % 1000000000 + 1
    View.pending[player:getPlayerNum()] = {serial = View.serial, item = item:getID(), callback = callback}
    local square, state = object:getSquare(), T.state(object)
    if not square or not state then return end
    sendClientCommand(player, "OMHTT_VoidView", "Read", {serial = View.serial, item = item:getID(), id = state.id,
        x = square:getX(), y = square:getY(), z = square:getZ(), offset = offset})
end

---@param module string Server namespace
---@param command string Bounded page
---@param message table Read-only presentation
---@return nil
function View.receive(module, command, message)
    if not isClient() or module ~= "OMHTT_VoidView" or command ~= "Page" or type(message) ~= "table"
        or type(message.rows) ~= "table" or #message.rows > 20 then return end
    for index, pending in pairs(View.pending) do
        if message.serial == pending.serial and message.item == pending.item then
            View.pending[index] = nil
            pending.callback(message)
            return
        end
    end
end

Events.OnClientCommand.Add(View.request)
Events.OnServerCommand.Add(View.receive)
return View
