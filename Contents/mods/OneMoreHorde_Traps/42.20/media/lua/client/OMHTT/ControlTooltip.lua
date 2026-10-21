if isServer() then return end
require("ISUI/ISToolTipInv")
local native=ISToolTipInv.render
function ISToolTipInv:render()
    native(self)
    if not self.item or (ISContextMenu.instance and ISContextMenu.instance.visibleCheck) then return end
    local D=require("OMHTT/ControlDefinitions")
    local kind
    for name,fullType in pairs(D.types) do if D.inputs[name] and self.item:getFullType()==fullType then kind=name; break end end
    if not kind then return end
    local description,color=require("OMHTT/ControlConsumption").description(kind,false)
    local font,spacing=self.tooltip:getFont(),self.tooltip:getLineSpacing()
    local lines=string.split(description,"\n")
    local width,height=self:getWidth(),self:getHeight()
    for i=1,#lines do width=math.max(width,getTextManager():MeasureStringX(font,lines[i])+12) end
    local total=height+#lines*spacing+8
    self:setWidth(width)
    self:setX(math.max(0,math.min(self:getX(),getCore():getScreenWidth()-width-1)))
    self:setY(math.max(0,math.min(self:getY(),getCore():getScreenHeight()-total-1)))
    self.tooltip:setX(self:getX()); self.tooltip:setY(self:getY())
    self:drawRect(0,0,width,height,self.backgroundColor.a,self.backgroundColor.r,self.backgroundColor.g,self.backgroundColor.b)
    self.item:DoTooltip(self.tooltip)
    self:setHeight(total)
    self:drawRect(0,height,width,total-height,self.backgroundColor.a,self.backgroundColor.r,self.backgroundColor.g,self.backgroundColor.b)
    self:drawRectBorder(0,0,width,total,self.borderColor.a,self.borderColor.r,self.borderColor.g,self.borderColor.b)
    for i=1,#lines do
        self:drawText(lines[i],5,height+4+(i-1)*spacing,i==1 and color.r or 1,i==1 and color.g or 1,i==1 and color.b or 1,1,font)
    end
end
