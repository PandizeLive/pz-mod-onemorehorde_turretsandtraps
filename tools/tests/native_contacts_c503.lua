-- Native actors/objects and real OnTick delivery on an isolated, empty dedicated server.
-- The square lookup is a fixture map; no client transport or rendered acceptance is claimed.
return function()
    local nativeCell, nativeGetCell = getCell(), getCell
    local squares, actors = {}, {}
    for x = 59, 72 do
        for y = 19, 24 do
            local square = IsoGridSquare.new(nativeCell, nil, x, y, 0)
            local chunk = IsoChunk.new(nativeCell)
            chunk:assignLoadID()
            chunk:setSquare(x % 8, y % 8, 0, square)
            squares[x .. ":" .. y .. ":0"] = square
        end
    end
    getCell = function()
        return {getZombieList=function() return {size=function() return #actors end,get=function(_,i) return actors[i+1] end} end, getGridSquare = function(_,x,y,z) return squares[x .. ":" .. y .. ":" .. z] end}
    end
    local function object(x,y,sprite)
        local square = squares[x .. ":" .. y .. ":0"]
        local result = IsoThumpable.new(nativeCell,square,sprite,false)
        square:getObjects():add(result)
        square:getSpecialObjects():add(result)
        return result
    end
    local function zombie(x,y,health)
        local actor = IsoZombie.new(nativeCell)
        actors[#actors+1] = actor
        local square = squares[x .. ":" .. y .. ":0"]
        actor:setX(x+.5); actor:setY(y+.5); actor:setZ(0); actor:setCurrent(square)
        actor:setHealth(health)
        actor:getModData().OMHTTPackRolled = true
        square:getMovingObjects():add(actor)
        require("OMHTT/TargetHealth").created(actor)
        return actor
    end
    local Beds, Wire = require("OMHTT/BedSpikes"), require("OMHTT/BarbSections")
    local bed = object(60,20,"omhtt_barrier_01_64")
    Beds.onCreate({thumpable=bed,facing="e"})
    local first, last = object(62,20,"omhtt_barrier_01_60"), object(62,21,"omhtt_barrier_01_72")
    Wire.onWireCreate({thumpable=first}); Wire.onWireCreate({thumpable=last})
    assert(Beds.record(bed) and Wire.record(first), "Native contact fixtures failed placement")
    local bedActor, wireActor, tackActor = zombie(60,20,2), zombie(62,20,2), zombie(65,20,2)
    bedActor:setCurrent(squares["61:20:0"])
    wireActor:setCurrent(squares["63:20:0"])
    tackActor:setCurrent(squares["66:20:0"])
    local E, Clock = require("OMHTT/TurretProc"), require("OMHTT/TurretClock")
    local function field(id,x)
        local now = Clock.now()
        local f = {id=id,x=x+.5,y=20.5,z=0,radius=.8,damage=10,source="c503-native",starts=now,expires=now+20000,sounded=true}
        E.fields[id], E.fieldCount = f, E.fieldCount+1
        E.fieldOrder[#E.fieldOrder+1] = f
        E.index(f,true)
    end
    field("c503-tack",65)
    field("c503-overlap",62)
    local root, victim, child = zombie(68,20,0), zombie(69,20,.1), zombie(70,20,.05)
    local stats = require("OMHTT/TurretStats").resolve({active={Martyrdom=1,Synergy=1}})
    local shot = {stats=stats}
    E.reserve(shot)
    E.hit(root,true,68.5,20.5,0,{id="c503-native-martyr"},nil,shot)
    E.release(shot)
    local started, phase, contactCalls = getTimestampMs(), 0, 0
    local dead = {}
    local function damage(actor,lost,source,kind)
        if actor:isDead() then
            dead[actor] = actor:isOnDeathDone()
            -- Native cell lists drop dead actors; the synthetic list must too.
            for i = #actors, 1, -1 do if actors[i] == actor then table.remove(actors,i) end end
        end
        if actor == bedActor or actor == wireActor or actor == tackActor then
            assert(lost > 0, "Native contact callback reported no damage")
            contactCalls = contactCalls + 1
        end
    end
    Events.OnOMHTTDamage.Add(damage)
    local step
    step = function()
        local elapsed = getTimestampMs() - started
        assert(elapsed < 30000, "Native contact timeout phase=" .. phase .. " bed=" .. bedActor:getHealth()
            .. " wire=" .. wireActor:getHealth() .. " tack=" .. tackActor:getHealth()
            .. " martyr=" .. tostring(dead[victim]) .. " child=" .. tostring(dead[child])
            .. " floor=" .. tostring(bedActor:isOnFloor()) .. " x=" .. bedActor:getX() .. " y=" .. bedActor:getY())
        local observed = require("OMHTT/DefenseActorState").peek(bedActor)
        if phase == 0 and wireActor:getHealth() < 2 and tackActor:getHealth() < 2
            and observed and observed.OMHTTBedContact then
            assert(bedActor:getHealth() == 2, "Upright stationary bed contact damaged before landing")
            assert(wireActor:getHealth() < 2 and tackActor:getHealth() < 2, "Real server tick failed wire/Tack contact")
            assert(math.abs(wireActor:getHealth()-1.9) < .0001, "Overlapping Tack doubled wire damage")
            bedActor:setOnFloor(true)
            phase = 1
        elseif phase == 1 and bedActor:getHealth() < 2 and dead[victim] then
            assert(math.abs(bedActor:getHealth()-1.8) < .0001, "Real server tick failed landed bed damage")
            assert(dead[victim], "Native Martyrdom root burst failed terminal damage")
            phase = 2
        elseif phase == 2 and dead[child] and wireActor:getHealth() < 1.85 and tackActor:getHealth() < 1.85 then
            assert(dead[child], "Native scheduled Synergy child failed")
            assert(math.abs(bedActor:getHealth()-1.8) < .0001, "Bed repeated damage without another fall")
            assert(wireActor:getHealth() < 1.85 and tackActor:getHealth() < 1.85 and contactCalls >= 5,
                "Real tick did not repeat continuous wire/Tack contact")
            getCell = nativeGetCell
            Events.OnTick.Remove(step)
            Events.OnOMHTTDamage.Remove(damage)
            print("[OMHTT-C503] native-contacts event=OnTick bed=landing-once wire=repeat tack=repeat overlap=single martyrdom=root-and-synergy clients=0 predictedMembership=divergent")
        end
    end
    Events.OnTick.Add(step)
end
