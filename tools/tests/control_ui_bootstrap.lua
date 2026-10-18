LuaEventManager.AddEvent("OnFillInventoryObjectContextMenu")
ISTextEntryBox = ISPanel:derive("TestTextEntry")
function ISTextEntryBox:new(text, x, y, width, height)
    local result = ISPanel.new(self, x, y, width, height)
    result.text = text
    return result
end
function ISTextEntryBox:getText() return self.text end
function ISTextEntryBox:setText(value) self.text = value end

testControlPanelBase, testControlListBase, testControlButtonBase, testControlTextBase = ISPanel, ISScrollingListBox, ISButton, ISTextEntryBox

function ISTextEntryBox:setEditable(value) self.editable=value end
function ISTextEntryBox:isFocused() return self.focused==true end
function ISTextEntryBox:unfocus() self.focused=false; if self.onLostFocus then self:onLostFocus() end end
function ISTextEntryBox:setMaxTextLength(value) self.maxTextLength=value end
function ISTextEntryBox:setPlaceholderText(value) self.placeholder=value end
function ISTextEntryBox:setPlaceholderTextRGBA(r,g,b,a) self.placeholderColor={r,g,b,a} end

LuaEventManager.AddEvent("OnContainerUpdate")
local paneFunctions=ISInventoryPane
ISInventoryPane=ISPanel:derive("NativePaneTestAdapter")
for key,value in pairs(paneFunctions) do ISInventoryPane[key]=value end
function ISInventoryPane:new(x,y,w,h,inventory,zoom)
    local pane=ISPanel.new(self,x,y,w,h)
    pane.inventory,pane.selected,pane.items=inventory,{},{}
    pane.draggedItems={reset=function(self) self.resetCalled=true end}
    return pane
end
function ISInventoryPane:createChildren() self:addScrollBars() end
function ISInventoryPane:onResize() end
function ISInventoryPane:hideButtons() end
function ISInventoryPane:refreshContainer() self.refreshes=(self.refreshes or 0)+1 end
function ISInventoryPane:update() end
function ISPanel:bringToTop() self.raised=true end
function ISPanel:isReallyVisible() return self.visible~=false end
function ISInventoryPaneDraggedItems:getDropContainer() return nil end

ISUIElement=ISPanel
ISLayoutManager={windows={},RegisterWindow=function(key, funcs, target) ISLayoutManager.windows[key]={funcs=funcs,target=target} end,OnPostSave=function() end}
