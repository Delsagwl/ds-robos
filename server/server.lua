local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('ds-robos:recompensa', function()
	local src = source
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local Player = QBCore.Functions.GetPlayer(src)
	local luck = math.random(1, 100)
	--local user = src..' | '.. GetPlayerName(src)..' | '..Player.PlayerData.citizenid..' | '.. Player.PlayerData.charinfo.firstname ..' '.. Player.PlayerData.charinfo.lastname
	if suerte then luck = luck + math.random(10,20) end
	local item = Robos.Items[math.random(1, #Robos.Items)]
	if Robos.Debug then

    end
	if luck >= 95 then
		item = Robos.ItemsEpicos[math.random(1, #Robos.ItemsEpicos)]
	elseif luck >= 50 then
		item = Robos.ItemsRaros[math.random(1, #Robos.ItemsRaros)]
	end
	Player.Functions.AddItem(item, 1)
	label = QBCore.Shared.Items[item].label
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
	TriggerClientEvent('QBCore:Notify', src, 'Has robado 1x'..label, 'success')
--	TriggerEvent('qb-log:server:CreateLog', 'robos', 'Robo a NPC', 'green', user..' | Ha robado '..label..' en '..playerCoords, false)
	local dineroRobado = math.random(Robos.mindinero, Robos.maxdinero)
	if Robos.efectivo then
		Player.Functions.AddItem('efectivo', dineroRobado)
		TriggerClientEvent('QBCore:Notify', src, 'Has robado $'..dineroRobado, 'success')
	end
--	TriggerEvent('qb-log:server:CreateLog', 'robos', 'Robo a NPC: '..user, 'green', 'Has robado $'..dineroRobado..' en '..playerCoords, false)
end)




QBCore.Functions.CreateCallback('ds-robos:server:GetCops', function(_, cb) -- policias de servicio
    local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for _, v in pairs(players) do
        if v and v.PlayerData.job.name == "police" and v.PlayerData.job.onduty then
            amount = amount + 1
        end
    end
    cb(amount)
end)