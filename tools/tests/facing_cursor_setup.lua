testFacingBuilding = ISBuildingObject
ISBuildingObject = testControlPanelBase:derive("TestFacingBuilding")
function ISBuildingObject:init() end
function ISBuildingObject:getFloorCursorSprite() return {RenderGhostTileColor=function() end} end
