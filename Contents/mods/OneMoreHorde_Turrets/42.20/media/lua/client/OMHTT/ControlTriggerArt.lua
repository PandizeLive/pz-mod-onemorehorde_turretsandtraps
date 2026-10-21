if isServer() then return end
local V={}
-- Dedicated identities avoid SpriteConfig collisions with Button. Reuse the
-- current game's switch frames, never rename or mutate the native sprites.
function V.loaded()
    local faces={2,0,1,3}
    for i=1,4 do
        local texture="lighting_indoor_01_" .. faces[i]
        if getTexture(texture) then
            for _,sheet in pairs({{name="omhtt_turret_01_",first=34},{name="omhtt_barrier_01_",first=98}}) do
                local sprite=getSprite(sheet.name .. (sheet.first+i-1))
                if sprite then sprite:LoadFramesNoDirPageSimple(texture) end
            end
        end
    end
end
Events.OnLoadedTileDefinitions.Add(V.loaded)
Events.OnGameStart.Add(V.loaded)
return V
