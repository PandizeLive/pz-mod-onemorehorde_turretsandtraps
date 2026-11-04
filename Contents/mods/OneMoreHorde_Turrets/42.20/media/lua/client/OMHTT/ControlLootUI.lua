if isServer() then return end
require("ISUI/ISComboBox")
local L = require("OMHTT/ControlLootDefinitions")
local R = require("OMHTT/ControlRarity")
local U = {}
U.groups = {
    {"Performance", {"Regulator", "Conservation", "Magazine", "RapidFire", "Velocity", "Range", "Suppression", "Critical", "Accuracy", "Reload", "Autoloader"}},
    {"Automation", {"FiringEnhanced", "MotionDetectionEnhanced", "Firing", "Filter", "MotionDetection", "Detection360"}},
    {"Effects", {"Piercing", "InitialBlow", "Execute", "Impact", "Splitter", "Fragment", "Synergy", "Martyrdom", "Tack"}},
    {"Utility", {"Grid", "Siphon", "Lure", "Void"}},
    {"Expansion", {"CapacitySmall", "Capacity", "CapacityLarge"}},
    {"Manuals", {"ManualBallista", "ManualRotaryBlades", "ManualLobber", "ManualArc", "ManualFirearms"}},
}
local defaults = {20, 18, 14, 10, 6, 3, 1}

---@param panel ISPanel Settings page
---@param control ISTextEntryBox Numeric field
---@return nil
function U.layout(panel, control)
    local combo = control.omhttRarity
    local right = math.min(control:getX() + control:getWidth(), panel:getWidth() - 12)
    local left = math.max(8, right - 220)
    local custom = combo.selected == 9
    combo:setX(left)
    combo:setY(control:getY())
    combo:setWidth(custom and right - left - 98 or right - left)
    control.omhttSetX(control, right - 90)
    control:setVisible(custom)
end

---@param panel ISPanel Native settings page
---@param tier integer Rarity
---@return number weight Exact configured anchor
function U.anchor(panel, tier)
    local name = "OMHTurretsTraps.RarityWeight" .. R.names[tier]
    local control = panel.controls[name] or panel.controls[name:gsub("%.", ".Traps", 1)]
    local value = control and tonumber(control:getText())
    if value and value > 0 then return value end
    return defaults[tier]
end

---@param panel ISPanel Native page
---@param control ISTextEntryBox Underlying numeric option
---@param key string Catalog key
---@return nil
function U.attach(panel, control, key)
    if control.omhttRarity or control.Type ~= "ISTextEntryBox" then return end
    local base = L.CATALOG[key]
    if not base then return end
    local rawSet, rawGet, setY, setX = control.setText, control.getText, control.setY, control.setX
    local border = control.borderColor
    local x, width = control:getX(), math.max(220, control:getWidth())
    local combo = ISComboBox:new(x, control:getY(), width, control:getHeight(), nil, nil)
    combo:initialise()
    combo:addOption(getText("UI_OMHTT_LootDisabled"))
    for i = 1, #R.names do
        combo:addOption(getText("UI_OMHTT_Rarity" .. i))
    end
    combo:addOption(getText("UI_OMHTT_LootCustom"))
    panel:addChild(combo)
    control.omhttRarity = combo
    control.omhttSetX = setX
    control.omhttLastValid = rawGet(control)
    if not tonumber(control.omhttLastValid) then
        control.omhttLastValid = tostring(L.DEFAULTS.items[key])
    end
    control:setWidth(90)
    control:setX(x + width - 90)
    combo.onChange = function()
        if combo.selected == 1 then
            rawSet(control, "0")
        elseif combo.selected <= 8 then
            rawSet(control, tostring(U.anchor(panel, combo.selected - 1) / base))
        end
        U.layout(panel, control)
        panel.omhttWidth = nil
    end
    control.setX = function(self, value)
        setX(self, value)
        U.layout(panel, self)
    end
    control.setY = function(self, y)
        setY(self, y)
        combo:setY(y)
    end
    control.setText = function(self, value)
        rawSet(self, value)
        local number = tonumber(value)
        combo.selected = 9
        if number and number < 0 and L.MANUALS[key] then
            combo.selected = L.MANUALS[key] + 1
        elseif number == 0 then
            combo.selected = 1
        elseif number then
            for tier = 1, #R.names do
                if math.abs(number * base - U.anchor(panel, tier)) < .0000001 then
                    combo.selected = tier + 1
                    break
                end
            end
        end
        if number then
            self.omhttLastValid = value
        end
        U.layout(panel, self)
        panel.omhttWidth = nil
    end
    -- Preserve exact imported values until the player explicitly chooses a tier.
    control.getText = function(self)
        local value = rawGet(self)
        local number = tonumber(value)
        local valid = number and number == number and number < math.huge
            and (number >= 0 or number == -1 and L.MANUALS[key])
        if not valid then
            self.borderColor = {r = .8, g = .2, b = .2, a = 1}
            return self.omhttLastValid
        end
        self.borderColor = border
        self.omhttLastValid = value
        return value
    end
    control:setText(rawGet(control))
end

---@param panel ISPanel Native settings page
---@return table sections Sorted category groups
function U.sections(panel)
    local sections = {}
    for i = 1, #U.groups do
        local group, keys = U.groups[i], {}
        for j = 1, #group[2] do
            local key = group[2][j]
            local name = "OMHTurretsTraps.LootRate" .. key
            local control = panel.controls[name] or panel.controls[name:gsub("%.", ".Traps", 1)]
            if control then
                U.attach(panel, control, key)
                keys[#keys + 1] = "LootRate" .. key
            end
        end
        table.sort(keys, function(a, b)
            local function weight(suffix)
                local name = "OMHTurretsTraps." .. suffix
                local control = panel.controls[name] or panel.controls[name:gsub("%.", ".Traps", 1)]
                local value = tonumber(control:getText()) or L.DEFAULTS.items[suffix:sub(9)]
                if value < 0 and L.MANUALS[suffix:sub(9)] then return U.anchor(panel, L.MANUALS[suffix:sub(9)]) end
                return value * L.CATALOG[suffix:sub(9)]
            end
            local aw, bw = weight(a), weight(b)
            local function band(weight)
                if weight <= 0 then return 8 end
                for tier = 1, 6 do
                    if weight > math.sqrt(U.anchor(panel, tier) * U.anchor(panel, tier + 1)) then return tier end
                end
                return 7
            end
            local ab, bb = band(aw), band(bw)
            if ab ~= bb then return ab < bb end
            return getText("Sandbox_OMHTurretsTraps_" .. a) < getText("Sandbox_OMHTurretsTraps_" .. b)
        end)
        sections[#sections + 1] = {"Sandbox_Title_OMHTurretsTraps_Loot" .. group[1], keys}
    end
    return sections
end

return U
