
ESX = nil
local PlayersTransforming  = {}
local PlayersSelling       = {}
local PlayersHarvesting = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function Harvest(source, zone)
	if PlayersHarvesting[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "RaisinFarm" then
			local itemQuantity = xPlayer.getInventoryItem('vigne').count
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, ('~r~Erreur ~n~~f~Tu n\'as pas de license'))
			else
			local itemQuantity = xPlayer.getInventoryItem('grapperaisin').count
			if itemQuantity >= 100 then
				TriggerClientEvent('esx:showNotification', source, ('~r~Erreur ~n~~f~Tu fais tomber des raisins de tes poches'))
				xPlayer.removeInventoryItem('grapperaisin', 1)
				return
			else
				local itemQuantity = xPlayer.getInventoryItem('vigne').count
				if itemQuantity >= 0 then
				SetTimeout(1000, function()
					TriggerClientEvent('grz:animation', source)
					Citizen.Wait(1000)
					xPlayer.addInventoryItem('grapperaisin', 1)
					Harvest(source, zone)
				end)
			end
		end
	end
end
	end
end

RegisterServerEvent('esx_vigneron:startHarvest')
AddEventHandler('esx_vigneron:startHarvest', function(zone)
	local _source = source
  	
	if PlayersHarvesting[_source] == false then
		PlayersHarvesting[_source]=false
		TriggerClientEvent('esx:showNotification', _source, ('~g~Vignes ~n~~f~Tu recoltes des raisins'))
		PlayersHarvesting[_source]=true 
		Harvest(_source,zone)
	else
		PlayersHarvesting[_source]=true 
		TriggerClientEvent('esx:showNotification', _source, ('~g~Vignes ~n~~f~Tu recoltes des raisins'))
		Harvest(_source,zone)
	end
end)


RegisterServerEvent('esx_vigneron:stopHarvest')
AddEventHandler('esx_vigneron:stopHarvest', function()
	local _source = source
	
	if PlayersHarvesting[_source] == true then
		PlayersHarvesting[_source]=false
	else
		PlayersHarvesting[_source]=false
		PlayersHarvesting[_source]=true
	end
end)


local function Transform(source, zone)

	if PlayersTransforming[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "TraitementRaisin" then
			local itemQuantity = xPlayer.getInventoryItem('vigne').count
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, ('~r~Erreur ~n~~f~Tu n\'as pas de license'))
			else
			local itemQuantity = xPlayer.getInventoryItem('grapperaisin').count
			
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, ('~r~Erreur ~n~~f~Tu n\'as pas de raisin'))
				return
			else
				SetTimeout(1000, function()
					TriggerClientEvent('grz:animation', source)
					Citizen.Wait(1000)
					xPlayer.removeInventoryItem('grapperaisin', 1)
					xPlayer.addInventoryItem('vin', 1)
					Transform(source, zone)
				end)
			end
			end
		end
	end	
end

RegisterServerEvent('esx_vigneron:startTransform')
AddEventHandler('esx_vigneron:startTransform', function(zone)
	local _source = source
  	
	if PlayersTransforming[_source] == false then
		PlayersTransforming[_source]=false
		TriggerClientEvent('esx:showNotification', _source, ('~g~Vignes ~n~~f~Tu fais des bouteilles de Vin'))
		PlayersTransforming[_source]=true
		Transform(_source,zone)
	else
		PlayersTransforming[_source]=true
		TriggerClientEvent('esx:showNotification', _source, ('~g~Vignes ~n~~f~Tu fais des bouteilles de Vin'))
		Transform(_source,zone)
	end
end)

RegisterServerEvent('esx_vigneron:stopTransform')
AddEventHandler('esx_vigneron:stopTransform', function()

	local _source = source
	
	if PlayersTransforming[_source] == true then
		PlayersTransforming[_source]=false	
	else
		PlayersTransforming[_source]=false	
		PlayersTransforming[_source]=true
		
	end
end)

local function Sell(source, zone)

	if PlayersSelling[source] == true then

		local xPlayer  = ESX.GetPlayerFromId(source)
		if zone == "SellFarm" then
			local itemQuantity = xPlayer.getInventoryItem('vigne').count
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, ('~r~Erreur ~n~~f~Tu n\'as pas de license'))
			else
			local itemQuantity = xPlayer.getInventoryItem('vin').count
			
			if itemQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, ('~r~Erreur ~n~~f~Tu n\'as pas de raisin'))
				return
			else
				SetTimeout(1000, function()
					TriggerClientEvent('grz:animation', source)
					Citizen.Wait(1000)
					xPlayer.removeInventoryItem('vin', 1)
					xPlayer.addMoney(30)
					TriggerClientEvent('esx:showNotification', source, ('~g~Vignoble ~n~~f~Tu as vendu une bouteille de Vin : 30$'))
					Sell(source, zone)
				end)
			end
			end
		end
	end	
end

RegisterServerEvent('esx_vigneron:startSell')
AddEventHandler('esx_vigneron:startSell', function(zone)

	local _source = source
	
	if PlayersSelling[_source] == false then
		PlayersSelling[_source]=false
		TriggerClientEvent('esx:showNotification', _source, ('~g~Vignes ~n~~f~Tu vends tes bouteilles de Vin'))
		PlayersSelling[_source]=true
		Sell(_source, zone)
	else
		PlayersSelling[_source]=true
		TriggerClientEvent('esx:showNotification', _source, ('~g~Vignes ~n~~f~Tu vends tes bouteilles de Vin'))
		Sell(_source, zone)
	end

end)

RegisterServerEvent('esx_vigneron:stopSell')
AddEventHandler('esx_vigneron:stopSell', function()

	local _source = source
	
	if PlayersSelling[_source] == true then
		PlayersSelling[_source]=false
		
	else
		PlayersSelling[_source]=false
		PlayersSelling[_source]=true
	end

end)

ESX.RegisterServerCallback('esx_vigneron:getPlayerInventory', function(source, cb)

	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({
		items      = items
	})

end)