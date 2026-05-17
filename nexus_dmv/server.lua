--[[
    DMV Driving School V2 - Server
    Author: Ken Mondragon
]]--

ESX = exports["es_extended"]:getSharedObject()

 
local SpawnedVehicles = {}

 
ESX.RegisterServerCallback(' nexus_dmv:canYouPay', function(source, cb, licenseType)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        cb(false)
        return
    end
    
    local price = Config.Prices[licenseType]
    
    if not price then
        print('[DMV ERROR] Invalid license type: ' .. tostring(licenseType))
        cb(false)
        return
    end
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price, "DMV License Purchase")
        TriggerClientEvent('esx:showNotification', source, '~g~You paid $' .. price .. ' for the test.')
        cb(true)
    else
        TriggerClientEvent('esx:showNotification', source, '~r~You don\'t have enough money!')
        cb(false)
    end
end)

 
RegisterNetEvent(' nexus_dmv:requestVehicle')
AddEventHandler(' nexus_dmv:requestVehicle', function(modelName, testType)
    local source = source
    
    -- Delete old vehicle if exists
    if SpawnedVehicles[source] then
        local oldVehicle = NetworkGetEntityFromNetworkId(SpawnedVehicles[source])
        if DoesEntityExist(oldVehicle) then
            DeleteEntity(oldVehicle)
        end
        SpawnedVehicles[source] = nil
    end
    
    local model = GetHashKey(modelName)
    
    local coords = vector3(
        Config.Zones.VehicleSpawnPoint.Pos.x,
        Config.Zones.VehicleSpawnPoint.Pos.y,
        Config.Zones.VehicleSpawnPoint.Pos.z
    )
    
    local heading = Config.Zones.VehicleSpawnPoint.Pos.h
    
   
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
    
    while not DoesEntityExist(vehicle) do
        Wait(50)
    end
    
   
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetVehicleNumberPlateText(vehicle, "DMV" .. math.random(100, 999))
    
    
    SpawnedVehicles[source] = netId
    
   
    TriggerClientEvent(' nexus_dmv:vehicleSpawned', source, netId, testType)
    
    print('[DMV] Vehicle spawned for player ' .. source .. ' | NetID: ' .. netId)
end)

 
RegisterNetEvent(' nexus_dmv:deleteVehicle')
AddEventHandler(' nexus_dmv:deleteVehicle', function(netId)
    local source = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    
    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
        print('[DMV] Vehicle deleted for player ' .. source)
    end
    
    SpawnedVehicles[source] = nil
end)

 
RegisterNetEvent(' nexus_dmv:addLicense')
AddEventHandler(' nexus_dmv:addLicense', function(licenseType, testData)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        return
    end
    
     
    TriggerEvent('esx_license:addLicense', source, licenseType, function()
        TriggerEvent('esx_license:getLicenses', source, function(licenses)
            TriggerClientEvent(' nexus_dmv:loadLicenses', source, licenses)
        end)
    end)
    
     
    local licenseNames = {
        dmv = 'Theory Test',
        drive = 'Car License',
        drive_bike = 'Motorcycle License',
        drive_truck = 'Truck License'
    }
    
    local receiptInfo = {
        type = licenseNames[licenseType] or 'DMV Test',
        date = os.date('%Y-%m-%d %H:%M:%S'),
        result = 'PASSED',
        player = xPlayer.getName()
    }
    
     
    if testData and licenseType == 'dmv' then
        receiptInfo.correct = testData.correct
        receiptInfo.wrong = testData.wrong
        receiptInfo.total = testData.total
        receiptInfo.percentage = testData.percentage
    end
    
     
    xPlayer.addInventoryItem('receipt', 1, receiptInfo)
    
    TriggerClientEvent('esx:showNotification', source, '~g~Receipt added to your inventory!')
    
     
    print('[DMV] License added: ' .. licenseType .. ' to player: ' .. xPlayer.getName() .. ' (' .. source .. ')')
    print('[DMV] Receipt given with metadata: ' .. json.encode(receiptInfo))
end)

 
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    TriggerEvent('esx_license:getLicenses', playerId, function(licenses)
        TriggerClientEvent(' nexus_dmv:loadLicenses', playerId, licenses)
    end)
end)

 
AddEventHandler('playerDropped', function()
    local source = source
    
    if SpawnedVehicles[source] then
        local vehicle = NetworkGetEntityFromNetworkId(SpawnedVehicles[source])
        if DoesEntityExist(vehicle) then
            DeleteEntity(vehicle)
        end
        SpawnedVehicles[source] = nil
        print('[DMV] Cleaned up vehicle for disconnected player ' .. source)
    end
end)

print('^2[DMV Driving School V2] ^7by Ken Mondragon - Server loaded successfully^0')