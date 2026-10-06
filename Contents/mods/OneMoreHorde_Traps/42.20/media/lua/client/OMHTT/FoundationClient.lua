if isServer() then return end

local Foundation = require("OMHTT/Foundation")
local Diagnostics = require("OMHTT/Diagnostics")
require("ISUI/ISContextMenu")
require("ISUI/ISModalRichText")

local snapshots = {}
local lastChanges = {}
local serial = 0
local dialog = nil
local menuSerial = 0

---@param player IsoPlayer Local player
---@param command string Requested action
---@param args table Request payload
---@return nil
local function dispatch(player, command, args)
    Diagnostics.emit("client-request", {request = args.request, command = command,
        tile = Foundation.key(args.x, args.y, args.z), id = args.id, epoch = args.epoch, revision = args.revision,
        playerX = player:getX(), playerY = player:getY(), playerZ = player:getZ()})
    if isClient() then
        sendClientCommand(player, Foundation.MODULE, command, args)
    elseif isServer() then
        error("[OMHTT] Client dispatch attempted on server")
    else
        local Server = require("OMHTT/FoundationServer")
        Server.onCommand(Foundation.MODULE, command, player, args)
    end
end

---@param target table Captured tile and local player
---@param command string Requested action
---@return nil
local function request(target, command)
    local player = getSpecificPlayer(target.playerNum)
    if not Foundation.canUse(player) then return end
    serial = serial + 1
    local args = {
        version = Foundation.VERSION, request = serial,
        x = target.x, y = target.y, z = target.z,
        epoch = 0, id = "", revision = 0,
    }
    local snapshot = snapshots[target.playerNum]
    if snapshot and snapshot.x == target.x and snapshot.y == target.y and snapshot.z == target.z then
        args.epoch = snapshot.epoch
        args.id = snapshot.id
        args.revision = snapshot.revision
    end
    if command == "Condition" then
        args.condition = 37
    end
    if command ~= "Inspect" then
        lastChanges[target.playerNum] = {command = command, args = args}
    end
    dispatch(player, command, args)
end

---@param target table Captured player
---@return nil
local function replay(target)
    local last = lastChanges[target.playerNum]
    if not last then return end
    local args = {}
    for key, value in pairs(last.args) do
        args[key] = value
    end
    serial = serial + 1
    args.request = serial
    dispatch(getSpecificPlayer(target.playerNum), last.command, args)
end

