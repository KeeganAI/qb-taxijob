local QBCore = exports['qb-core']:GetCoreObject()

function NearTaxi(src)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    for _, v in pairs(Config.NPCLocations.DeliverLocations) do
        local dist = #(coords - vector3(v.x,v.y,v.z))
        if dist < 20 then
            return true
        end
    end
end

RegisterNetEvent('qb-taxi:server:NpcPay', function(Payment)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.job.name == Config.jobRequired then
        if NearTaxi(src) then
            local randomAmount = math.random(1, 5)
            local r1, r2 = math.random(1, 5), math.random(1, 5)
            if randomAmount == r1 or randomAmount == r2 then Payment = Payment + math.random(10, 20) end
            if Config.Management then
                MySQL.insert('INSERT INTO management_funds (job_name, amount, type) VALUES (:job_name, :amount, :type) ON DUPLICATE KEY UPDATE amount = :amount',
                {
                    ['job_name'] = Config.jobRequired,
                    ['amount'] = Payment,
                    ['type'] = 'boss'
                })
            else
                Player.Functions.AddMoney('cash', Payment)
            end
            local chance = math.random(1, 100)
            if chance < 26 then
                Player.Functions.AddItem("cryptostick", 1, false)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items["cryptostick"], "add")
            end
        else
            DropPlayer(src, 'Attempting To Exploit')
        end
    else
        DropPlayer(src, 'Attempting To Exploit')
    end
end)

QBCore.Functions.CreateCallback('qb-taxi:server:handleMoney', function(source, cb, bool)
    local Player = QBCore.Functions.GetPlayer(source)
    local payMethod = Config.depositSystem.method
    local amount = Config.depositSystem.amount
    if bool then -- remove money (retrieve taxi)
        if Player.Functions.RemoveMoney(payMethod, amount) then
            cb(true) 
        else
            cb(false)
        end
    else
        Player.Functions.AddMoney(payMethod, amount)
        cb(true)
    end
end)