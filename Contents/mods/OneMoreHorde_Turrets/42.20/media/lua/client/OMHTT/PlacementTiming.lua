local P = {}

---@param cursor ISBuildIsoEntity Exact portable-item cursor
---@return nil
function P.preview(cursor)
    if cursor.objectInfo and cursor.objectInfo:getName() == "OMHTTDeployPoke" then
        cursor.renderFloorGrid = function(self, x, y, z)
            if not self.drawFloorGrid then return end
            local footprint = require("OMHTT/ControlPokeFootprint")
            local square = getCell():getGridSquare(x,y,z)
            local valid = self:isValid(square) and footprint.valid(square,nil,self.character)
            local color = valid and getCore():getGoodHighlitedColor() or getCore():getBadHighlitedColor()
            local sprite = self:getFloorCursorSprite()
            for i=1,#footprint.offsets do
                local offset = footprint.offsets[i]
                sprite:RenderGhostTileColor(x+offset[1],y+offset[2],z,color:getR(),color:getG(),color:getB(),.8)
            end
        end
    end
end

---@param cursor ISBuildIsoEntity Exact portable-item cursor
---@return nil
function P.apply(cursor)
    P.preview(cursor)
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
