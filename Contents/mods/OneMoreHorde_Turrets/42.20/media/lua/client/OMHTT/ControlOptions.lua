if isServer() then return end
require("PZAPI/ModOptions")
local O = {defaults = {LaserVisible = false, LaserOpacity = 25, FeedbackVolume = 100,
    StateMarkers = true, ShowNoiseRadius = true, PackAnimation = true, ShowRanges = true,
    ArcLighting = true, ArcLightIntensity = 50}}

---@return table saved Native option values; new IDs win over legacy IDs
local function savedValues()
    local values, legacy = {}, {}
    local reader = getFileReader("ModOptions.ini", true)
    while true do
        local line = reader:readLine()
        if not line then break end
        local kind, mod, key, raw = string.match(line, "^([^|]+)|([^|]+)|([^|]+)|(.+)$")
        if mod == "OMHTT" or mod == "OneMoreHorde_TurretsAndTraps" then
            local value = tonumber(raw)
            if kind == "tickbox" then
                value = raw == "true"
            end
            if value ~= nil then
                if mod == "OMHTT" then
                    values[key] = value
                else
                    legacy[key] = value
                end
            end
        end
    end
    reader:close()
    for key, value in pairs(legacy) do
        if values[key] == nil then
            values[key] = value
        end
    end
    return values
end

---@return nil
function O.register()
    if O.options then return end
    local values = savedValues()
    local options = PZAPI.ModOptions:getOptions("OMHTT")
    if not options then
        options = PZAPI.ModOptions:create("OMHTT", "OMH: Turrets & Traps")
    end
    O.options = options
    local toggles = {
        {"ShowNoiseRadius", "UI_OMHTT_ShowNoiseRadius"}, {"ShowRanges", "UI_OMHTT_OptionRanges"},
        {"PackAnimation", "UI_OMHTT_PackAnimation"}, {"LaserVisible", "UI_OMHTT_OptionLaser"},
        {"StateMarkers", "UI_OMHTT_OptionMarkers"}, {"ArcLighting", "UI_OMHTT_OptionArcLight"},
    }
    for i = 1, #toggles do
        local key, label = toggles[i][1], toggles[i][2]
        if not options:getOption(key) then
            local value = values[key]
            if type(value) ~= "boolean" then
                value = O.defaults[key]
            end
            options:addTickBox(key, getText(label), value)
        end
    end
    local sliders = {
        {"LaserOpacity", "UI_OMHTT_OptionOpacity", 5, 60, 5},
        {"FeedbackVolume", "UI_OMHTT_OptionVolume", 0, 100, 1},
        {"ArcLightIntensity", "UI_OMHTT_OptionArcIntensity", 0, 100, 5},
    }
    for i = 1, #sliders do
        local row = sliders[i]
        if not options:getOption(row[1]) then
            local value = values[row[1]]
            if type(value) ~= "number" then
                value = O.defaults[row[1]]
            end
            options:addSlider(row[1], getText(row[2]), row[3], row[4], row[5], value)
        end
    end
end

---@param name string Preference
---@return boolean|number value
function O.get(name)
    O.register()
    local option = O.options:getOption(name)
    if option then
        local value = option:getValue()
        if type(value) == type(O.defaults[name]) then return value end
    end
    return O.defaults[name]
end

---@return number gain Local master times legacy device mix
---@nodiscard
function O.volume()
    local settings = SandboxVars.OMHTurretsTraps or {}
    local legacy = settings.DeviceSoundVolume or settings.TrapsDeviceSoundVolume or 1
    return math.max(0, math.min(2, legacy)) * O.get("FeedbackVolume") / 100
end

Events.OnGameBoot.Add(O.register)
Events.OnGameStart.Add(O.register)
return O
