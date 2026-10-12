local R = require("OMHTT/TurretRarity")
local L = require("OMHTT/LootDefinitions")
local anchors = {20, 16, 12, 8, 5, 2, 1}
local settings = {}
for i = 1, #R.names do settings["RarityWeight" .. R.names[i]] = anchors[i] end
for i = 1, #anchors do
    settings.LootRateRange = anchors[i] / L.WEIGHTS.Range
    R.refresh(settings)
    check(R.get("Range").band == i, "Exact custom anchor selects its named band")
    check(R.get("Range").surcharge == R.surcharges[i], "Custom band sets battery surcharge")
    check(math.abs(R.get("Range").r - R.stops[i][1] / 255) < .000001, "Custom band uses shared color")
end
for i = 1, 6 do
    local midpoint = math.sqrt(anchors[i] * anchors[i + 1])
    settings.LootRateRange = midpoint / L.WEIGHTS.Range
    R.refresh(settings)
    check(R.get("Range").band == i + 1, "Geometric tie selects rarer band")
    settings.LootRateRange = midpoint * 1.00001 / L.WEIGHTS.Range
    R.refresh(settings)
    check(R.get("Range").band == i, "Above geometric midpoint selects commoner band")
end
settings.RarityWeightMythic = 2
R.refresh(settings)
check(R.anchorError ~= nil, "Duplicate custom anchors report fallback")
settings.RarityWeightMythic = 0
R.refresh(settings)
check(R.anchorError ~= nil, "Partial custom anchors report fallback")
R.refresh({})
local expected = R.get("Range").band
for i = 1, #R.names do settings["RarityWeight" .. R.names[i]] = 0 end
settings.LootRateRange = nil
R.refresh(settings)
check(R.anchorError == nil and R.get("Range").band == expected, "Unset anchors retain old automatic rarity")
R.refresh(SandboxVars.OMHTurretsTraps or {})
