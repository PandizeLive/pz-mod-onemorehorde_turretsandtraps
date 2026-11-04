local function script(name,hidden,obsolete)
    return {getFullName=function() return name end,isHidden=function() return hidden end,getObsolete=function() return obsolete end}
end
local values={script("Base.OMHTTModuleExecute"),script("Base.CarBattery1"),script("Base.OMHTTTrapPokeFloor",true),
    script("Base.OMHTTTrapBarbedPanel"),script("Other.OMHTTModuleExecute"),script("Base.OMHTTOld",false,true)}
local tabs={}
local viewer=setmetatable({items={size=function() return #values end,get=function(_,i) return values[i+1] end},
    panel={width=600,height=500,tabHeight=24,addView=function(_,name,view) tabs[#tabs+1]={name=name,view=view} end}}, {__index=ISItemsListViewer})
viewer:initList()
check(viewer.nativeCalls==1 and #tabs==1 and #tabs[1].view.items==2,"Filtered item tab preserves native initialization and excludes hidden, obsolete and unrelated items")
check(tabs[1].view.items[1]==values[1] and tabs[1].view.items[2]==values[4],"Item tab retains exact script identities")
local installed
CharacterTraitDefinition={getCharacterTraitDefinition=function() return {setTexture=function(_,texture) installed=texture end} end}
local source={getWidth=function() return 48 end,getHeight=function() return 64 end,
    getXStart=function() return .25 end,getYStart=function() return .5 end,
    getWidthHW=function() return 1024 end,getHeightHW=function() return 1024 end}
function source:split(name,x,y,w,h)
    check(name=="OMHTTTurretSpecialist" and x==256 and y==512 and w==48 and h==64,"Manual atlas origin is retained instead of sampling the fish at sheet zero")
    return {setWidth=function(self,w) self.width=w end,setHeight=function(self,h) self.height=h end}
end
getTexture=function() return source end
testC474.icon()
check(installed.width==12 and installed.height==16 and source:getWidth()==48,"Trait icon fits16px without resizing the shared manual")
ISItemsListViewer,ISItemsListTable,getTexture,CharacterTraitDefinition,Events.OnGameBoot,testMode=
    testC474.viewer,testC474.list,testC474.texture,testC474.traits,testC474.boot,testC474.mode
print("[C474] Item List identities and atlas region/size verified")
