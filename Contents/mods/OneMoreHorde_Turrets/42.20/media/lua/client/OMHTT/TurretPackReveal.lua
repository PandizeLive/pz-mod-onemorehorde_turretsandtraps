require("ISUI/ISPanel")
require("ISUI/ISButton")
local P = require("OMHTT/TurretModulePack")
local T = require("OMHTT/Turret")
local R = require("OMHTT/TurretRarity")
local Panel = ISPanel:derive("OMHTTTurretPackReveal")
local active = {}
local ROLL_DURATION = 6000
local ROW_DELAY = 150
local TRAVEL_CARDS = 39
local WINNER_CARD = TRAVEL_CARDS + 1

---@return nil
function Panel:close()
    if self.sound and self.sound ~= 0 then
        getSoundManager():stopUISound(self.sound)
        self.sound = nil
    end
    if not self.finished and self.revealSound and self.revealSound ~= 0 then
        getSoundManager():stopUISound(self.revealSound)
        self.revealSound = nil
    end
    active[self.playerIndex] = nil
    self:removeFromUIManager()
end

---@return nil
function Panel:finish()
    if self.finished then return end
    local now = getTimestampMs()
    self.finished, self.settledAt = true, now
    for row = 1, #self.reels do
        local reel = self.reels[row]
        reel.position, reel.crossed = TRAVEL_CARDS, TRAVEL_CARDS
        reel.settledAt = reel.settledAt or now
    end
    if self.sound and self.sound ~= 0 then
        getSoundManager():stopUISound(self.sound)
    end
    self.sound = getSoundManager():playUISound("UIObjectMenuObjectPickup")
    self.revealSound = getSoundManager():playUISound(self.revealCue)
    self.collectButton:setTitle(getText("UI_OMHTT_PackCollect"))
    self.collectButton.backgroundColor = {r = .08, g = .42, b = .16, a = .9}
    self.collectButton.backgroundColorMouseOver = {r = .12, g = .58, b = .22, a = 1}
end

---@return nil
function Panel:activate()
    if self.finished then
        self:close()
    else
        self:finish()
    end
end

---@param delta number Wheel direction
---@return boolean handled
function Panel:onMouseWheel(delta)
    self.offset = math.max(0, math.min(self.maxOffset, self.offset + delta * self.rowHeight / 2))
    return self.maxOffset > 0
end

---@param button ISButton Scroll control
---@return nil
function Panel:scroll(button)
    self:onMouseWheel(button.direction)
end

