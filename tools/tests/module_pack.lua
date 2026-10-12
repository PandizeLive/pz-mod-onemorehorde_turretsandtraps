local P = require("OMHTT/TurretModulePack")
local L = require("OMHTT/LootDefinitions")
local T = require("OMHTT/Turret")
local settings = SandboxVars.OMHTurretsTraps
local oldSettings, oldFactory, oldRoll, oldFloat = {}, instanceItem, ZombRand, ZombRandFloat
for key, value in pairs(settings) do oldSettings[key] = value end
for name in pairs(L.WEIGHTS) do settings["LootRate" .. name] = nil end
local entries, total = P.pool()
check(#entries == 29 and total > 0, "All 29 exported modules and expansion kits are eligible")
check(L.WEIGHTS.Firing * L.DEFAULTS.items.Firing == 15 and L.WEIGHTS.Martyrdom * L.DEFAULTS.items.Martyrdom == 2,
    "Owner weights are defaults on the unchanged saved multiplier scale")
local sample = {{name = "first", ceiling = 1}, {name = "last", ceiling = 4}}
check(P.pick(sample, 4, 0) == "first" and P.pick(sample, 4, .25) == "last" and P.pick(sample, 4, .9999) == "last", "Weighted cumulative boundaries")
local inventory = {items = {}}
function inventory:contains(item) return self.items[item] == true end
function inventory:AddItem(item)
    if self.fail then return nil end
    self.items[item] = true
    item.container = self
    return item
end
function inventory:Remove(item) self.items[item] = nil; item.container = nil end
local function item(kind)
    local value = {kind = kind, data = {}}
    function value:getFullType() return self.kind end
    function value:getModData() return self.data end
    function value:getContainer() return self.container end
    return value
end
instanceItem = item
ZombRandFloat = function() return 0 end
local player = {isDead = function() return false end, getInventory = function() return inventory end}
local pack = item(P.TYPE)
inventory:AddItem(pack)
inventory.fail = true
check(P.open(player, pack) == nil and inventory:contains(pack), "Failed reward insertion preserves pack")
local selected = pack.data.OMHTTPackRewards
inventory.fail = false
ZombRandFloat = function() error("Retry must not reroll committed pack") end
local rewards = P.open(player, pack)
check(#rewards == 3 and not inventory:contains(pack) and pack.data.OMHTTPackRewards == selected, "Exact pack consumed once after three grants")
check(rewards[1]:getFullType() == rewards[2]:getFullType() and rewards[1] ~= rewards[2], "Duplicate draws grant distinct physical items")
check(P.open(player, pack) == nil, "Duplicate completion cannot grant again")
for name in pairs(L.WEIGHTS) do settings["LootRate" .. name] = 0 end
local emptyPack = item(P.TYPE)
inventory:AddItem(emptyPack)
check(P.open(player, emptyPack) == nil and inventory:contains(emptyPack), "Zero eligible weights preserve unopened pack")
testMode = "client"
check(P.open(player, emptyPack) == nil, "Deferred MP opening stays disabled")
testMode = "sp"
for name in pairs(L.WEIGHTS) do settings["LootRate" .. name] = nil end
P.pool()
local count = 0
local zombie = {data = {}, getInventory = function() return {AddItem = function(_, kind) check(kind == P.TYPE, "Only packs added to bodies"); count = count + 1 end} end}
function zombie:getModData() return self.data end
settings.PackZombieChance, settings.ModuleLootRate, settings.PotatoTurret, settings.TurretsEnabled = 15, 1, true, true
ZombRand = function() return 1499 end
P.onDeath(zombie); P.onDeath(zombie)
check(count == 1, "15 percent boundary succeeds once per zombie")
zombie.data = {}; ZombRand = function() return 1500 end; P.onDeath(zombie)
check(count == 1, "15 percent boundary excludes 1500 and above")
zombie.data = {}; settings.PackZombieChance = 0; ZombRand = function() return 0 end; P.onDeath(zombie)
check(count == 1, "Zero disables corpse packs")
local B = require("OMHTT/TurretBenefits")
local E = require("OMHTT/TurretBatteryEstimate")
local originalDuration, originalTime = E.duration, getGameTime
local minutes = 59.9
getGameTime = function() return {getMinutesPerDay = function() return 1440 end} end
E.duration = function() return minutes * 60000 end
local head = {getCondition = function() return 100 end, getModData = function() return {} end}
local battery = {getCondition = function() return 100 end, getCurrentUsesFloat = function() return 1 end}
local contents, stats = {head = head, battery = battery}, {batteryPercent = .1}
check(string.find(B.battery(contents, stats), "59.9 in-game minutes", 1, true), "Below one hour uses minutes")
minutes = 60
check(string.find(B.battery(contents, stats), "1.0 in-game hours", 1, true), "One-hour boundary uses hours")
minutes = 360
check(string.find(B.battery(contents, stats), "6.0 in-game hours", 1, true), "Long battery estimates use hours")
check(stats.batteryPercent == .1, "Duration formatting never changes consumption")
E.duration, getGameTime = originalDuration, originalTime
local Reveal = require("OMHTT/TurretPackReveal")
ZombRandFloat = function() return .25 end
local originalManager, originalScripts = getTextManager, getScriptManager
getScriptManager = function() return {getItem = function(_, kind) return {
    getDisplayName = function() return kind end, getNormalTexture = function() return nil end}
end} end
getTextManager = function() return {getFontHeight = function() return 16 end,
    WrapText = function(_, font, text, width) return text end} end
instanceItem = function(kind)
    local value = item(kind)
    function value:getTex() return nil end
    function value:getDisplayName() return self.kind end
    return value
end
function player:getPlayerNum() return 0 end
local drawCount = 0
function Reveal:drawText() drawCount = drawCount + 1 end
function Reveal:drawTextCentre() drawCount = drawCount + 1 end
function Reveal:drawRect() end
function Reveal:drawRectBorder() end
function Reveal:setStencilRect() end
function Reveal:clearStencilRect() end
local originalNew, originalPrerender = ISPanel.new, ISPanel.prerender
ISPanel.prerender = function() end
ISPanel.new = function(self, x, y, width, height) return setmetatable({x=x,y=y,width=width,height=height}, {__index=self}) end
function Reveal:initialise() end
function Reveal:addChild() end
function Reveal:addToUIManager() end
function Reveal:removeFromUIManager() end
local panel = Reveal.show(player, rewards)
panel:prerender()
check(not panel.finished and #panel.reels == 3 and #panel.reels[1] == 16, "Three bounded visual reels")
panel.started = testMillis - 4000; panel:prerender()
check(panel.finished and drawCount > 0 and panel.reels[1][14].lines[1] == rewards[1]:getFullType(), "Finished reveal lands on the already granted reward")
panel.collectButton.callback(panel)
for i = 1, #rewards do check(inventory:contains(rewards[i]), "Collect preserves previously granted rewards") end
local Action = require("OMHTT/TurretPackAction")
local actionPack = item(P.TYPE)
actionPack.data.OMHTTPackRewards = {"Regulator", "Regulator", "CapacityLarge"}
inventory:AddItem(actionPack)
local action = Action:new(player, actionPack)
check(not action:complete() and inventory:contains(actionPack), "Opening cannot complete before two seconds")
action.elapsed = 2
check(action:complete() and not inventory:contains(actionPack), "Completed action grants before reveal")
check(not action:complete(), "Timed action duplicate completion blocked")
getTextManager, getScriptManager = originalManager, originalScripts
ISPanel.new, ISPanel.prerender = originalNew, originalPrerender
instanceItem, ZombRand, ZombRandFloat = oldFactory, oldRoll, oldFloat
for key in pairs(settings) do settings[key] = nil end
for key, value in pairs(oldSettings) do settings[key] = value end
P.pool()
