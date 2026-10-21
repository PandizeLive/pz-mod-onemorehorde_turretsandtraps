local P = {}

---@param cursor ISBuildIsoEntity Exact portable-item cursor
---@param seconds number? Selected category duration; defaults to turret timing
---@return nil
function P.apply(cursor, seconds)
    seconds = seconds or 5
    if isClient() then return end
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
            timed.OMHTTElapsed = timed.OMHTTElapsed + getGameTime():getMultiplier() / getGameTime():getMultiplierFromTimeDelta(1)
            timed:setJobDelta(math.min(timed.OMHTTElapsed / seconds, .999))
            if timed.OMHTTElapsed >= seconds then timed.action:forceComplete() end
        end
    end
end

return P
