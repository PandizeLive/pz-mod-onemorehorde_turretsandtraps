local F = require("OMHTT/Foundation")
local square = testSquares[F.key(100, 100, 0)]
triggerEvent("OnGameStart")
triggerEvent("OnFillWorldObjectContextMenu", 0, testMenu, {square.objects[1]}, false)
local inspect = testMenu.options[getText("ContextMenu_OMHTT_Inspect")]
check(inspect ~= nil, "SP context menu registered")
inspect.callback(inspect.target, inspect.command)
check(string.find(testDialog, getText("UI_OMHTT_Agrees"), 1, true) ~= nil, "SP direct command and reply reach translated UI")
testMode = "client"
triggerEvent("OnFillWorldObjectContextMenu", 0, testMenu, {square.objects[1]}, false)
inspect.callback(inspect.target, inspect.command)
check(testLastCommand.module == F.MODULE and testLastCommand.command == "Inspect", "MP client dispatch sends request")
local change = testMenu.options[getText("ContextMenu_OMHTT_Condition")]
change.callback(change.target, change.command)
local sent = testLastCommand
check(sent.args.condition == 37 and sent.args.id ~= "", "client mutation carries server identity")
testMode = "server"
require("OMHTT/FoundationServer").onCommand(sent.module, sent.command, sent.player, sent.args)
local response = testResults[#testResults]
testMode = "client"
triggerEvent("OnServerCommand", F.MODULE, "Result", response)
check(testHalo == getText("UI_OMHTT_Changed"), "MP mutation reply uses translated nonmodal notification")
triggerEvent("OnFillWorldObjectContextMenu", 0, testMenu, {square.objects[1]}, false)
local repeatOption = testMenu.options[getText("ContextMenu_OMHTT_Replay")]
repeatOption.callback(repeatOption.target)
check(testLastCommand.args.epoch == sent.args.epoch and testLastCommand.args.request > sent.args.request, "replay retains stale epoch with fresh display request")
local replay = testLastCommand
testMode = "server"
require("OMHTT/FoundationServer").onCommand(replay.module, replay.command, replay.player, replay.args)
check(testResults[#testResults].status == "Stale", "MP replay rejected")
testMode = "client"
testAdmin = false
testMenu.options = {}
triggerEvent("OnFillWorldObjectContextMenu", 0, testMenu, {square.objects[1]}, false)
check(testMenu.options[getText("ContextMenu_OMHTT_Inspect")] == nil, "non-admin menu hidden")
testAdmin = true
testMode = "sp"
