local Config = lib.load("config.config")
local utils = lib.load("client.utils")

Stations = {Blips = {}, Zones = {}}

local function InitTargets()
	target.AddGlobalVehicle()

	for model, data in pairs(Config.Pumps) do
		target.AddModel(model, data.type == "ev")
	end
end

local function CreateStationZone(name, data)
	Stations.Zones[name] = lib.zones.sphere({
		coords = data.coords,
		radius = data.radius,
		onEnter = function(self)
			TriggerServerEvent("mnr_fuel:server:EnterStation", name)
		end,
		onExit = function(self)
			TriggerServerEvent("mnr_fuel:server:ExitStation")
		end,
		debug = data.debug,
	})
end

local function CreateStationBlip(coords, name, ev)
	Stations.Blips[name] = utils.CreateBlip(coords, ev)
end

function InitGasStations()
	for name, data in pairs(Config.GasStations) do
		CreateStationZone(name, data)
		CreateStationBlip(data.coords, name, data.type == "ev")
	end
	InitTargets()
end

function RemoveStationBlips()
	for _, blip in pairs(Stations.Blips) do
		RemoveBlip(blip)
	end
end