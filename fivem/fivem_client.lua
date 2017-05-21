AddEventHandler('onClientMapStart', function()
	Citizen.Trace("ocms fivem\n")
    
    -- exports.spawnmanager:setAutoSpawn(true)
    -- exports.spawnmanager:forceRespawn()
    
    exports.spawnmanager:setAutoSpawn(false)
    exports.spawnmanager:spawnPlayer()

    SetClockTime(24, 0, 0)
    PauseClock(true)
    Citizen.Trace("ocms fivem end\n")
end)