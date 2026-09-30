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
getTextManager=oldTextManager
