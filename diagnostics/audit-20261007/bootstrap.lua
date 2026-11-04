modules = {}
function assert(value, message) if not value then error(message or 'audit assertion failed') end; return value end
if not math.min then function math.min(a,b) if a < b then return a end; return b end end
if not math.max then function math.max(a,b) if a > b then return a end; return b end end
function require(name) return assert(modules[name], name) end
function isClient() return false end
function isServer() return false end
clock = 1000
function getTimestampMs() return clock end
GameTime = {isGamePaused = function() return false end}
Events = {OnTick = {Add = function() end}, OnOMHTTTurretChanged = {Add = function() end}}
queries, inventories, rays = 0, 0, 0
origin = {getX = function() return 0 end, getY = function() return 0 end, getZ = function() return 0 end,
    getMovingObjects = function() return {size = function() return 0 end} end}
cell = {getGridSquare = function() queries = queries + 1; return origin end}
function getCell() return cell end
state = {aimDegrees = 0}
object = {getSquare = function() return origin end, getObjectIndex = function() return 1 end,
    getContainer = function() return {} end}
target = {getX = function() return 1 end, getY = function() return .5 end, getSquare = function() return origin end}
contents = {active = {}}
modules['OMHTT/Turret'] = {state = function() return state end,
    contents = function() inventories = inventories + 1; return contents end,
    turnSpeed = function() return 30 end}
modules['OMHTT/TurretClock'] = {now = function() return clock end}
modules['OMHTT/TurretModules'] = {option = function(_, fallback) return fallback end,
    detects = function() return true end, inside = function() return true, 1 end,
    profile = function() return {heading = 0, cone = 90, range = 6, priority = 'Random'} end}
modules['OMHTT/Diagnostics'] = {defer = function() end}
modules['OMHTT/Foundation'] = {}
modules['OMHTT/PrototypeCombat'] = {clearLane = function() rays = rays + 1; return true end}
modules['OMHTT/TurretWorld'] = {contents = function() return contents end,
    valid = function() return true end, power = function() return true end}
modules['OMHTT/TurretSearch'] = {pending = {}}
