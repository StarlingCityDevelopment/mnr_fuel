local Config = lib.load("config.config")
local utils = lib.load("client.utils")

Stations = {Blips = {}, Zones = {}}

local function InitTargets()
	target.AddGlobalVehicle()

	for pumpModel, pumpData in pairs(Config.Pumps) do
		target.AddModel(pumpModel, pumpData.type == "ev")
	end
end

local function CreateStationZone(name, stationData)
	Stations.Zones[name] = lib.zones.sphere({
		coords = stationData.coords,
		radius = stationData.radius,
		onEnter = function(self)
			TriggerServerEvent("mnr_fuel:server:EnterStation", name)
		end,
		onExit = function(self)
			TriggerServerEvent("mnr_fuel:server:ExitStation")
		end,
		debug = stationData.debug,
	})
end

local function CreateStationBlip(coords, name, ev)
	Stations.Blips[name] = utils.CreateBlip(coords, ev)
end

function InitGasStations()
	for name, stationData in pairs(Config.GasStations) do
		CreateStationZone(name, stationData)
		CreateStationBlip(stationData.coords, name, stationData.type == "ev")
	end
	InitTargets()
end

function RemoveStationBlips()
	for _, blip in pairs(Stations.Blips) do
		RemoveBlip(blip)
	end
end