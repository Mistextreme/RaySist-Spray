local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterUsableItem("spray_remover", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem("spray_remover")
    
    if item.count > 0 then
        TriggerClientEvent('RaySist-spray:removeClosestSpray', source)
        TriggerClientEvent('esx:showNotification', source, 'Stai rimuovendo lo spray!')
    else
        TriggerClientEvent('esx:showNotification', source, 'Non hai un kit per rimuovere lo spray!')
    end
end)

RegisterNetEvent('RaySist-spray:remove')
AddEventHandler('RaySist-spray:remove', function(pos)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem("spray_remover")

    if item.count > 0 then
        xPlayer.removeInventoryItem("spray_remover", 1)
        local sprayAtCoords = GetSprayAtCoords(pos)

        MySQL.Async.execute('DELETE FROM sprays WHERE x = @x AND y = @y AND z = @z LIMIT 1', {
            ['@x'] = pos.x,
            ['@y'] = pos.y,
            ['@z'] = pos.z
        })

        for idx, s in pairs(SPRAYS) do
            if s.location.x == pos.x and s.location.y == pos.y and s.location.z == pos.z then
                SPRAYS[idx] = nil
            end
        end
        TriggerClientEvent('RaySist-spray:setSprays', -1, SPRAYS)

        local sprayAtCoordsAfterRemoval = GetSprayAtCoords(pos)

        -- ensure someone doesnt bug it so its trying to remove other tags
        -- while deducting loyalty from not-deleted-but-at-coords tag
        if sprayAtCoords and not sprayAtCoordsAfterRemoval then
            TriggerEvent('RaySist-sprays:removeSpray', source, sprayAtCoords.text, sprayAtCoords.location)
        end
    end
end)
