local T = require("OMHTT/Turret")
local W = require("OMHTT/TurretWorld")
local saved = {state=T.state,contents=T.contents,enabled=T.enabled,valid=W.valid,refresh=W.refresh,
    player=getSpecificPlayer,cell=getCell,utils=IsoUtils,mx=getMouseXScaled,my=getMouseYScaled,context=ISContextMenu,tooltip=ISWorldObjectContextMenu.addToolTip}
local object = {getContainer=function() return {} end,getHealth=function() return 100 end,getMaxHealth=function() return 100 end}
T.state=function(value) return value==object and {id="context-regression"} or nil end
T.contents=function() return {ammo=0,modules=0} end
T.enabled=function() return true end
W.valid=function(value) return value==object end
W.refresh=function() end
getSpecificPlayer=function() return {isDead=function() return false end,getZ=function() return 0 end} end
getCell=function() return {getGridSquare=function() return nil end} end
IsoUtils={XToIso=function() return 0 end,YToIso=function() return 0 end}
getMouseXScaled,getMouseYScaled=function() return 0 end,function() return 0 end
local menus={}
local function menu()
    local m={options={}}
    function m:addOption(title,target,callback) local value={title=title,target=target,callback=callback};self.options[#self.options+1]=value;return value end
    function m:addSubMenu(option,sub) option.sub=sub end
    menus[#menus+1]=m
    return m
end
ISContextMenu={getNew=function() return menu() end}
ISWorldObjectContextMenu.addToolTip=function() return {} end
local root=menu()
local handlers=Events.OnFillWorldObjectContextMenu.handlers
handlers[#handlers](0,root,{object},false)
check(#root.options==1 and #root.options[1].sub.options==4, "Turret world context builds Manage/Pickup/Repair/Condition without stale Fire")
for i=1,#root.options[1].sub.options do
    local option=root.options[1].sub.options[i]
    check(option.title~=getText("UI_OMHTT_ManageFire"), "Fire remains absent from world menu")
end
T.state,T.contents,T.enabled,W.valid,W.refresh=saved.state,saved.contents,saved.enabled,saved.valid,saved.refresh
getSpecificPlayer,getCell,IsoUtils,getMouseXScaled,getMouseYScaled,ISContextMenu=saved.player,saved.cell,saved.utils,saved.mx,saved.my,saved.context
ISWorldObjectContextMenu.addToolTip=saved.tooltip
