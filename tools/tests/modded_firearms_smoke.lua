Events.OnServerStarted.Add(function()
    local T = require("OMHTT/Turret")
    local G = require("OMHTT/Firearms")
    local A = require("OMHTT/FirearmAccuracy")
    local Class = require("OMHTT/FirearmClass")
    SandboxVars.OMHTurretsTraps.FirearmTurrets = true
    SandboxVars.OMHTurretsTraps.FirearmAccuracyMultiplier = 1
    local all = getScriptManager():getAllItems()
    local accepted, skipped, rounds = 0, 0, 0
    local expected = { ["Base.AssaultRifle"] = false, ["Base.AssaultRifle2"] = true,
        ["Base.HuntingRifle"] = true, ["Base.Pistol"] = false, ["Base.FN_FAL"] = false,
        ["Base.M60"] = false, ["Base.G3"] = false }
    local checked = {}
    for i = 0, all:size() - 1 do
        local script = all:get(i)
        if script:isRanged() and script:getAmmoType() then
            local gun = instanceItem(script:getFullName())
            local originalMode, originalRecoil, originalRate = gun:getFireMode(), gun:getRecoilDelay(), gun:getCyclicRateMultiplier()
            local evidence = require("OMHTT/FirearmAudit").inspect(script:getFullName())
            assert(evidence.accepted == (G.profile(gun) ~= nil), "Audit/admission mismatch")
            if G.profile(gun) then
                local storage = instanceItem(T.BASE):getInventory()
                storage:AddItem(gun)
                if gun:getMagazineType() then gun:setContainsClip(true) end
                for n = 1, 50 do assert(storage:AddItem(G.ammoType(gun)), "Missing ammo") end
                local contents = T.contents(storage)
                local stats = T.cycleConfig(contents)
                assert(stats.range > 0 and stats.cooldown > 0 and stats.reload >= 0)
                if gun:getFullType() == "Base.M4" or gun:getFullType() == "Base.AssaultRifle" then
                    assert(gun:getFireMode() == "Single", "Fixture must exercise the mod default Single mode")
                    assert(math.abs(stats.cooldown - 1000 / 3 / 1.5 / .75) < .001, "Auto capability must determine modded rifle cadence")
                    local enhanced = require("OMHTT/TurretStats").resolve({head = gun, active = {FiringEnhanced = 1}})
                    assert(math.abs(enhanced.cooldown - 1000 / 3 / 1.5) < .001, "Enhanced native-derived cadence")
                    print("[OMHTT-Modded] cadence=" .. gun:getFullType() .. " normal=" .. stats.cooldown .. " enhanced=" .. enhanced.cooldown)
                end
                local precision = Class.precision(gun)
                assert(A.chance(gun, stats, stats.range, false) == (precision and 80 or 60), "Wrong range accuracy")
                if expected[gun:getFullType()] ~= nil then
                    assert(precision == expected[gun:getFullType()], "Classification mismatch: " .. gun:getFullType())
                    checked[gun:getFullType()] = true
                end
                local time, fired = getTimestampMs(), 0
                for n = 1, 300 do
                    contents = T.contents(storage)
                    local _, status = G.update(contents, stats, time, true)
                    if status == "Ready" then
                        local before = contents.ammo
                        assert(G.consume(contents, stats, time))
                        assert(T.contents(storage).ammo == before - 1, "Ammo conservation failed")
                        fired, rounds = fired + 1, rounds + 1
                        if fired == 3 then break end
                    end
                    time = time + 1000
                end
                assert(fired == 3, "Unable to feed/fire: " .. gun:getFullType())
                assert(gun:getFireMode() == originalMode and gun:getRecoilDelay() == originalRecoil
                    and gun:getCyclicRateMultiplier() == originalRate, "Turret modified handheld timing: " .. gun:getFullType())
                accepted = accepted + 1
                print("[OMHTT-Modded] gun=" .. gun:getFullType() .. " precision=" .. tostring(precision) .. " range=" .. stats.range .. " shots=3")
            else
                skipped = skipped + 1
                print("[OMHTT-Modded] unsupported=" .. gun:getFullType())
            end
        end
    end
    for fullType in pairs(expected) do assert(checked[fullType], "Expected modded fixture missing: " .. fullType) end
    print("[OMHTT-Modded] PASS accepted=" .. accepted .. " skipped=" .. skipped .. " conservedShots=" .. rounds)
end)
