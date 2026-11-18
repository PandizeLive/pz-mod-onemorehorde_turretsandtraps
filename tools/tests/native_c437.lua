local M = require("OMHTT/TurretManuals")
return function(player)
    local gun = instanceItem("Base.Pistol")
    assert(not M.canMount(player, gun), "Unlearned player can mount a firearm")
    for i = 1, #M.definitions do
        local row = M.definitions[i]
        local item = instanceItem(row.item)
        assert(item and item:getLearnedRecipes():size() == #row.recipes, "Manual script recipes")
        player:ReadLiterature(item)
        for j = 1, #row.recipes do
            assert(player:getKnownRecipes():contains(row.recipes[j]), "Native reading did not teach " .. row.recipes[j])
        end
    end
    assert(M.canMount(player, gun), "Native Firearms knowledge did not unlock mounting")
    local trait = CharacterTraitDefinition.getCharacterTraitDefinition(OMHTTTurretSpecialist)
    assert(trait and trait:getCost() == 2 and trait:getGrantedRecipes():size() == 6, "Specialist registration")
    assert(trait:getXpBoosts():isEmpty(), "Specialist grants unintended XP")
    local specialist = IsoPlayer.new(getCell())
    local traits = ArrayList.new()
    traits:add(OMHTTTurretSpecialist)
    specialist:applyTraits(traits)
    specialist:applyCharacterTraitsRecipes()
    for i = 0, trait:getGrantedRecipes():size() - 1 do
        assert(specialist:getKnownRecipes():contains(trait:getGrantedRecipes():get(i)), "Native trait knowledge")
    end
    assert(specialist:getInventory():getItems():isEmpty(), "Specialist grants unintended gear")
    OMHTT_C437ManualPlayer, OMHTT_C437Specialist = player, specialist
    local pools = ProceduralDistributions.list
    for _, name in pairs(M.literature) do
        local pool = pools[name]
        assert(pool, "Unknown literature distribution " .. name)
        local found = 0
        for i = 1, #pool.items, 2 do
            for j = 1, #M.definitions do
                if pool.items[i] == M.definitions[j].item then found = found + 1 end
            end
        end
        assert(found == 5, "Manuals missing from " .. name)
    end
    local light = IsoLightSource.new(0, 0, 0, .1, .2, .3, 3)
    light:setR(.2); light:setG(.3); light:setB(.4); light:setActive(false)
    print("[OMHTT-C437] native manuals=5 read=6 firearmGate=pass traitCost=2 traitKnowledge=6 gear=0 xpBoosts=0 literaturePools=5 lightAPI=pass")
end
