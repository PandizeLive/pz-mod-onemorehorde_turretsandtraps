if isServer() then return end
require("ISUI/ISTextEntryBox")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
---@class OMHTTControlNameEntry: ISTextEntryBox
local Entry = ISTextEntryBox:derive("OMHTTControlNameEntry")

---@return nil
function Entry:commit()
    if not self.object then return end
    local value = string.gsub(self:getText(), "[%c<>]", "")
    value = string.gsub(string.gsub(value, "^%s+", ""), "%s+$", "")
    if #value > 48 then return end
    self:setText(value)
    if value == self.submitted or not A.authorized(self.player, self.object) then return end
    self.submitted = value
    U.command(self.player, self.object, "Name", value)
end

---@return nil
function Entry:onCommandEntered()
    self:commit()
    self:unfocus()
end

---@return nil
function Entry:onLostFocus()
    self:commit()
end

---@param object IsoObject? Selected device
---@return nil
function Entry:select(object)
    if self.object == object then return end
    self:commit()
    self.object = object
    self.placeholderReady = false
    local state = A.state(object)
    self.observed = state and state.name or ""
    self.submitted = self.observed
    self:setText(self.observed)
end

---@return nil
function Entry:refresh()
    local state = A.state(self.object)
    local name = state and state.name or ""
    if name ~= self.observed and not self:isFocused() then
        self.observed, self.submitted = name, name
        self:setText(name)
    end
    local head, number = state and state.headType, state and state.number
    if not self.placeholderReady or head ~= self.placeholderHead or number ~= self.placeholderNumber then
        self.placeholderReady, self.placeholderHead, self.placeholderNumber = true, head, number
        self:setPlaceholderText(self.object and U.name(self.object, true) or "")
    end
    local editable = state ~= nil and state.kind ~= "Controller" and A.authorized(self.player, self.object)
    if editable ~= self.nameEditable then
        self.nameEditable = editable
        self:setEditable(editable)
    end
end

---@param panel ISPanel Owning window
---@param object IsoObject? Device
---@param x number Left
---@param y number Top
---@param width number Width
---@param height number Height
---@return ISTextEntryBox entry
function Entry.create(panel, object, x, y, width, height)
    local entry = Entry:new("", x, y, width, height)
    entry.player = panel.player
    entry:initialise()
    panel:addChild(entry)
    entry:setMaxTextLength(48)
    entry:setPlaceholderTextRGBA(.55, .55, .55, 1)
    entry:select(object)
    entry:refresh()
    return entry
end

return Entry
