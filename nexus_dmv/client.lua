--[[
    DMV Driving School V2 - Client
    Author: Ken Mondragon
]]--

ESX = exports["es_extended"]:getSharedObject()

 
local Licenses = {}
local CurrentTest = nil
local CurrentTestType = nil
local CurrentVehicle = nil
local CurrentCheckPoint = 0
local DriveErrors = 0
local LastCheckPoint = -1
local CurrentBlip = nil
local CurrentZoneType = nil
local LastVehicleHealth = nil
local failedTest = false
local dmvPed = nil

 
function DrawMissionText(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, true)
end

-- Ped Creation
function CreateDMVPed()
    local pedModel = GetHashKey(Config.Ped.model)
    
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(100)
    end
    
    dmvPed = CreatePed(4, pedModel, Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z - 1.0, Config.Ped.coords.w, false, true)
    
    SetEntityHeading(dmvPed, Config.Ped.coords.w)
    FreezeEntityPosition(dmvPed, true)
    SetEntityInvincible(dmvPed, true)
    SetBlockingOfNonTemporaryEvents(dmvPed, true)
    TaskStartScenarioInPlace(dmvPed, Config.Ped.scenario, 0, true)
    
    SetModelAsNoLongerNeeded(pedModel)
    
     
    exports.qtarget:AddTargetEntity(dmvPed, {
        options = {
            {
                icon = "fas fa-graduation-cap",
                label = "Open DMV School",
                action = function()
                    OpenDMVSchoolMenu()
                end
            }
        },
        distance = 2.5
    })
    
    print('[DMV] Ped created and QTarget configured')
end

 
function StartTheoryTest()
    CurrentTest = 'theory'
    
     
    local shuffledQuestions = {}
    for i = 1, #Config.TheoryQuestions do
        shuffledQuestions[i] = Config.TheoryQuestions[i]
    end
    
     
    for i = #shuffledQuestions, 2, -1 do
        local j = math.random(i)
        shuffledQuestions[i], shuffledQuestions[j] = shuffledQuestions[j], shuffledQuestions[i]
    end
    
    SendNUIMessage({
        action = 'openTheoryTest',
        questions = shuffledQuestions
    })
    
    SetNuiFocus(true, true)
end

function StopTheoryTest(success, correct, wrong, total, percentage)
    CurrentTest = nil
    
    SendNUIMessage({
        action = 'closeTheoryTest'
    })
    
    SetNuiFocus(false, false)
    
    if success then
         
        TriggerServerEvent(' nexus_dmv:addLicense', 'dmv', {
            correct = correct,
            wrong = wrong,
            total = total,
            percentage = math.floor(percentage)
        })
        ESX.ShowNotification('~g~Congratulations! You passed the theory test!')
        ESX.ShowNotification(string.format('~y~Score: %d/%d (%d%%)', correct, total, math.floor(percentage)))
    else
        ESX.ShowNotification('~r~You failed the theory test. Study and try again.')
        ESX.ShowNotification(string.format('~y~Score: %d correct, %d wrong', correct, wrong))
    end
end

 
function StartDriveTest(testType, selectedModel)
    if not selectedModel then
        ESX.ShowNotification('~r~Error: No vehicle selected!')
        return
    end
    
    ESX.ShowNotification('~y~Preparing test vehicle...')
    
     
    TriggerServerEvent(' nexus_dmv:requestVehicle', selectedModel, testType)
end

 
RegisterNetEvent(' nexus_dmv:vehicleSpawned')
AddEventHandler(' nexus_dmv:vehicleSpawned', function(netId, testType)
    local vehicle = NetToVeh(netId)
    
     
    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 10000 do
        Wait(100)
        timeout = timeout + 100
    end
    
    if not DoesEntityExist(vehicle) then
        ESX.ShowNotification('~r~Error: Failed to load test vehicle!')
        return
    end
    
     
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    
     
    local playerPed = PlayerPedId()
    TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
    
     
    CurrentTest = 'drive'
    CurrentTestType = testType
    CurrentCheckPoint = 0
    LastCheckPoint = -1
    CurrentZoneType = 'residence'
    DriveErrors = 0
    CurrentVehicle = vehicle
    LastVehicleHealth = GetEntityHealth(vehicle)
    failedTest = false
    
    ESX.ShowNotification('~g~Driving test started! Follow the checkpoints.')
    ESX.ShowNotification('~y~Speed limit: ' .. Config.SpeedLimits['residence'] .. ' km/h')
end)

