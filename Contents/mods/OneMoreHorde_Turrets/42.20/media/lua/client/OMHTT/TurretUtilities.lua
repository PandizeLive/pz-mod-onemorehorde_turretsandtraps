if isServer() then return end
require("ISUI/ISContextMenu")
require("TimedActions/ISTimedActionQueue")
local T = require("OMHTT/Turret")
local View = require("OMHTT/TurretNetworkView")
local Void = require("OMHTT/TurretVoid")
local Action = require("OMHTT/TurretVoidAction")
local U = {}

---@param panel ISPanel Manage window
---@param command string Server control
---@param value any Validated control value
---@return nil
function U.control(panel, command, value)
    View.control(panel.player, panel.object, command, value)
end

---@param panel ISPanel Manage window
---@param items table Exact selected items
---@return nil
function U.store(panel, items)
    local contents = T.contents(panel.object:getContainer())
    if not contents.void then return end
    local groups = {}
    local controller = require("OMHTT/ControlAccess").stockpile(panel.player, panel.object, panel.controller)
    local stockpile = controller and controller:getContainer()
    for i = 1, #items do
        local item, source = items[i], items[i]:getContainer()
        if source and not item:isFavorite() and require("OMHTT/TurretAmmo").family(item:getFullType())
            and (source == panel.object:getContainer() or source:isInCharacterInventory(panel.player) or source == stockpile) then
            local ids = groups[source]
            if not ids then
                ids = {}
                groups[source] = ids
            end
            ids[#ids + 1] = item:getID()
        end
    end
    for source, ids in pairs(groups) do
        for first = 1, #ids, 20 do
            local batch = {}
            for i = first, math.min(first + 19, #ids) do batch[#batch + 1] = ids[i] end
            local origin = source == panel.object:getContainer() and "turret" or "inventory"
            if source == stockpile then origin = "controller" end
            ISTimedActionQueue.add(Action:new(panel.player, panel.object, panel.deviceId, contents.void,
                batch, origin, origin == "inventory" and source:getContainingItem() or nil, panel.controller))
        end
    end
end

---@param panel ISPanel Manage window
---@return nil
function U.inspect(panel)
    if panel.voidList then
        panel.voidList:onMouseDown()
    end
    local contents = T.contents(panel.object:getContainer())
    local data = Void.data(contents.void)
    if not data then return end
    local List = require("OMHTT/TurretBenefitList")
    local list = List:new(panel:getAbsoluteX() + 20, panel:getAbsoluteY() + 80, math.max(320, panel.width - 40), 240, panel.lineHeight)
    list:initialise()
    panel.voidList = list
    list.title = getText("UI_OMHTT_VoidStored")
    if isClient() then
        local View = require("OMHTT/TurretVoidView")
        local page, due, closed = 0, 0, false
        local function request()
            if closed or getTimestampMs() < due then return end
            due = getTimestampMs() + 500
            View.read(panel.player, panel.object, contents.void, page, function(message)
                if closed then return end
                list.rows, list.offset = {}, 0
                for i = 1, #message.rows do
                    local row = message.rows[i]
                    local script = getScriptManager():getItem(row.type)
                    list.rows[#list.rows + 1] = {title = script and script:getDisplayName() or row.type,
                        effect = tostring(row.count), details = row.type}
                end
                list.totalTypes = message.total
                list.title = getText("UI_OMHTT_VoidPage", page + 1, math.min(page + 20, message.total), message.total)
            end)
        end
        local wheel = list.onMouseWheel
        list.onMouseWheel = function(self, delta)
            local bottom = math.max(0, #self.rows - self.visibleRows)
            if delta > 0 and self.offset >= bottom and page + 20 < (self.totalTypes or 0) and getTimestampMs() >= due then
                page = page + 20
                request()
            elseif delta < 0 and self.offset == 0 and page > 0 and getTimestampMs() >= due then
                page = math.max(0, page - 20)
                request()
            else
                wheel(self, delta)
            end
            return true
        end
        list.onMouseDown = function(self)
            closed = true
            panel.voidList = nil
            self:hideTooltip()
            self:removeFromUIManager()
            return true
        end
        list.onRightMouseUp = list.onMouseDown
        list:addToUIManager()
        request()
        return
    end
    local totals = {}
    for i = 1, #data.groups do
        local group = data.groups[i]
        totals[group.type] = (totals[group.type] or 0) + group.count
    end
    local keys = {}
    for key in pairs(totals) do keys[#keys + 1] = key end
    table.sort(keys)
    for i = 1, #keys do
        local script = getScriptManager():getItem(keys[i])
        list.rows[#list.rows + 1] = {title = script and script:getDisplayName() or keys[i], effect = tostring(totals[keys[i]]), details = keys[i]}
    end
    list.onMouseDown = function(self)
        panel.voidList = nil
        self:hideTooltip()
        self:removeFromUIManager()
        return true
    end
    list.onRightMouseUp = list.onMouseDown
    list:addToUIManager()
end

---@param panel ISPanel Manage window
---@return nil
function U.menu(panel, kind)
    if kind == "ammo" then
        require("OMHTT/TurretLoadOrderPanel").open(panel)
        return
    end
    local contents, state = T.contents(panel.object:getContainer()), T.state(panel.object)
    local menu = ISContextMenu.get(panel.player:getPlayerNum(), getMouseX(), getMouseY())
    if kind == "lure" and contents.active.Lure then
        menu:addOption(getText("UI_OMHTT_LurePulse"), panel, U.control, "LurePulse", true)
        menu:addOption(getText(state.lureRepeat and "UI_OMHTT_LureStop" or "UI_OMHTT_LureRepeat"), panel, U.control, "LureRepeat", not state.lureRepeat)
        local option = menu:addOption(getText("UI_OMHTT_LureRange", state.lureRange or 10), nil, nil)
        local ranges = ISContextMenu:getNew(menu)
        menu:addSubMenu(option, ranges)
        for i = 5, 20 do ranges:addOption(tostring(i), panel, U.control, "LureRange", i) end
    end
    if kind == "void" and contents.void then
        menu:addOption(getText("UI_OMHTT_VoidStored"), panel, U.inspect)
        menu:addOption(getText("UI_OMHTT_StoreReserveVoid"), panel, U.store, contents.rounds)
    end
end

return U
