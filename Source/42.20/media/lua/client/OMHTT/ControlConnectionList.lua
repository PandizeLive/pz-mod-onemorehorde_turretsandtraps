if isServer() then return end
require("ISUI/ISScrollingListBox")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local List = ISScrollingListBox:derive("OMHTTControlConnectionList")

---@param row table Published source identity
---@return IsoObject? source Loaded exact input
local function resolve(row)
    local square = getCell():getGridSquare(row.x, row.y, row.z)
    local objects = square and square:getObjects()
    if not objects then return nil end
    for i = 0, objects:size() - 1 do
        local object = objects:get(i)
        local state = A.state(object)
        if state and state.id == row.id then return object end
    end
end

---@return nil
function List:refresh()
    local now = getTimestampMs()
    local panel = self.owner
    if self.pending then
        if self.pending.target ~= panel.selected or now > self.pending.untilTime then
            self.pending = nil
        elseif A.authorized(panel.player, self.pending.source) then
            U.command(panel.player, self.pending.source, "Link", false, self.pending.target)
            self.pending = nil
        end
    end
    if self.target == panel.selected and now < self.due then return end
    local previous = self.target
    self.target, self.due = panel.selected, now + 500
    local view = self.target and self.target:getModData().OMHTTControl
    local rows, keys = {}, {}
    for i = 1, #(view and view.inputs or {}) do
        local row = view.inputs[i]
        local object = resolve(row)
        local state = A.state(object)
        local writable = object and A.write(panel.player, state)
            and (A.near(panel.player, object) or require("OMHTT/ControlRemote").valid(panel.player, panel.object, object))
            and A.write(panel.player, A.state(panel.selected)) and A.range(object, panel.selected)
        local title = state and U.name(object) or row.name or getText("UI_OMHTT_Control" .. row.kind)
        rows[#rows + 1] = {title = title, object = object, active = state and state.active, writable = writable == true}
        keys[#keys + 1] = row.id .. ":" .. title .. ":" .. tostring(state and state.active) .. ":" .. tostring(writable)
    end
    local signature = table.concat(keys, "|")
    if self.signature == signature and previous == self.target then return end
    self.signature = signature
    self:clear()
    self:setScrollHeight(0)
    for i = 1, #rows do
        self:addItem(rows[i].title, rows[i], getText("UI_OMHTT_DisconnectHelp"))
    end
end

---@param y number Row top
---@param item table Native list entry
---@param alt boolean Alternating row
---@return number nextY
function List:doDrawItem(y, item, alt)
    local row = item.item
    self:drawRect(0, y, self.width, self.itemheight, .85, alt and .09 or .065, alt and .09 or .065, alt and .09 or .065)
    local right = self.width - 106
    local clipX, clipY, clipW, clipH = self:clampStencilRectToParent(8, y, right - 12, self.itemheight)
    self:drawText(item.text, 8, y + 6, .9, .9, .9, 1, UIFont.Small)
    self:clearStencilRect()
    self:repaintStencilRect(clipX, clipY, clipW, clipH)
    self:drawRect(right, y + 10, 5, 5, 1, row.active and .4 or .65, row.active and .85 or .25, .25)
    self:drawText(getText("UI_OMHTT_DisconnectInput"), right + 12, y + 6,
        row.writable and .9 or .45, row.writable and .9 or .45, row.writable and .9 or .45, 1, UIFont.Small)
    return y + self.itemheight
end

---@param x number Local click X
---@param y number Local click Y
---@return boolean handled
function List:onMouseDown(x, y)
    ISScrollingListBox.onMouseDown(self, x, y)
    local row = self.items[self.selected]
    if x >= self.width - 94 and x < self.width - 16 and row and row.item.writable then
        if A.authorized(self.owner.player, row.item.object) then
            U.command(self.owner.player, row.item.object, "Link", false, self.owner.selected)
        elseif U.remote(self.owner.player, self.owner.object, row.item.object) then
            self.pending = {source = row.item.object, target = self.owner.selected, untilTime = getTimestampMs() + 5000}
        end
        self.due = 0
    end
    return true
end

---@param panel ISPanel Controller
---@return ISScrollingListBox list
function List.create(panel)
    local list = List:new(10, 0, 200, 96)
    list:initialise()
    list.owner, list.due = panel, 0
    list:setFont(UIFont.Small, 8)
    list.itemheight = math.max(30, panel.lineHeight + 10)
    list.backgroundColor = {r = .025, g = .025, b = .025, a = 1}
    list.borderColor = {r = .25, g = .25, b = .25, a = 1}
    list.tooltip = getText("UI_OMHTT_DisconnectHelp")
    panel.detailBody:addChild(list)
    return list
end

return List
