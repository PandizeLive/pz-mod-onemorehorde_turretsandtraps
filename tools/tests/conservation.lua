local C = require("OMHTT/TurretConservation")
local Cycle = require("OMHTT/TurretCycle")
local S = require("OMHTT/TurretStats")
local B = require("OMHTT/TurretBenefits")
for copies = 0, 16 do
    for cost = 1, 3 do
        local head, total = {}, 0
        for shot = 1, (copies + 1) * 20 do
            total = total + C.consume(head, cost, copies + 1)
            check(total == math.floor(shot * cost / (copies + 1) + .000001), "Conservation discounts exact existing charge without fractional items")
        end
        check(total == cost * 20, "Conservation does not drift over complete cycles")
    end
end
local state = {loaded = 1, impactReady = true}
local config = {magazine = 1, conservation = 2, cooldown = 100, reload = 100}
local spent = C.consume(state, 1, config.conservation)
Cycle.consume(state, 1 - spent, config, 1000, spent)
check(spent == 0 and state.loaded == 1 and not state.impactReady, "Saved last round remains ready without rearming Impact")
spent = C.consume(state, 1, config.conservation)
Cycle.consume(state, 1 - spent, config, 1100, spent)
check(spent == 1 and state.loaded == 0, "Second last-round use consumes the real item")
local saved = {conservationDebt = .5}
check(C.consume(saved, 1, 1) == 1 and saved.conservationDebt == .5, "Removing Conservation preserves prior progress")
check(C.consume(saved, 1, 2) == 1 and saved.conservationDebt == 0, "Reinstalling cannot reset progress")
local debt = {conservationDebt = .75}
check(C.consume(debt, 3, 2) == 2 and debt.conservationDebt == .25, "Splitter carries fractional debt across configuration changes")
local stats = S.resolve({active = {Execute = 3, Splitter = 2, Conservation = 2, Piercing = 1}, powerLoad = 8})
local rows = B.rows({active = {Execute = 3, Splitter = 2, Conservation = 2, Piercing = 1}, powerLoad = 8,
    moduleDetails = {Execute = {count = 3}, Splitter = {count = 2}, Conservation = {count = 2}, Piercing = {count = 1}, Impact = {count = 1}}}, stats)
check(#rows == 5 and stats.conservation == 3, "Grouped list includes inactive and broken copies")
for i = 1, #rows do
    local row = rows[i]
    check(row.details ~= "" and row.effect ~= "", "Every grouped module has a short effect and individual details")
    if row.name == "Impact" then check(row.inactive, "Broken module marked inactive") end
    if row.name == "Piercing" then check(not row.inactive, "Potato Piercing is now supported") end
end
check(B.number(.23436) == "0.23" and B.number(.005) == "0.0050", "Display rounding preserves small draw readability")
