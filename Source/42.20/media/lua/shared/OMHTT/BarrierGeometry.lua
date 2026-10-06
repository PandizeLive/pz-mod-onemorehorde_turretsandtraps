local F = require("OMHTT/Foundation")
local G = {}

---@param x number Edge X
---@param y number Edge Y
---@param z number Floor
---@param north boolean Horizontal world edge
---@param role string Front or cap
---@param nx number Outward normal X
---@param ny number Outward normal Y
---@return table edge
---@nodiscard
function G.edge(x, y, z, north, role, nx, ny)
    return {x = x, y = y, z = z, north = north, role = role, nx = nx, ny = ny,
        key = F.key(x, y, z) .. (north and ":N" or ":W"),
        tx = x + (north and 1 or 0), ty = y + (north and 0 or 1)}
end

---@param record table Two-tile barrier
---@return table fronts Two front edges
---@return table caps Two possible end caps
---@nodiscard
function G.shape(record)
    local nx, ny = F.barrierDirection(record.facing)
    local sx, sy = record.x - ny, record.y + nx
    local left, top = math.min(record.x, sx), math.min(record.y, sy)
    local right, bottom = math.max(record.x, sx) + 1, math.max(record.y, sy) + 1
    local fronts, caps = {}, {}
    if nx == 0 then
        local fy = top
        if ny > 0 then
            fy = bottom
        end
        fronts = {G.edge(left, fy, record.z, true, "front", nx, ny), G.edge(left + 1, fy, record.z, true, "front", nx, ny)}
        caps = {G.edge(left, top, record.z, false, "cap", -1, 0), G.edge(right, top, record.z, false, "cap", 1, 0)}
        caps[1].joinX, caps[1].joinY = left, fy
        caps[2].joinX, caps[2].joinY = right, fy
    else
        local fx = left
        if nx > 0 then
            fx = right
        end
        fronts = {G.edge(fx, top, record.z, false, "front", nx, ny), G.edge(fx, top + 1, record.z, false, "front", nx, ny)}
        caps = {G.edge(left, top, record.z, true, "cap", 0, -1), G.edge(left, bottom, record.z, true, "cap", 0, 1)}
        caps[1].joinX, caps[1].joinY = fx, top
        caps[2].joinX, caps[2].joinY = fx, bottom
    end
    return fronts, caps
end

---@param edge table Native edge
---@param x number Point X
---@param y number Point Y
---@return boolean touches Point on edge
---@nodiscard
function G.touches(edge, x, y)
    return x >= edge.x and x <= edge.tx and y >= edge.y and y <= edge.ty
end

---@param record table Candidate barrier
---@param records table All persistent outline barriers
---@return table edges Front and exposed end edges
---@nodiscard
function G.outline(record, records)
    local fronts, caps = G.shape(record)
    local edges = {fronts[1], fronts[2]}
    for i = 1, #caps do
        local cap, joined = caps[i], false
        for j = 1, #records do
            local other = records[j]
            if other.id ~= record.id and other.z == record.z then
                local otherFronts = G.shape(other)
                for k = 1, #otherFronts do
                    if G.touches(otherFronts[k], cap.joinX, cap.joinY) then
                        joined = true
                    end
                end
            end
        end
        if not joined then
            edges[#edges + 1] = cap
        end
    end
    return edges
end

return G
