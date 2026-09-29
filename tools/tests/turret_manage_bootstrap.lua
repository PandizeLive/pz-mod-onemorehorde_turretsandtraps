luautils = {}
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
function ISPanel:drawText(text) check(type(text) == "string", "Manage draws resolved status text") end
ISButton = {new = function(self, x, y, w, h, title, target, callback)
    return {initialise = function() end, setEnable = function(self, enabled) self.enabled = enabled end,
        target = target, callback = callback}
end}
testTurretOldPanel = oldPanel
