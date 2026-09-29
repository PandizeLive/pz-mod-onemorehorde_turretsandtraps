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
function ISPanel:drawText(text) check(type(text) == "string", "Manage draws resolved status text") end
ISButton = {new = function(self, x, y, w, h, title, target, callback)
    return {initialise = function() end, setEnable = function(self, enabled) self.enabled = enabled end,
        target = target, callback = callback, setTitle = function(self, title) self.title = title end}
end}
ISMouseDrag = {}
ISInventoryItem = {renderItemIcon = function() end}
ISInventoryPane = {}
ISInventoryTransferAction = {
    isValid = function(self) return self.srcContainer:contains(self.item) end,
    transferItem = function(self, item)
        self.srcContainer:Remove(item)
        self.destContainer:AddItem(item)
    end,
    new = function(self, player, item, source, destination)
        return setmetatable({character = player, item = item, srcContainer = source, destContainer = destination}, {__index = self})
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