function StopDriveTest(success)
     
    if CurrentVehicle and DoesEntityExist(CurrentVehicle) then
        TriggerServerEvent(' nexus_dmv:deleteVehicle', VehToNet(CurrentVehicle))
    end
    
     
    if DoesBlipExist(CurrentBlip) then
        RemoveBlip(CurrentBlip)
    end
    
     
    CurrentVehicle = nil
    CurrentBlip = nil
    
      
    if success then
         
        TriggerServerEvent(' nexus_dmv:addLicense', CurrentTestType, nil)
        ESX.ShowNotification('~g~Congratulations! You passed the driving test!')
        ESX.ShowNotification('~g~License has been added to your records.')
    else
        ESX.ShowNotification('~r~You failed the driving test. Practice and try again.')
    end
    
    CurrentTest = nil
    CurrentTestType = nil
end

function SetCurrentZoneType(type)
    CurrentZoneType = type
end

function TestFailedGoToLastCheckPoint()
    CurrentCheckPoint = #Config.CheckPoints - 1
    failedTest = true
end

 
function OpenDMVSchoolMenu()
    local ownedLicenses = {}
    
    for i = 1, #Licenses do
        ownedLicenses[Licenses[i].type] = true
    end
    
    local elements = {
        {unselectable = true, icon = "fas fa-graduation-cap", title = "DMV Driving School"}
    }
    
     
    if not ownedLicenses['dmv'] then
        elements[#elements + 1] = {
            icon = "fas fa-book",
            title = ('Theory Test: <span style="color:green;">$%s</span>'):format(ESX.Math.GroupDigits(Config.Prices['dmv'])),
            value = "theory_test"
        }
    end
    
     
    if ownedLicenses['dmv'] then
        if not ownedLicenses['drive'] then
            elements[#elements + 1] = {
                icon = "fas fa-car",
                title = ('Car License: <span style="color:green;">$%s</span>'):format(ESX.Math.GroupDigits(Config.Prices['drive'])),
                value = "drive_test",
                type = "drive"
            }
        end
        
        if not ownedLicenses['drive_bike'] then
            elements[#elements + 1] = {
                icon = "fas fa-motorcycle",
                title = ('Motorcycle License: <span style="color:green;">$%s</span>'):format(ESX.Math.GroupDigits(Config.Prices['drive_bike'])),
                value = "drive_test",
                type = "drive_bike"
            }
        end
        
        if not ownedLicenses['drive_truck'] then
            elements[#elements + 1] = {
                icon = "fas fa-truck",
                title = ('Truck License: <span style="color:green;">$%s</span>'):format(ESX.Math.GroupDigits(Config.Prices['drive_truck'])),
                value = "drive_test",
                type = "drive_truck"
            }
        end
    end
    
    ESX.OpenContext("right", elements, function(menu, element)
        if element.value == "theory_test" then
            ESX.TriggerServerCallback(' nexus_dmv:canYouPay', function(haveMoney)
                if haveMoney then
                    ESX.CloseContext()
                    StartTheoryTest()
                else
                    ESX.ShowNotification('~r~You don\'t have enough money!')
                end
            end, 'dmv')
        elseif element.value == "drive_test" then
            ESX.TriggerServerCallback(' nexus_dmv:canYouPay', function(haveMoney)
                if haveMoney then
                    ESX.CloseContext()
                    
                    Wait(100)
                    
                    SendNUIMessage({
                        action = 'openVehicleSelection',
                        testType = element.type,
                        vehicles = Config.VehicleModels[element.type]
                    })
                    
                    SetNuiFocus(true, true)
                else
                    ESX.ShowNotification('~r~You don\'t have enough money!')
                end
            end, element.type)
        end
    end, function()
         
    end)
end

 
RegisterNUICallback('theoryTestResult', function(data, cb)
    StopTheoryTest(data.passed, data.correct, data.wrong, data.total, data.percentage)
    cb('ok')
end)

RegisterNUICallback('closeTheoryTest', function(data, cb)
    StopTheoryTest(false, 0, 0, 0, 0)
    cb('ok')
end)

RegisterNUICallback('selectVehicle', function(data, cb)
    SetNuiFocus(false, false)
    StartDriveTest(data.testType, data.model)
    cb('ok')
end)

