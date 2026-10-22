if isServer() then return end
require("PZAPI/ModOptions")
local O = {defaults = {LaserVisible = false, LaserOpacity = 25, FeedbackVolume = 100, StateMarkers = true}}

---@return nil
function O.register()
    if O.options or not PZAPI or not PZAPI.ModOptions then return end
    local options = PZAPI.ModOptions:getOptions("OMHTT")
    if not options then options = PZAPI.ModOptions:create("OMHTT", "OMH: Turrets & Traps") end
    O.options = options
    if not options:getOption("LaserVisible") then
        options:addTickBox("LaserVisible", getText("UI_OMHTT_OptionLaser"), false)
    end
    if not options:getOption("LaserOpacity") then
        options:addSlider("LaserOpacity", getText("UI_OMHTT_OptionOpacity"), 5, 60, 5, 25)
    end
    if not options:getOption("FeedbackVolume") then
        options:addSlider("FeedbackVolume", getText("UI_OMHTT_OptionVolume"), 0, 100, 1, 100)
    end
    if not options:getOption("StateMarkers") then
        options:addTickBox("StateMarkers", getText("UI_OMHTT_OptionMarkers"), true)
    end
end

---@param name string Preference
---@return boolean|number value
function O.get(name)
    O.register()
    local option = O.options and O.options:getOption(name)
    if option then
        local value = option:getValue()
        if type(value) == type(O.defaults[name]) then return value end
    end
    return O.defaults[name]
end

Events.OnGameBoot.Add(O.register)
Events.OnGameStart.Add(O.register)
return O
