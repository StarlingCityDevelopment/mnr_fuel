local pumpOptions = {
    ["fv"] = {
        {
            label = locale("target.take-nozzle"),
            name = "mnr_fuel:pump:option_1",
            icon = "fas fa-gas-pump",
            distance = 3.0,
            canInteract = function()
                return not state.refueling and state.holding == "null"
            end,
            onSelect = function(data)
                TriggerEvent("mnr_fuel:client:TakeNozzle", data, "fv")
            end,
        }
        {
            label = locale("target.return-nozzle"),
            name = "mnr_fuel:pump:option_2",
            icon = "fas fa-hand",
            distance = 3.0,
            canInteract = function()
                return not state.refueling and (state.holding == "fv_nozzle" or state.holding == "ev_nozzle")
            end,
            onSelect = function(data)
                TriggerEvent("mnr_fuel:client:ReturnNozzle", data, "fv")
            end,
        },
        {
            label = locale("target.buy-jerrycan"),
            name = "mnr_fuel:pump:option_3",
            icon = "fas fa-fire-flame-simple",
            distance = 3.0,
            canInteract = function()
                return not state.refueling and (state.holding ~= "fv_nozzle" and state.holding ~= "ev_nozzle")
            end,
            event = "mnr_fuel:client:BuyJerrycan",
        },
    },
    ["ev"] = {
        {
            label = locale("target.take-charger"),
            name = "mnr_fuel:pump:option_1",
            icon = "fas fa-bolt",
            distance = 3.0,
            canInteract = function()
                return not state.refueling and state.holding == "null"
            end,
            onSelect = function(data)
                TriggerEvent("mnr_fuel:client:TakeNozzle", data, "ev")
            end,
        },
        {
            label = locale("target.return-charger"),
            name = "mnr_fuel:pump:option_2",
            icon = "fas fa-hand",
            distance = 3.0,
            canInteract = function()
                return not state.refueling and (state.holding == "fv_nozzle" or state.holding == "ev_nozzle")
            end,
            onSelect = function(data)
                TriggerEvent("mnr_fuel:client:ReturnNozzle", data, "ev")
            end,
        },
        {
            label = locale("target.buy-jerrycan"),
            name = "mnr_fuel:pump:option_3",
            icon = "fas fa-fire-flame-simple",
            distance = 3.0,
            canInteract = function()
                return not state.refueling and (state.holding ~= "fv_nozzle" and state.holding ~= "ev_nozzle")
            end,
            event = "mnr_fuel:client:BuyJerrycan",
        },
    }

}

local target = {}

function target.AddGlobalVehicle()
    exports.ox_target:addGlobalVehicle({
        {
            label = locale("target.refuel-nozzle"),
            name = "mnr_fuel:veh_option_1",
            icon = "fas fa-gas-pump",
            distance = 1.5,
            canInteract = function()
                return not state.refueling and (state.holding == "fv_nozzle" or state.holding == "ev_nozzle")
            end,
            event = "mnr_fuel:client:RefuelVehicle"
        },
        {
            label = locale("target.refuel-jerrycan"),
            name = "mnr_fuel:veh_option_2",
            icon = "fas fa-gas-pump",
            canInteract = function()
                return not state.refueling and state.holding == "jerrycan"
            end,
            serverEvent = "mnr_fuel:server:RefuelVehicle"
        },
    })
end

function target.RemoveGlobalVehicle()
    exports.ox_target:removeGlobalVehicle("mnr_fuel:veh_option")
end

function target.AddPumpTargets(entity, pumpType)
    exports.ox_target:addLocalEntity(entity, pumpOptions[pumpType])
end

function target.RemovePumpTargets(entity)
    exports.ox_target:removeLocalEntity(entity, {
        "mnr_fuel:pump:option_1",
        "mnr_fuel:pump:option_2",
        "mnr_fuel:pump:option_3",
    })
end

return target