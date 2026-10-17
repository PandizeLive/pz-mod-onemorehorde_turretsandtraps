testC300UI = {core=getCore,text=getTextManager,panel=ISPanel,button=ISButton,pane=ISInventoryPane,
    texture=getTexture,player=getSpecificPlayer,hotbar=getPlayerHotbar,mode=testMode,resizable=ISResizableButton}
testMode="client"
ISPanel=testControlPanelBase
getCore=function() return {getGoodHighlitedColor=function() return {} end,getOptionInventoryFont=function() return "Small" end} end
getTextManager=function() return {getFontHeight=function() return 18 end,getFontFromEnum=function() return {getLineHeight=function() return 18 end} end,
    MeasureStringX=function(_,font,text) return #text*8 end} end
getTexture=function() return {getWidth=function() return 16 end,getHeight=function() return 16 end} end
ISButton=ISPanel:derive("NativeButtonAdapter")
function ISButton:new(x,y,w,h,title,target,callback)
    local b=ISPanel.new(self,x,y,w,h)
    b.title,b.target,b.onclick=title,target,callback
    b.borderColor={a=1};return b
end
function ISButton:setImage(image) self.image=image end
ISResizableButton=ISButton
getPlayerHotbar=function() return {} end
getSpecificPlayer=function() return {} end
