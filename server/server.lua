local QBCore = exports[Config.CoreName]:GetCoreObject()
local jobs = {}
local clientAvailable = 0

Citizen.CreateThread(function()
    while true do
        for k,v in pairs(shuffle(Config.JobLocations)) do
            local has = false
            for k2,v2 in pairs(jobs) do
                if v.id == v2.id then
                    has = true
                end
            end
            if not has then
                table.insert(jobs, v)
            end
        end
        Citizen.Wait(60000 * Config.NewListingTime)
    end
end)

QBCore.Functions.CreateCallback('rv_oxyjob:server:CheckStack', function(source, cb, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.OxyBottleName)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_oxys, 'error')
        cb(false)
        return
    end
    if item.amount < amount then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.dont_have_bottles, 'error')
        cb(false)
        return
    end
    cb(true)
end)

QBCore.Functions.CreateCallback('rv_oxyjob:server:StartJob', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.DownPayment > Player.Functions.GetMoney('cash') then
        TriggerClientEvent('QBCore:Notify', src, string.gsub(Locale.Error.not_enough_cash, "amount", Config.DownPayment), 'error')
        cb(false)
        return
    end
    TriggerClientEvent('QBCore:Notify', src, Locale.Success.started_job, 'success')
    Player.Functions.RemoveMoney('cash', Config.DownPayment)
    cb(true)
end)

RegisterNetEvent('rv_oxyjob:server:GlobalCooldown', function()
    clientAvailable = os.time() + (Config.GlobalClientCooldownMinutes * 1000)
end)

RegisterNetEvent('rv_oxyjob:server:DealEnding', function(amount, success)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem(Config.OxyBottleName, amount)
    if success then
        Player.Functions.AddMoney('cash', Config.DownPayment + Config.SellPricePerBottle)
    end
end)

RegisterNetEvent('rv_oxyjob:server:GiveOxysBack', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(Config.OxyBottleName, amount)
end)

RegisterNetEvent('rv_oxyjob:server:GetClient', function()
    local src = source
    if clientAvailable > os.time() then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_clients, 'error')
        return
    end
    TriggerClientEvent('rv_oxyjob:client:GetClient', src)
end)

RegisterNetEvent('rv_oxyjob:server:GiveOxys', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amount = Config.OxysPerTrunk
    Player.Functions.AddItem(Config.OxyItemName, amount)
    TriggerClientEvent('QBCore:Notify', src, string.gsub(Locale.Success.oxys_received, "amount", amount), 'success')
end)

RegisterNetEvent('rv_oxyjob:server:BottleOxys', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.OxyItemName)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_oxys, 'error')
        return
    end
    local bottles = item.amount / Config.OxysPerBottle
    local plasticNeeded = bottles * Config.PlasticPerBottle
    local plastic = Player.Functions.GetItemByName(Config.PlasticItemName)
    if plastic == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_plastic, 'error')
        return
    end
    if plasticNeeded > plastic.amount then
        TriggerClientEvent('QBCore:Notify', src, string.gsub(Locale.Error.not_enough_plastic, "amount", math.floor(plasticNeeded)), 'error')
        return
    end
    if item.amount < Config.OxysPerBottle then
        TriggerClientEvent('QBCore:Notify', src, string.gsub(Locale.Error.not_enough_oxys, "amount", Config.OxysPerBottle), 'error')
        return
    end
    TriggerClientEvent('rv_oxyjob:client:BottleOxys', src, bottles, plasticNeeded)
end)

RegisterNetEvent('rv_oxyjob:server:GiveOxyBottles', function(bottles, plasticNeeded)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local item = Player.Functions.GetItemByName(Config.OxyItemName)
    if item == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_oxys, 'error')
        return
    end
    if item.amount < bottles then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.oxys_not_in_inventory, 'error')
        return
    end
    local plastic = Player.Functions.GetItemByName(Config.PlasticItemName)
    if plastic == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_plastic, 'error')
        return
    end
    if plastic.amount < plasticNeeded then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.plastic_not_in_inventory, 'error')
        return
    end
    Player.Functions.RemoveItem(Config.OxyItemName, bottles * Config.OxysPerBottle)
    Player.Functions.RemoveItem(Config.PlasticItemName, bottles * Config.PlasticPerBottle)
    Player.Functions.AddItem(Config.OxyBottleName, bottles)
end)

RegisterNetEvent('rv_oxyjob:server:JobListings', function()
    local src = source
    if jobs[1] == nil then
        TriggerClientEvent('QBCore:Notify', src, Locale.Error.no_jobs, 'error')
        return
    end
    TriggerClientEvent('rv_oxyjob:client:JobListings', src, jobs)
end)

function shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end