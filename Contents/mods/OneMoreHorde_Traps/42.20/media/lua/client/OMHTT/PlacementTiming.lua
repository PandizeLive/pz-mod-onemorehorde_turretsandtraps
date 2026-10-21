local P = {}

---@param cursor ISBuildIsoEntity Exact portable-item cursor
---@return nil
function P.apply(cursor)
    ---@param self ISBuildIsoEntity Preview cursor
    ---@param x number Destination X
    ---@param y number Destination Y
    ---@param z number Floor
    ---@return OMHTTPlacementAction? action
    cursor.tryBuild = function(self, x, y, z)
        if self.blockBuild or not self:isValid(getCell():getGridSquare(x, y, z)) then return nil end
        if not self:walkTo(x, y, z) then return nil end
        local Action = require("OMHTT/PlacementAction")
        local inputs = self.omhttInputs
        local action = Action:new(self.character, inputs[1], inputs[2], self.objectInfo:getName(), self.nSprite, x, y, z)
        action.preview = self
        if self.dragNilAfterPlace then
            getCell():setDrag(nil, self.player)
        elseif self.blockAfterPlace then
            self.blockBuild = true
        end
        ISTimedActionQueue.add(action)
        return action
    end
end

return P
