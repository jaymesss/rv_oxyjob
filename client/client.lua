local QBCore = exports[Config.CoreName]:GetCoreObject()
local job = nil
local spawned = false
local shooters = {}
local van = nil
local keys = nil
local hasKeys = false
local blip
local resprayed = false
local trunkNotification = false
local trunkTarget = false

local client = nil
local clientsSpawned = false
local clients = {}
local oxysStolen = 0
local oxyAmount = 0

function ResetJob()
    job = nil
    spawned = false
    shooters = {}
    van = nil
    keys = nil
    hasKeys = false
    blip = nil
    resprayed = false
    trunkNotification = false
    trunkTarget = false
end

function ResetClient()
    RemoveBlip(blip)
    blip = nil
    client = nil
    clientsSpawned = false
    clients = {}
    oxysStolen = 0
    oxyAmount = 0
end

Citizen.CreateThread(function()
    -- Job Listing Ped
    RequestModel(GetHashKey(Config.JobListing.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.JobListing.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.JobListing.Ped.Model), Config.JobListing.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports['qb-target']:AddBoxZone('oxyjob-information', Config.JobListing.Target.Coords, 1.5, 1.6, {
        name = "oxyjob-information",
        heading = Config.JobListing.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "server",
                event = "rv_oxyjob:server:JobListings",
                icon = "fas fa-pills",
                label = Config.JobListing.Target.Label
            }
        }
    })
    -- Clientele Ped
    RequestModel(GetHashKey(Config.ClienteleList.Ped.Model))
    while not HasModelLoaded(GetHashKey(Config.ClienteleList.Ped.Model)) do
        Wait(1)
    end
    local ped = CreatePed(5, GetHashKey(Config.ClienteleList.Ped.Model), Config.ClienteleList.Ped.Coords, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    exports['qb-target']:AddBoxZone('oxyjob-clientele', Config.ClienteleList.Target.Coords, 1.5, 1.6, {
        name = "oxyjob-clientele",
        heading = Config.ClienteleList.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "server",
                event = "rv_oxyjob:server:GetClient",
                icon = "fas fa-pills",
                label = Config.ClienteleList.Target.Label
            }
        }
    })    
    -- Scale
    exports['qb-target']:AddBoxZone('oxyjob-scale', Config.Scales.Target.Coords, 1.5, 1.6, {
        name = "oxyjob-information",
        heading = Config.Scales.Target.Heading,
        debugPoly = false
    }, {
        options = {
            {
                type = "server",
                event = "rv_oxyjob:server:BottleOxys",
                icon = "fas fa-pills",
                label = Config.Scales.Target.Label
            }
        }
    })
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if job ~= nil then
            if not spawned and GetDistanceBetweenCoords(GetEntityCoords(ped), job.Van.Coords) <= 60 then
                SpawnJob()
            end
            if keys ~= nil and not hasKeys then
                if not DoesEntityExist(keys) or IsPedDeadOrDying(keys) then
                    hasKeys = true
                    TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(van))
                    QBCore.Functions.Notify(Locale.Success.picked_up_keys, 'success', 5000)
                    RemoveBlip(blip)
                    blip = AddBlipForCoord(job.Respray.Coords)
                    SetBlipSprite(blip, 8)
                    SetBlipColour(blip, 3)
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, 3)
                end
            end
        end 
        if client ~= nil then
            if not clientsSpawned and GetDistanceBetweenCoords(GetEntityCoords(ped), client.TradePoint.Coords) <= 60 then
                QBCore.Functions.Notify(Locale.Info.dont_shoot_clients, 'error', 7500)
                SpawnClient()
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if resprayed then
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local dist = #(PlayerPos - Config.Scales.Target.Coords) 
            if dist < 20 then
                if not trunkNotification then
                    QBCore.Functions.Notify(Locale.Success.take_out_drugs, 'success', 10000)
                    trunkNotification = true
                    RemoveBlip(blip)
                end
                if not trunkTarget and GetVehiclePedIsIn(PlayerPed, false) == 0 then
                    trunkTarget = true
                    local vehicle = GetVehiclePedIsIn(PlayerPed, true)
                    exports['qb-target']:AddTargetEntity(vehicle, {
                        options = {
                            {
                                type = "client",
                                event = "rv_oxyjob:client:TakeOutOxys",
                                icon = 'fas fa-pills',
                                label = Locale.Info.trunk_target
                            }
                        }
                    })
                end
            end
            if not InRange then
                Wait(1000)
            end
        end
        if clientsSpawned then
            local InRange = false
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local dist = #(PlayerPos - client.TradePoint.Coords) 
            local dead = 0
            for k,v in pairs(clients) do
                if IsPedDeadOrDying(v) then
                    dead = dead + 1
                end
            end
            if dead == #clients then
                TriggerServerEvent('rv_oxyjob:server:GiveOxysBack', oxysStolen)
                QBCore.Functions.Notify(Locale.Success.stole_oxys_back, 'success', 5000)
                ResetClient()
            end
            if dist < 30 and oxysStolen <= 0 then
                InRange = true
                DrawMarker(2,client.TradePoint.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                if dist < 10 then
                    DrawText3Ds(client.TradePoint.Coords, '~g~E~w~ - ' .. Locale.Info.trade_text) 
                    if IsControlJustPressed(0, 38) then
                        QBCore.Functions.Progressbar("trading", Locale.Info.trade_progress_bar, 10000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            local p = promise.new()
                            local allowed
                            QBCore.Functions.TriggerCallback('rv_oxyjob:server:CheckStack', function(result)
                                p:resolve(result)
                            end, oxyAmount)
                            allowed = Citizen.Await(p)
                            local rob = math.random(1, 100) <= Config.ClientsRobChance
                            if not allowed then
                                QBCore.Functions.Notify(Locale.Error.skimp, 'error', 5000)
                                StartRobbery(true)
                                return
                            end
                            if rob then
                                TriggerServerEvent('rv_oxyjob:server:DealEnding', oxyAmount, false)
                                QBCore.Functions.Notify(Locale.Error.stick_up, 'error', 5000)
                                oxysStolen = oxyAmount
                                StartRobbery(false)
                                return
                            end
                            for k,v in pairs(clients) do
                                if IsPedDeadOrDying(v) then
                                    QBCore.Functions.Notify(Locale.Error.killed_clients, 'error', 6000)
                                    dead = true
                                    StartRobbery(true)
                                    return
                                end
                            end
                            ResetClient()
                            TriggerServerEvent('rv_oxyjob:server:DealEnding', oxyAmount, true)
                        end, function() -- Cancel
                        end)
                    end
                end
            end
            if not InRange then
                Wait(1000)
            end
        end
        if hasKeys then
            local InRange = false
            local PlayerPed = PlayerPedId()
            local PlayerPos = GetEntityCoords(PlayerPed)
            local dist = #(PlayerPos - job.Respray.Coords) 
            if dist < 30 then
                InRange = true
                DrawMarker(2,job.Respray.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 0, 0, 155, 0, 0, 0, 1, 0, 0, 0)
                if dist < 10 then
                    DrawText3Ds(job.Respray.Coords, '~g~E~w~ - ' .. Locale.Info.respray_text) 
                    if IsControlJustPressed(0, 38) then
                        QBCore.Functions.Progressbar("respraying", Locale.Info.respray_progress_bar, 30000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                        }, {
                        }, {}, {}, function() -- Done
                            local vehicle = GetVehiclePedIsIn(PlayerPed, true)
                            SetVehicleColours(vehicle, 0, 0)
                            resprayed = true
                            RemoveBlip(blip)
                            blip = AddBlipForCoord(Config.Scales.Target.Coords)
                            SetBlipSprite(blip, 8)
                            SetBlipColour(blip, 3)
                            SetBlipRoute(blip, true)
                            SetBlipRouteColour(blip, 3)
                        end, function() -- Cancel
                        end)
                    end
                end
            end

            if not InRange then
                Wait(1000)
            end
        end
        Citizen.Wait(5)
    end
