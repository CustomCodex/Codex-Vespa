ESX = nil

-- Load ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

-- Check if Config is defined
if not Config then
    print("Config is not defined. Please check your fxmanifest.lua and ensure config.lua is loaded.")
    return
end

-- Configurable rental location from the config file
local rentalMarker = Config.RentalMarker
local displayTimer = nil
local playerOnVehicle = false
local vehicle = nil
local warningMessageShown = false
local vehicleDeletionTimer = nil
local playerPed = PlayerPedId()

-- Create a blip on the map for the rental location
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(rentalMarker.x, rentalMarker.y, rentalMarker.z)
    SetBlipSprite(blip, 226) -- Bike icon
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 5) -- Blue color
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Locales[Config.Locale].rental_blip_name)
    EndTextCommandSetBlipName(blip)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(playerPed)
        local dist = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, rentalMarker.x, rentalMarker.y, rentalMarker.z)

        -- Draw marker and text for vehicle rental using the config coordinates
        if dist < 5.0 then
            -- Draw blue circle marker on the ground
            DrawMarker(1, rentalMarker.x, rentalMarker.y, rentalMarker.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 0, 255, 100, false, true, 2, false, false, false, false)
            
            -- Draw a larger white circle around the marker
            DrawMarker(1, rentalMarker.x, rentalMarker.y, rentalMarker.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 255, 255, 255, 50, false, true, 2, false, false, false, false)

            -- Draw text above the marker
            DrawText3D(rentalMarker.x, rentalMarker.y, rentalMarker.z + 1.0, Config.Locales[Config.Locale].rent_vehicle, 0.4)

            if dist < 1.5 and IsControlJustReleased(1, 51) then
                TriggerServerEvent('codex_vespa:tryRentVespa')
            end
        end

        -- Check if the player is on the vehicle
        if playerOnVehicle and vehicle then
            local playerPed = PlayerPedId()
            local playerVehicle = GetVehiclePedIsIn(playerPed, false)

            if not IsPedInVehicle(playerPed, playerVehicle, false) then
                -- Player has gotten off the vehicle
                Citizen.Wait(3000) -- Wait for 3 seconds
                if not IsPedInVehicle(playerPed, playerVehicle, false) then
                    if not warningMessageShown then
                        ESX.ShowNotification(Config.Locales[Config.Locale].get_back_on_message)
                        warningMessageShown = true

                        -- Start vehicle deletion timer
                        vehicleDeletionTimer = GetGameTimer() + 10000 -- 10 seconds in milliseconds
                    end

                    -- Check if it's time to delete the vehicle
                    if GetGameTimer() >= vehicleDeletionTimer then
                        if DoesEntityExist(vehicle) then
                            ESX.Game.DeleteVehicle(vehicle)
                            ESX.ShowNotification(Config.Locales[Config.Locale].thank_you_message)
                            displayTimer = nil
                            playerOnVehicle = false
                            warningMessageShown = false
                            vehicleDeletionTimer = nil
                            vehicle = nil
                        end
                    end
                end
            else
                -- Reset timers and messages when the player gets back on the vehicle
                warningMessageShown = false
                vehicleDeletionTimer = nil
            end
        end

        -- Display rental timer if active
        if displayTimer and playerOnVehicle then
            local currentTime = GetGameTimer()
            local timeLeft = math.ceil((displayTimer - currentTime) / 1000) -- Time left in seconds

            if timeLeft > 0 then
                -- Only show rental time above the Vespa
                if DoesEntityExist(vehicle) then
                    local vehCoords = GetEntityCoords(vehicle)
                    DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z + 1.0, string.format(Config.Locales[Config.Locale].rental_time_left_message, timeLeft), 0.3)
                end
            else
                -- Remove vehicle if rental time is over
                if DoesEntityExist(vehicle) then
                    ESX.Game.DeleteVehicle(vehicle)
                    ESX.ShowNotification(Config.Locales[Config.Locale].rental_expired)
                    displayTimer = nil
                    playerOnVehicle = false
                    warningMessageShown = false
                    vehicleDeletionTimer = nil
                    vehicle = nil
                end
            end
        end
    end
end)

RegisterNetEvent('codex_vespa:spawnVespa')
AddEventHandler('codex_vespa:spawnVespa', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicleName = Config.VehicleName or 'tmax' -- Default to 'tmax' if Config.VehicleName is not set

    ESX.Game.SpawnVehicle(vehicleName, playerCoords, GetEntityHeading(playerPed), function(spawnedVehicle)
        TaskWarpPedIntoVehicle(playerPed, spawnedVehicle, -1)
        SetVehicleNumberPlateText(spawnedVehicle, "RENTAL")
        
        displayTimer = GetGameTimer() + (Config.RentalDuration or 600000) -- 10 minutes in milliseconds
        playerOnVehicle = true
        warningMessageShown = false
        vehicleDeletionTimer = nil
        vehicle = spawnedVehicle

        -- Show welcome message
        ESX.ShowNotification(Config.Locales[Config.Locale].thank_you_message)
    end)
end)

-- Function to draw text in 3D
function DrawText3D(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local dist = Vdist(p.x, p.y, p.z, x, y, z)
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale or 0.35

    if onScreen then
        SetTextScale(scale * fov, scale * fov)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
