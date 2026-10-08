if isClient() or isServer() then return end
local B = require("OMHTT/BarbSections")
local C = require("OMHTT/BarbContact")
local S = require("OMHTT/BarbSupport")
local F = require("OMHTT/Foundation")
local Damage = require("OMHTT/Damage")
local edge = {}

---@param zombie IsoZombie Updated zombie
---@return nil
function B.zombie(zombie)
    if #B.order == 0 or not B.enabled() or zombie:isDead() then return end
    local square = zombie:getSquare()
    if not square then return end
    local bucket = B.nearby[F.key(square:getX(), square:getY(), square:getZ())]
    if not bucket then return end
    local data = zombie:getModData()
    local state = data.OMHTTBarbContact
    if not state then
        state = {}
        data.OMHTTBarbContact = state
    end
    local interval = B.option("Interval", 2, .1, 60) * 1000
    C.step(state, B.time, B.session, false, interval)
    if state.nextHit and B.time < state.nextHit then return end
    local selected, source = nil, nil
    for id in pairs(bucket) do
        local node = B.nodes[id]
        if node then
            local _, host, attachment, status = B.resolve(node.record)
            if status == "active" and S.edge(host, node.record.north, node.record.side, edge)
                and C.touching(edge, zombie:getX(), zombie:getY(), zombie:getZ(), zombie:getWidth()) then
                if not selected or id < selected.id then
                    selected, source = node.record, attachment
                end
            end
        end
    end
    if C.step(state, B.time, B.session, selected ~= nil, interval) then
        local damage = Damage.apply(zombie, B.option("Damage", 10, 0, 1000) / 100, selected.id, "barbs", nil, nil)
        if S.wear(source, damage) then
            B.retire(selected)
        end
    end
end

Events.OnZombieUpdate.Add(B.zombie)
