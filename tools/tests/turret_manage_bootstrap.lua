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
function ISPanel:addChild(child) self.children[#self.children + 1] = child; child.parent = self end
function ISPanel:removeChild(child)
    for i = #self.children, 1, -1 do if self.children[i] == child then table.remove(self.children, i) end end
    child.parent = nil
end
function ISPanel:setX(x) self.x = x end
function ISPanel:setWidth(width) self.width = width end
function ISPanel:setVisible(value) self.visible = value end
function ISPanel:prerender() end
function ISPanel:isMouseOver() return false end
function ISPanel:setStencilRect() end
function ISPanel:clearStencilRect() end
function ISPanel:drawRectBorder() end
function ISPanel:drawRect() end
function ISPanel:drawRectStatic() end
function ISPanel:onMouseDown() self.moving = true end
function ISPanel:drawProgressBar(x, y, width, height, value) check(x >= 0 and x + width <= self.width and value >= 0 and value <= 1, "Supply meter stays inside its slot") end
function ISPanel:setY(y) self.y = y end
function ISPanel:setHeight(height) self.height = height end
function ISPanel:setScrollChildren(value) self.scrollChildren = value end
function ISPanel:addScrollBars() end
function ISPanel:setScrollHeight(value) self.scrollHeight = value end
function ISPanel:getYScroll() return self.yScroll or 0 end
function ISPanel:setYScroll(value) self.yScroll = value end
function ISPanel:drawText(text) check(type(text) == "string", "Manage draws resolved status text") end
ISButton = {new = function(self, x, y, w, h, title, target, callback)
    return {setX = function(self, x) self.x = x end, setHeight = function(self, h) self.height = h end, initialise = function() end, setWidth = function(self, w) self.width = w end, setY = function(self, y) self.y = y end, setVisible = function(self, visible) self.visible = visible end, setEnable = function(self, enabled) self.enabled = enabled end,
        x=x, y=y, width=w, height=h, title=title, target = target, callback = callback, setTitle = function(self, title) self.title = title end}
end}
ISMouseDrag = {}
ISScrollingListBox = ISPanel:derive("TestScrollingList")
function ISScrollingListBox:clear() self.items, self.selected = {}, 0 end
function ISScrollingListBox:addItem(name, value)
    self.items = self.items or {}
    self.items[#self.items + 1] = {text = name, item = value, index = #self.items + 1}
end
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
    return {x=x, y=y, width=w, height=h, setWidth = function(self, w) self.width = w end, setY = function(self, y) self.y = y end, setVisible = function(self, v) self.visible = v end, currentValue = 1, initialise = function() end,
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
