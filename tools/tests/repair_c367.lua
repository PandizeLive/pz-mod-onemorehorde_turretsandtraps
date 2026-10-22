local R = require("OMHTT/ControlRepair")
local U = require("OMHTT/ControlRepairTooltip")
local entries = {}
local list = {size = function() return #entries end, get = function(_, index) return entries[index + 1] end}
local player = {getInventory = function() return {getItems = function() return list end,
    getFirstTagEvalRecurse = function() return {} end} end}
local function item(kind, favorite)
    return {getFullType = function() return kind end, isFavorite = function() return favorite end}
end
local scrap = item("Base.ScrapMetal", false)
local favorite = item("Base.ScrapMetal", true)
entries = {favorite, item("Base.Aluminum", false), scrap}
local materials = R.materials(player, "Poke")
check(#materials == 1 and materials[1] == scrap, "Repair material selection excludes favorites and unrelated items")
check(string.find(U.description("Poke", player), getItemNameFromFullType("Base.ScrapMetal"), 1, true),
    "Poke repair tooltip shows the authoritative eligible material count")
local second = item("Base.ScrapMetal", false)
entries[#entries + 1] = second
entries[#entries + 1] = item("Base.ScrapMetal", false)
materials = R.materials(player, "Poke")
check(#materials == 1 and materials[1] == scrap, "Repair selection caps at exactly the consumed count")
check(string.find(U.description("Poke", player), getItemNameFromFullType("Base.ScrapMetal"), 1, true),
    "Poke tooltip changes when the missing material is supplied")
local action = require("OMHTT/ControlPokeAction")
local chosen = action.materials({character = player})
check(#chosen == 1 and chosen[1] == materials[1],
    "Poke authority and tooltip select the same exact items")
entries = {favorite}
check(action.materials({character = player}) == nil, "Missing unfavorited scrap keeps repair invalid")
for kind, profile in pairs(R.profiles) do
    local description = U.description(kind, player)
    check(not string.find(description, getText("UI_OMHTT_RepairSkills"), 1, true)
        and string.find(description, getText("UI_OMHTT_RepairTime", profile.seconds), 1, true),
        "Repair tips omit nonexistent skill requirements and show duration: " .. kind)
    if not profile.material then
        check(not string.find(description, getText("UI_OMHTT_RepairMaterials", getText("UI_OMHTT_RepairNone")), 1, true),
            "Free repair only lists its retained tool: " .. kind)
    end
end
check(string.find(U.description("Barb", player, false), "<RGB:1,0.3,0.3>", 1, true),
    "Barbed panel tooltip explains missing retained tools")
check(not string.find(U.description("Turret", player), getText("UI_OMHTT_RepairBaseResult"), 1, true),
    "Repair tip excludes extra result instructions")
local oldMenu = ISWorldObjectContextMenu
ISWorldObjectContextMenu = {addToolTip = function() return {} end}
local option = {notAvailable = true}
U.bind(option, "Poke", player)
check(option.notAvailable and option.toolTip.description == U.description("Poke", player),
    "Disabled repair entries retain their uniform requirements tooltip")
ISWorldObjectContextMenu = oldMenu

-- C369: one material, one usable retained tool, authoritative consumption.
local oldMode, oldRemove = testMode, sendRemoveItemFromContainer
local activeTool, toolCondition, sent = nil, 10, 0
local stock = {items = {}}
function stock:getItems() return {size = function() return #self.items end, get = function(_, i) return self.items[i + 1] end} end
function stock:getFirstTagEvalRecurse(tag, predicate)
    local tool = {getCondition = function() return toolCondition end}
    if activeTool == tag and predicate(tool) then return tool end
end
function stock:Remove(candidate)
    for i = #self.items, 1, -1 do if self.items[i] == candidate then table.remove(self.items, i) end end
end
local operator = {getInventory = function() return stock end, removeFromHands = function() end}
sendRemoveItemFromContainer = function(source) check(source == stock, "Repair syncs exact source container"); sent = sent + 1 end
for kind, profile in pairs(R.profiles) do
    testMode, sent, toolCondition = "server", 0, 10
    stock.items = profile.material and {item(profile.material, false), item(profile.material, false)} or {}
    activeTool = nil
    check(not R.consume(operator, kind) and sent == 0, "Missing tool cannot consume repair material: " .. kind)
    activeTool, toolCondition = ItemTag[profile.tag], 0
    check(not R.ready(operator, kind), "Broken retained tool cannot repair: " .. kind)
    toolCondition = 10
    local before = #stock.items
    testMode = "client"
    check(not R.consume(operator, kind) and #stock.items == before, "Clients cannot consume authoritative repair material: " .. kind)
    testMode = "server"
    check(R.consume(operator, kind) and #stock.items == before - (profile.material and 1 or 0), "Repair consumes exactly one material or none for triggers: " .. kind)
    check(sent == (profile.material and 1 or 0) and toolCondition == 10, "Repair retains tool and publishes one material removal: " .. kind)
    if profile.material then
        stock.items = {item(profile.material, true)}
        check(not R.ready(operator, kind) and not R.consume(operator, kind), "Favorited-only material cannot be consumed: " .. kind)
    end
end
testMode, sendRemoveItemFromContainer = oldMode, oldRemove

local Names = require("OMHTT/DefenseNames")
local fresh = {getID = function() return 981101 end, getFullType = function() return "Base.OMHTTTrapBedSpikes" end,
    getCondition = function() return 50 end, getConditionMax = function() return 50 end}
local worn = {getID = function() return 981102 end, getFullType = fresh.getFullType,
    getCondition = function() return 1 end, getConditionMax = fresh.getConditionMax,
    setCondition = function() end, getModData = function() return {} end}
Names.pack({health = 17, maxHealth = 50}, worn)
local mixed = {size = function() return 2 end, get = function(_, i) return i == 0 and fresh or worn end}
local right, left = {}, {}
Names.restore(right, mixed, 2, fresh:getFullType())
Names.restore(left, mixed, 1, fresh:getFullType())
check(Names.health(right, 50) == 17 and Names.health(left, 50) == 50,
    "Mixed fresh/worn Bed inputs preserve exact positions even with reversed callbacks")

local Access = require("OMHTT/ControlAccess")
local stateBefore, modeBefore = Access.state, testMode
local currentKind
Access.state = function() return {kind = currentKind, id = "category-timing"} end
testMode = "server"
for _, kind in pairs({"Controller", "Button", "Plate"}) do
    currentKind = kind
    local Control = require("OMHTT/ControlAction")
    local pickup = Control:new({}, {}, "Pickup", nil, nil, "category-timing")
    local repair = Control:new({}, {}, "Repair", nil, nil, "category-timing")
    check(pickup:getDuration() == R.profiles[kind].pickup * 50 and repair:getDuration() == R.profiles[kind].seconds * 50,
        "Server reconstructs category duration from authoritative device kind: " .. kind)
end
Access.state, testMode = stateBefore, modeBefore
