local Config = lib.load("config.config")
local InStation = {}

RegisterNetEvent("mnr_fuel:server:EnterStation", function(name)
    local station = Config.GasStations[name]

    if not source or not station then return end
    
    local stationCoords = station.coords
    local stationRadius = station.radius
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    if #(playerCoords - stationCoords) > stationRadius then return end

    InStation[source] = name
end)

RegisterNetEvent("mnr_fuel:server:ExitStation", function()
    if not source then return end

    InStation[source] = nil
end)

lib.callback.register("mnr_fuel:server:InStation", function(name)
    if not source then return end
    
    return InStation[source] == name
end)