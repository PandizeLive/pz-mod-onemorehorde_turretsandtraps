if isServer() then return end
require("ISUI/ISTextEntryBox")
require("ISUI/ISButton")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local E = {}
local controls = {"fireButton", "priorityButton", "reloadButton", "lurePlay", "lureLoop"}

---@param panel ISPanel Turret Manage
---@return nil
function E.create(panel)
    panel.nameEntry = ISTextEntryBox:new(U.name(panel.object), 12, panel.titleHeight + 4, panel.width - 208, 26)
    panel.nameEntry:initialise()
    panel:addChild(panel.nameEntry)
    local save = ISButton:new(panel.width - 188, panel.titleHeight + 4, 86, 26, getText("UI_OMHTT_SaveName"), panel, function(self)
        U.command(self.player, self.object, "Name", self.nameEntry:getText())
    end)
    save:initialise()
    panel:addChild(save)
    panel.nameSave = save
    local auto = ISButton:new(panel.width - 96, panel.titleHeight + 4, 52, 26, getText("UI_OMHTT_AutoName"), panel, function(self)
        U.command(self.player, self.object, "Name", "")
        self.nameEntry:setText("")
    end)
    auto:initialise()
    panel:addChild(auto)
    panel.nameAuto = auto
    if panel.controller then
        panel.sourceButton = ISButton:new(12, panel.titleHeight + 36, panel.width - 24, 26, "Transfer destination: Your inventory", panel, function(self)
            self.toStockpile = not self.toStockpile
            self.sourceButton:setTitle(self.toStockpile and "Transfer destination: Controller stockpile" or "Transfer destination: Your inventory")
            if self.toStockpile then
                require("OMHTT/ControlPanel").stockpile(self, self.controller)
            end
        end)
        panel.sourceButton:initialise()
        panel:addChild(panel.sourceButton)
    end
end

---@param panel ISPanel Turret Manage
---@return nil
function E.refresh(panel)
    if panel.controller and getTimestampMs() >= (panel.remoteDue or 0) then
        panel.remoteDue = getTimestampMs() + 5000
        U.remote(panel.player, panel.controller, panel.object)
    end
    local writable = require("OMHTT/TurretAccess").near(panel.player, panel.object)
    panel.readOnly = not writable
    panel.powerButton:setEnable(writable)
    if not writable then
        for i = 1, #controls do
            local control = panel[controls[i]]
            if control then
                control:setEnable(false)
            end
        end
    end
    panel.nameSave:setEnable(writable)
    panel.nameAuto:setEnable(writable)
    local storage = panel.object:getContainer()
    local weight = storage:getCapacityWeight() + 6
    panel.weightLabel = string.format("Weight: %.1f%s", weight, weight > 100 and "  ! Heavy — two-hand carry" or "")
    if panel.sourceButton then
        panel.sourceButton:setTitle((panel.toStockpile and "To stockpile" or "To inventory") .. "  •  " .. panel.weightLabel)
        panel.sourceButton:setEnable(writable)
    end
end

---@param panel ISPanel Manage window
---@return nil
function E.close(panel)
    if panel.storage then
        panel.storage:close()
        panel.storage = nil
    end
end

return E
