local function trace(root)
    local base = testControlPanelBase
    local names = {"drawRect", "drawRectStatic", "drawRectBorder", "drawText", "drawTextRight", "drawTextCentre", "drawLine2", "drawLine", "drawProgressBar"}
    local previous, svg, serial = {}, {}, 0
    local function escape(value)
        return string.gsub(string.gsub(string.gsub(tostring(value), "&", "&amp;"), "<", "&lt;"), ">", "&gt;")
    end
    local function color(r,g,b) return string.format("rgb(%d,%d,%d)",math.floor((r or 1)*255),math.floor((g or 1)*255),math.floor((b or 1)*255)) end
    local function xy(self,x,y,static)
        return self:getAbsoluteX()-root.x+x, self:getAbsoluteY()-root.y+y+(static and 0 or self:getYScroll())
    end
    for i=1,#names do previous[names[i]]=base[names[i]] end
    local function rect(self,x,y,w,h,a,r,g,b,border,static)
        x,y=xy(self,x,y,static)
        svg[#svg+1]=string.format('<rect x="%f" y="%f" width="%f" height="%f" fill="%s" stroke="%s" opacity="%f"/>',x,y,math.max(0,w),math.max(0,h),border and "none" or color(r,g,b),border and color(r,g,b) or "none",a or 1)
    end
    base.drawRect=function(self,x,y,w,h,a,r,g,b) rect(self,x,y,w,h,a,r,g,b) end
    base.drawRectStatic=function(self,x,y,w,h,a,r,g,b) rect(self,x,y,w,h,a,r,g,b,false,true) end
    base.drawRectBorder=function(self,x,y,w,h,a,r,g,b) rect(self,x,y,w,h,a,r,g,b,true) end
    local function text(self,value,x,y,r,g,b,a,font,anchor)
        x,y=xy(self,x,y)
        svg[#svg+1]=string.format('<text x="%f" y="%f" fill="%s" opacity="%f" font-size="%d" text-anchor="%s">%s</text>',x,y+14,color(r,g,b),a or 1,font==UIFont.Medium and 16 or 14,anchor or "start",escape(value))
    end
    base.drawText=text
    base.drawTextRight=function(self,value,x,y,r,g,b,a,font) text(self,value,x,y,r,g,b,a,font,"end") end
    base.drawTextCentre=function(self,value,x,y,r,g,b,a,font) text(self,value,x,y,r,g,b,a,font,"middle") end
    base.drawLine2=function(self,x1,y1,x2,y2,a,r,g,b)
        x1,y1=xy(self,x1,y1); x2,y2=xy(self,x2,y2)
        svg[#svg+1]=string.format('<line x1="%f" y1="%f" x2="%f" y2="%f" opacity="%f" stroke="%s"/>',x1,y1,x2,y2,a,color(r,g,b))
    end
    base.drawLine=function(self,texture,x1,y1,x2,y2,thickness,a,r,g,b) base.drawLine2(self,x1,y1,x2,y2,a,r,g,b) end
    base.drawProgressBar=function(self,x,y,w,h,value) rect(self,x,y,w,h,1,.18,.18,.18); rect(self,x,y,w*value,h,1,.5,.8,.5) end
    local function visit(widget)
        if widget.visible==false then return end
        serial=serial+1
        local id=serial
        local x,y
        if widget.getAbsoluteX then x,y=xy(widget,0,0,true)
        else x,y=xy(widget.parent,widget.x,widget.y) end
        svg[#svg+1]=string.format('<clipPath id="clip%d"><rect x="%f" y="%f" width="%f" height="%f"/></clipPath><g clip-path="url(#clip%d)">',id,x,y,widget.width,widget.height,id)
        local plain = not widget.getAbsoluteX
        if not plain and widget.prerender then widget:prerender() end
        if widget.title and widget.parent then
            local parent=widget.parent
            local bg=widget.backgroundColor or {r=.13,g=.13,b=.13,a=1}
            local border=widget.borderColor or {r=.6,g=.6,b=.6,a=1}
            rect(parent,widget.x,widget.y,widget.width,widget.height,bg.a,bg.r,bg.g,bg.b)
            rect(parent,widget.x,widget.y,widget.width,widget.height,border.a,border.r,border.g,border.b,true)
            text(parent,widget.title,widget.x+widget.width/2,widget.y+6,.9,.9,.9,1,UIFont.Small,"middle")
        elseif widget.placeholder and widget.parent then
            rect(widget,0,0,widget.width,widget.height,1,.6,.6,.6,true)
            text(widget,widget.text~="" and widget.text or widget.placeholder,4,6,.7,.7,.7,1,UIFont.Small)
        end
        for i=1,#(widget.children or {}) do visit(widget.children[i]) end
        if not plain and widget.render then widget:render() end
        svg[#svg+1]='</g>'
    end
    -- Stockpile rows/icons are native widgets; this artifact reviews geometry and layering only.
    svg[#svg+1]=string.format('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" style="font-family:Arial;background:#090909">',root.width,root.height)
    visit(root)
    svg[#svg+1]='</svg>'
    for i=1,#names do base[names[i]]=previous[names[i]] end
    return table.concat(svg,"\n")
end
return trace
