if isServer() then return end
require("ISUI/ISPanel")
require("ISUI/ISButton")
local A = require("OMHTT/ControlAccess")
local U = require("OMHTT/ControlClient")
local Theme = require("OMHTT/ControlTheme")
local Targeting = require("OMHTT/ControlTargetingUI")
local Host = ISPanel:derive("OMHTTControllerHostDetails")

---@param delta number Wheel movement
---@return boolean handled
function Host:onMouseWheel(delta)
    self:setYScroll(math.max(math.min(0, self.height - self.contentHeight), math.min(0, self:getYScroll() - delta * 36)))
    return true
end

---@return nil
function Host:arrange()
    local h, row = self.owner.lineHeight, math.max(28, self.owner.lineHeight + 6)
    self.infoY = 10
    self.targeting:setX(10)
    self.targeting:setY(self.infoY + h * 4 + 12)
    self.targeting:setWidth((self.width - 44) / 2)
    self.targeting:setHeight(row)
    self.policy:setX(18 + (self.width - 44) / 2)
    self.policy:setY(self.targeting.y)
    self.policy:setWidth((self.width - 44) / 2)
    self.policy:setHeight(row)
    self.ownerY = self.policy.y + row + 10
    self.contentHeight = self.ownerY + h + 12
    self:setScrollHeight(self.contentHeight)
    self:setYScroll(math.max(math.min(0, self.height - self.contentHeight), self:getYScroll()))
    Theme.scrollbar(self)
end

---@return nil
function Host:prerender()
    local panel, h = self.owner, self.owner.lineHeight
    local state = A.state(panel.object)
    if not state then return end
    self:setStencilRect(0, 0, self.width, self.height)
    self:drawRectStatic(0, 0, self.width, self.height, .12, .045, .045, .045)
    local y, width = self.infoY, self.width - 36
    self:setStencilRect(10, y + self:getYScroll(), width, h * 4)
    self:drawText(getText("UI_OMHTT_ControllerRange", A.radius(panel.object)), 10, y, .8, .8, .8, 1, UIFont.Small)
    self:drawText(getText(state.powered and "UI_OMHTT_ControllerPowerReady" or "UI_OMHTT_ControllerPowerEmpty"), 10, y + h, .8, .8, .8, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_DeviceCondition", panel.object:getHealth(), panel.object:getMaxHealth()), 10, y + h * 2, .8, .8, .8, 1, UIFont.Small)
    self:drawText(getText("UI_OMHTT_ControllerLimits"), 10, y + h * 3, .8, .8, .8, 1, UIFont.Small)
    self:clearStencilRect()
    self:repaintStencilRect(0, 0, self.width, self.height)
    self:setStencilRect(10, self.ownerY + self:getYScroll(), width, h)
    self:drawText(getText("UI_OMHTT_ControlOwner", state.owner), 10, self.ownerY, .8, .8, .8, 1, UIFont.Small)
    self:clearStencilRect()
    self:repaintStencilRect(0, 0, self.width, self.height)
    Targeting.refresh(self.targeting, panel.player, panel.object)
    self.policy:setTitle(getText("UI_OMHTT_Access", state.access))
    self.policy:setEnable(A.near(panel.player, panel.object) and A.write(panel.player, state, true))
end

---@return nil
function Host:render()
    self:clearStencilRect()
end

---@param panel ISPanel Controller window
---@return ISPanel body
function Host.create(panel)
    local body = Host:new(0, 0, 240, 300)
    body.owner = panel
    body:initialise()
    body.background = false
    body:setScrollChildren(true)
    body:addScrollBars(false)
    panel:addChild(body)
    body.targeting = ISButton:new(10, 10, 200, 28, "", body, function(self)
        Targeting.open(self.owner.player, self.owner.object)
    end)
    body.policy = ISButton:new(10, 50, 200, 28, "", body, function(self)
        local state = A.state(self.owner.object)
        if not state then return end
        local modes = {Private = "Faction", Faction = "Public", Public = "Private"}
        local mode = modes[state.access]
        if mode == "Faction" and not Faction.getPlayerFaction(self.owner.player) then
            mode = "Public"
        end
        U.command(self.owner.player, self.owner.object, "Access", mode)
    end)
    body.targeting:initialise()
    body.policy:initialise()
    body:addChild(body.targeting)
    body:addChild(body.policy)
    body:arrange()
    return body
end

return Host