end)

RegisterNetEvent('rv_oxyjob:client:GetClient', function()
    local input = lib.inputDialog(Locale.Info.dialog_title, {{type = 'number', label = Locale.Info.dialog_amount, icon = 'hashtag'}})
    if input ~= nil  and input[1] ~= nil then
        local amount = input[1]
        local p = promise.new()
        local allowed
        QBCore.Functions.TriggerCallback('rv_oxyjob:server:CheckStack', function(result)
            p:resolve(result)
        end, amount)
        allowed = Citizen.Await(p)
        if not allowed then
            return
        end
        TriggerServerEvent('rv_oxyjob:server:GlobalCooldown')
        QBCore.Functions.Notify(Locale.Success.started_client, 'success', 5000)
        client = Config.Clients[math.random(#Config.Clients)]
        oxyAmount = amount
        StartClient()
    end
end)

RegisterNetEvent('rv_oxyjob:client:JobListings', function(jobs)
    local options = {}
    for k,v in pairs(jobs) do
        options[#options+1] = {
            title = v.Name,
            description = Locale.Info.click_accept,
            icon = 'pills',
            onSelect = function()
                local p = promise.new()
                local allowed
                QBCore.Functions.TriggerCallback('rv_oxyjob:server:StartJob', function(result)
                    p:resolve(result)
                end)
                allowed = Citizen.Await(p)
                if not allowed then
                    return
                end
                job = v
                StartJob()
            end
        }
    end
    lib.registerContext({
        id = 'oxy_joblistings',
        title = Locale.Info.job_listing,
        options = options,
    })
    lib.showContext('oxy_joblistings')
end)

RegisterNetEvent('rv_oxyjob:client:TakeOutOxys', function()
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    QBCore.Functions.Progressbar("emptying_trunk", Locale.Info.emptying_trunk, 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        exports['qb-target']:RemoveTargetEntity(van, 'table')
        exports['qb-target']:RemoveTargetEntity(van, 'string')
        TriggerServerEvent('rv_oxyjob:server:GiveOxys')
        LoadAnimDict("amb@prop_human_bum_bin@idle_b")
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
        ResetJob()
    end, function() -- Cancel
    end)
end)

RegisterNetEvent('rv_oxyjob:client:BottleOxys', function(bottles, plastic)
    LoadAnimDict("amb@prop_human_bum_bin@idle_b")
    TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "idle_d", 4.0, 4.0, -1, 50, 0, false, false, false)
    QBCore.Functions.Progressbar("open_tablet", string.gsub(Locale.Info.crafting_bottles, "amount", math.floor(bottles)), 2500 * bottles, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
    }, {}, {}, function() -- Done
        TriggerServerEvent('rv_oxyjob:server:GiveOxyBottles', bottles, plastic)
        QBCore.Functions.Notify(string.gsub(Locale.Success.oxy_bottles_received, "amount", math.floor(bottles)), 'success', 15000)
        LoadAnimDict("amb@prop_human_bum_bin@idle_b")
        TaskPlayAnim(PlayerPedId(), "amb@prop_human_bum_bin@idle_b", "exit", 4.0, 4.0, -1, 50, 0, false, false, false)
    end, function() -- Cancel
    end)
end)