RegisterNUICallback('closeVehicleSelection', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

 
RegisterNetEvent(' nexus_dmv:loadLicenses')
AddEventHandler(' nexus_dmv:loadLicenses', function(licenses)
    Licenses = licenses
end)

 
CreateThread(function()
    local blip = AddBlipForCoord(Config.Ped.coords.x, Config.Ped.coords.y, Config.Ped.coords.z)
    
    SetBlipSprite(blip, 408)
    SetBlipColour(blip, 3)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("DMV Driving School")
    EndTextCommandSetBlipName(blip)
end)

 
CreateThread(function()
    Wait(1000)
    CreateDMVPed()
end)

 
CreateThread(function()
    while true do
        local sleep = 1500
        
        if CurrentTest == 'theory' then
            sleep = 0
            local playerPed = PlayerPedId()
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisablePlayerFiring(playerPed, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 106, true)
        end
        
        if CurrentTest == 'drive' then
            sleep = 0
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local nextCheckPoint = CurrentCheckPoint + 1
            
            if Config.CheckPoints[nextCheckPoint] == nil then
                if DoesBlipExist(CurrentBlip) then
                    RemoveBlip(CurrentBlip)
                end
                
                CurrentTest = nil
                StopDriveTest(DriveErrors < Config.MaxErrors)
            else
                if CurrentCheckPoint ~= LastCheckPoint then
                    if DoesBlipExist(CurrentBlip) then
                        RemoveBlip(CurrentBlip)
                    end
                    
                    CurrentBlip = AddBlipForCoord(
                        Config.CheckPoints[nextCheckPoint].Pos.x,
                        Config.CheckPoints[nextCheckPoint].Pos.y,
                        Config.CheckPoints[nextCheckPoint].Pos.z
                    )
                    SetBlipRoute(CurrentBlip, 1)
                    
                    LastCheckPoint = CurrentCheckPoint
                end
                
                local Pos = vector3(
                    Config.CheckPoints[nextCheckPoint].Pos.x,
                    Config.CheckPoints[nextCheckPoint].Pos.y,
                    Config.CheckPoints[nextCheckPoint].Pos.z
                )
                local distance = #(coords - Pos)
                
                if distance <= Config.DrawDistance then
                    DrawMarker(
                        1, Config.CheckPoints[nextCheckPoint].Pos.x,
                        Config.CheckPoints[nextCheckPoint].Pos.y,
                        Config.CheckPoints[nextCheckPoint].Pos.z,
                        0.0, 0.0, 0.0, 0, 0.0, 0.0,
                        1.5, 1.5, 1.5,
                        102, 204, 102, 100,
                        false, true, 2, false, false, false, false
                    )
                end
                
                if distance <= 3.0 then
                    Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
                    CurrentCheckPoint = CurrentCheckPoint + 1
                end
            end
        end
        
        Wait(sleep)
    end
end)

 
CreateThread(function()
    while true do
        local sleep = 1500
        
        if CurrentTest == 'drive' then
            sleep = 0
            local playerPed = PlayerPedId()
            
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local speed = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
                local health = GetEntityHealth(vehicle)
                
                 
                for k, v in pairs(Config.SpeedLimits) do
                    if CurrentZoneType == k and speed > v then
                        DriveErrors = DriveErrors + 1
                        
                        if DriveErrors <= Config.MaxErrors then
                            ESX.ShowNotification('~r~Speed violation! Limit: ' .. v .. ' km/h')
                            ESX.ShowNotification('~y~Errors: ' .. DriveErrors .. '/' .. Config.MaxErrors)
                        end
                        
                        sleep = math.max(5000, Config.SpeedingErrorDelay)
                    end
                end
                
                 
                if health < LastVehicleHealth then
                    DriveErrors = DriveErrors + 1
                    
                    if DriveErrors <= Config.MaxErrors then
                        ESX.ShowNotification('~r~Vehicle damaged!')
                        ESX.ShowNotification('~y~Errors: ' .. DriveErrors .. '/' .. Config.MaxErrors)
                    end
                    
                    LastVehicleHealth = health
                    sleep = 1500
                end
                
                 
                if DriveErrors > Config.MaxErrors then
                    ESX.ShowNotification('~r~Test failed! Too many errors. Return to start point.')
                    
                    if not failedTest then
                        TestFailedGoToLastCheckPoint()
                    end
                    
                    sleep = 5000
                end
            end
        end
        
        Wait(sleep)
    end
end)

 
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if DoesEntityExist(dmvPed) then
        DeleteEntity(dmvPed)
    end
end)
 
 
exports('useReceipt', function(data, slot)
    local metadata = slot.metadata
    
    if not metadata then
        ESX.ShowNotification('~r~Invalid receipt!')
        return
    end
    
     
    SendNUIMessage({
        action = 'showReceipt',
        metadata = metadata
    })
    
    SetNuiFocus(true, true)
    
     
    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
end)

RegisterNUICallback('closeReceipt', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)