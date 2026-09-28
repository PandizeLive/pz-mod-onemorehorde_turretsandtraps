if isClient() or isServer() then return end
require("ISUI/ISToolTipInv")
require("TimedActions/ISInventoryTransferAction")
require("TimedActions/ISTimedActionQueue")
require("OMHTT/TurretPickupAction")
local T = require("OMHTT/Turret")
local D = require("OMHTT/Diagnostics")
local Selection = require("OMHTT/BarrierSelection")
local tooltipRender = ISToolTipInv.render
local transferValid = ISInventoryTransferAction.isValid
local transferItem = ISInventoryTransferAction.transferItem

---@return nil
function ISToolTipInv:render()
    if self.item and self.item:getFullType() == T.BASE then
        T.configure(self.item:getInventory())
        local old = self.item:getTooltip()
        self.item:setTooltip(getTextManager():WrapText(UIFont.Small, T.description(self.item:getInventory(), self.item:getActualWeight()), 320))
        tooltipRender(self)
        self.item:setTooltip(old)
        return
    end
    tooltipRender(self)
end

---@return boolean valid
---@nodiscard
function ISInventoryTransferAction:isValid()
    if self.item and self.srcContainer and not T.canRemove(self.srcContainer, self.item) then return false end
    if T.isContainer(self.destContainer) then T.configure(self.destContainer) end
    return transferValid(self)
end

---@param item InventoryItem Transferred item
---@return nil
function ISInventoryTransferAction:transferItem(item)
    local source, destination = self.srcContainer, self.destContainer
    if T.isContainer(destination) then T.configure(destination) end
    transferItem(self, item)
    if T.isContainer(source) or T.isContainer(destination) then
        local W = require("OMHTT/TurretWorld")
        if source:getParent() and T.state(source:getParent()) then W.refresh(source:getParent()) end
        if destination:getParent() and T.state(destination:getParent()) then W.refresh(destination:getParent()) end
        D.emit("turret-transfer", {item = item:getFullType(), itemId = item:getID(),
            source = source:getType(), destination = destination:getType(), moved = destination:contains(item)})
    end
end

---@param object IsoThumpable Selected turret
---@param player IsoPlayer Operator
---@return nil
local function pickup(object, player)
    if luautils.walkAdj(player, object:getSquare()) then
        ISTimedActionQueue.add(OMHTTTurretPickupAction:new(player, object))
    end
end

---@param object IsoThumpable Selected turret
---@param player IsoPlayer Operator
---@return nil
local function fire(object, player)
    local result = require("OMHTT/TurretWorld").fire(player, object)
    player:setHaloNote(getText("UI_OMHTT_" .. result), 255, 255, 255, 120)
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
            local title = getText("UI_OMHTT_TurretBase")
            if contents.head then title = getText("UI_OMHTT_PotatoTurret") end
            local option = context:addOption(title, nil, nil)
            Selection.bindHighlight(option, {object})
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = string.gsub(T.description(object:getContainer(), 6), "\n", " <LINE> ")
            local menu = ISContextMenu:getNew(context)
            context:addSubMenu(option, menu)
            local shot = menu:addOption(getText("ContextMenu_OMHTT_TurretFire"), object, fire, player)
            shot.notAvailable = not W.near(player, object) or not contents.head or contents.ammo == 0 or W.power(object, contents) == nil
            local recovery = menu:addOption(getText("ContextMenu_OMHTT_PickupTurret"), object, pickup, player)
            recovery.toolTip = ISWorldObjectContextMenu.addToolTip()
            recovery.toolTip.description = getText("UI_OMHTT_ServiceDuration")
            local condition = menu:addOption(getText("ContextMenu_OMHTT_BarrierCondition", object:getHealth(), object:getMaxHealth()), nil, nil)
            condition.notAvailable = true
            Selection.bindHighlight(shot, {object})
            Selection.bindHighlight(recovery, {object})
            D.emit("turret-menu", {id = T.state(object).id, ammo = contents.ammo, modules = contents.modules,
                battery = contents.battery ~= nil, head = contents.head ~= nil})
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
        local dx, dy = direction[1], direction[2]
        local sx, sy = x + 0.5, y + 0.5
        local tx, ty = sx + dx * 0.45, sy + dy * 0.45
        renderIsoLine(sx, sy, z, tx, ty, z, 3, 1, 1, 1, 1)
        renderIsoLine(tx, ty, z, tx - dx * 0.15 + dy * 0.12, ty - dy * 0.15 - dx * 0.12, z, 3, 1, 1, 1, 1)
        renderIsoLine(tx, ty, z, tx - dx * 0.15 - dy * 0.12, ty - dy * 0.15 + dx * 0.12, z, 3, 1, 1, 1, 1)
    end
    ISBuildIsoEntity.omhttTurretPreview = true
end

Events.OnGameStart.Add(installPreview)
