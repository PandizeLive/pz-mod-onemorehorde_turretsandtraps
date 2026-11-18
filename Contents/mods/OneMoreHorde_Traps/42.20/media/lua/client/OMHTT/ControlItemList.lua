if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/AdminPanel/ISItemsListViewer")
require("ISUI/AdminPanel/ISItemsListTable")

local nativeList = ISItemsListViewer.initList
---@return nil
function ISItemsListViewer:initList()
    nativeList(self)
    local items = {}
    for i = 0, self.items:size() - 1 do
        local item = self.items:get(i)
        if not item:getObsolete() and not item:isHidden()
            and string.sub(item:getFullName(), 1, 10) == "Base.OMHTT" then
            items[#items + 1] = item
        end
    end
    if #items == 0 then return end
    local view = ISItemsListTable:new(0, 0, self.panel.width, self.panel.height - self.panel.tabHeight, self)
    view:initialise()
    self.panel:addView(getText("UI_OMHTT_ItemList"), view)
    view:initList(items)
end
