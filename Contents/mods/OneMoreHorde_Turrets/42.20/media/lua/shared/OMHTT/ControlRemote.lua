local existing = rawget(_G, "OMHTT_ControlRemote")
if existing then return existing end
local A = require("OMHTT/ControlAccess")
local R = {requests = setmetatable({}, {__mode = "k"}), rates = setmetatable({}, {__mode = "k"}), serial = 0}
OMHTT_ControlRemote = R
R.MODULE = "OMHTT_ControlRemote"

---@param player IsoPlayer Operator
---@param controller IsoObject? Controller
---@param target IsoObject? Assigned device
---@return boolean valid
function R.valid(player, controller, target)
    local host, state = A.state(controller), A.state(target)
    return host ~= nil and state ~= nil and host.kind == "Controller" and host.powered == true
        and controller:getHealth() > 0 and target:getHealth() > 0 and state.controller == host.id
        and A.near(player, controller) and A.range(controller, target)
        and A.visible(controller, target) and A.write(player, host)
end

---@param player IsoPlayer Operator
---@param controller IsoObject Controller
---@param target IsoObject Assigned device
---@return boolean requested
function R.request(player, controller, target)
    if not R.valid(player, controller, target) then return false end
    if not isClient() then
        A.session(player, controller, target)
        require("OMHTT/ControlWorld").publish(target)
        return true
    end
    local entries = R.requests[player]
    if not entries then
        entries = {}
        R.requests[player] = entries
    end
    local now, record, slot = getTimestampMs(), nil, 1
    for i = 1, #entries do
        local entry = entries[i]
        if entry.controller == controller and entry.target == target then
            record, slot = entry, i
            break
        end
        if entry.sent < entries[slot].sent then
            slot = i
        end
    end
    if record and now >= record.sent and now < record.sent + 5000 then return true end
    if not record and #entries < 8 then
        slot = #entries + 1
    end
    R.serial = R.serial % 2147483647 + 1
    record = {controller = controller, target = target, sent = now, serial = R.serial,
        hostId = A.state(controller).id, targetId = A.state(target).id}
    entries[slot] = record
    sendClientCommand(player, R.MODULE, "Renew", {controller = record.hostId, target = record.targetId,
        serial = record.serial, player = player:getPlayerNum()})
    return true
end

---@param module string Namespace
---@param command string Operation
---@param player IsoPlayer Authenticated sender
---@param args table? Request
---@return nil
function R.command(module, command, player, args)
    if not isServer() or module ~= R.MODULE or command ~= "Renew" or type(args) ~= "table" then return end
    if not player or player:isDead() or type(args.controller) ~= "string" or #args.controller > 80
        or type(args.target) ~= "string" or #args.target > 80 or type(args.serial) ~= "number"
        or args.serial ~= math.floor(args.serial) or args.serial < 1 or args.serial > 2147483647
        or type(args.player) ~= "number" or args.player ~= math.floor(args.player) or args.player < 0 or args.player > 3 then return end
    local now, rate = getTimestampMs(), R.rates[player]
    if not rate or now < rate.start or now >= rate.start + 1000 then
        rate = {start = now, count = 0}
        R.rates[player] = rate
    end
    if rate.count >= 8 then return end
    rate.count = rate.count + 1
    local world = require("OMHTT/ControlWorld")
    local controller, target = world.objects[args.controller], world.objects[args.target]
    local granted = R.valid(player, controller, target)
        and A.state(controller).id == args.controller and A.state(target).id == args.target
    if granted then
        A.session(player, controller, target)
        world.publish(target)
    end
    sendServerCommand(player, R.MODULE, "Renewed", {controller = args.controller, target = args.target,
        serial = args.serial, player = args.player, granted = granted})
end

---@param module string Namespace
---@param command string Response
---@param args table? Server response
---@return nil
function R.response(module, command, args)
    if not isClient() or module ~= R.MODULE or command ~= "Renewed" or type(args) ~= "table"
        or type(args.player) ~= "number" or args.player ~= math.floor(args.player) or args.player < 0 or args.player > 3 then return end
    local player = getSpecificPlayer(args.player)
    local entries = player and R.requests[player]
    if not entries then return end
    local now = getTimestampMs()
    for i = 1, #entries do
        local entry = entries[i]
        if entry.serial == args.serial and entry.hostId == args.controller and entry.targetId == args.target
            and now >= entry.sent and now < entry.sent + 5000 then
            if args.granted == true and R.valid(player, entry.controller, entry.target)
                and A.state(entry.controller).id == entry.hostId and A.state(entry.target).id == entry.targetId then
                A.session(player, entry.controller, entry.target)
            else
                local sessions = A.remote[player]
                if sessions then
                    sessions[entry.target] = nil
                end
            end
            return
        end
    end
end

if isServer() then
    Events.OnClientCommand.Add(R.command)
elseif isClient() then
    Events.OnServerCommand.Add(R.response)
end
return R
