luautils = {}
LuaEventManager.AddEvent("OnPreUIDraw")
LuaEventManager.AddEvent("OnObjectLeftMouseButtonDown")
LuaEventManager.AddEvent("RenderOpaqueObjectsInWorld")
local oldPanel = ISPanel
ISPanel = ISBaseObject:derive("TestPanel")
function ISPanel:new(x, y, width, height)
    return setmetatable({x = x, y = y, width = width, height = height, children = {}}, {__index = self})
end
function ISPanel:initialise() end
function ISPanel:addToUIManager() testTurretPanel = self end
function ISPanel:removeFromUIManager() self.removed = true end
function ISPanel:addChild(child) self.children[#self.children + 1] = child end
function ISPanel:prerender() end
function ISPanel:isMouseOver() return false end
function ISPanel:setStencilRect() end
function ISPanel:clearStencilRect() end
function ISPanel:drawRectBorder() end
function ISPanel:drawRect() end
function ISPanel:setY(y) self.y = y end
function ISPanel:setHeight(height) self.height = height end
function ISPanel:drawText(text) check(type(text) == "string", "Manage draws resolved status text") end
ISButton = {new = function(self, x, y, w, h, title, target, callback)
    return {initialise = function() end, setWidth = function(self, w) self.width = w end, setY = function(self, y) self.y = y end, setVisible = function(self, visible) self.visible = visible end, setEnable = function(self, enabled) self.enabled = enabled end,
        x=x, y=y, width=w, height=h, target = target, callback = callback, setTitle = function(self, title) self.title = title end}
end}
ISMouseDrag = {}
ISInventoryItem = {renderItemIcon = function() end}
ISInventoryPane = {}
ISInventoryTransferAction = {
    canMergeAction = function(self, other) return self ~= other and other.srcContainer == self.srcContainer and other.destContainer == self.destContainer end,
    isValid = function(self) return self.srcContainer:contains(self.item) end,
    transferItem = function(self, item)
        self.srcContainer:Remove(item)
        self.destContainer:AddItem(item)
    end,
    new = function(self, player, item, source, destination)
        return setmetatable({character = player, item = item, queueList = {{items = {item}, type = item:getFullType(), time = 1}}, srcContainer = source, destContainer = destination}, {__index = self})
    end
}
testTurretOldPanel = oldPanel

testTurretRequire = require
testTurretEarlyRequires = 0
function require(name)
    if name == "OMHTT/TurretWorld" then
        testTurretEarlyRequires = testTurretEarlyRequires + 1
        return nil
    end
    return testTurretRequire(name)
end

PZAPI = {ModOptions = {getOptions = function() return nil end, create = function()
    local option = {getValue = function() return true end}
    return {addTickBox = function() end, getOption = function() return option end}
end}}
ISSliderPanel = {new = function(self, x, y, w, h, target, callback)
    return {setWidth = function(self, w) self.width = w end, setY = function(self, y) self.y = y end, setVisible = function(self, v) self.visible = v end, currentValue = 1, initialise = function() end,
        setValues = function(self, low, high) self.minValue, self.maxValue = low, high end,
        setCurrentValue = function(self, value) self.currentValue = value end,
        getCurrentValue = function(self) return self.currentValue end}
end}
ISComboBox = {new = function(self, x, y, w, h, target, callback)
    return {selected = 1, options = {}, initialise = function() end,
        clear = function(self) self.options = {} end,
        addOption = function(self, value) self.options[#self.options + 1] = value end,
        target = target, callback = callback}
end}
