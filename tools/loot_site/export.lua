require("Items/Distributions")
require("Items/ProceduralDistributions")
local function quote(s)
    return '"' .. string.gsub(string.gsub(string.gsub(string.gsub(tostring(s), '\\', '\\\\'), '"', '\\"'), '\n', '\\n'), '\r', '') .. '"'
end
local function encode(v)
    local kind = type(v)
    if kind == "string" then return quote(v) end
    if kind == "number" or kind == "boolean" then return tostring(v) end
    if kind ~= "table" then return "null" end
    local out = {}
    if #v > 0 then
        for i = 1, #v do out[#out + 1] = encode(v[i]) end
        return "[" .. table.concat(out, ",") .. "]"
    end
    for k, value in pairs(v) do out[#out + 1] = quote(k) .. ":" .. encode(value) end
    return "{" .. table.concat(out, ",") .. "}"
end
local function export()
    local definitions = require("OMHTT/LootDefinitions")
    local wanted = {}
    for i = 1, #definitions.POOLS do wanted[definitions.POOLS[i]] = true end
    local routes, pools, explicit = {}, {}, {}
    for room, distribution in pairs(SuburbsDistributions) do
        if type(distribution) == "table" then
            explicit[room] = {}
            for container, rule in pairs(distribution) do
                if type(rule) == "table" then explicit[room][container] = true end
                if type(rule) == "table" and rule.procList then
                    local eligible = false
                    for i = 1, #rule.procList do
                        if wanted[rule.procList[i].name] then eligible = true end
                    end
                    if eligible then
                        routes[#routes + 1] = {room = room, container = container, rules = rule.procList}
                    end
                end
            end
        end
    end
    for name in pairs(wanted) do pools[name] = ProceduralDistributions.list[name] end
    local writer = getFileWriter("loot-routes.json", true, false)
    writer:write(encode({requiredModId = "OneMoreHorde_Turrets", routes = routes, pools = pools, explicit = explicit, definitions = definitions})); writer:close()
    local reader = getFileReader("loot-tiles.txt", false)
    writer = getFileWriter("loot-tile-properties.txt", true, false)
    local tile = reader:readLine()
    local count = 0
    while tile do
        local sprite = getSprite(tile)
        if sprite then
            local props = sprite:getProperties()
            local container = props:get("container")
            if container then
                writer:write(tile .. "\t" .. container .. "\t" .. tostring(props:get("ContainerCapacity") or "") .. "\n")
                count = count + 1
            end
        end
        tile = reader:readLine()
    end
    reader:close(); writer:close()
    print("[OMHTT-LOOT] export-complete routes=" .. #routes .. " containerSprites=" .. count)
end
Events.OnServerStarted.Add(export)