---@param target table Local player reference
---@return nil
local function dumpNearby(target)
    local player = getSpecificPlayer(target.playerNum)
    if not Foundation.canUse(player) then return end
    local examined = 0
    local found = 0
    for dx = -2, 2 do
        for dy = -2, 2 do
            local square = getCell():getGridSquare(math.floor(player:getX()) + dx,
                math.floor(player:getY()) + dy, math.floor(player:getZ()))
            if square then
                local objects = square:getObjects()
                for i = 0, objects:size() - 1 do
                    if examined >= 128 then break end
                    examined = examined + 1
                    local object = objects:get(i)
                    local name = object:getName()
                    if type(name) == "string" and string.sub(name, 1, #Foundation.PREFIX) == Foundation.PREFIX then
                        found = found + 1
                        Diagnostics.object(object, "nearby-dump", target.playerNum)
                    end
                end
            end
        end
    end
    Diagnostics.emit("nearby-summary", {playerX = player:getX(), playerY = player:getY(), playerZ = player:getZ(),
        examined = examined, found = found, capped = examined >= 128})
    player:setHaloNote(getText("UI_OMHTT_Dumped"), 255, 255, 255, 180)
end

---@param playerNum number Local player index
---@param context ISContextMenu Context menu
---@param worldobjects table Clicked objects
---@param test boolean Menu probe
---@return boolean? available
local function fillMenu(playerNum, context, worldobjects, test)
    local player = getSpecificPlayer(playerNum)
    if not Foundation.canUse(player) or #worldobjects == 0 then return end
    local square = worldobjects[1]:getSquare()
    if not square then return end
    if test then return true end
    menuSerial = menuSerial + 1
    local target = {playerNum = playerNum, x = square:getX(), y = square:getY(), z = square:getZ()}
    Diagnostics.emit("menu-pick", {menu = menuSerial, pickedObjects = #worldobjects,
        selected = Foundation.key(target.x, target.y, target.z), selection = "first-worldobject",
        playerX = player:getX(), playerY = player:getY(), playerZ = player:getZ(),
        mouseX = getMouseXScaled(), mouseY = getMouseYScaled(), zoom = getCore():getZoom(playerNum)})
    for i = 1, math.min(8, #worldobjects) do
        Diagnostics.object(worldobjects[i], "menu-" .. menuSerial .. "-pick-" .. i, playerNum)
    end
    local root = context:addOption(getText("ContextMenu_OMHTT_Foundation", Foundation.VERSION), nil, nil)
    local menu = ISContextMenu:getNew(context)
    context:addSubMenu(root, menu)
    local tileOption = menu:addOption(getText("ContextMenu_OMHTT_SelectedTile", target.x, target.y, target.z), nil, nil)
    tileOption.notAvailable = true
    menu:addOption(getText("ContextMenu_OMHTT_Dump"), target, dumpNearby)
    menu:addOption(getText("ContextMenu_OMHTT_Inspect"), target, request, "Inspect")
    menu:addOption(getText("ContextMenu_OMHTT_Place"), target, request, "Place")
    menu:addOption(getText("ContextMenu_OMHTT_PlaceBarrier"), target, request, "PlaceBarrier")
    if Foundation.turretsAvailable then
        menu:addOption(getText("ContextMenu_OMHTT_PlacePotato"), target, request, "PlacePotato")
    end
    local snapshot = snapshots[playerNum]
    if snapshot and snapshot.x == target.x and snapshot.y == target.y and snapshot.z == target.z and snapshot.id ~= "" then
        menu:addOption(getText("ContextMenu_OMHTT_Condition"), target, request, "Condition")
        menu:addOption(getText("ContextMenu_OMHTT_Remove"), target, request, "Remove")
        if snapshot.kind == "potato" then
            menu:addOption(getText("ContextMenu_OMHTT_Fire"), target, request, "Fire")
            menu:addOption(getText("ContextMenu_OMHTT_Refill"), target, request, "Refill")
            menu:addOption(getText("ContextMenu_OMHTT_Aim"), target, request, "Aim")
        elseif snapshot.kind == "barrier" then
            menu:addOption(getText("ContextMenu_OMHTT_RotateBarrier"), target, request, "RotateBarrier")
        end
    end
    if lastChanges[playerNum] then
        menu:addOption(getText("ContextMenu_OMHTT_Replay"), target, replay)
    end
end

---@param module string Server namespace
---@param command string Server command
---@param result table Authoritative tile snapshot
---@return nil
local function onResult(module, command, result)
    if module ~= Foundation.MODULE or command ~= "Result" then return end
    local previous = snapshots[result.playerNum]
    if previous and previous.request > result.request then return end
    if result.stateIncluded then
        snapshots[result.playerNum] = result
    end
    local localCount = 0
    local localCondition = -1
    local localRevision = 0
    local suppliesAgree = true
    local square = getCell():getGridSquare(result.x, result.y, result.z)
    if square and result.id ~= "" then
        local object, count = Foundation.find(square, result.id)
        localCount = count
        if count == 1 then
            object:invalidateRenderChunkLevel(FBORenderChunk.DIRTY_REDRAW)
            Diagnostics.object(object, "client-result-" .. result.request, result.playerNum)
            local marker = object:getModData().OMHTT
            localCondition = marker.condition
            localRevision = marker.revision
            suppliesAgree = marker.ammo == result.ammo and marker.shots == result.shots and marker.facing == result.facing
        end
    elseif square then
        localCount = Foundation.countPrototypes(square)
    end
    local agreement = "Waiting"
    if not result.stateIncluded then
        agreement = "NotCompared"
    elseif square and suppliesAgree and localCount == result.count and localCondition == result.condition and localRevision == result.revision then
        agreement = "Agrees"
    end
    local text = getText("UI_OMHTT_Header", Foundation.VERSION, result.version, result.game)
        .. " <LINE> " .. getText("UI_OMHTT_" .. result.status)
        .. " <LINE> " .. getText("UI_OMHTT_Tile", result.x, result.y, result.z)
        .. " <LINE> " .. getText("UI_OMHTT_State", result.id, result.condition, result.revision, result.count)
        .. " <LINE> " .. getText("UI_OMHTT_Local", localCondition, localRevision, localCount)
        .. " <LINE> " .. getText("UI_OMHTT_Supplies", result.kind, result.ammo, result.shots, result.facing)
        .. " <LINE> " .. getText("UI_OMHTT_Budget", result.peakVisits)
        .. " <LINE> " .. getText("UI_OMHTT_" .. agreement)
    print("[OMHTT] client-result status=" .. result.status .. " id=" .. result.id
        .. " serverCondition=" .. result.condition .. " localCondition=" .. localCondition
        .. " serverCount=" .. result.count .. " localCount=" .. localCount .. " agreement=" .. agreement)
    Diagnostics.emit("client-result", {request = result.request, command = result.command, status = result.status,
        tile = Foundation.key(result.x, result.y, result.z), id = result.id, kind = result.kind,
        authorityRevision = result.revision, localRevision = localRevision, ammo = result.ammo, shots = result.shots,
        facing = result.facing, nextShot = result.nextShot, agreement = agreement, stateIncluded = result.stateIncluded})
    if result.command ~= "Inspect" then
        local player = getSpecificPlayer(result.playerNum)
        if player then
            player:setHaloNote(getText("UI_OMHTT_" .. result.status), 255, 255, 255, 180)
        end
        return
    end
    if dialog then
        dialog:removeFromUIManager()
    end
    dialog = ISModalRichText:new(getCore():getScreenWidth() / 2 - 300,
        getCore():getScreenHeight() / 2 - 160, 600, 320, text, false)
    dialog:initialise()
    dialog:addToUIManager()
    Diagnostics.emit("report-open", {request = result.request, status = result.status, width = 600, height = 320})
end

---@return nil
local function onStart()
    snapshots = {}
    lastChanges = {}
    serial = 0
    menuSerial = 0
    print("[OMHTT] client-ready version=" .. Foundation.VERSION .. " game=" .. getCore():getVersionNumber())
    Diagnostics.auditTranslations()
    Diagnostics.emit("client-ready", {game = getCore():getVersionNumber(), screenWidth = getCore():getScreenWidth(),
        screenHeight = getCore():getScreenHeight(), apiSprite = tostring(IsoSprite), apiDirections = tostring(IsoDirections)})
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)
Events.OnServerCommand.Add(onResult)
Events.OnGameStart.Add(onStart)