function StartJob() 
    blip = AddBlipForCoord(job.Van.Coords)
    SetBlipSprite(blip, 8)
    SetBlipColour(blip, 3)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 3)
end

function StartClient() 
    blip = AddBlipForCoord(client.TradePoint.Coords)
    SetBlipSprite(blip, 8)
    SetBlipColour(blip, 3)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 3)
end

function SpawnJob()
    spawned = true
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, GetHashKey('PLAYER'))
    AddRelationshipGroup('ShooterPeds')
    QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netid)
        local vehicle = NetToVeh(netid)
        exports[Config.FuelResource]:SetFuel(vehicle, 100)
        SetEntityHeading(vehicle, job.Van.Coords.w)
        SetVehicleColours(vehicle, 150, 150)
        van = vehicle
    end, job.Van.Model, job.Van.Coords, false)
    for k,v in pairs(job.Shooters) do
        RequestModel(GetHashKey(v.Model))
        while not HasModelLoaded(GetHashKey(v.Model)) do
            Wait(1)
        end
        shooter = CreatePed(1, GetHashKey(v.Model), v.Coords, false, false)
        NetworkRegisterEntityAsNetworked(shooter)
        networkID = NetworkGetNetworkIdFromEntity(shooter)
        SetNetworkIdCanMigrate(networkID, true)
        GiveWeaponToPed(shooter, GetHashKey(v.Weapon), 255, false, false) 
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetEntityAsMissionEntity(shooter)
        SetPedDropsWeaponsWhenDead(shooter, false)
        SetPedRelationshipGroupHash(shooter, GetHashKey("ShooterPeds"))
        SetEntityVisible(shooter, true)
        SetPedRandomComponentVariation(shooter, 0)
        SetPedRandomProps(shooter)
        SetPedCombatMovement(shooter, 3)
        SetPedAlertness(shooter, 3)
        SetPedAccuracy(shooter, 60)
        SetPedMaxHealth(shooter, v.Health)
        TaskCombatPed(shooter, ped, 0, 16)
        table.insert(shooters, shooter)
        if v.Keys then
            keys = shooter
        end
        Wait(100)
    end
end

function SpawnClient()
    clientsSpawned = true
    local ped = PlayerPedId()
    SetPedRelationshipGroupHash(ped, GetHashKey('PLAYER'))
    AddRelationshipGroup('ClientPeds')
    for k,v in pairs(client.Peds) do
        RequestModel(GetHashKey(v.Model))
        while not HasModelLoaded(GetHashKey(v.Model)) do
            Wait(1)
        end
        shooter = CreatePed(1, GetHashKey(v.Model), v.Coords, false, false)
        NetworkRegisterEntityAsNetworked(shooter)
        networkID = NetworkGetNetworkIdFromEntity(shooter)
        SetNetworkIdCanMigrate(networkID, true)
        GiveWeaponToPed(shooter, GetHashKey(v.Weapon), 255, false, false) 
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetEntityAsMissionEntity(shooter)
        SetPedDropsWeaponsWhenDead(shooter, false)
        SetPedRelationshipGroupHash(shooter, GetHashKey("ClientPeds"))
        SetEntityVisible(shooter, true)
        SetPedRandomComponentVariation(shooter, 0)
        SetPedRandomProps(shooter)
        SetPedCombatMovement(shooter, 3)
        SetPedAlertness(shooter, 3)
        SetPedAccuracy(shooter, 60)
        SetPedMaxHealth(shooter, v.Health)
        table.insert(clients, shooter)
        Wait(100)
    end
end

function StartRobbery(reset)
    local ped = PlayerPedId()
    for k,v in pairs(clients) do
        TaskCombatPed(v, ped, 0, 16)
    end
    if reset then
        ResetClient()
    end

end

function DrawText3Ds(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x,coords.y,coords.z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function LoadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end
