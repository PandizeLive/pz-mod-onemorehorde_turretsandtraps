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
