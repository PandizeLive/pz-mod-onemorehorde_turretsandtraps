return function(player, turret)
    local T = require("OMHTT/Turret")
    local G = require("OMHTT/Firearms")
    local State = require("OMHTT/TurretItemState")
    local A = require("OMHTT/TurretExpansionAction")
    local saved = SandboxVars.OMHTurretsTraps
    SandboxVars.OMHTurretsTraps = {FirearmAmmoCapacity=2,CapacitySmallAmmoBonus=0,CapacitySmallModuleBonus=0}
    local inventory, storage = player:getInventory(), turret:getContainer()
    local state, square = T.state(turret), turret:getSquare()
    local oldPower = state.powered
    state.powered = false
    local gun = storage:AddItem("Base.Pistol")
    gun:setContainsClip(true);gun:setCurrentAmmoCount(10);gun:setRoundChambered(true)
    local oldKit = storage:AddItem(T.TYPES.CapacityLarge)
    local newKit = inventory:AddItem(T.TYPES.CapacitySmall)
    local modules = {}
    for _, name in pairs({"RapidFire","Velocity","Siphon","Grid","Void"}) do modules[#modules+1]=storage:AddItem(T.TYPES[name]) end
    T.rememberModules(storage,modules)
    for i=1,4 do storage:AddItem("Base.Bullets9mm") end
    State.set(gun,"feed",2)
    local cycle = G.state(gun)
    cycle.conservationDebt,cycle.reloadReady,cycle.rackReady=.37,100000,100000
    local final = A:new(player,turret,newKit,oldKit,state.id,nil,true)
    local batch = A:new(player,turret,newKit,oldKit,state.id,nil,false)
    OMHTT_NativeExpansionAction=final
    OMHTT_NativeExpansionNetwork=NetTimedAction.new()
    OMHTT_NativeExpansionNetwork:set(player,final)
    local projected,excess=final:projection()
    assert(excess==13 and projected.activeCapacity==2,"Native kit projection double-counted extended magazine")
    assert(not final:complete() and storage:contains(oldKit),"Native excess-ammo exchange bypassed evacuation")
    -- A zero-capacity native fixture exercises the real full-inventory fallback.
    local oldCapacity=inventory:getCapacity()
    inventory:setCapacity(0)
    assert(not inventory:hasRoomFor(player,oldKit),"Native overflow fixture is not full")
    local before=square:getWorldObjects():size()
    assert(batch:complete() and not batch:complete() and storage:contains(oldKit),"Native bounded batch/replay failed")
    assert(G.loaded(gun)==2 and T.contents(storage).reserveAll==0 and State.get(gun,"feed")==nil,"Native loaded/chamber/extended rounds were lost or duplicated")
    assert(cycle.conservationDebt==.37 and not cycle.reloadReady and not cycle.rackReady,"Native spill reset debt or retained stale loading deadlines")
    assert(final:complete() and not final:complete() and storage:contains(newKit) and not storage:contains(oldKit),"Native final kit exchange/replay failed")
    assert(square:getWorldObjects():size()==before+14,"Native floor fallback did not create thirteen rounds plus exact old kit")
    local foundKit,rounds=false,0
    for i=before,square:getWorldObjects():size()-1 do
        local v=square:getWorldObjects():get(i):getItem()
        if v==oldKit then foundKit=true end
        if v:getFullType()=="Base.Bullets9mm" then rounds=rounds+1 end
    end
    assert(foundKit and rounds==13,"Native fallback changed kit identity or ammo quantity")
    local summary=T.contents(storage)
    assert(summary.modules==5 and summary.active.RapidFire==1 and summary.active.Velocity==1
        and not summary.active.Siphon and not summary.active.Grid and not summary.void,"Native inactive modules still supply gameplay effects")
    require("OMHTT/TurretAuthority").publish(turret,false)
    assert(turret:getModData().OMHTTTurret.moduleSlot1==modules[1]:getID(),"Activation order missing from network snapshot")
    inventory:setCapacity(oldCapacity)
    storage:Remove(gun);storage:Remove(newKit)
    for i=1,#modules do storage:Remove(modules[i]) end
    T.rememberModules(storage)
    state.powered=oldPower
    SandboxVars.OMHTurretsTraps=saved
    require("OMHTT/TurretWorld").refresh(turret)
    print("[OMHTT-C444] native kit=exact overflow=13 floor=14 inactive=filtered debt=preserved feed=conserved replay=blocked")
end
