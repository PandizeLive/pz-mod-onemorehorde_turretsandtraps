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
