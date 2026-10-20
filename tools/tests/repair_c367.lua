local R = require("OMHTT/ControlRepair")
local U = require("OMHTT/ControlRepairTooltip")
local entries = {}
local list = {size = function() return #entries end, get = function(_, index) return entries[index + 1] end}
local player = {getInventory = function() return {getItems = function() return list end} end}
local function item(kind, favorite)
    return {getFullType = function() return kind end, isFavorite = function() return favorite end}
end
local scrap = item("Base.ScrapMetal", false)
local favorite = item("Base.ScrapMetal", true)
entries = {favorite, item("Base.Aluminum", false), scrap}
local materials = R.materials(player, "Poke")
check(#materials == 1 and materials[1] == scrap, "Repair material selection excludes favorites and unrelated items")
check(string.find(U.description("Poke", player), getText("UI_OMHTT_RepairScrap", 1, 2), 1, true),
    "Poke repair tooltip shows the authoritative eligible material count")
local second = item("Base.ScrapMetal", false)
entries[#entries + 1] = second
entries[#entries + 1] = item("Base.ScrapMetal", false)
materials = R.materials(player, "Poke")
check(#materials == 2 and materials[1] == scrap and materials[2] == second, "Repair selection caps at exactly the consumed count")
check(string.find(U.description("Poke", player), getText("UI_OMHTT_RepairScrap", 2, 2), 1, true),
    "Poke tooltip changes when the missing material is supplied")
local action = require("OMHTT/ControlPokeAction")
local chosen = action.materials({character = player})
check(#chosen == 2 and chosen[1] == materials[1] and chosen[2] == materials[2],
    "Poke authority and tooltip select the same exact items")
entries = {favorite}
check(action.materials({character = player}) == nil, "Missing unfavorited scrap keeps repair invalid")
for kind, profile in pairs(R.profiles) do
    local description = U.description(kind, player)
    check(string.find(description, getText("UI_OMHTT_RepairSkills"), 1, true)
        and string.find(description, getText("UI_OMHTT_RepairTime", profile.seconds), 1, true),
        "Every repair profile shows skill and the action duration: " .. kind)
    if profile.scrap == 0 then
        check(string.find(description, getText("UI_OMHTT_RepairMaterials", getText("UI_OMHTT_RepairNone")), 1, true),
            "Free repair explicitly shows no consumed materials: " .. kind)
    end
end
check(string.find(U.description("Barb", player, false), getText("UI_OMHTT_RepairToolsMissing"), 1, true),
    "Barbed panel tooltip explains missing retained tools")
check(string.find(U.description("Turret", player), getText("UI_OMHTT_RepairBaseResult"), 1, true),
    "Turret repair explains that installed head condition is separate")
local oldMenu = ISWorldObjectContextMenu
ISWorldObjectContextMenu = {addToolTip = function() return {} end}
local option = {notAvailable = true}
U.bind(option, "Poke", player)
check(option.notAvailable and option.toolTip.description == U.description("Poke", player),
    "Disabled repair entries retain their uniform requirements tooltip")
ISWorldObjectContextMenu = oldMenu
