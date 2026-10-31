testC474={viewer=ISItemsListViewer,list=ISItemsListTable,texture=getTexture,traits=CharacterTraitDefinition,boot=Events.OnGameBoot,mode=testMode}
testMode="client"
ISItemsListViewer={initList=function(self) self.nativeCalls=(self.nativeCalls or 0)+1 end}
ISItemsListTable={new=function(self,x,y,w,h,owner)
    return {initialise=function() end,initList=function(self,items) self.items=items end} end}
Events.OnGameBoot={Add=function(fn) testC474.icon=fn end}
