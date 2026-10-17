ISWidgetBuildControl = {startBuild = function(self) self.nativeStarted = true end,
    prerender = function(self) self.buttonCraft.enable = true end}
Events.OnContainerUpdate = Events.OnContainerUpdate or {Add = function() end}
