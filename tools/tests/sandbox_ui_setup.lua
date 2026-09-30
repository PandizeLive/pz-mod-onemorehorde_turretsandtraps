for i = 1, 4 do
    local paths = {"OptionScreens/SandboxOptions", "ISUI/AdminPanel/ISServerSandboxOptionsUI", "OptionScreens/ServerSettingsScreen", "ISUI/ISLabel"}
    __modules[paths[i]] = {}
end
SandboxOptionsScreen = {createPanel = function(self, page) return page end}
ISServerSandboxOptionsUI = {createPanel = function(self, page) return page end}
ServerSettingsScreen = {create = function(self) self.pageEdit = {createPanel = function(self, category) return category end} end}
ISLabel = {}
function ISLabel:new(x, y, h, title)
    return {getWidth = function() return 100 end, getHeight = function() return h end,
        setX = function(self,v) self.x=v end, setY = function(self,v) self.y=v end}
end
