local UI = require("OMHTT/SandboxUI")
local sharedPage={settings={{name="OMHTurretsTraps.TriggerLaserConsumption"},{name="OMHTurretsTraps.TrapsTriggerLaserConsumption"},{name="OtherMod.Setting"}}}
UI.triggerSettings(sharedPage)
check(#sharedPage.settings==2 and sharedPage.settings[2].name=="OtherMod.Setting", "Combined trigger page shows one effective control and preserves other mods")
local singlePage={settings={{name="OMHTurretsTraps.TrapsTriggerLaserConsumption"}}}
check(#UI.triggerSettings(singlePage).settings==1,"Traps-only trigger controls remain visible")
local oldTextManager = getTextManager
function getTextManager() return {getFontHeight = function() return 20 end} end
local names = {"PotatoRequirePower", "PotatoDamage", "PotatoAmmoCapacity", "PotatoTurret"}
local panel = {controls = {}, labels = {}, settingNames = {}, children = {}, width = 500}
for i=1,#names do
    local name = "OMHTurretsTraps." .. names[i]
    panel.settingNames[i] = name
    panel.controls[name] = {setY=function(self,y) self.y=y end,getHeight=function() return 20 end}
    panel.labels[name] = {setY=function(self,y) self.y=y end,getHeight=function() return 20 end}
end
function panel:addChild(child) self.children[#self.children+1]=child end
function panel:getWidth() return self.width end
function panel:insertNewLineOfButtons(control) self.joypadButtonsY[#self.joypadButtonsY+1]={control} end
function panel:setScrollHeight(h) self.scrollHeight=h end
function panel:prerender() self.originalCalled=true end
check(SandboxOptionsScreen:createPanel(panel)==panel and #panel.children==4, "Potato page gains four headings")
panel:prerender()
check(panel.originalCalled and panel.settingNames[1]=="OMHTurretsTraps.PotatoTurret" and panel.settingNames[4]=="OMHTurretsTraps.PotatoRequirePower", "Native panel remains active with grouped order")
local height=panel.scrollHeight
UI.attach(panel); panel.width=800; panel:prerender()
check(#panel.children==4 and panel.scrollHeight==height and #panel.joypadButtonsY==4, "Resize and repeated attachment preserve layout and joypad rows")
local unrelated={controls={}}
check(UI.attach(unrelated)==unrelated and unrelated.omhttTitles==nil, "Other mods' Sandbox pages untouched")
local modules = {controls = {}, labels = {}, settingNames = {}, children = {}, width = 500}
local names = {"CapacityAmmoBonus", "RangeBonus", "VelocityBonus", "ReloadBonus", "RapidFireBonus",
    "CapacityImprovisedModuleBonus", "CapacityImprovisedAmmoBonus", "ImprovisedFiringFailure"}
for i = 1, #names do
    local name = "OMHTurretsTraps." .. names[i]
    modules.settingNames[i] = name
    modules.controls[name] = {setY=function(self,y) self.y=y end,getHeight=function() return 20 end}
    modules.labels[name] = {setY=function(self,y) self.y=y end,getHeight=function() return 20 end}
end
modules.addChild, modules.getWidth, modules.insertNewLineOfButtons = panel.addChild, panel.getWidth, panel.insertNewLineOfButtons
modules.setScrollHeight = panel.setScrollHeight
modules.prerender = function(self) self.originalCalled = true end
UI.attach(modules)
modules:prerender()
check(#modules.children == 6 and modules.settingNames[1] == "OMHTurretsTraps.ImprovisedFiringFailure"
    and modules.settingNames[6] == "OMHTurretsTraps.CapacityImprovisedModuleBonus"
    and modules.settingNames[8] == "OMHTurretsTraps.CapacityAmmoBonus", "Firing reliability and starter expansion settings have correct semantic headings")
UI.attach(modules); modules.width = 700; modules:prerender()
check(#modules.children == 6 and #modules.joypadButtonsY == 8, "Module headings survive resize without duplicates")
local traps = {controls = {}, labels = {}, settingNames = {}, children = {}, width = 500}
local keys = {"BedScratchChance", "BarbMovementDivisor", "ReinforcedBarrierDamage", "SpikeBarrierHealth", "SpikeBarrier", "BedSpikes", "BedHealth", "BarbWire", "BarbSections"}
for i = 1, #keys do
    local name = "OMHTurretsTraps." .. keys[i]
    traps.settingNames[i] = name
    traps.controls[name] = {setY = function(self, y) self.y = y end, getHeight = function() return 20 end}
    traps.labels[name] = traps.controls[name]
end
traps.addChild, traps.getWidth, traps.insertNewLineOfButtons = panel.addChild, panel.getWidth, panel.insertNewLineOfButtons
traps.setScrollHeight, traps.prerender = panel.setScrollHeight, function() end
ISServerSandboxOptionsUI:createPanel(traps)
traps:prerender()
check(#traps.children == 4 and traps.settingNames[1] == "OMHTurretsTraps.SpikeBarrier"
    and traps.settingNames[2] == "OMHTurretsTraps.ReinforcedBarrierDamage"
    and traps.settingNames[9] == "OMHTurretsTraps.BedScratchChance", "Trap damage precedes durability; shared player injuries have their own final heading")
check(#traps.joypadButtonsY == #keys, "Server editing retains controller order for all settings")
getTextManager=oldTextManager
