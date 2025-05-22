local Config = lib.load("config.config")
local InStation = {}

lib.callback.register("mnr_fuel:server:EnterStation", function(source, name)
    local station = Config.GasStations[name]

    if not source or not station then return end
    
    local stationCoords = station.coords
    local stationRadius = station.radius
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    if #(playerCoords - stationCoords) > stationRadius then return end

    InStation[source] = name
end)