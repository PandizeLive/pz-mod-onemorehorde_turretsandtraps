if isClient() or isServer() then return end
require("ISUI/ISToolTipInv")
require("TimedActions/ISInventoryTransferAction")
require("TimedActions/ISTimedActionQueue")
require("OMHTT/TurretPickupAction")
local T = require("OMHTT/Turret")
local M = require("OMHTT/TurretModules")
local D = require("OMHTT/Diagnostics")
local Range = require("OMHTT/TurretRange")
local manage = require("OMHTT/TurretManage")
require("OMHTT/TurretTooltip")

---@param object IsoThumpable Selected turret
---@param player IsoPlayer Operator
---@return nil
local function pickup(object, player)
    if luautils.walkAdjObject(player, object, false) then
        ISTimedActionQueue.add(OMHTTTurretPickupAction:new(player, object))
    end
end

---@param object IsoThumpable Selected turret
---@param player IsoPlayer Operator
---@return nil
local function repair(object, player)
    if luautils.walkAdjObject(player, object, false) then
        ISTimedActionQueue.add(OMHTTTurretPickupAction:new(player, object, "Repair"))
    end
end

---@param playerIndex number Local player
---@param context ISContextMenu Menu
---@param worldobjects table Native picked objects
---@param test boolean Probe mode
---@return nil
local function fillMenu(playerIndex, context, worldobjects, test)
    if test or not T.enabled() then return end
    local player = getSpecificPlayer(playerIndex)
    if not player or player:isDead() then return end
    local found, seen = {}, {}
    for i = 1, #worldobjects do
        local object = worldobjects[i]
        if T.state(object) and not seen[object] then
            seen[object] = true
            found[#found + 1] = object
        end
    end
    local x = math.floor(IsoUtils.XToIso(getMouseXScaled(), getMouseYScaled(), player:getZ()))
    local y = math.floor(IsoUtils.YToIso(getMouseXScaled(), getMouseYScaled(), player:getZ()))
    local square = getCell():getGridSquare(x, y, player:getZ())
    if square then
        local objects = square:getObjects()
        for i = 0, objects:size() - 1 do
            local object = objects:get(i)
            if T.state(object) and not seen[object] then found[#found + 1] = object end
        end
    end
    local W = require("OMHTT/TurretWorld")
    for i = 1, #found do
        local object = found[i]
        if W.valid(object) then
            W.refresh(object)
            local contents = T.contents(object:getContainer())
            local title = getText("UI_OMHTT_Turret")
            local option = context:addOption(title, nil, nil)
            Range.bind(option, {object})
            local menu = ISContextMenu:getNew(context)
            context:addSubMenu(option, menu)
            local manageOption = menu:addOption(getText("UI_OMHTT_Manage"), object, manage, player)
            Range.bind(manageOption, {object})
            local recovery = menu:addOption(getText("ContextMenu_OMHTT_PickupTurret"), object, pickup, player)
            recovery.toolTip = ISWorldObjectContextMenu.addToolTip()
            recovery.toolTip.description = getText("UI_OMHTT_PickupDuration")
            local repairOption = menu:addOption(getText("ContextMenu_OMHTT_RepairTurret"), object, repair, player)
            repairOption.notAvailable = object:getHealth() >= object:getMaxHealth() or not require("OMHTT/ControlRepair").ready(player, "Turret")
            require("OMHTT/ControlRepairTooltip").bind(repairOption, "Turret", player)
            Range.bind(repairOption, {object})
            local condition = menu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", object:getHealth(), object:getMaxHealth()), nil, nil)
            condition.notAvailable = true
            Range.bind(recovery, {object})
            D.emit("turret-menu", {id = T.state(object).id, ammo = contents.ammo, modules = contents.modules,
                battery = contents.battery ~= nil, head = contents.head ~= nil}, nil, nil, "turrets")
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)

---@return nil
local function installPreview()
    require("BuildingObjects/ISBuildingObject")
    require("BuildingObjects/ISBuildIsoEntity")
    if ISBuildIsoEntity.omhttTurretPreview then return end
    local original = ISBuildIsoEntity.render
    ---@param x number Cursor X
    ---@param y number Cursor Y
    ---@param z number Floor
    ---@param square IsoGridSquare Cursor square
    ---@return nil
    function ISBuildIsoEntity:render(x, y, z, square)
        original(self, x, y, z, square)
        if not self.objectInfo or self.objectInfo:getName() ~= "OMHTTDeployTurret" then return end
        local face = self:getFace()
        if not face then return end
        local directions = {e = {1, 0}, n = {0, -1}, w = {-1, 0}, s = {0, 1}}
        local direction = directions[face:getFaceName()]
        if not direction then return end
        local heading = (math.deg(math.atan2(-direction[2], direction[1])) + 360) % 360
        local contents = {active = {}}
        if self.buildPanelLogic then
            local data = self.buildPanelLogic:getRecipeData()
            local recipe = data:getRecipe()
            if recipe then
                local inputs = recipe:getInputs()
                for i = 0, inputs:size() - 1 do
                    local item = data:getFirstManualInputFor(inputs:get(i))
                    if item and item:getFullType() == T.BASE then
                        contents = T.contents(item:getInventory())
                    end
                end
            end
        end
        local profile = M.profile({baseFacing = heading / 22.5}, contents)
        local lines = Range.lines(x + 0.5, y + 0.5, profile.range, heading, profile.cone)
        for i = 1, #lines do
            local line = lines[i]
            renderIsoLine(line[1], line[2], z, line[3], line[4], z, 1, 0.25, 0.85, 1, 0.85)
        end
    end
    ISBuildIsoEntity.omhttTurretPreview = true
end

Events.OnGameStart.Add(installPreview)
