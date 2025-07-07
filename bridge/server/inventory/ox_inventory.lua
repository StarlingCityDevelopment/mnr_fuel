---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("ox_inventory") ~= "started" then return end

inventory = {}

function inventory.GetItem(source, itemName)
    local src = source
    local item = exports.ox_inventory:GetItem(src, itemName, nil, false)
    return item
end

function inventory.CanCarry(source, itemName, amount)
    local src = source
    local success = exports.ox_inventory:CanCarryItem(src, itemName, amount)
    return success
end

function inventory.AddItem(source, itemName, count)
    local src = source
    exports.ox_inventory:AddItem(src, itemName, count)
end

function inventory.GetJerrycan(source)
    local src = source
    local weapon = exports.ox_inventory:GetCurrentWeapon(src)

    if not weapon then
        return false, false
    end

    local durability = weapon.metadata.durability
    return weapon, durability
end

function inventory.UpdateJerrycan(source, item, newDurability)
    local src = source
    local metadata = {durability = newDurability, ammo = newDurability}
    exports.ox_inventory:SetMetadata(src, item.slot, metadata)
end