---@return nil
function Panel:prerender()
    ISPanel.prerender(self)
    self:drawText(getText("UI_OMHTT_ModulePack"), 12, 8, 1, 1, 1, 1, UIFont.Medium)
    local now = getTimestampMs()
    local allFinished, crossedCard = true, false
    for row = 1, #self.reels do
        local reel = self.reels[row]
        local progress = math.min(1, math.max(0, (now - self.started - (row - 1) * ROW_DELAY) / ROLL_DURATION))
        if self.finished then
            progress = 1
        end
        reel.position = (1 - (1 - progress) ^ 3) * TRAVEL_CARDS
        local crossed = math.floor(reel.position)
        if crossed > reel.crossed then
            crossedCard = true
        end
        reel.crossed = crossed
        if progress == 1 then
            if not reel.settledAt then
                reel.settledAt = now
            end
        else
            allFinished = false
        end
    end
    if allFinished and not self.finished then
        self:finish()
    elseif not self.finished and crossedCard and now - self.lastTick >= 100 then
        if self.sound and self.sound ~= 0 then
            getSoundManager():stopUISound(self.sound)
        end
        self.sound = getSoundManager():playUISound("UIObjectMenuObjectRotate")
        self.lastTick = now
    end
    for row = 1, #self.reels do
        local reel = self.reels[row]
        local pulse = reel.settledAt and math.max(0, 1 - (now - reel.settledAt) / 4000) or 0
        local cardWidth = reel.settledAt and (self.width - 20) or self.cardWidth
        local offset = reel.position * cardWidth
        local y = 40 + (row - 1) * self.rowHeight - self.offset
        local clipTop = math.max(40, y)
        local clipBottom = math.min(self.height - 42, y + self.rowHeight - 6)
        if clipBottom > clipTop then
            self:setStencilRect(10, clipTop, self.width - 20, clipBottom - clipTop)
            self:drawRect(10, y, self.width - 20, self.rowHeight - 6, .95, .025, .025, .025)
            local center = self.width / 2 - cardWidth / 2
            local first = math.max(1, math.floor((10 - center + offset) / cardWidth) + 1)
            local last = math.min(#reel, math.ceil((self.width - 10 - center + offset) / cardWidth))
            for i = first, last do
                local x = self.width / 2 - cardWidth / 2 + (i - 1) * cardWidth - offset
                if x + cardWidth >= 10 and x < self.width - 10 then
                    local card = reel[i]
                    local color = card.color
                    self:drawRect(x + 2, y + 2, cardWidth - 4, self.rowHeight - 10, .12 + .2 * pulse, color.r, color.g, color.b)
                    self:drawRectBorder(x + 2, y + 2, cardWidth - 4, self.rowHeight - 10, .5 + .5 * pulse, color.r, color.g, color.b)
                    if card.texture then
                        self:drawTextureScaledAspect(card.texture, x + cardWidth / 2 - 14, y + 8, 28, 28, 1, 1, 1, 1)
                    end
                    for n = 1, #card.lines do
                        self:drawTextCentre(card.lines[n], x + cardWidth / 2, y + 40 + (n - 1) * self.fontHeight,
                            color.tr, color.tg, color.tb, 1, UIFont.Small)
                    end
                end
            end
            if not reel.settledAt then
                self:drawRect(self.width / 2 - 1, y, 2, 8, 1, 1, 1, 1)
                self:drawRect(self.width / 2 - 1, y + self.rowHeight - 14, 2, 8, 1, 1, 1, 1)
            end
            self:clearStencilRect()
        end
    end
end

---@param player IsoPlayer Recipient
---@param rewards table Already granted items
---@return table panel
function Panel.show(player, rewards)
    local index = player:getPlayerNum()
    if active[index] then
        active[index]:close()
    end
    local width = math.min(540, getPlayerScreenWidth(index) - 20)
    local fontHeight = getTextManager():getFontHeight(UIFont.Small)
    local rowHeight = 52 + fontHeight * 3
    local height = math.min(40 + P.COUNT * rowHeight + 42, getPlayerScreenHeight(index) - 20)
    local panel = ISPanel.new(Panel, getPlayerScreenLeft(index) + (getPlayerScreenWidth(index) - width) / 2,
        getPlayerScreenTop(index) + (getPlayerScreenHeight(index) - height) / 2, width, height)
    panel:initialise()
    panel.playerIndex, panel.started = index, getTimestampMs()
    panel.fontHeight, panel.rowHeight, panel.cardWidth = fontHeight, rowHeight, math.min(180, width - 20)
    panel.offset, panel.lastTick = 0, panel.started
    panel.backgroundColor = {r = .04, g = .04, b = .04, a = .96}
    panel.moveWithMouse = true
    panel.reels = {}
    local entries, total = P.pool()
    local cards = {}
    local names = {}
    for i = 1, #entries do
        names[entries[i].name] = true
    end
    local highestBand = 1
    for i = 1, #rewards do
        local name = T.component(rewards[i]:getFullType())
        names[name] = true
        highestBand = math.max(highestBand, R.get(name).band)
    end
    panel.revealCue = "OMHTTPack" .. R.names[highestBand]
    for name in pairs(names) do
        local item = getScriptManager():getItem(T.TYPES[name])
        local wrapped = getTextManager():WrapText(UIFont.Small, item:getDisplayName(), panel.cardWidth - 14)
        local lines = string.split(wrapped, "\n")
        cards[name] = {lines = lines, texture = item:getNormalTexture(), color = R.get(name)}
        panel.rowHeight = math.max(panel.rowHeight, 52 + #lines * fontHeight)
    end
    panel.maxOffset = math.max(0, P.COUNT * panel.rowHeight - (height - 82))
    for row = 1, #rewards do
        local reel = {position = 0, crossed = 0}
        for i = 1, WINNER_CARD + 2 do
            local name = T.component(rewards[row]:getFullType())
            if i ~= WINNER_CARD and total > 0 then
                name = P.pick(entries, total, ZombRandFloat(0, 1))
            end
            reel[i] = cards[name]
        end
        panel.reels[row] = reel
    end
    local collect = ISButton:new(12, height - 34, width - 24, 24, getText("UI_OMHTT_PackSkip"), panel, Panel.activate)
    collect.backgroundColor = {r = .12, g = .12, b = .12, a = .9}
    collect.backgroundColorMouseOver = {r = .22, g = .22, b = .22, a = 1}
    collect:initialise()
    panel:addChild(collect)
    panel.collectButton = collect
    if panel.maxOffset > 0 then
        for direction = -1, 1, 2 do
            local button = ISButton:new(width - 44 + direction * 15, 8, 26, 24,
                direction < 0 and "^" or "v", panel, Panel.scroll)
            button.direction = direction
            button:initialise()
            panel:addChild(button)
        end
    end
    panel:addToUIManager()
    active[index] = panel
    return panel
end

return Panel
