local jerrycan = {}

function jerrycan.refill(source, method, price)
    local item, durability = inventory.GetJerrycan(source)
    if not item or item.name ~= "WEAPON_PETROLCAN" then return end

    if durability > 0 then
        return server.Notify(source, locale("notify.jerrycan-not-empty"), "error")
    end

    if not server.PayMoney(source, method, price) then return end

    inventory.UpdateJerrycan(source, item, 100)
end

function jerrycan.buy(source, method, price)
    if not inventory.CanCarry(source, "WEAPON_PETROLCAN") then
        return server.Notify(source, locale("notify.not-enough-space"), "error")
    end

    if not server.PayMoney(source, method, price) then return end

    inventory.AddItem(source, "WEAPON_PETROLCAN", 1)
end

function jerrycan.purchase(source, method, price)
    local playerState = Player(source).state
    if playerState.holding == "jerrycan" then
        return refillJerrycan(source, method, price)
    else
        return buyJerrycan(source, method, price)
    end
end

return jerrycan