ISPanel = {derive = function(self, name) return {} end}
Events.SetDragItem = {Add = function() end}
ArrayList = {new = function()
    local list = {}
    function list:size() return #self end
    function list:get(index) return self[index + 1] end
    function list:add(value) self[#self + 1] = value end
    function list:addAll(other)
        for i = 0, other:size() - 1 do self:add(other:get(i)) end
    end
    function list:contains(value)
        for i = 1, #self do if self[i] == value then return true end end
        return false
    end
    return list
end}
