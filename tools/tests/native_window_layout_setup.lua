testLayoutSaved = {panel=ISPanel,core=getCore, reader=getFileReader, writer=getFileWriter, manager=ISLayoutManager, starts=luautils.stringStarts}
ISPanel=testControlPanelBase
testLayoutText = ""
getCore = function() return {getGameMode=function() return "Sandbox" end,getScreenWidth=function() return 1280 end,getScreenHeight=function() return 720 end} end
luautils.stringStarts = function(value, prefix) return string.sub(value,1,#prefix)==prefix end
getFileWriter = function()
    testLayoutText = ""
    return {write=function(_,value) testLayoutText=testLayoutText..value end,close=function() end}
end
getFileReader = function()
    local lines, index = string.split(testLayoutText, "\n"), 0
    return {readLine=function() index=index+1; return lines[index] end,close=function() end}
end
LuaEventManager.AddEvent("OnPostSave")
