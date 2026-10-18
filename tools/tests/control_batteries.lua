local Slot = require("OMHTT/ControlBatterySlot")
local A = require("OMHTT/ControlAccess")
local Transfer = require("OMHTT/ControlTransferAction")
local saved = {panel=ISPanel,script=getScriptManager,manager=getTextManager,queue=ISTimedActionQueue.add,
    near=A.near,write=A.write,new=Transfer.new,actual=ISInventoryPane.getActualItems}
ISPanel=testControlPanelBase
getTextManager=function() return {MeasureStringX=function(_,font,text) return #text*6 end} end
local script={getNormalTexture=function() return {} end,getIconsForTexture=function() return nil end}
getScriptManager=function() return {getItem=function(_,name) check(name=="Base.Battery","Ghost resolves the native small battery script");return script end} end
local items,reads={},0
local container={getItems=function() return {size=function() return #items end,get=function(_,i) reads=reads+1;return items[i+1] end} end}
local owner={object={getContainer=function() return container end},player={},lineHeight=22,addChild=function() end}
local function item(kind,stored)
    return {getFullType=function() return kind end,getContainer=function() return stored and container or {} end}
end
local slot=Slot.create(owner,0,0,340,64)
slot.drawTextureScaledAspect=function(_,texture,x,y,w,h,alpha,r,g,b)
    check(texture==slot.hintTexture and alpha==.85 and r==0 and g==0 and b==0 and w==28 and h==28,
        "Controller empty slot uses normal Battery texture tinted black, without creating an item")
end
slot:refreshCount()
slot:prerender()
check(slot.storedCount==0,"Empty stockpile reports no stored batteries")
for i=1,160 do items[i]=item(i%2==0 and "Base.Battery" or "Base.CarBattery1") end
slot:refreshCount()
check(reads==64 and slot.countIndex==64,"Large Stockpile count examines at most 64 entries per update")
slot:refreshCount();slot:refreshCount()
check(slot.storedCount==80 and not slot.countIndex,"Stored count distinguishes small batteries from car batteries")
local completedReads=reads
for i=1,100 do slot:refreshCount() end
check(reads==completedReads,"Idle updates do not rescan Stockpile contents")
items[1]=item("Base.Battery")
slot.countDirty=true
slot:refreshCount();slot:refreshCount();slot:refreshCount()
check(slot.storedCount==81,"Same-size content changes invalidate cached count")
items={}
slot:refreshCount()
check(slot.storedCount==0,"Stockpile shrink safely restarts count")
local allowed,queued,created=true,{},0
A.near=function() return allowed end
A.write=function() return allowed end
Transfer.new=function(_,player,object,value,incoming,id,destination,stored)
    created=created+1
    return {item=value,stored=stored,isValid=function() return value.valid~=false end,
        setOnComplete=function(self,callback,target,action) self.finish=function() callback(target,action) end end}
end
ISTimedActionQueue.add=function(action) queued[#queued+1]=action end
ISInventoryPane.getActualItems=function(values) return values end
local focus={onMouseUp=function() end}
local first,second=item("Base.Battery"),item("Base.Battery")
ISMouseDrag.dragging,ISMouseDrag.draggingFocus={first,item("Base.CarBattery1"),second},focus
slot:onMouseUp(0,0)
check(#queued==1 and queued[1].item==first and not ISMouseDrag.dragging,"Stack drop starts one exact-item transfer and ends drag")
slot:transferNext()
check(#queued==1,"Remaining batteries wait for completion/replication, not another frame alone")
queued[1].done=true;slot:transferNext()
check(#queued==2 and queued[2].item==second,"SP completion advances to next battery even when perform ran before complete")
queued[2]:finish();slot:transferNext()
check(not slot.pendingItems,"Finished batch releases selected items")
slot.pendingItems={}
for i=1,100 do slot.pendingItems[i]=item("Base.CarBattery1") end
slot.pendingIndex=1
slot:transferNext()
check(slot.pendingIndex==17 and #queued==2,"Rejected bulk selection is examined in bounded slices")
slot.pendingItems,slot.pendingIndex={first,second},1
slot:transferNext();queued[3].cancelled=true;slot:transferNext()
check(not slot.pendingItems and #queued==3,"Cancelled transfer stops the remaining stack")
slot.pendingItems,slot.pendingIndex={first,second},1
allowed=false;slot:transferNext()
check(not slot.pendingItems and #queued==3,"Lost reach or permission cannot continue bulk deposits")
allowed=true
slot.pendingItems,slot.pendingIndex={first,second},1
slot:transferNext();slot:cleanup();queued[4]:finish();slot:transferNext()
check(not slot.pendingItems and #queued==4,"Closing window cannot revive a pending stack via late completion")
slot.pendingItems,slot.pendingIndex={item("Base.Battery",true),item("Base.Battery",true)},1
slot:transferNext()
check(queued[5].stored and not slot.pendingItems,"Dropping existing spares selects one without re-transferring the stockpile")
slot:cleanup()
ISPanel,getScriptManager,getTextManager,ISTimedActionQueue.add=saved.panel,saved.script,saved.manager,saved.queue
A.near,A.write,Transfer.new,ISInventoryPane.getActualItems=saved.near,saved.write,saved.new,saved.actual
