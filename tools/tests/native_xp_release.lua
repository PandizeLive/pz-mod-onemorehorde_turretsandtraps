local function run()
    assert(isServer() and not isClient())
    assert(OneMoreHordeTraitShop.VERSION == "0.9.1")
    assert(require("OMH_Config").VERSION == "0.6.16.6")
    assert(require("OMHTT/Foundation").VERSION == "0.2.68")
    assert(OMHTS_DefenseCredit.API_VERSION == 1)
    assert(type(OneMoreHordeDifficultyRuntime.traitShopIdentityStatus) == "function")
    local State = require("OMHTS_State")
    local Rewards = require("OMHTS_Rewards")
    local Pools = require("OMHTS_DefenseRewards")
    local store = ModData.getOrCreate("OMHTS_XPReleaseProbe")
    assert(State.initialize(store) and Rewards.initialize(store) and Pools.initialize(store))
    if EXPECT_READ then
        local record = store.accounts.Offline
        assert(record and store.defense.pending.Offline.amount == 12.5)
        assert(store.defense.encounters.Victim.owner == "Owner")
        assert(store.defense.encounters.Victim.assists.Offline == record.life.id)
        assert(store.rewards.cooldowns.Offline.Victim == 58)
        assert(Pools.attach(store, "Offline", record, "Offline", "Offline"))
        assert(record.life.xp == 12.5 and not store.defense.pending.Offline)
        assert(not Pools.attach(store, "Offline", record, "Offline", "Offline"))
        assert(record.life.xp == 12.5)
    else
        assert(not store.accounts.Offline, "Use a fresh diagnostic world for the write pass")
        local record = State.attach(store, "Offline", 991, 0)
        Pools.attach(store, "Offline", record, "Offline", "Offline")
        local member = {key="Offline",username="Offline",life=record.life.id,online=false,unofficial=true}
        Pools.settle(store, Pools.plan(25,.5,{member},{},false), "Victim", 10, 48)
        local encounter = Pools.encounter(store,"Victim",1)
        encounter.owner,encounter.attacker="Owner","none"
        encounter.assists.Offline=record.life.id
        assert(store.defense.pending.Offline.amount==12.5 and record.life.xp==0)
    end
    print("[OMHTT-XPRelease] PASS mode=" .. (EXPECT_READ and "read" or "write") .. " versions=0.2.68/0.9.1/0.6.16.6 clients=0")
end
Events.OnServerStarted.Add(run)
