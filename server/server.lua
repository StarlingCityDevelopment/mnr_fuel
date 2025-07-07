local config = lib.load("config.config")
local stations = lib.load("config.stations")
local jerrycan = require "server.jerrycan"
local InStation = {}

GlobalState:set("fuelPrice", config.fuelPrice, true)

---@return boolean
local function inStation(source)
	local src = source
	return InStation[src] ~= nil
end

lib.callback.register("mnr_fuel:server:InStation", inStation)

---@return number, number
lib.callback.register("mnr_fuel:server:GetPlayerMoney", function(source)
	local src = source
	local cashMoney, bankMoney = server.GetPlayerMoney(src)

	return cashMoney, bankMoney
end)

---@param name string
RegisterNetEvent("mnr_fuel:server:EnterStation", function(name)
	local src = source
    local station = stations[name]

    if not station then return end
    
    local stationCoords = station.coords
    local stationRadius = station.radius
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)

    if #(playerCoords - stationCoords) > stationRadius then return end

    InStation[src] = name
end)

RegisterNetEvent("mnr_fuel:server:ExitStation", function()
	local src = source
    InStation[src] = nil
end)

---@param netID number
---@param fuelAmount number
local function setFuel(netID, fuelAmount)
	local vehicle = NetworkGetEntityFromNetworkId(netID)
	if vehicle == 0 or GetEntityType(vehicle) ~= 2 then return end

	local vehicleState = Entity(vehicle)?.state
	local fuelLevel = vehicleState.fuel

	local fuel = math.min(fuelLevel + fuelAmount, 100)

	vehicleState:set("fuel", fuel, true)
end

---@param purchase string
---@param method string
---@param total number
---@param amount number
---@param netId number
RegisterNetEvent("mnr_fuel:server:ElaborateAction", function(purchase, method, total, amount, netId)
	local src = source
	if not inStation(src) then return end

	local price = purchase == "fuel" and math.ceil(amount * GlobalState.fuelPrice) or config.jerrycanPrice
	local playerMoney = server.GetPlayerMoney(src, method)
	
	if playerMoney < price then
		return server.Notify(src, locale("notify.not-enough-money"), "error")
	end

	if purchase == "fuel" then
		if not server.PayMoney(src, method, price) then return end

		local fuelAmount = math.floor(amount)
		setFuel(netId, fuelAmount)

		TriggerClientEvent("mnr_fuel:client:PlayRefuelAnim", src, {netId = netId, amount = fuelAmount}, true)
	elseif purchase == "jerrycan" then
		jerrycan.purchase(src, method, price)
	end
end)

RegisterNetEvent("mnr_fuel:server:RefuelVehicle", function(data)
	local src = source
	if not data.entity then return end

	local item, durability = inventory.GetJerrycan(src)
	if not item or item.name ~= "WEAPON_PETROLCAN" then return end

	local vehicle = NetworkGetEntityFromNetworkId(data.entity)
	if vehicle == 0 or GetEntityType(vehicle) ~= 2 then return end

	local vehicleState = Entity(vehicle)?.state
	local fuelLevel = math.ceil(vehicleState.fuel)
	local requiredFuel = 100 - fuelLevel
	if requiredFuel <= 0 then
		server.Notify(src, locale("notify.vehicle-full"), "error")
		return
	end

	local item, durability = inventory.GetJerrycan(src)
	if not item or durability <= 0 then return end

	local newDurability = math.floor(durability - requiredFuel)
	inventory.UpdateJerrycan(src, item, newDurability)

	setFuel(data.entity, requiredFuel)
	TriggerClientEvent("mnr_fuel:client:PlayRefuelAnim", src, {netId = data.entity, amount = requiredFuel}, false)
end)