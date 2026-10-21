local D = {}
local defaults = {Button = .0001, Plate = .01, Lever = .01, Laser = .1}
local names = {"Minimal", "VeryLow", "Low", "Medium", "High", "VeryHigh", "Extreme"}
local limits = {1, 2.5, 5, 15, 30, 60}
local colors = {{130,174,255}, {115,204,255}, {89,230,102}, {255,250,77}, {255,148,51}, {255,46,46}, {66,13,130}}
function D.rate(kind)
    local settings = SandboxVars.OMHTurretsTraps or {}
    local value = settings["Trigger" .. kind .. "Consumption"]
    -- Independent packages cannot register the same native Sandbox identity.
    -- Turrets owns the common set when both load; Traps-only uses its fallback.
    if value == nil then value = settings["TrapsTrigger" .. kind .. "Consumption"] end
    if type(value) ~= "number" or value ~= value then value = defaults[kind] or 0 end
    return math.max(0, math.min(100, value))
end
local ratings = {}
for i=1,#names do
    local color=colors[i]
    ratings[i]={key="UI_OMHTT_HeadBattery" .. names[i],r=.55+color[1]/255*.45,g=.55+color[2]/255*.45,b=.55+color[3]/255*.45}
end
local none={key="UI_OMHTT_HeadBatteryNone",r=.8,g=.8,b=.8}
---@param rate number Percentage points per real unpaused hour
---@return table OMH band and color
function D.band(rate)
    if rate<=0 then return none end
    local band=1
    while band<=#limits and rate>=limits[band] do band=band+1 end
    return ratings[band]
end
function D.rating(kind)
    local rate=D.rate(kind)
    local rating
    if kind=="Button" then rating=rate>0 and ratings[1] or none
    else rating=D.band(rate*1440/math.max(1,getGameTime():getMinutesPerDay())) end
    return string.sub(rating.key,#"UI_OMHTT_HeadBattery"+1),rating
end
function D.description(kind, rich)
    local rating, color = D.rating(kind)
    local value = getText("UI_OMHTT_HeadBattery" .. rating)
    if rich then value = string.format("<RGB:%.2f,%.2f,%.2f> %s <RGB:1,1,1>", color.r, color.g, color.b, value) end
    local cost = string.format("%.4f", D.rate(kind)):gsub("0+$", ""):gsub("%.$", "")
    local lines = {getText("UI_OMHTT_HeadBattery", value), getText("UI_OMHTT_TriggerCost" .. kind, cost),
        getText("UI_OMHTT_TriggerSupply"), getText("UI_OMHTT_TriggerOverhead")}
    return table.concat(lines, rich and " <LINE> " or "\n"), color
end
return D
