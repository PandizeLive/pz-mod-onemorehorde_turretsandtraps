__modules = {}
if not math.min then function math.min(a, b) if a < b then return a end return b end end
if not math.max then function math.max(a, b) if a > b then return a end return b end end
-- Standalone Kahlua registration omits the game's supplemental Lua standard library.
if not table.sort then
    function table.sort(values, compare)
        if not compare then compare = function(a, b) return a < b end end
        for i = 2, #values do
            local value = values[i]
            local j = i - 1
            while j >= 1 and compare(value, values[j]) do
                values[j + 1] = values[j]
                j = j - 1
            end
            values[j + 1] = value
        end
    end
end
pairs = table.pairs
testMode = "sp"
testAssertions = 0
testPackets = {}
testResults = {}
testSquares = {}
testData = nil
testLoaded = true
testTime = 100
testMillis = 1000
testLogs = {}
testDialogs = 0
function print(value) testLogs[#testLogs + 1] = tostring(value) end
function getTimestampMs() return testMillis end
function getMouseXScaled() return 400 end
function getMouseYScaled() return 300 end
IsoDirections = {N = "N", S = "S", E = "E", W = "W"}
FBORenderChunk = {DIRTY_REDRAW = 1, DIRTY_OBJECT_MODIFY = 256, DIRTY_OBJECT_ADD = 64}
IsoUtils = {XToIso = function() return 400 end, YToIso = function() return 300 end, XToScreen = function(x, y, z, ignored) return x end, YToScreen = function(x, y, z, ignored) return y end}
IsoCamera = {getOffX = function() return 0 end, getOffY = function() return 0 end}
testAdmin = true
testPlayer = {x = 100.5, y = 100.5, z = 0, dead = false}
SandboxVars = {OMHTurretsTraps = {FoundationTestControls = true}}
Capability = {UseDebugContextMenu = "debug"}

function check(value, message)
    testAssertions = testAssertions + 1
    if not value then error(message) end
end

function require(name)
    return __modules[name]
end

function isClient() return testMode == "client" end
function isServer() return testMode == "server" end
function getCore()
    return {
        getVersionNumber = function() return "42.20-test-double" end,
        isOption3DGroundItem = function() return false end,
        getScreenWidth = function() return 1280 end,
        getScreenHeight = function() return 720 end,
        getZoom = function() return 1 end,
    }
end

function testPlayer:isDead() return self.dead end
function testPlayer:getX() return self.x end
function testPlayer:getY() return self.y end
function testPlayer:getZ() return self.z end
function testPlayer:getUsername() return "foundation-tester" end
function testPlayer:getPlayerNum() return 0 end
function testPlayer:setHaloNote(text, r, g, b, duration) testHalo = text end
function testPlayer:getRole() return {hasCapability = function() return testAdmin end} end
function getSpecificPlayer(index) return testPlayer end

Events = {}
Events.OnObjectAdded = {handlers = {}, Add = function() end}
for _, name in pairs({"OnInitGlobalModData", "LoadGridsquare", "OnObjectAboutToBeRemoved", "OnClientCommand", "OnServerCommand", "OnFillWorldObjectContextMenu", "OnGameStart", "OnTick", "OnPostRender", "OnPreUIDraw", "OnPostUIDraw", "OnZombieCreate", "OnZombieUpdate", "OnZombieDead", "OnContextKey", "OnPlayerUpdate"}) do
    local handlers = {}
    Events[name] = {handlers = handlers, Add = function(callback) table.insert(handlers, callback) end}
end
LuaEventManager = {AddEvent = function(name)
    local handlers = {}
    Events[name] = {handlers = handlers, Add = function(callback) table.insert(handlers, callback) end}
end}
Vector2 = {new = function(x, y) return {x = x, y = y} end}

function triggerEvent(name, ...)
    if name == "OnServerCommand" then
        local args = {...}
        table.insert(testResults, args[3])
    end
    local handlers = Events[name].handlers
    for i = 1, #handlers do handlers[i](...) end
end

ModData = {getOrCreate = function(key)
    if testData == nil then testData = {} end
    return testData
end}

function sendServerCommand(player, module, command, args)
    table.insert(testPackets, args)
    table.insert(testResults, args)
end

function sendClientCommand(player, module, command, args)
    table.insert(testPackets, args)
    testLastCommand = {player = player, module = module, command = command, args = args}
end

function makeSquare(x, y, z)
    local square = {x = x, y = y, z = z, objects = {}, moving = {}, floor = true, free = true, blocked = false, window = false}
    function square:getX() return self.x end
    function square:getY() return self.y end
    function square:getZ() return self.z end
    function square:getFloor() return self.floor end
    function square:isFree(ignore) return self.free end
    function square:HasStairs() return false end
    function square:HasStairsBelow() return false end
    function square:isVehicleIntersecting() return false end
    function square:has() return false end
    function square:testCollideAdjacent(player, dx, dy, dz)
        local other = testSquares[tostring(self.x + dx) .. ":" .. tostring(self.y + dy) .. ":" .. tostring(self.z + dz)]
        return not other or self.blocked or other.blocked
    end
    function square:getSpecialObjects() return self:getObjects() end
    function square:isBlockedTo(other) return self.blocked or other.blocked end
    function square:isWindowTo(other) return self.window or other.window end
    function square:getMovingObjects()
        local objects = self.moving
        return {size = function() return #objects end, get = function(self, index) return objects[index + 1] end}
    end
    function square:getObjects()
        local objects = self.objects
        return {size = function() return #objects end, get = function(self, index) return objects[index + 1] end}
    end
    function square:AddTileObject(object) table.insert(self.objects, object) end
    function square:AddSpecialObject(object) self:AddTileObject(object) end
    function square:RecalcAllWithNeighbours(value) self.recalculated = true end
    function square:setSquareChanged() self.changed = true end
    function square:transmitRemoveItemFromSquare(object)
        check(not testRemoving, "nested world removal inside native callback")
        testRemoving = true
        triggerEvent("OnObjectAboutToBeRemoved", object)
        testRemoving = false
        for i = #self.objects, 1, -1 do
            if self.objects[i] == object then table.remove(self.objects, i) end
        end
        object.removed = true
    end
    testSquares[tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)] = square
    return square
end

function getCell()
    return {getGridSquare = function(self, x, y, z)
        if not testLoaded then return nil end
        return testSquares[tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)]
    end}
end

IsoObject = {new = function(square, sprite, name)
    local object = {square = square, sprite = sprite, name = name, data = {}, removed = false}
    function object:getName() return self.name end
    function object:getSpriteName() return self.sprite end
    function object:getOffsetX() return 64 end
    function object:getOffsetY() return 192 end
    function object:invalidateRenderChunkLevel(reason) self.renderInvalidated = reason end
    function object:getSprite()
        if self.noSprite then return nil end
        return {getID = function() return 1918369792 end, getTextureForCurrentFrame = function()
            if self.noTexture then return nil end
            return {
                isReady = function() return not self.texturePending end,
                getName = function() return self.sprite end,
                getWidth = function() return 128 end, getHeight = function() return 256 end,
                getWidthOrig = function() return 128 end, getHeightOrig = function() return 256 end,
                getOffsetX = function() return 0 end, getOffsetY = function() return 0 end,
            }
        end}
    end
    function object:setName(value) self.name = value end
    function object:setSprite(value) self.sprite = value end
    function object:setSpriteFromName(value) self.sprite = value end
    function object:getSpriteConfig()
        if not string.find(self.sprite, "omhtt_barrier_01_", 1, true) then return nil end
        local object = self
        return {isValid = function() return true end,
            getTileInfo = function() return {getSpriteName = function() return object.sprite end} end,
            getObjectInfo = function() return {getName = function()
                local index = tonumber(string.match(object.sprite, "_(%d+)$"))
                if index >= 20 then return "OMHTTDeployReinforcedBarrier" end
                if index >= 8 then return "OMHTTDeploySpikeBarrier" end
                return "OMHTTSpikeBarrier"
            end} end}
    end
    function object:transmitUpdatedSpriteToClients() self.spriteSent = true end
    function object:getSquare() return self.square end
    function object:getModData() return self.data end
    function object:getProperties() return nil end
    function object:hasModData() return true end
    function object:setOutlineOnMouseover(value) self.outline = value end
    function object:transmitCompleteItemToClients() self.sent = true end
    function object:transmitModData() self.synced = true end
    function object:getObjectIndex()
        if self.removed then return -1 end
        return 1
    end
    return object
end}

IsoThumpable = {new = function(cell, square, sprite, north)
    local object = IsoObject.new(square, sprite, "")
    object.kind = "IsoThumpable"
    function object:getNorth() return north end
    function object:isTallHoppable() return false end
    function object:setBlockAllTheSquare(value) self.blockAll = value end
    function object:setCanPassThrough(value) self.passThrough = value end
    function object:setIsHoppable(value) self.hoppable = value end
    function object:setIsThumpable(value) self.thumpable = value end
    function object:setMaxHealth(value) self.maxHealth = value end
    function object:setHealth(value) self.health = value end
    function object:getHealth() return self.health end
    function object:getMaxHealth() return self.maxHealth end
    function object:isBlockAllTheSquare() return self.blockAll end
    function object:isCanPassThrough() return self.passThrough end
    function object:isHoppable() return self.hoppable end
    function object:isThumpable() return self.thumpable end
    function object:setBreakSound(value) self.breakSound = value end
    function object:setIsDismantable(value) self.dismantable = value end
    return object
end}

function getGameTime() return {getWorldAgeHours = function() return testTime end} end
testRoll = 0
function ZombRand(maximum) return testRoll end
function instanceof(object, kind) return object.kind == kind end
function instanceItem(name)
    return {
        setRanged = function() end,
        setKnockBackOnNoDeath = function() end,
        setSplatBloodOnNoDeath = function() end,
    }
end

function makeZombie(square, health)
    local zombie = {kind = "IsoZombie", square = square, health = health, floor = false, data = {}, hits = 0,
        kills = 0, variables = {ThumpType = "Door"}, state = "thump"}
    function zombie:getSquare() return self.square end
    function zombie:getX() return self.square.x + 0.5 end
    function zombie:getY() return self.square.y + 0.5 end
    function zombie:getZ() return self.square.z end
    function zombie:getHealth() return self.health end
    function zombie:setHealth(value) self.health = value end
    function zombie:isDead() return self.health <= 0 end
    function zombie:isOnFloor() return self.floor end
    function zombie:setKnockedDown(value) self.knocked = value end
    function zombie:isKnockedDown() return self.knocked == true end
    function zombie:knockDown(behind) self.knocked = true; self.nativeKnockdown = true end
    function zombie:setPlayerAttackPosition(position) self.attackPosition = position end
    function zombie:setUsePhysicHitReaction(value) self.physics = value end
    function zombie:usePhysicHitReaction() return self.physics == true end
    function zombie:canRagdoll() return self.allowRagdoll == true end
    function zombie:isRagdoll() return self.ragdoll == true end
    function zombie:getCurrentStateName() return self.state end
    function zombie:getThumpTarget() return self.thumpTarget end
    function zombie:getVariableString(name) return self.variables[name] end
    function zombie:setVariable(name, value) self.variables[name] = value end
    function zombie:clearVariable(name) self.variables[name] = nil end
    function zombie:setHitDir(value) self.hitDirection = value end
    function zombie:setHitForce(value) self.hitForce = value end
    function zombie:hasModData() return true end
    function zombie:getModData() return self.data end
    function zombie:hitConsequences(weapon, player, ignored, damage, remote)
        if not ignored then self.health = self.health - damage end
        self.hits = self.hits + 1
        if self.health <= 0 then self:Kill(player, false) end
    end
    function zombie:Kill(killer, gory)
        self.health = 0
        self.kills = self.kills + 1
        triggerEvent("OnZombieDead", self)
    end
    square.moving[#square.moving + 1] = zombie
    triggerEvent("OnZombieCreate", zombie)
    return zombie
end

function getText(key, ...) return nativeText(key, ...) end
ISModalRichText = {new = function(self, x, y, width, height, text, yesno)
    return {
        initialise = function() end,
        addToUIManager = function() testDialog = text; testDialogs = testDialogs + 1 end,
        removeFromUIManager = function() end,
    }
end}
ISContextMenu = {getNew = function(self, parent) return parent end}
testMenu = {options = {}}
function testMenu:addOption(name, target, callback, command)
    local option = {name = name, target = target, callback = callback, command = command}
    self.options[name] = option
    return option
end
function testMenu:addSubMenu(option, menu) end

function testPlayer:isRunning() return self.running == true end
function testPlayer:isSprinting() return self.sprinting == true end
function testPlayer:getVehicle() return nil end
function testPlayer:isIgnoreAutoVault() return false end
function testPlayer:isGrappling() return false end
function testPlayer:isPlayerMoving() return false end
function testPlayer:pressedMovement() return self.pressed == true end
function testPlayer:getFeelersize() return 0.5 end
function testPlayer:getDir() return IsoDirections.E end
function testPlayer:isSafeToClimbOver() return true end

IsoFlagType = {water="water", solid="solid", solidtrans="solidtrans", collideN="collideN", collideW="collideW", WallN="WallN", WallW="WallW"}

function getSprite(name) return {getProperties = function() return {set = function() end, unset = function() end} end} end
IsoFlagType.FloorOverlay = "FloorOverlay"
function getWorld() return {getFreeEmitter = function() return {playSound = function() return 1 end, setPitch = function() end, setVolume = function() end} end} end
function getSoundManager() return {PlayWorldSound = function() end} end

UIFont = {Small="small"}
function getTextManager() return {DrawStringCentre = function() testDraws = testDraws + 1 end} end

function getScriptManager()
    return {getAllItems = function() return {size = function() return 0 end} end}
end
