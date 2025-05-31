local Config = lib.load("config.config")
local stationsData = lib.load("config.stations")
local jerrycan = require "server.jerrycan"
local InStation = {}

GlobalState:set("fuelPrice", Config.FuelPrice, true)

---@description Callbacks
local function inStation(source)
	return InStation[source] ~= nil
end

lib.callback.register("mnr_fuel:server:InStation", inStation)

lib.callback.register("mnr_fuel:server:GetPlayerMoney", function(source)
	local cashMoney, bankMoney = server.GetPlayerMoney(source)

	return cashMoney, bankMoney
end)

---@description Zones Handling
RegisterNetEvent("mnr_fuel:server:EnterStation", function(name)
    local station = stationsData[name]

    if not station then return end
    
    local stationCoords = station.coords
    local stationRadius = station.radius
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)

    if #(playerCoords - stationCoords) > stationRadius then return end

    InStation[source] = name
end)

RegisterNetEvent("mnr_fuel:server:ExitStation", function()
    InStation[source] = nil
end)

local function setFuel(netID, fuelAmount)
	local vehicle = NetworkGetEntityFromNetworkId(netID)
	if vehicle == 0 or GetEntityType(vehicle) ~= 2 then return end

	local vehicleState = Entity(vehicle)?.state
	local fuelLevel = vehicleState.fuel

	local fuel = math.min(fuelLevel + fuelAmount, 100)

	vehicleState:set("fuel", fuel, true)
end

RegisterNetEvent("mnr_fuel:server:ElaborateAction", function(purchase, method, total, amount, netId)
	if not inStation(source) then return end

	local price = purchase == "fuel" and math.ceil(amount * GlobalState.fuelPrice) or Config.JerrycanPrice
	local playerMoney = server.GetPlayerMoney(source, method)
	
	if playerMoney < price then
		return server.Notify(source, locale("notify.not-enough-money"), "error")
	end

	if purchase == "fuel" then
		if not server.PayMoney(source, method, price) then return end

		local fuelAmount = math.floor(amount)
		setFuel(netId, fuelAmount)

		TriggerClientEvent("mnr_fuel:client:PlayRefuelAnim", source, {netId = netId, Amount = fuelAmount}, true)
	elseif purchase == "jerrycan" then
		jerrycan.purchase(source, method, price)
	end
end)

RegisterNetEvent("mnr_fuel:server:RefuelVehicle", function(data)
	if not data.entity then return end
	local playerState = Player(source).state
	if playerState.holding ~= "jerrycan" then return end

	local vehicle = NetworkGetEntityFromNetworkId(data.entity)
	if vehicle == 0 or GetEntityType(vehicle) ~= 2 then return end

	local vehicleState = Entity(vehicle)?.state
	local fuelLevel = math.ceil(vehicleState.fuel)
	local requiredFuel = 100 - fuelLevel
	if requiredFuel <= 0 then return server.Notify(source, locale("notify.vehicle-full"), "error") end

	local item, durability = inventory.GetJerrycan(source)
	if not item or durability <= 0 then return end

	local newDurability = math.floor(durability - requiredFuel)
	inventory.UpdateJerrycan(source, item, newDurability)

	setFuel(data.entity, requiredFuel)
	TriggerClientEvent("mnr_fuel:client:PlayRefuelAnim", source, {NetID = data.entity, Amount = requiredFuel}, false)
end)