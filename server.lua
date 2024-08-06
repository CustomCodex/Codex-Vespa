ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('codex_vespa:tryRentVespa')
AddEventHandler('codex_vespa:tryRentVespa', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and Config then
        if xPlayer.getMoney() >= Config.RentalPrice then
            -- Deduct the rental price
            xPlayer.removeMoney(Config.RentalPrice)
            
            -- Notify the player
            TriggerClientEvent('esx:showNotification', source, "You have rented a Vespa for $" .. Config.RentalPrice)

            -- Trigger the client to spawn the Vespa
            TriggerClientEvent('codex_vespa:spawnVespa', source)
        else
            -- Notify the player about insufficient funds
            TriggerClientEvent('esx:showNotification', source, "You do not have enough money to rent a Vespa")
        end
    else
        print("Config or ESX is nil")
    end
end)
