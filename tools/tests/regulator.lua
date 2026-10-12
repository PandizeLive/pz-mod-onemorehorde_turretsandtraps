local S = require("OMHTT/TurretStats")
local T = require("OMHTT/Turret")
local R = require("OMHTT/TurretRarity")
local saved = SandboxVars.OMHTurretsTraps
SandboxVars.OMHTurretsTraps = {}
R.refresh({})
local baseline = S.resolve({active = {}, powerLoad = 16})
check(math.abs(baseline.batteryPercent - .00765) < .00000001, "Approved .00045 base and sixteen maximum surcharges resolve exactly")
for _, copies in pairs({1, 2, 4, 16}) do
    local stats = S.resolve({active = {Regulator = copies}, powerLoad = 16})
    check(math.abs(stats.batteryPercent * (1 + .25 * copies) - baseline.batteryPercent) < .00000001,
        "Regulator gives linear endurance without free firing")
    check(stats.generatorFuel == baseline.generatorFuel and stats.batteryPercent > 0, "Regulator is battery-only")
end
local modules = {}
for i = 1, 3 do
    modules[i] = {getFullType = function() return T.TYPES.Regulator end, getActualWeight = function() return .2 end,
        getCondition = function() return i == 3 and 0 or 100 end, getDisplayName = function() return "Regulator" end}
end
local items = {size = function() return #modules end, get = function(self, i) return modules[i + 1] end}
local contents = T.contents({getItems = function() return items end})
check(contents.modules == 3 and contents.active.Regulator == 2 and contents.powerLoad == 0,
    "Regulator occupies slots, broken copies do not work, no self-surcharge")
check(R.get("Regulator").band == 1 and R.get("Synergy").surcharge == 1, "Owner weight makes Regulator Abundant; Synergy retains maximum surcharge")
local description = require("OMHTT/TurretDescriptions").get("Regulator", false)
check(string.find(description, "Battery Drain: +0x", 1, true) and string.find(description, "Rarity: Abundant"), "Regulator tooltip reports its actual exception")
SandboxVars.OMHTurretsTraps.PotatoBatteryPercentPerShot = .1
check(S.resolve({active = {}}).batteryPercent == .1, "Existing custom sandbox settings are not silently overwritten")
SandboxVars.OMHTurretsTraps = saved
R.refresh(saved or {})

local originalTextManager = getTextManager
getTextManager = function() return {WrapText = function(self, font, text, width) return text end} end
local originalCore = getCore
getCore = function() return {getScreenHeight = function() return 720 end} end
local panel = {height = 100, width = 250, y = 660, labels = {}, backgroundColor = {a=1,r=0,g=0,b=0}, borderColor = {a=1,r=1,g=1,b=1}}
panel.tooltip = {getLineSpacing = function() return 18 end, getFont = function() return UIFont.Small end,
    setY = function(self, y) self.y = y end}
panel.item = {DoTooltip = function() panel.redraw = true end}
function panel:getHeight() return self.height end
function panel:getWidth() return self.width end
function panel:getY() return self.y end
function panel:setHeight(value) self.height = value end
function panel:setY(value) self.y = value end
function panel:drawRect() end
function panel:drawRectBorder() end
function panel:drawText(text) self.labels[#self.labels + 1] = text end
require("OMHTT/TurretItemTooltip").footer(panel, "Regulator")
check(panel.height == 180 and panel.y + panel.height < 720 and panel.redraw,
    "Colored footer fits the screen with no native public padding fields")
check(#panel.labels == 4 and string.find(panel.labels[4], "Rarity:"), "Four dynamic lines outside native translation, including rarity")
getCore = originalCore
getTextManager = originalTextManager
