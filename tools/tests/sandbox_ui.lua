local UI = require("OMHTT/SandboxUI")
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
local names = {"CapacityAmmoBonus", "RangeBonus", "VelocityBonus", "ReloadBonus", "RapidFireBonus"}
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
check(#modules.children == 5 and modules.settingNames[1] == "OMHTurretsTraps.RapidFireBonus"
    and modules.settingNames[5] == "OMHTurretsTraps.CapacityAmmoBonus", "Module tuning has five ordered headings")
UI.attach(modules); modules.width = 700; modules:prerender()
check(#modules.children == 5 and #modules.joypadButtonsY == 5, "Module headings survive resize without duplicates")
getTextManager=oldTextManager
