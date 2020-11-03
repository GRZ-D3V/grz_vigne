
local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PlayerData                = {}
local GUI                       = {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local JobBlips                = {}
local publicBlip = false
ESX                             = nil
GUI.Time                        = 0

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function TeleportFadeEffect(entity, coords)

	Citizen.CreateThread(function()

		DoScreenFadeOut(800)

		while not IsScreenFadedOut() do
			Citizen.Wait(0)
		end

		ESX.Game.Teleport(entity, coords, function()
			DoScreenFadeIn(800)
		end)

	end)
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
	blips()
end)

RegisterNetEvent('grz:animation')
AddEventHandler('grz:animation', function()
	local dict, anim = 'random@domestic', 'pickup_low'
	local playerPed = PlayerPedId()
    ESX.Streaming.RequestAnimDict(dict)
	TaskPlayAnim(playerPed, dict, anim, 8.0, 1.0, 1000, 16, 0.0, false, false, false)
end)

AddEventHandler('esx_vigneron:hasEnteredMarker', function(zone)
	if zone == 'RaisinFarm' then
		CurrentAction     = 'raisin_harvest'
		CurrentActionMsg  = _U('press_collect_raisin')
		CurrentActionData = {zone= zone}
	end
	if zone == 'TraitementRaisin' then
		CurrentAction     = 'vine_traitement'
		CurrentActionMsg  = _U('press_traitement_vin')
		CurrentActionData = {zone= zone}
	end		
		
	if zone == 'SellFarm' then
		CurrentAction     = 'farm_resell'
		CurrentActionMsg  = _U('press_sell')
		CurrentActionData = {zone = zone}
	end

end)

AddEventHandler('esx_vigneron:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	if (zone == 'RaisinFarm') then
		TriggerServerEvent('esx_vigneron:stopHarvest')
	end  
	if (zone == 'TraitementRaisin') then
		TriggerServerEvent('esx_vigneron:stopTransform')
	end
	if (zone == 'SellFarm')  then
		TriggerServerEvent('esx_vigneron:stopSell')
	end
	CurrentAction = nil
end)

function deleteBlips()
	if JobBlips[1] ~= nil then
		for i=1, #JobBlips, 1 do
		RemoveBlip(JobBlips[i])
		JobBlips[i] = nil
		end
	end
end


-- Enter / Exit marker events
Citizen.CreateThread(function()
	while true do

		Wait(0)


			local coords      = GetEntityCoords(GetPlayerPed(-1))
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('esx_vigneron:hasEnteredMarker', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('esx_vigneron:hasExitedMarker', LastZone)
			end
	end
end)

-- Key Controls
Citizen.CreateThread(function()
	while true do

		Citizen.Wait(0)

		if CurrentAction ~= nil then

			SetTextComponentFormat('STRING')
			AddTextComponentString(CurrentActionMsg)
			DisplayHelpTextFromStringLabel(0, 0, 1, -1)

			if IsControlPressed(0,  Keys['E']) and (GetGameTimer() - GUI.Time) > 300 then
				if CurrentAction == 'raisin_harvest' then
					TriggerServerEvent('esx_vigneron:startHarvest', CurrentActionData.zone)
				end
				if CurrentAction == 'vine_traitement' then
					TriggerServerEvent('esx_vigneron:startTransform', CurrentActionData.zone)
				end
				if CurrentAction == 'farm_resell' then
					TriggerServerEvent('esx_vigneron:startSell', CurrentActionData.zone)
				end
				CurrentAction = nil
				GUI.Time      = GetGameTimer()

			end
		end
	end
end)
