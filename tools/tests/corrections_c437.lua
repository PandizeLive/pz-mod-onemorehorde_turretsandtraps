local Active = require("OMHTT/ActiveTime")
local saved = {time=getGameTime, wall=getTimestampMs, paused=GameTime.isGamePaused, combo=ISComboBox}
local hours, wall, paused = 10, 1000, false
getGameTime = function() return {getWorldAgeHours=function() return hours end,getMinutesPerDay=function() return 60 end} end
getTimestampMs = function() return wall end
GameTime.isGamePaused = function() return paused end
local sim, real = Active.new(true), Active.new()
Active.step(sim); Active.step(real)
hours, wall = hours + .004, wall + 100
check(math.abs(Active.step(sim)-600)<.001 and Active.step(real)==100,"Sixfold simulation retains real-time presentation budgets")
paused=true; hours=hours+1; Active.step(sim)
paused=false; hours=hours+1; check(Active.step(sim)==0,"Pause/resume excludes skipped world time")
getGameTime,getTimestampMs,GameTime.isGamePaused=saved.time,saved.wall,saved.paused
local C=require("OMHTT/TetherCycle")
local cycle=C.new(0,0,0,1,0,{range=6,speed=30,returnSpeed=4,resetTime=2,holdTime=.75})
C.start(cycle,true,false)
local casts=0
for i=1,10 do C.step(cycle,.6,function() casts=casts+1; return nil end,function() end) end
check(cycle.phase=="idle" and cycle.debt==0 and casts<=8,"Fast-forward tether completes without simulation backlog")
local R=require("OMHTT/ControlRarity")
R.refresh({RarityWeightAbundant=40,RarityWeightCommon=30,RarityWeightUncommon=24,RarityWeightRare=12,RarityWeightEpic=8,RarityWeightLegendary=4,RarityWeightMythic=2})
check(R.cache.ManualBallista.weight==24 and R.cache.ManualArc.weight==8,"New manuals inherit assigned loaded rarity weights")
R.refresh({LootRateManualBallista=7.25})
check(R.cache.ManualBallista.weight==7.25,"Manual custom weight overrides its assigned default tier")
R.refresh(SandboxVars.OMHTurretsTraps)
local L=require("OMHTT/ControlLootDefinitions")
for key in pairs(L.MANUALS) do check(not L.WEIGHTS[key],"Manual cannot enter module pack pool") end
ISComboBox={new=function(self,x,y,w,h) return {selected=1,width=w,initialise=function() end,addOption=function() end,setX=function(self,v) self.x=v end,setY=function(self,v) self.y=v end,setWidth=function(self,v) self.width=v end} end}
local U=require("OMHTT/ControlLootUI")
local panel={controls={},width=500,addChild=function() end,getWidth=function(self) return self.width end}
local field={Type="ISTextEntryBox",x=250,width=220,text="1.011111111111111",getX=function(self) return self.x end,getY=function() return 0 end,getWidth=function(self) return self.width end,getHeight=function() return 24 end,setText=function(self,v) self.text=v end,getText=function(self) return self.text end,setY=function() end,setX=function(self,v) self.x=v end,setWidth=function(self,v) self.width=v end,setVisible=function(self,v) self.visible=v end}
U.attach(panel,field,"Range")
check(field.omhttRarity.selected==9 and field:getText()=="1.011111111111111","Rarity selector preserves exact imported custom value")
field.omhttRarity.selected=5;field.omhttRarity.onChange()
check(tonumber(field:getText())==2 and not field.visible,"Rare dropdown uses assigned weight divided by catalog base")
field.omhttRarity.selected=1;field.omhttRarity.onChange()
check(field:getText()=="0","Disabled dropdown writes explicit zero")
field.omhttRarity.selected=9;field.omhttRarity.onChange()
field.text=""
check(field:getText()=="0", "Incomplete Custom edit preserves last valid weight instead of native parse spam")
field.text="3.125"
check(field:getText()=="3.125", "Custom edit accepts an exact new weight")
for _, width in pairs({300,500,800}) do
    panel.width=width
    field:setX(width-100)
    check(field.omhttRarity.x >= 0 and field.omhttRarity.x+field.omhttRarity.width < field.x
        and field.x+field.width <= width, "Custom combo and numeric input remain visible and separate after native reposition")
end
local Controls=require("OMHTT/ControlDefinitions")
local occupied={hasModData=function() return true end,getModData=function() return {OMHTTControl={}} end}
local square={TreatAsSolidFloor=function() return true end,isSolid=function(self) return self.solid end,
    getX=function() return 9740 end,getY=function() return 9740 end,getZ=function() return 0 end,
    getProperties=function() return {has=function() return false end} end,
    isSolidTrans=function() return false end,getObjects=function(self) return {size=function() return self.occupied and 1 or 0 end,get=function() return occupied end} end}
check(Controls.controller({square=square}), "Controller accepts clear solid floor")
square.solid=true
check(not Controls.controller({square=square}), "Controller rejects furniture collision")
square.solid=false;square.occupied=true
check(not Controls.controller({square=square}) and Controls.valid({square=square}), "Controller rejects devices without banning intentional floor traps")
ISComboBox=saved.combo
local Heads=require("OMHTT/TurretHeads")
check(Heads.motion(0,false,120)==-60 and Heads.motion(120,false,120)==60,"Rotary cone controls actual arm excursion")
check(Heads.crossing(55,100,120,false,120)~=nil and Heads.crossing(55,100,120,false,90)==nil,"Rotary contact sweep follows configured cone")
print("[OMHTT-C437] simulation, pause, tether debt, manual tiers, pack exclusions, exact loot controls and per-head rotary geometry checked")
