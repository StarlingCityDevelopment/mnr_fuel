---@diagnostic disable: duplicate-set-field, lowercase-global

if GetResourceState("qb-inventory") ~= "started" then return end

inventory = {}

function inventory.GetItem(source, itemName)
    local src = source
    local item = exports["qb-inventory"]:GetItemByName(src, itemName)
    return item
end

function inventory.CanCarry(source, itemName, amount)
    local src = source
    local success = exports["qb-inventory"]:CanAddItem(src, itemName, amount)
    return success
end

function inventory.AddItem(source, itemName, amount, metadata)
    local src = source
    exports["qb-inventory"]:AddItem(src, itemName, amount, false, metadata)
end

function inventory.GetJerrycan(source)
    local src = source
    local item = exports["qb-inventory"]:GetItemByName(src, "WEAPON_PETROLCAN")
    return item, item.info.quality
end

function inventory.UpdateJerrycan(source, item, newDurability)
    local src = source
    exports["qb-inventory"]:SetItemData(src, item.name, "quality", newDurability)
end