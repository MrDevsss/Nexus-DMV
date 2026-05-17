--[[
    DMV Driving School V2
    Author: Ken Mondragon
]]--

Config = {}

-- General Settings
Config.DrawDistance = 10.0
Config.MaxErrors = 5
Config.SpeedMultiplier = 3.6
Config.SpeedingErrorDelay = 5000
Config.Locale = GetConvar('esx:locale', 'en')

-- Pricing Configuration
Config.Prices = {
    dmv = 500,           -- Theory test
    drive = 2500,        -- Car license
    drive_bike = 3000,   -- Motorcycle license
    drive_truck = 5000   -- Truck license
}

-- Ped Configuration
Config.Ped = {
    model = 'a_m_y_business_01',
    coords = vector4(239.471, -1380.960, 33.741, 140.0),
    scenario = 'WORLD_HUMAN_CLIPBOARD'
}

-- Vehicle Models with Images
Config.VehicleModels = {
    drive = {
        {model = 'blista', name = 'Blista', image = 'https://docs.fivem.net/vehicles/blista.webp'},
        {model = 'dilettante', name = 'Dilettante', image = 'https://docs.fivem.net/vehicles/dilettante.webp'},
        {model = 'issi2', name = 'Issi', image = 'https://docs.fivem.net/vehicles/issi2.webp'},
        {model = 'panto', name = 'Panto', image = 'https://docs.fivem.net/vehicles/panto.webp'},
        {model = 'prairie', name = 'Prairie', image = 'https://docs.fivem.net/vehicles/prairie.webp'}
    },
    drive_bike = {
        {model = 'sanchez', name = 'Sanchez', image = 'https://docs.fivem.net/vehicles/sanchez.webp'},
        {model = 'pcj', name = 'PCJ-600', image = 'https://docs.fivem.net/vehicles/pcj.webp'},
        {model = 'bagger', name = 'Bagger', image = 'https://docs.fivem.net/vehicles/bagger.webp'},
        {model = 'akuma', name = 'Akuma', image = 'https://docs.fivem.net/vehicles/akuma.webp'},
        {model = 'double', name = 'Double T', image = 'https://docs.fivem.net/vehicles/double.webp'},
        {model = 'faggio', name = 'Faggio', image = 'https://docs.fivem.net/vehicles/faggio.webp'},
        {model = 'hexer', name = 'Hexer', image = 'https://docs.fivem.net/vehicles/hexer.webp'}
    },
    drive_truck = {
        {model = 'mule3', name = 'Mule', image = 'https://docs.fivem.net/vehicles/mule3.webp'},
        {model = 'packer', name = 'Packer', image = 'https://docs.fivem.net/vehicles/packer.webp'},
        {model = 'phantom', name = 'Phantom', image = 'https://docs.fivem.net/vehicles/phantom.webp'},
        {model = 'benson', name = 'Benson', image = 'https://docs.fivem.net/vehicles/benson.webp'},
        {model = 'pounder', name = 'Pounder', image = 'https://docs.fivem.net/vehicles/pounder.webp'}
    }
}

-- Speed Limits by Zone
Config.SpeedLimits = {
    residence = 50,
    town = 80,
    freeway = 120
}

-- Theory Test Questions
Config.TheoryQuestions = {
    {question = "When approaching a red traffic light, you must come to a complete stop?", answer = true},
    {question = "You can use your phone while driving if you're using hands-free mode?", answer = false},
    {question = "You must yield to pedestrians in a crosswalk?", answer = true},
    {question = "It's legal to drive 10 mph over the speed limit on highways?", answer = false},
    {question = "You should check your mirrors before changing lanes?", answer = true},
    {question = "You can park in a no parking zone for just a few minutes?", answer = false},
    {question = "You must use turn signals when changing lanes?", answer = true},
    {question = "Driving under the influence of alcohol is illegal?", answer = true},
    {question = "You can ignore stop signs if there's no traffic?", answer = false},
    {question = "Seat belts must be worn at all times while driving?", answer = true}
}

-- Locations
Config.Zones = {
    VehicleSpawnPoint = {
        Pos = {x = 249.409, y = -1407.230, z = 28.4094, h = 317.0}
    }
}

-- Driving Test Checkpoints
Config.CheckPoints = {
    {
        Pos = {x = 255.139, y = -1400.731, z = 29.537},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Next checkpoint - Speed limit: ' .. Config.SpeedLimits['residence'] .. ' km/h', 5000)
        end
    },
    {
        Pos = {x = 271.874, y = -1370.574, z = 30.932},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Proceed to the next checkpoint', 5000)
        end
    },
    {
        Pos = {x = 234.907, y = -1345.385, z = 29.542},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            CreateThread(function()
                DrawMissionText('Stop for pedestrians crossing', 5000)
                PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
                FreezeEntityPosition(vehicle, true)
                Wait(4000)
                FreezeEntityPosition(vehicle, false)
                DrawMissionText('Good! Continue to next checkpoint', 5000)
            end)
        end
    },
    {
        Pos = {x = 217.821, y = -1410.520, z = 28.292},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            setCurrentZoneType('town')
            CreateThread(function()
                DrawMissionText('Stop and look left - Speed limit: ' .. Config.SpeedLimits['town'] .. ' km/h', 5000)
                PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
                FreezeEntityPosition(vehicle, true)
                Wait(6000)
                FreezeEntityPosition(vehicle, false)
                DrawMissionText('Good! Turn right at the intersection', 5000)
            end)
        end
    },
    {
        Pos = {x = 178.550, y = -1401.755, z = 27.725},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Watch for traffic lights', 5000)
        end
    },
    {
        Pos = {x = 113.160, y = -1365.276, z = 27.725},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Continue to next checkpoint', 5000)
        end
    },
    {
        Pos = {x = -73.542, y = -1364.335, z = 27.789},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Stop for passing vehicles', 5000)
            PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
            FreezeEntityPosition(vehicle, true)
            Wait(6000)
            FreezeEntityPosition(vehicle, false)
        end
    },
    {
        Pos = {x = -355.143, y = -1420.282, z = 27.868},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Proceed to checkpoint', 5000)
        end
    },
    {
        Pos = {x = -439.148, y = -1417.100, z = 27.704},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Continue driving safely', 5000)
        end
    },
    {
        Pos = {x = -453.790, y = -1444.726, z = 27.665},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            setCurrentZoneType('freeway')
            DrawMissionText('Entering highway - Speed limit: ' .. Config.SpeedLimits['freeway'] .. ' km/h', 5000)
            PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
        end
    },
    {
        Pos = {x = -463.237, y = -1592.178, z = 37.519},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Maintain highway speed', 5000)
        end
    },
    {
        Pos = {x = -900.647, y = -1986.28, z = 26.109},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Continue on highway', 5000)
        end
    },
    {
        Pos = {x = 1225.759, y = -1948.792, z = 38.718},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            setCurrentZoneType('town')
            DrawMissionText('Exiting highway - Reduce speed to ' .. Config.SpeedLimits['town'] .. ' km/h', 5000)
        end
    },
    {
        Pos = {x = 1163.603, y = -1841.771, z = 35.679},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            DrawMissionText('Almost done! Stay alert and drive safely', 5000)
            PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
        end
    },
    {
        Pos = {x = 235.283, y = -1398.329, z = 28.921},
        Action = function(playerPed, vehicle, setCurrentZoneType)
            ESX.Game.DeleteVehicle(vehicle)
        end
    }
}