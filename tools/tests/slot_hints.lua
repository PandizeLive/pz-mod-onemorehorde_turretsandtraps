local Hint = require("OMHTT/SlotHint")
local Slot = require("OMHTT/TurretSlot")
local savedScript, savedInstance, savedPanel = getScriptManager, instanceItem, ISPanel
local savedGetter, savedIcon = ISUITextureGetter, ISInventoryItem.renderItemIcon
local texture, alternate, lookups, draws, realDraws = {}, {}, 0, 0, 0
getScriptManager=function() return {getItem=function(_,name)
    lookups=lookups+1
    if name=="Mod.Missing" then return nil end
    return {getNormalTexture=function() return name~="Mod.NoIcon" and texture or nil end,
        getIconsForTexture=function() return name=="Mod.MultiIcon" and {isEmpty=function() return false end,get=function() return alternate end} or nil end}
end} end
instanceItem=function() error("Visual hints must never allocate inventory items") end
ISPanel=testControlPanelBase
ISUITextureGetter={checkGetTexture=function(value) return value end}
ISInventoryItem.renderItemIcon=function() realDraws=realDraws+1 end
local owner={lineHeight=18}
local slot=Slot:new(owner,"head","Head",0,0,160,64)
slot.javaObject={DrawTextureScaledAspect=function(_,tex,x,y,w,h,r,g,b,a)
    check(tex==slot.hintTexture and r==0 and g==0 and b==0 and a==.85,
        "Installed native draw wrapper sends transparent normal texture and black RGBA to Java")
    check(x>=0 and y>=0 and x+w<=slot.width and y+h<=slot.height,"Silhouette stays within slot at constrained sizes")
    draws=draws+1
end}
slot.drawTextureScaledAspect=testNativeHintDraw
local initialReads=lookups
for i=1,120 do Hint.set(slot,slot.hintType);slot:prerender() end
check(lookups==initialReads and draws==120,"Idle rendering reuses cached texture without script lookups or inventory allocation")
slot:onMouseDown(0,0)
check(#slot.items==0 and not ISMouseDrag.dragging,"Empty silhouette is never a draggable inventory item")
slot.items={{getDisplayName=function() return "Real Head" end}}
slot:prerender()
check(draws==120 and realDraws==1,"Occupied slot keeps normal full-color rendering without an empty hint")
slot.items={};slot.kind="module";slot.disabled=true
slot:prerender()
check(draws==120,"Locked empty module never draws a usable hint")
slot.disabled=false;slot.height=26
slot:prerender()
check(draws==121,"Compact module retains its hint inside the short row")
slot.kind="ammo";slot.height=64;slot.summary="Next Load: None";slot.subtext="0 Ammo Type(s)"
slot:prerender()
check(draws==122 and slot.summary=="Next Load: None" and slot.subtext=="0 Ammo Type(s)","Summary slot preserves next-load and type-count text alongside hint")
slot.disabled=true;slot:prerender()
check(draws==122,"Not-needed or absent-Module summaries never advertise a drop hint")
slot.disabled=false
Hint.set(slot,"Mod.MultiIcon");check(slot.hintTexture==alternate,"Multi-icon script uses the same first texture as native inventory")
Hint.set(slot,"Mod.NoIcon");slot:prerender();check(not slot.hintTexture and draws==122,"Missing texture leaves readable labels and summaries")
Hint.set(slot,"Mod.Missing");local missingReads=lookups
for i=1,20 do Hint.set(slot,"Mod.Missing") end
check(not slot.hintTexture and lookups==missingReads,"Absent mod item is cached without exceptions or repeated lookups")
Hint.set(slot,"Mod.OtherAmmo");check(slot.hintTexture==texture,"Modded item texture resolves normally")
Hint.set(slot,nil);check(not slot.hintTexture and not slot.hintType,"Removing head clears stale texture")
getScriptManager,instanceItem,ISPanel=savedScript,savedInstance,savedPanel
ISUITextureGetter,ISInventoryItem.renderItemIcon=savedGetter,savedIcon
