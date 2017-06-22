require "resources/[essential]/es_extended/lib/MySQL"
MySQL:open("127.0.0.1", "gta5_gamemode_essential", "root", "foo")

RegisterServerEvent('esx_ambulancejob:requestPlayerData')
AddEventHandler('esx_ambulancejob:requestPlayerData', function(reason)
	TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)
		TriggerEvent('esx_skin:requestPlayerSkinInfosCb', source, function(skin, jobSkin)

			local data = {
				job       = xPlayer.job,
				inventory = xPlayer.inventory,
				skin      = skin
			}

			TriggerClientEvent('esx_ambulancejob:responsePlayerData', source, data, reason)
		end)
	end)
end)

RegisterServerEvent('esx_ambulancejob:requestPlayerPositions')
AddEventHandler('esx_ambulancejob:requestPlayerPositions', function(reason)
	
	local _source = source

	TriggerEvent('esx:getPlayers', function(xPlayers)

		local positions = {}

		for k, v in pairs(xPlayers) do
			positions[tostring(k)] = v.player.coords
		end

		TriggerClientEvent('esx_ambulancejob:responsePlayerPositions', _source, positions, reason)

	end)

end)

RegisterServerEvent('esx_ambulancejob:revive')
AddEventHandler('esx_ambulancejob:revive', function(playerId)

	TriggerEvent('esx:getPlayerFromId', playerId, function(xPlayer)
		xPlayer['revived'] = true
	end)

	TriggerClientEvent('esx_ambulancejob:revive', playerId)
end)

RegisterServerEvent('esx_ambulancejob:putInVehicle')
AddEventHandler('esx_ambulancejob:putInVehicle', function(playerId)
	TriggerClientEvent('esx_ambulancejob:putInVehicle', playerId)
end)

RegisterServerEvent('esx_ambulancejob:onBeforeRespawn')
AddEventHandler('esx_ambulancejob:onBeforeRespawn', function()
	TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)

		xPlayer['revived'] = false

		if Config.RemoveWeaponsAfterRPDeath then
			xPlayer.loadout = {}
		end

		if Config.RemoveCashAfterRPDeath then

			if xPlayer.player.money > 0 then
				xPlayer:setMoney(0)
			end

			local blackMoneyAccount = xPlayer:getAccount('black_money')

			if blackMoneyAccount.money > 0 then
				xPlayer:setAccountMoney('black_money', 0)
			end

		end

		if Config.RemoveItemsAfterRPDeath then

			for i=1, #xPlayer.inventory, 1 do
				if xPlayer.inventory[i].count > 0 then
					xPlayer:removeInventoryItem(xPlayer.inventory[i].item, xPlayer.inventory[i].count)
				end
			end

		end

		MySQL:executeQuery("UPDATE users SET position = '@position' WHERE identifier = '@identifier'", {['@position'] = json.encode(Config.Zones.Hospital.Pos), ['@identifier'] = xPlayer.identifier})

	end)
end)

TriggerEvent('esx_phone:registerCallback', 'special', function(source, phoneNumber, playerName, type, message)

	if phoneNumber == 'ambulance' then

		TriggerEvent('esx:getPlayerFromId', source, function(xPlayer)
			TriggerEvent('esx:getPlayers', function(xPlayers)
				for k, v in pairs(xPlayers) do

					if v.job.name == 'ambulance' then
						RconPrint('Message => ' .. playerName .. ' ' .. message)
						TriggerClientEvent('esx_phone:onMessage', v.player.source, xPlayer.phoneNumber, playerName, type, message, xPlayer.player.coords, {reply = 'Répondre', gps = 'GPS'})
					end
				end
			end)
		end)

	end
end)