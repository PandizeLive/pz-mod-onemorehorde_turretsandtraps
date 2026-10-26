local function run(panel, player, controller)
    local G = require("OMHTT/WindowGeometry")
    local Graph = require("OMHTT/ControlGraph")
    local U = require("OMHTT/ControlClient")
    local A = require("OMHTT/ControlAccess")
    local savedCommand, savedRemote = U.command, U.remote
    local commands, renewals = 0, 0
    U.command = function() commands = commands + 1 end
    U.remote = function() renewals = renewals + 1; return true end
    local inventory = panel.stockWing.inventoryPane.inventory
    -- UIElement.update dispatches every child's update with that child's table.
    -- Calling only Graph's owner-side helper missed the 0.2.55 callback collision.
    local function uiTick(widget)
        if widget.update then widget:update() end
        for i = 1, #(widget.children or {}) do uiTick(widget.children[i]) end
    end
    for i = 1, 600 do uiTick(panel) end
    check(commands == 0 and renewals == 0, "600 native-style recursive UI updates complete without errors or commands")
    local savedMap = {rules=SandboxVars.Map, native=UIWorldMap, item=MapItem, utils=MapUtils,
        dirs=getLotDirectories, exists=fileExists}
    local opens, files = 0, 0
    SandboxVars.Map = {AllowWorldMap=true}
    getLotDirectories = function() return {size=function() return 1 end,get=function() return "test-map" end} end
    fileExists = function() files=files+1; return true end
    MapItem = {getSingleton=function() return {} end}
    MapUtils = {initDefaultStyleV1=function() end}
    local api = {data=0,images=0,options={}}
    function api:setMapItem(item) self.item=item end
    function api:addData(path) self.data=self.data+1 end
    function api:endDirectoryData() end
    function api:addImages(path) self.images=self.images+1 end
    function api:getDataCount() return self.data end
    function api:getImagesCount() return self.images end
    function api:setBoundsFromWorld() end
    function api:setMaxZoom(value) self.maxZoom=value end
    function api:setZoom(value) self.zoom=value end
    function api:setBoolean(key,value) self.options[key]=value end
    function api:centerOn(x,y) self.x,self.y=x,y end
    UIWorldMap = {new=function()
        opens=opens+1
        return {getAPIv3=function() return api end,setX=function() end,setY=function() end,
            setWidth=function() end,setHeight=function() end,setConsumeMouseEvents=function() end}
    end}
    local Map = require("OMHTT/ControlMap")
    local native = Map.create(panel)
    for i=1,100 do native:loadNative(); native:prerender() end
    check(native.nativeMode and opens==1 and files==1 and api.data==1 and api.images==1,
        "In-game map opens by default and loads its data once, never during repeated UI draws")
    check(api.options.HideUnvisited==true and api.options.ImagePyramid==false,
        "Default map preserves visited-area visibility without satellite images")
    local expansion=require("OMHTT/ControlExpansion")
    local oldGrade,oldRange,oldKit=expansion.grade,SandboxVars.OMHTurretsTraps.ControllerRange,SandboxVars.OMHTurretsTraps.ControllerKitRange
    SandboxVars.OMHTurretsTraps.ControllerRange,SandboxVars.OMHTurretsTraps.ControllerKitRange=10,10
    local oldGraph=native.owner.graph
    native.owner.graph={markers={},edges={}}
    for grade=0,4 do
        expansion.grade=function() return grade end
        for _,zoom in pairs({2,7,19}) do
            api.worldToUIX=function(_,x) return (x-native.centerX)*zoom+native.width/2 end
            api.worldToUIY=function(_,x,y) return (y-native.centerY)*zoom+native.height/2 end
            local segments=0
            native.drawLine=function(_,texture,x1,y1,x2,y2)
                segments=segments+1
            end
            native:render()
            check(segments==0 and A.radius(controller)==10+grade*10,"No Controller circle is drawn; authoritative radius is unchanged")
        end
    end
    expansion.grade,SandboxVars.OMHTurretsTraps.ControllerRange,SandboxVars.OMHTurretsTraps.ControllerKitRange=oldGrade,oldRange,oldKit
    native.owner.graph=oldGraph
    local menuBefore, hitBefore, routed = Graph.menu, native.hit, 0
    Graph.menu = function(owner, object) check(owner==panel and object==controller, "Map forwards the exact selected device"); routed=routed+1 end
    native.hit = function() return controller end
    check(native.nativeMap:onRightMouseDown(5,5) and native.nativeMap:onRightMouseUp(5,5)
        and routed==1, "Native child right-button callbacks route one disconnect menu")
    Graph.menu, native.hit = menuBefore, hitBefore
    panel:removeChild(native)
    SandboxVars.Map = {AllowWorldMap=false}
    local unavailable = Map.create(panel)
    check(not unavailable.nativeMode and opens==1 and unavailable.tooltip==getText("UI_OMHTT_MapUnavailable"),
        "Disabled world maps keep device connections without repeatedly attempting map creation")
    panel:removeChild(unavailable)
    SandboxVars.Map,UIWorldMap,MapItem,MapUtils = savedMap.rules,savedMap.native,savedMap.item,savedMap.utils
    getLotDirectories,fileExists = savedMap.dirs,savedMap.exists
    for _, width in pairs({900, 1050, 1220}) do
        G.resize(panel, width, 690)
        check(panel.stockWing.inventoryPane.inventory == inventory, "Resize retains exact native Stockpile container")
        check(panel.graph.x + panel.graph.width < panel.mapView.x
            and panel.mapView.y + panel.mapView.height < panel.detailBody.y,
            "Resized Connections, Map and Selected Device occupy separate regions")
        for _, section in pairs({panel.graph, panel.detailBody}) do
            local bar = section.vscroll
            check(bar.x + bar.width == section.width and bar.y == 0 and bar.height == section.height
                and bar.anchorRight == false and bar.anchorBottom == false and bar.doSetStencil == false,
                "Scrollbar stays at its section edge without deferred anchoring or escaping its parent stencil")
        end
        for i = 1, #panel.children do
            local child = panel.children[i]
            check(child.visible == false or (child.x >= 0 and child.y >= 0 and child.x + child.width <= panel.width
                and child.y + child.height <= panel.height), "Visible resized Controller children remain inside window")
        end
        if not panel.stockCompact then
            check(panel.stockWing.x > panel.mapView.x + panel.mapView.width
                and panel.stockWing.y < panel.mapView.y
                and panel.stockWing.y + panel.stockWing.height >= panel.detailBody.y + panel.detailBody.height,
                "Desktop Stockpile extends alongside Map and Selected Device")
        end
    end
    check(commands == 0 and renewals == 0, "Resizing sends no gameplay or remote-session commands")
    local screenWidth, screenLeft = getPlayerScreenWidth, getPlayerScreenLeft
    getPlayerScreenWidth = function() return 960 end
    getPlayerScreenLeft = function() return 1280 end
    G.checkViewport(panel)
    check(panel.x >= 1288 and panel.x + panel.width <= 2232 and panel.width <= 944,
        "Live viewport change clamps existing window to its player's bounds")
    check(commands == 0 and renewals == 0, "Viewport clamp sends no commands")
    getPlayerScreenWidth, getPlayerScreenLeft = screenWidth, screenLeft
    G.checkViewport(panel)
    G.resize(panel, 1220, 690)
    local stored = {}
    G.save(panel, "test", stored)
    G.resize(panel, 1050, 660)
    G.restore(panel, "test", stored)
    check(panel.width == stored.width and panel.height == stored.height and stored.object == nil,
        "Saved geometry restores dimensions without retaining device identity")
    panel.resizeGrip.resizing = true
    panel.resizeGrip:setCapture(true)
    panel.resizeGrip:onMouseUpOutside(9999, 9999)
    check(not panel.resizeGrip.resizing and not panel.resizeGrip.capture, "Installed native resize grip releases outside window")
    local mouseX, mouseY = getMouseX, getMouseY
    local mx, my = 100, 100
    getMouseX, getMouseY = function() return mx end, function() return my end
    local grip = panel.resizeGrip
    local originalX, originalY, originalWidth, originalHeight = panel.x, panel.y, panel.width, panel.height
    grip:onMouseDown(9, 9)
    mx, my = 20, 60
    grip:onMouseMove(-80, -40)
    local shrunkWidth, shrunkHeight = panel.width, panel.height
    for i = 1, 20 do grip:onMouseMove(0, 0) end
    check(panel.width == shrunkWidth and panel.height == shrunkHeight and panel.x == originalX and panel.y == originalY,
        "Stationary resize pointer cannot accumulate size or move the window")
    mx, my = 9999, 9999
    grip:onMouseMoveOutside(9979, 9939)
    check(panel.x == originalX and panel.y == originalY and panel.x + panel.width <= getPlayerScreenWidth(0) - 8,
        "Resize past screen edge stays anchored at original top-left")
    check(grip.anchorRight == false and grip.anchorBottom == false and grip.x == panel.width - grip.width and grip.y == panel.height - grip.height,
        "Resize handle uses explicit placement without native deferred anchors")
    grip:onMouseUpOutside(0, 0)
    G.resize(panel, originalWidth, originalHeight)
    getMouseX, getMouseY = mouseX, mouseY

    local function device(kind, id, dx)
        local object = setmetatable({data = {OMHTTControl = {id = id, kind = kind, owner = "ui-owner", access = "Private",
            controller = controller.data.OMHTTControl.id, links = {}, displayName = kind .. " #" .. id}},
            square = makeSquare(1950 + dx, 1950, 0)}, {__index = controller})
        function object:getSquare() return self.square end
        function object:getX() return self.square:getX() end
        return object
    end
    local input, output = device("Button", "map-input", 2), device("Turret", "map-output", 8)
    output.data.OMHTTControl.headType = "Base.OMHTTTurretBallista"
    output.data.OMHTTTurret = {schema = 1, id = "map-output", powered = false}
    panel.devices.items = {{item = controller}, {item = input}, {item = output}}
    panel.devices.selected = 1
    panel:select()
    panel.graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    check(#panel.graph.triggers == 1 and #panel.graph.defenses == 1
        and panel.graph.defenses[1].subtitle == getItemNameFromFullType(output.data.OMHTTControl.headType),
        "Connections separates inputs from receivers and preserves head subtitle")
    local map = panel.mapView
    map:focus(controller)
    local ix, iy = map:point(input:getX() + .5, input:getY() + .5)
    local ox, oy = map:point(output:getX() + .5, output:getY() + .5)
    check(ox > ix and oy == iy, "Map projection preserves world direction and aligned tiles")
    map:onMouseDown(ix, iy)
    map:onMouseUp(ix, iy)
    check(panel.selected == input and commands == 0, "Clicking map Button selects without activating its pulse")
    map:focus(controller)
    map:onMouseDown(ix, iy)
    map:onMouseUp(ox, oy)
    Graph.refreshForPanel(panel)
    check(commands == 1 and renewals >= 2 and panel.selected == output, "Map drag queues one existing authorized Link action")
    Graph.refreshForPanel(panel)
    check(commands == 1, "Subsequent refresh does not replay drag command")
    input.data.OMHTTControl.links = {"map-output"}
    Graph.connect(panel, input, output)
    Graph.refreshForPanel(panel)
    check(commands == 1, "Dropping an already connected pair does not toggle or duplicate its link")
    panel.graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    check(#panel.graph.edges == 1, "Published links appear in graph without a new world scan")
    map:focus(controller)
    map:onMouseDown(ix, iy)
    map:onMouseUpOutside(-100, -100)
    check(not map.dragObject and not map.capture and commands == 1, "Map outside release cancels drag")
    local oldPlayer, oldWalk, oldCell = getSpecificPlayer, luautils.walkAdjObject, getCell
    local pulses = 0
    getSpecificPlayer = function() return player end
    getCell = function() return {getDrag = function() return nil end} end
    luautils.walkAdjObject = function() return true end
    U.command = function(actor, device, command)
        check(actor == player and device == input and command == "Pulse", "World Button uses existing authoritative Pulse")
        pulses = pulses + 1
    end
    U.clicked(input)
    U.clicked(controller)
    luautils.walkAdjObject = function() return false end
    U.clicked(input)
    check(pulses == 1, "World Button click queues once; non-buttons and failed approach do not pulse")
    getSpecificPlayer, luautils.walkAdjObject, getCell = oldPlayer, oldWalk, oldCell
    U.command = function() commands = commands + 1 end
    local priorWrite = A.write
    A.write = function() return false end
    input.data.OMHTTControl.links = {}
    Graph.connect(panel, input, output)
    Graph.refreshForPanel(panel)
    check(commands == 1, "Read-only drag cannot submit a Link")
    A.write = priorWrite
    local graph = panel.graph
    local half, y = (graph.width - 88) / 2, graph.triggers[1].y + graph.rowHeight / 2
    local before, value = commands, nil
    U.command = function(actor, source, command, enabled, target)
        check(actor == player and source == input and target == output and command == "Link", "Graph uses exact authoritative endpoints")
        commands, value = commands + 1, enabled
    end
    graph:onMouseDown(12, y)
    graph:onMouseUp(half + 110, y)
    Graph.refreshForPanel(panel)
    check(commands == before, "Row dragging no longer creates connections")
    graph:onMouseDown(half - 13, y)
    graph:onMouseUp(half - 13, y)
    check(panel.linkSource == input, "Trigger handle click arms connection")
    graph:onMouseDown(half + 86, y)
    graph:onMouseUp(half + 86, y)
    Graph.refreshForPanel(panel)
    check(commands == before + 1 and value == true and panel.linkSource == nil, "Two handle clicks connect and consume armed source")
    input.data.OMHTTControl.links = {"map-output"}
    graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    graph:onMouseDown(half + 86, y)
    graph:onMouseUp(half + 86, y)
    Graph.refreshForPanel(panel)
    check(commands == before + 2 and value == false, "Connected defense handle removes its single link")
    graph:onMouseDown(half - 13, y)
    graph:onMouseUp(half - 13, y)
    graph:onMouseDown(half + 86, y)
    graph:onMouseUp(half + 86, y)
    Graph.refreshForPanel(panel)
    check(commands == before + 2, "Armed source never removes an already linked pair")
    input.data.OMHTTControl.links = {}
    Graph.refreshForPanel(panel)
    panel.linkSource = nil
    input.data.OMHTTControl.links = {"map-output"}
    local Groups = require("OMHTT/ControlGroupUI")
    local hostState = A.state(controller)
    local savedOrganization = hostState.organization
    hostState.organization = {revision=1,serial=2,groups={{id="1",name="Front"},{id="2",name="Rear"}},
        members={["map-input"]="1",["map-output"]="2"},order={"map-output","map-input"}}
    graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    check(graph.triggers[1].group == "1" and graph.defenses[1].group == "2" and #graph.edges == 1,
        "Shared groups lay out both columns without removing cross-group links")
    graph.collapsed["1"] = true
    Groups.layout(graph)
    check(graph.triggers[1].collapsed and graph.positions["map-input"] == 1,
        "Collapsed groups retain connection endpoints")
    graph.collapsed = {}
    Groups.layout(graph)
    for _,scroll in pairs({0,-18}) do
        graph:setYScroll(scroll)
        local group=graph.groups[scroll==0 and 1 or 2]
        local title=group.y+5
        local body=group.y+group.header+12
        local gap=graph.width/2
        graph:onMouseDown(gap,body);graph:onMouseUp(gap,body)
        check(not graph.collapsed[group.id],"Blank group body does not collapse, including after scrolling")
        graph:onMouseDown(gap,title);graph:onMouseUp(gap,body)
        check(not graph.collapsed[group.id],"Title press followed by body release does not collapse")
        graph:onMouseDown(gap,title);graph:onMouseUp(gap,title)
        check(graph.collapsed[group.id],"Same title click collapses at native scrolled coordinates")
        graph.collapsed[group.id]=nil
    end
    graph:setYScroll(0)
    local proposed = {revision=2,serial=2,groups={{id="1",name="New Front"},{id="2",name="Rear"}},members={},order={}}
    check(Groups.applied({expected=proposed},proposed), "Matching group confirmation succeeds")
    check(not Groups.applied({expected=proposed},hostState.organization), "Concurrent differing group update is not reported as success")
    hostState.organization.members["map-input"] = "deleted"
    Groups.layout(graph)
    check(graph.triggers[1].group == "", "Stale group membership falls back to Ungrouped")
    hostState.organization = savedOrganization
    graph.collapsed = {}
    graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    local extra = device("Plate", "second-input", 3)
    extra.data.OMHTTControl.links = {"map-output"}
    panel.devices.items[#panel.devices.items + 1] = {item=extra}
    graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    local previousMenu, choices = ISContextMenu, {}
    ISContextMenu = {getNew=function() return {addOption=function() end} end,get=function() return {addSubMenu=function() end,bringToTop=function() end,addOption=function(self,title,owner,callback,source,target)
        choices[#choices+1]={title=title,owner=owner,callback=callback,source=source,target=target}
    end} end}
    local previousX, previousY = getMouseX, getMouseY
    getMouseX, getMouseY = function() return 100 end, function() return 100 end
    Graph.outputPort(panel, output)
    check(#choices == 4 and commands == before + 2, "Multiple incoming links require choosing one rather than deleting all")
    choices = {}
    local hitBefore = panel.mapView.hit
    panel.mapView.hit = function() return output end
    panel.mapView:onRightMouseDown(10,10)
    panel.mapView:onRightMouseUp(10,10)
    check(#choices==4 and choices[1].title==getText("UI_OMHTT_All"), "Map receiver exposes the same All and individual disconnections")
    panel.mapView.hit = hitBefore
    choices[2].callback(choices[2].owner, choices[2].source, choices[2].target)
    Graph.refreshForPanel(panel)
    check(commands == before + 3 and value == false, "Chosen incoming connection alone is removed")
    ISContextMenu, getMouseX, getMouseY = previousMenu, previousX, previousY
    U.command = function() commands = commands + 1 end

    local stats = require("OMHTT/ControlGraphStats")
    local oldContainer, reads = output.getContainer, 0
    local round = {getFullType=function() return "Base.Bullets9mm" end}
    local rounds = {size=function() return 2048 end,get=function() reads=reads+1; return round end}
    local storage = {getItems=function() return rounds end}
    output.getContainer = function() return storage end
    local sampler = {defenses={{object=output}},stats={},statsIndex=1,statsDue=0}
    stats.step(sampler)
    check(reads <= 128 and sampler.statsJob ~= nil and sampler.stats[output] == nil, "Large ammo scan yields after at most 128 item reads")
    for i=1,16 do stats.step(sampler) end
    check(sampler.stats[output] ~= nil and sampler.statsJob == nil, "Bounded ammo scan completes across frames")
    output.getContainer = oldContainer
    panel.devices.items = {{item = controller}}
    for i = 1, 32 do
        panel.devices.items[#panel.devices.items + 1] = {item = device("Plate", "input-" .. i, 1)}
        panel.devices.items[#panel.devices.items + 1] = {item = device("Turret", "output-" .. i, 2)}
        local source = panel.devices.items[#panel.devices.items - 1].item.data.OMHTTControl
        for j = 1, 32 do source.links[j] = "output-" .. j end
    end
    panel.graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    panel.graph:onMouseWheel(100)
    check(panel.graph:getYScroll() < 0 and #panel.graph.triggers == 32 and #panel.graph.defenses == 32,
        "Full 32-input / 32-output lists scroll together within their bounded view")
    local graphItems = panel.graph.triggers
    Graph.refreshForPanel(panel)
    check(panel.graph.triggers == graphItems, "Unchanged frames reuse connection row and wrapped-text cache")
    local point, projections = map.point, 0
    map.point = function(self, x, y) projections = projections + 1; return point(self, x, y) end
    map:render()
    map.point = point
    check(#panel.graph.edges == 1024 and projections <= 140,
        "Fully linked 32-by-32 graph projects each marker once rather than once per edge")
    panel.graph:prerender()
    panel.graph:onMouseDown(-1, 20)
    panel.graph:onMouseUpOutside(-1, -1)
    check(not panel.graph.capture, "Connections releases pointer outside its bounds")
    panel.devices.items = {{item = controller}}
    panel.devices.selected = 1
    panel:select()
    panel.graph.refreshDue = 0
    Graph.refreshForPanel(panel)
    panel.devices.items = {{item=controller},{item=input},{item=output}}
    input.data.OMHTTControl.links = {"map-output"}
    panel.devices.selected = 3
    panel:select()
    panel.graph:setYScroll(0)
    panel.graph.refreshDue = 0
    panel.scanIndex, panel.scanDue = nil, testMillis + 5000
    panel:prerender()
    local previousHeight = getPlayerScreenHeight
    getPlayerScreenHeight = function() return 1080 end
    G.resize(panel, 1220, 1000)
    panel:prerender()
    check(panel.infoY + panel.lineHeight * 4 <= panel.detailBody.y + panel.detailBody.height
        and math.abs(panel.detailBody.width - panel.hostBody.width) <= 1
        and panel.detailBody.y == panel.hostBody.y, "Equal settings panes keep device summary visible and scroll remaining controls")
    check(panel.mapView.height >= panel.detailBody.height * 1.8,"Map retains roughly two-thirds of the right column")
    testControllerSvg = require("tests/UITrace")(panel)
    getPlayerScreenHeight = previousHeight
    G.resize(panel, 1220, 690)
    panel.devices.selected = 1
    panel:select()
    U.command, U.remote = savedCommand, savedRemote
end

return run
