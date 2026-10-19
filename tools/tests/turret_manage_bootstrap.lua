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
function ISPanel:createChildren() end
function ISPanel:addToUIManager() testTurretPanel = self end
function ISPanel:removeFromUIManager() self.removed = true end
function ISPanel:instantiate()
    self.javaObject = {setScrollChildren=function(_, value) self.scrollChildren=value end}
end
function ISPanel:addChild(child)
    if not self.javaObject then self:instantiate() end
    if not child.javaObject then
        if child.instantiate then child:instantiate() else child.javaObject={} end
    end
    self.children[#self.children + 1] = child; child.parent = self
end
function ISPanel:updateScrollbars() end
function ISPanel:removeChild(child)
    for i = #self.children, 1, -1 do if self.children[i] == child then table.remove(self.children, i) end end
    child.parent = nil
end
function ISPanel:setX(x) self.x = x end
function ISPanel:setWidth(width) self.width = width end
function ISPanel:setVisible(value) self.visible = value end
function ISPanel:prerender() end
function ISPanel:isMouseOver() return false end
function ISPanel:getAbsoluteX() return self.x + (self.parent and self.parent:getAbsoluteX() or 0) end
function ISPanel:getAbsoluteY()
    return self.y + (self.parent and self.parent:getAbsoluteY() + (self.parent.scrollChildren and self.parent:getYScroll() or 0) or 0)
end
function ISPanel:setStencilRect(x,y,w,h)
    if not testStencil then return end
    local ax,ay = self:getAbsoluteX()+x,self:getAbsoluteY()+y
    for i=1,#testStencil.points do
        local p=testStencil.points[i]
        if p.x>=ax and p.x<ax+w and p.y>=ay and p.y<ay+h and p.level==testStencil.level then p.level=p.level+1 end
    end
    testStencil.level=testStencil.level+1
end
function ISPanel:clampStencilRectToParent(x,y,w,h)
    if self.parent then
        local dx,dy=self:getAbsoluteX()-self.parent:getAbsoluteX(),self:getAbsoluteY()-self.parent:getAbsoluteY()
        local x2,y2=math.min(x+w,self.parent.width-dx),math.min(y+h,self.parent.height-dy)
        x,y=math.max(x,-dx),math.max(y,-dy)
        w,h=math.max(0,x2-x),math.max(0,y2-y)
    end
    self:setStencilRect(x,y,w,h)
    return x,y,w,h
end
function ISPanel:repaintStencilRect(x,y,w,h)
    if not testStencil or testStencil.level==0 then return end
    local ax,ay=self:getAbsoluteX()+x,self:getAbsoluteY()+y
    for i=1,#testStencil.points do
        local p=testStencil.points[i]
        if p.x>=ax and p.x<ax+w and p.y>=ay and p.y<ay+h then p.level=testStencil.level end
    end
end
function ISPanel:clearStencilRect()
    if not testStencil then return end
    testStencil.level=math.max(0,testStencil.level-1)
    if testStencil.level==0 then for i=1,#testStencil.points do testStencil.points[i].level=0 end end
end
function ISPanel:drawRectBorder() end
function ISPanel:drawRect() end
function ISPanel:drawRectStatic() end
function ISPanel:onMouseDown() self.moving = true end
function ISPanel:setCapture(value) self.capture=value end
function ISPanel:setFont(font, padding) self.font=font end
function ISPanel:drawTextRight(text) check(type(text)=="string", "Right-aligned text resolves") end
function ISPanel:drawProgressBar(x, y, width, height, value) check(x >= 0 and x + width <= self.width and value >= 0 and value <= 1, "Supply meter stays inside its slot") end
function ISPanel:setY(y) self.y = y end
function ISPanel:setHeight(height) self.height = height end
function ISPanel:onResize() end
function ISPanel:setScrollChildren(value)
    if self.javaObject then self.javaObject:setScrollChildren(value) end
end
function ISPanel:addScrollBars()
    self.vscroll = ISPanel:new(self.width - 17, 0, 17, self.height)
    self:addChild(self.vscroll)
end
function ISPanel:setAnchorRight(value) self.anchorRight = value end
function ISPanel:setAnchorBottom(value) self.anchorBottom = value end
function ISPanel:setScrollHeight(value) self.scrollHeight = value end
function ISPanel:getYScroll() return self.yScroll or 0 end
function ISPanel:setYScroll(value) self.yScroll = value end
function ISPanel:drawText(text) check(type(text) == "string", "Manage draws resolved status text") end
ISButton = {new = function(self, x, y, w, h, title, target, callback)
    return {setX = function(self, x) self.x = x end, setHeight = function(self, h) self.height = h end, initialise = function() end, setWidth = function(self, w) self.width = w end, setY = function(self, y) self.y = y end, setVisible = function(self, visible) self.visible = visible end, setEnable = function(self, enabled) self.enabled = enabled; self.enable = enabled end,
        x=x, y=y, width=w, height=h, title=title, target = target, callback = callback, setTitle = function(self, title) self.title = title end}
end}
ISMouseDrag = {}
ISScrollingListBox = ISPanel:derive("TestScrollingList")
function ISScrollingListBox:initialise() self:addScrollBars() end
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
    return {x=x, y=y, width=w, height=h, setX = function(self, x) self.x=x end, setWidth = function(self, w) self.width = w end, setY = function(self, y) self.y = y end, setVisible = function(self, v) self.visible = v end, currentValue = 1, initialise = function() end,
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

ISInventoryPane.canPutIn=function() return "native-admission" end
ISInventoryPaneDraggedItems={update=function(self) self.nativeUpdates=(self.nativeUpdates or 0)+1 end}
ISInventoryPage={refreshBackpacks=function(self) self.nativeRefreshes=(self.nativeRefreshes or 0)+1 end,
    update=function(self) self.capacity=100 end,canPutIn=function() return "native-page-admission" end}
ISInventoryPaneContextMenu = ISInventoryPaneContextMenu or {}
ISInventoryPaneContextMenu.hasRoomForAny=function() return "native-context-admission" end

function ISPanel:getScrollHeight() return self.scrollHeight or self.height end
function ISPanel:getIsVisible() return self.visible~=false end
function ISPanel:getX() return self.x end
function ISPanel:getY() return self.y end
function ISPanel:getWidth() return self.width end
function ISPanel:getHeight() return self.height end
function ISPanel:drawLine2() end
function ISPanel:drawLine(texture, x1, y1, x2, y2, thickness, a, r, g, b)
    check(texture == nil and thickness > 0 and b ~= nil, "Native line receives width and complete RGBA")
end
function ISPanel:drawTextCentre() end

function ISPanel:getMouseX() return 0 end
function ISPanel:getMouseY() return 0 end
