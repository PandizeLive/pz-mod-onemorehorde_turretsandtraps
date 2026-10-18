if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
require("ISUI/ISScrollingListBox")
local T = require("OMHTT/Turret")
local L = require("OMHTT/TurretLoadOrder")
local Ammo = require("OMHTT/TurretAmmo")
local Access = require("OMHTT/TurretAccess")
local P = ISPanel:derive("OMHTTLoadOrderPanel")

---@return nil
function P:reflow()
    self:setWidth(self.owner.width - 12)
    self:setHeight(self.owner.height - self.owner.titleHeight - 24)
    self.list:setWidth(self.width - 24)
    self.list:setHeight(self.height - 114)
    self.upButton:setY(self.height - 40)
    self.downButton:setY(self.height - 40)
    self.backButton:setY(self.height - 40)
    self.backButton:setX(self.width - 164)
    self.applyButton:setY(self.height - 40)
    self.applyButton:setX(self.width - 88)
end

---@return nil
function P:close()
    self.closed = true
    self.owner.orderPanel = nil
    self.owner:removeChild(self)
    self.owner.nextRefresh = 0
    require("OMHTT/TurretManageLayout").page(self.owner)
end

---@return nil
function P:fill()
    local selected = self.list.selected
    self.list:clear()
    self.rows = {}
    for i = 1, #self.groups do
        local group = self.groups[i]
        local titles = {spear = "UI_OMHTT_PlatformSpear", potato = "UI_OMHTT_PlatformPotato",
            bomb = "UI_OMHTT_PlatformBomb", scrap = "UI_OMHTT_PlatformScrap"}
        local title = titles[group.platform] and getText(titles[group.platform])
        if not title then
            local script = getScriptManager():getItem(string.sub(group.platform, 7))
            title = script and script:getDisplayName() or string.sub(group.platform, 7)
        end
        local header = {header = true, group = group}
        self.rows[#self.rows + 1] = header
        self.list:addItem(title, header)
        for j = 1, #group.rows do
            local row = group.rows[j]
            row.group, row.position = group, j
            local script = getScriptManager():getItem(row.type)
            local name = script and script:getDisplayName() or row.type
            self.rows[#self.rows + 1] = row
            self.list:addItem(name, row)
        end
    end
    self.list.selected = math.max(1, math.min(selected or 1, #self.rows))
end

---@param button ISButton Move operation
---@return nil
function P:move(button)
    local index = self.list.selected
    local row = self.rows[index]
    if not row or row.header or self.loading then return end
    local group, target = row.group, row.position + button.step
    if target < 1 or target > #group.rows then return end
    group.rows[row.position], group.rows[target] = group.rows[target], group.rows[row.position]
    group.dirty = true
    self.list.selected = index + button.step
    self:fill()
end

---@return nil
function P:apply()
    if self.loading or #self.rows == 0 then return end
    local requests, state = {}, T.state(self.owner.object)
    for i = 1, #self.groups do
        local group = self.groups[i]
        if group.dirty then
            local types = {}
            for j = 1, #group.rows do
                types[j] = group.rows[j].type
            end
            local value = {platform = group.platform, previous = group.previous, order = table.concat(types, "|")}
            if not L.validGroup(value, state) then
                self.message = getText("UI_OMHTT_LoadOrderChanged")
                return
            end
            requests[#requests + 1] = value
        end
    end
    for i = 1, #requests do
        require("OMHTT/TurretUtilities").control(self.owner, "AmmoPlatformOrder", requests[i])
    end
    self:close()
end

---@param y number Row position
---@param item table List row
---@param alternate boolean Alternate row
---@return number nextY
function P.drawRow(self, y, item, alternate)
    local row, panel = item.item, self.parent
    if y + self:getYScroll() + self.itemheight < 0 or y + self:getYScroll() >= self.height then
        return y + self.itemheight
    end
    if row.header then
        self:drawRect(0, y, self.width, self.itemheight, 1, .12, .12, .12)
        self:drawText(item.text, 6, y + 8, .8, .9, 1, 1, UIFont.Small)
        return y + self.itemheight
    end
    if self.selected == item.index then
        self:drawRect(0, y, self.width, self.itemheight, .4, .25, .4, .3)
    end
    self:drawText(item.text, 6, y + 3, 1, 1, 1, 1, UIFont.Small)
    local detail = row.detail
    if not detail then
        detail = P.describe(row, panel.owner.stats)
        row.detail = detail
    end
    self:drawText(detail, 6, y + panel.lineHeight + 4, .8, .8, .8, 1, UIFont.Small)
    return y + self.itemheight
end

---@param row table Ammunition summary
---@param stats table Head snapshot
---@return string detail Counts and ammunition benefits
function P.describe(row, stats)
    local bonus = Ammo.scraps[row.type]
    local detail = getText("UI_OMHTT_LoadCounts", row.physical, row.virtual)
    if bonus ~= nil then
        detail = detail .. " | " .. getText("UI_OMHTT_LoadAmmoBonus", string.format("%+.1f", bonus * 100))
    elseif Ammo.bombs[row.type] then
        local bomb = Ammo.bombs[row.type]
        detail = detail .. " | " .. getText("UI_OMHTT_LoadBlast", bomb.damage or (tostring(bomb.minimum) .. "-" .. tostring(bomb.maximum)), bomb.radius)
    elseif Ammo.family(row.type) == "spear" then
        local script = getScriptManager():getItem(row.type)
        local baseline = getScriptManager():getItem("Base.SpearCrafted")
        if script and baseline then
            local reference = baseline:getMinDamage() + baseline:getMaxDamage()
            if reference > 0 then
                local multiplier = 1 + .25 * ((script:getMinDamage() + script:getMaxDamage()) / reference - 1)
                detail = detail .. " | " .. getText("UI_OMHTT_LoadAmmoBonus", string.format("%+.1f", (multiplier - 1) * 100))
            end
        end
    end
    return detail
end

---@return nil
function P:prerender()
    if getTimestampMs() >= (self.nextCheck or 0) then
        self.nextCheck = getTimestampMs() + 250
        self.contents = T.contents(self.owner.object:getContainer())
    end
    local contents = self.contents
    if not Access.near(self.owner.player, self.owner.object, self.owner.deviceId, true)
        or (self.loading and (not contents.void or contents.void:getID() ~= self.module:getID())) then
        self:close()
        return
    end
    ISPanel.prerender(self)
    self:drawText(getText("UI_OMHTT_LoadOrder"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    self:drawText(self.message or getText("UI_OMHTT_LoadOrderHint"), 12, 36, .8, .8, .8, 1, UIFont.Small)
    self.applyButton:setEnable(not self.loading and #self.rows > 0 and not self.owner.readOnly)
    local selected = self.rows[self.list.selected]
    self.upButton:setEnable(not self.loading and selected ~= nil and not selected.header and selected.position > 1)
    self.downButton:setEnable(not self.loading and selected ~= nil and not selected.header and selected.position < #selected.group.rows)
    if self.loading and getTimestampMs() >= self.due then
        self.due = getTimestampMs() + 750
        require("OMHTT/TurretVoidView").read(self.owner.player, self.owner.object, self.module, self.offset, function(page)
            if self.closed then return end
            if self.revision and self.revision ~= page.revision then
                self.offset, self.totals, self.revision = 0, {}, nil
                return
            end
            self.revision = page.revision
            for i = 1, #page.rows do self.totals[page.rows[i].type] = page.rows[i].count end
            self.offset = page.offset + #page.rows
            if self.offset >= page.total then
                self.loading, self.message = false, nil
                self.groups = L.groups(T.contents(self.owner.object:getContainer()), T.state(self.owner.object), self.totals)
                self:fill()
            end
        end)
    end
end

---@param owner ISPanel Manage window
---@return nil
function P.open(owner)
    if owner.orderPanel then
        owner.orderPanel:close()
    end
    local contents = T.contents(owner.object:getContainer())
    local width, height = owner.width - 12, owner.height - owner.titleHeight - 12
    local panel = P:new(6, owner.titleHeight + 4, width, height)
    panel.owner, panel.contents = owner, contents
    panel.groups = L.groups(contents, T.state(owner.object))
    panel.lineHeight = owner.lineHeight
    panel.backgroundColor = {r = .06, g = .06, b = .06, a = 1}
    panel.moveWithMouse = false
    panel:initialise()
    panel.list = ISScrollingListBox:new(12, 62, width - 24, height - 114)
    panel.list:initialise()
    panel.list.itemheight = owner.lineHeight * 2 + 10
    panel.list.doDrawItem = P.drawRow
    panel:addChild(panel.list)
    local up = ISButton:new(12, height - 40, 66, 28, getText("UI_OMHTT_OrderUp"), panel, P.move)
    local down = ISButton:new(84, height - 40, 66, 28, getText("UI_OMHTT_OrderDown"), panel, P.move)
    up.step, down.step = -1, 1
    panel.upButton, panel.downButton = up, down
    local cancel = ISButton:new(width - 164, height - 40, 70, 28, getText("UI_OMHTT_OrderBack"), panel, P.close)
    panel.backButton = cancel
    panel.applyButton = ISButton:new(width - 88, height - 40, 76, 28, getText("UI_OMHTT_OrderApply"), panel, P.apply)
    local buttons = {up, down, cancel, panel.applyButton}
    for i = 1, #buttons do buttons[i]:initialise(); panel:addChild(buttons[i]) end
    if isClient() and contents.void then
        panel.loading, panel.module, panel.offset, panel.due, panel.totals = true, contents.void, 0, 0, {}
        panel.message = getText("UI_OMHTT_OrderLoading")
    end
    panel:fill()
    owner.orderPanel = panel
    owner:addChild(panel)
    require("OMHTT/TurretManageLayout").page(owner)
end

return P
