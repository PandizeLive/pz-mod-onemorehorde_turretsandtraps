local Highlight = {}

---@param option table Native context option
---@param menu ISContextMenu Owning menu
---@param active boolean Hover state
---@param parts table Exact visible parts
---@return nil
function Highlight.highlight(option, menu, active, parts)
    local color = getCore():getWorldItemHighlightColor()
    for i = 1, #parts do
        local object = parts[i]
        if object:getObjectIndex() >= 0 then
            object:setHighlighted(menu.player, active, false)
            object:setHighlightColor(menu.player, color)
            object:setOutlineHighlight(menu.player, active)
            object:setOutlineHighlightCol(menu.player, color)
        end
    end
end

return Highlight
