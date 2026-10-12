local P = require("OMHTT/TurretModulePack")
local L = require("OMHTT/LootDefinitions")
local T = require("OMHTT/Turret")
local settings = SandboxVars.OMHTurretsTraps
settings.TurretsEnabled, settings.PotatoTurret = true, true
settings.ModuleLootRate, settings.PackZombieChance = 1, 15
for name in pairs(L.WEIGHTS) do settings["LootRate" .. name] = nil end
testMode = "sp"
local drops, rolls, calls = 0, 0, 0
local inventory = {AddItem = function() drops = drops + 1 end}
local zombie = {data = {}, getInventory = function() return inventory end}
function zombie:getModData() return self.data end
ZombRand = function() local value = rolls % 10000; rolls = rolls + 1; return value end
local started = realMillis()
for i = 1, 10000 do
    zombie.data = {}
    P.onDeath(zombie)
    P.onDeath(zombie)
end
local deathMs = realMillis() - started
check(drops == 1500 and rolls == 10000, "10,000 unique death rolls produce exactly 1,500 packs on exhaustive RNG boundaries; repeats add none")
for name in pairs(L.WEIGHTS) do settings["LootRate" .. name] = 0 end
zombie.data = {}
P.onDeath(zombie)
local emptyEntries, emptyTotal = P.pool()
check(drops == 1501 and #emptyEntries == 0 and emptyTotal == 0, "Reproduced: empty reward pool still allows corpse packs")
for name in pairs(L.WEIGHTS) do settings["LootRate" .. name] = nil end
local function item(kind)
    local value = {kind = kind, data = {}}
    function value:getFullType() return self.kind end
    function value:getModData() return self.data end
    function value:getContainer() return self.container end
    function value:getDisplayName() return self.kind end
    function value:getTex() return nil end
    return value
end
instanceItem = item
ZombRandFloat = function() return .3 end
local inv = {items = {}}
function inv:contains(value) return self.items[value] == true end
function inv:AddItem(value)
    calls = calls + 1
    if calls == self.failAt then return nil end
    self.items[value], value.container = true, self
end
function inv:Remove(value)
    if self.blockRemove == value then return end
    self.items[value], value.container = nil, nil
end
local player = {getInventory = function() return inv end, isDead = function() return false end, getPlayerNum = function() return 0 end}
for failAt = 2, 3 do
    local pack = item(P.TYPE)
    inv:AddItem(pack)
    calls, inv.failAt = 0, failAt
    check(P.open(player, pack) == nil and inv:contains(pack), "Partial grant preserves pack")
    local count = 0
    for _ in pairs(inv.items) do count = count + 1 end
    check(count == 1, "Partial grant rolls back already inserted rewards")
    inv.failAt = nil
    inv:Remove(pack)
end
local pack = item(P.TYPE)
inv:AddItem(pack)
inv.blockRemove = pack
check(P.open(player, pack) == nil and inv:contains(pack), "Failed pack removal preserves original")
local count = 0
for _ in pairs(inv.items) do count = count + 1 end
check(count == 1, "Failed pack removal rolls back rewards")
inv.blockRemove = nil
local rewards = P.open(player, pack)
check(rewards and #rewards == 3, "Preserved pack can complete safely on retry")

local creates, wraps, fontHeight, screenHeight = 0, 0, 16, 720
instanceItem = function(kind) creates = creates + 1; return item(kind) end
getTextManager = function() return {
    getFontHeight = function() return fontHeight end,
    WrapText = function(_, font, text) wraps = wraps + 1; return text end,
} end
getPlayerScreenWidth = function() return 1280 end
getPlayerScreenHeight = function() return screenHeight end
getPlayerScreenLeft = function() return 0 end
getPlayerScreenTop = function() return 0 end
local Reveal = require("OMHTT/TurretPackReveal")
ISPanel.new = function(self, x, y, width, height) return setmetatable({x=x,y=y,width=width,height=height}, {__index=self}) end
ISPanel.prerender = function() end
local panel = Reveal.show(player, rewards)
local openCreates, openWraps = creates, wraps
started = realMillis()
for i = 1, 300 do testMillis = testMillis + 16; panel:prerender() end
local renderMs = realMillis() - started
check(creates == openCreates and wraps == openWraps, "Reveal frames do not instantiate items or wrap text")
check(openCreates == 29 and openWraps == 29, "Reveal prepares all 29 display items once per opening")
screenHeight = 360
local small = Reveal.show(player, rewards)
check(small.y < 0 and small.y + small.height > screenHeight, "Reproduced: 360-pixel split viewport overflows vertically")
local overflow = small.height - screenHeight
local U = require("OMHTT/TurretItemTooltip")
local tip = {getLineSpacing = function() return 18 end, getFont = function() return UIFont.Small end}
local tooltip = {tooltip=tip, backgroundColor={a=1,r=0,g=0,b=0}, borderColor={a=1,r=1,g=1,b=1},
    getHeight=function() return 100 end, getWidth=function() return 250 end, getY=function() return 0 end,
    setHeight=function() end, drawRect=function() end, drawRectBorder=function() end, drawText=function() end}
wraps = 0
for i = 1, 600 do U.footer(tooltip, "Regulator") end
check(wraps == 600, "Reproduced: unchanged tooltip wraps text on every render")
testPackAudit = "deaths=10000 repeats=10000 packs=1500 emptyPoolCorpseDrop=true mockDeathBatchMs=" .. deathMs
    .. " partialGrantRollback=pass removeRollback=pass revealCreateItems=" .. openCreates
    .. " revealFrames=300 newFrameItems=0 newFrameWraps=0 mockRenderBatchMs=" .. renderMs
    .. " smallViewportOverflowPx=" .. overflow .. " tooltipFrames=600 tooltipWraps=" .. wraps
