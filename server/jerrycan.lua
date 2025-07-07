local jerrycan = {}

function jerrycan.refill(source, method, price)
    local src = source
    local item, durability = inventory.GetJerrycan(src)
    if not item or item.name ~= "WEAPON_PETROLCAN" then return end

    if durability > 0 then
        return server.Notify(src, locale("notify.jerrycan-not-empty"), "error")
    end

    if not server.PayMoney(src, method, price) then return end

    inventory.UpdateJerrycan(src, item, 100)
end

function jerrycan.buy(source, method, price)
    local src = source
    if not inventory.CanCarry(src, "WEAPON_PETROLCAN") then
        return server.Notify(src, locale("notify.not-enough-space"), "error")
    end

    if not server.PayMoney(src, method, price) then return end

    inventory.AddItem(src, "WEAPON_PETROLCAN", 1)
end

function jerrycan.purchase(source, method, price)
    local src = source
    local item = inventory.GetJerrycan(src)
    if item and item.name == "WEAPON_PETROLCAN" then
        return jerrycan.refill(src, method, price)
    else
        return jerrycan.buy(src, method, price)
    end
end

return jerrycan