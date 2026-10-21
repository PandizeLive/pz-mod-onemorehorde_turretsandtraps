if isServer() then return end
require("ISUI/ISContextMenu")
require("ISUI/ISToolTip")
local U={}
function U.range(player,object)
    local menu=ISContextMenu.get(player:getPlayerNum(),getMouseX(),getMouseY())
    for i=1,10 do
        menu:addOption(getText("UI_OMHTT_BeamRange",i),object,function(target,value)
            if require("OMHTT/ControlAccess").authorized(player,target) or luautils.walkAdjObject(player,target,false) then
                require("OMHTT/ControlClient").command(player,target,"BeamRange",value)
            end
        end,i)
    end
    menu:bringToTop()
end
function U.activate(player,object)
    local state=require("OMHTT/ControlAccess").state(object)
    if not state then return end
    local command,value="Pulse",nil
    if state.kind=="Laser" then U.range(player,object); return end
    if state.kind=="Lever" then command="Toggle"
    elseif state.kind=="Plate" then command,value="Trigger",({Both="Players",Players="Zombies",Zombies="Both"})[state.trigger or "Both"] end
    if require("OMHTT/ControlAccess").authorized(player,object) or luautils.walkAdjObject(player,object,false) then
        require("OMHTT/ControlClient").command(player,object,command,value)
    end
end
function U.world(menu,player,object,option)
    local state=require("OMHTT/ControlAccess").state(object)
    if not option then
        option=menu:addOption(getText(state.kind=="Laser" and "UI_OMHTT_BeamRange" or "UI_OMHTT_TriggerMode",
            state.kind=="Laser" and (state.beamRange or 10) or (state.trigger or "Both")),object,function(target) U.activate(player,target) end)
    end
    local tip=ISToolTip:new()
    tip:initialise()
    tip.description=require("OMHTT/ControlConsumption").description(state.kind,true)
    if not state.powered then tip.description=tip.description .. " <LINE> " .. getText("UI_OMHTT_TriggerUnpowered") end
    option.toolTip=tip
end
return U
