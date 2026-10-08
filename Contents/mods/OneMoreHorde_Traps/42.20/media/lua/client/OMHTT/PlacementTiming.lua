local P = {}

---@param cursor ISBuildIsoEntity Exact portable-item cursor
---@return nil
function P.apply(cursor)
    local start = cursor.onTimedActionStart
    ---@param self ISBuildIsoEntity Copied build cursor
    ---@param action ISBuildAction Native placement action
    ---@return nil
    cursor.onTimedActionStart = function(self, action)
        start(self, action)
        if action.character:isTimedActionInstant() then return end
        local update = action.update
        action.maxTime = 480
        action.action:setTime(480)
        action.action:setWaitForFinished(true)
        action.OMHTTElapsed = 0
        ---@param timed ISBuildAction Running action
        ---@return nil
        action.update = function(timed)
            update(timed)
            timed.OMHTTElapsed = timed.OMHTTElapsed + math.min(getGameTime():getRealworldSecondsSinceLastUpdate(), .25)
            timed:setJobDelta(math.min(timed.OMHTTElapsed / 5, .999))
            if timed.OMHTTElapsed >= 5 then timed.action:forceComplete() end
        end
    end
end

return P
