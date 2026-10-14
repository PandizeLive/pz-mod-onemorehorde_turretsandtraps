local A = require("OMHTT/TurretAmmo")
local V = require("OMHTT/TurretVoid")
local oldScripts, oldCategory, oldInstance = getScriptManager, WeaponCategory, instanceof
WeaponCategory = {SPEAR = "spear"}
local reads = 0
local scripts = {
    ["Base.SpearCrafted"] = {category = "spear", damage = 2},
    ["Mod.LongSpear"] = {category = "spear", damage = 4},
    ["Mod.WeakSpear"] = {category = "spear", damage = 1},
    ["Mod.SpearNamedHat"] = {category = "clothing", damage = 0},
}
getScriptManager = function() return {getItem = function(_, kind)
    reads = reads + 1
    local script = scripts[kind]
    if not script then return nil end
    return {containsWeaponCategory = function(_, category) return script.category == category end,
        getMinDamage = function() return script.damage / 2 end,
        getMaxDamage = function() return script.damage / 2 end}
end} end
instanceof = function() return false end
local function item(kind, condition)
    local result = {data = {}, kind = kind, condition = condition or 10}
    function result:getFullType() return self.kind end
    function result:getModData() return self.data end
    function result:getCondition() return self.condition end
    function result:getContainer() return self.container end
    function result:isFavorite() return self.favorite == true end
    function result:getMinDamage() return scripts[self.kind].damage / 2 end
    function result:getMaxDamage() return scripts[self.kind].damage / 2 end
    function result:getAge() return self.age or 50 end
    function result:isCooked() return self.cooked == true end
    function result:isBurnt() return self.burnt == true end
    return result
end
local source = {items = {}}
function source:contains(value) return self.items[value] == true end
function source:add(value) self.items[value], value.container = true, self end
function source:Remove(value)
    if self.blocked then return end
    self.items[value], value.container = nil, nil
end
check(A.family("Mod.LongSpear") == "spear", "Native spear category discovers mod ammo")
local before = reads
for i = 1, 1000 do check(A.family("Mod.LongSpear") == "spear", "Cached spear classification") end
check(reads == before, "No repeated script discovery on cached ammo")
check(A.family("Mod.SpearNamedHat") == nil, "Names do not confer spear compatibility")
A.overrides["Mod.LongSpear"] = false
check(A.family("Mod.LongSpear") == nil, "Explicit rejection overrides cached native discovery")
A.overrides["Mod.LongSpear"] = nil
check(A.family("Base.Potato") == "potato" and A.family("Base.SweetPotato") == "potato", "Whole native potato family")
check(A.family("Base.PotatoPancakes") == nil and A.family("Base.CannedPotato") == nil, "Prepared dishes are not implicitly ammunition")
check(A.describe(item("Mod.LongSpear")).multiplier == 1.25, "Double donor damage adds 25 percent")
check(A.describe(item("Mod.WeakSpear")).multiplier == .875, "Half donor damage contributes negative 12.5 percent")
check(A.describe(item("Base.SpearCrafted", 0)) == nil, "Broken spears cannot be converted")
local module = item(V.TYPE)
check(V.count(module) == 0 and module.data.OMHTTVoid == nil, "Reading an empty module does not create state")
local potato = item("Base.Potato")
potato.age, potato.cooked, potato.burnt = 100, true, true
source:add(potato)
source.blocked = true
check(not V.deposit(module, potato, source) and V.count(module) == 0, "Failed native removal never credits Void")
source.blocked = false
potato.favorite = true
check(not V.deposit(module, potato, source) and source:contains(potato), "Favorite ammo remains physical")
potato.favorite = false
check(V.deposit(module, potato, source) and not source:contains(potato), "Conversion removes the exact physical source")
check(not V.deposit(module, potato, source) and V.count(module) == 1, "Duplicate conversion cannot create ammo")
local _, food = V.count(module)
check(food.age == 100 and food.cooked and food.burnt, "Rotten and prepared-state metadata survive conversion")
local started = realMillis()
for i = 1, 600 do
    local round = item("Base.Bullets9mm")
    source:add(round)
    check(V.deposit(module, round, source), "Bulk round converts once")
end
local elapsed = realMillis() - started
check(V.count(module) == 601 and #V.data(module).groups == 2, "600 identical rounds occupy one quality group")
local _, bullets = V.count(module, nil, "Base.Bullets9mm")
local copy = {}
for key, value in pairs(bullets) do copy[key] = value end
check(not V.spend(module, copy, 1), "Unbound descriptor cannot debit a module")
check(not V.spend(module, bullets, 601) and bullets.count == 600, "Overdraft is atomic")
check(not V.spend(module, bullets, math.huge) and not V.spend(module, bullets, 0/0), "Nonfinite debit is rejected")
local charged, cost = V.consume(module, bullets, 1, 2)
check(charged and cost == 0 and V.data(module).debt[bullets.type] == .5, "First conserved shot retains fractional debt on module")
module.data = nativeRoundTrip(module.data)
local restoredCount, restored = V.count(module, nil, "Base.Bullets9mm")
check(restoredCount == 600 and V.data(module).debt[restored.type] == .5, "Native Kahlua persistence retains count and fractional debt")
check(not V.spend(module, bullets, 1), "Stale pre-load binding cannot spend restored storage")
charged, cost = V.consume(module, restored, 1, 2)
check(charged and cost == 1 and restored.count == 599 and V.data(module).debt[restored.type] == 0, "Second conserved shot after load charges one round")
local other = item(V.TYPE)
check(V.count(other) == 0, "Another module has no access to stored ammunition")
local spear = item("Mod.LongSpear", 7)
source:add(spear)
check(V.deposit(module, spear, source), "Modded spear converts")
local ballista = item("Base.OMHTTTurretBallista")
local count, donor = V.count(module, ballista)
check(count == 1 and donor.condition == 7 and donor.multiplier == 1.25, "Compatible count retains donor condition and attenuated damage")
scripts["Mod.LongSpear"], A.cache["Mod.LongSpear"] = nil, nil
check(V.count(module, ballista) == 0 and V.count(module) == 601, "Unavailable mod ammo is retained, not deleted or fired")
local stale = item(V.TYPE)
stale.data.OMHTTVoid = {schema = 99, untouched = true}
local round = item("Base.Bullets9mm")
source:add(round)
check(not V.deposit(stale, round, source) and source:contains(round) and stale.data.OMHTTVoid.untouched, "Unknown schema is preserved without consuming input")
for _, mode in pairs({"client", "server"}) do
    testMode = mode
    local revision = V.data(module).revision
    check(not V.deposit(module, round, source) and source:contains(round), "MP conversion remains guarded: " .. mode)
    check(not V.spend(module, restored, 1) and not V.consume(module, restored, 1, 2), "MP consumption remains guarded: " .. mode)
    check(V.data(module).revision == revision and V.data(other, true) == nil, "MP paths do not initialize or mutate storage: " .. mode)
end
testMode = "sp"
A.cache = {}
getScriptManager, WeaponCategory, instanceof = oldScripts, oldCategory, oldInstance
testVoidAudit = "conversion=600 groups=2 mockBatchMs=" .. elapsed .. " nativeTablePersistence=pass mpMutationGuards=pass integration=pending"
