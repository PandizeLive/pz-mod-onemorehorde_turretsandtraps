require = testOriginalRequire
testBarrierMenuHandler = Events.OnFillWorldObjectContextMenu.handlers[#Events.OnFillWorldObjectContextMenu.handlers]
check(OMHTTBarrierServiceAction ~= nil and testBarrierMenuHandler ~= nil, "shared action and client menu load before any server modules")
