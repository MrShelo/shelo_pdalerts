ESX = nil

local timing, isPlayerWhitelisted = math.ceil(Config.Timer * 60000), false
local streetName, playerGender
local clockalert = 5000
local shelomark = false



Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
		ESX.PlayerData = ESX.GetPlayerData()
	end



	TriggerEvent('skinchanger:getSkin', function(skin)
		playerGender = skin.sex
	end)

	isPlayerWhitelisted = refreshPlayerWhitelisted()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job

	isPlayerWhitelisted = refreshPlayerWhitelisted()
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(100)

		if NetworkIsSessionStarted() then
			DecorRegister('isOutlaw', 3)
			DecorSetInt(PlayerPedId(), 'isOutlaw', 1)

			return
		end
	end
end)

RegisterNetEvent('streets:speed')
AddEventHandler('streets:speed', function(speedCoords)
	streetName,_ = GetStreetNameAtCoord(speedCoords.x, speedCoords.y, speedCoords.z)
	streetName = GetStreetNameFromHashKey(streetName)
	TriggerEvent('esx_speed:outlawspeed', streetName, speedCoords)
end)

RegisterNetEvent('streets:atmrob')
AddEventHandler('streets:atmrob', function(atmCoords)
	streetName,_ = GetStreetNameAtCoord(atmCoords.x, atmCoords.y, atmCoords.z)
	streetName = GetStreetNameFromHashKey(streetName)
	TriggerEvent('esx_atmRobbery:outlawnotifrob', streetName, atmCoords)
end)

RegisterNetEvent('streets:kasarob')
AddEventHandler('streets:kasarob', function(atmCoords)
	streetName,_ = GetStreetNameAtCoord(atmCoords.x, atmCoords.y, atmCoords.z)
	streetName = GetStreetNameFromHashKey(streetName)
	TriggerEvent('esx_kasaRobbery:outlawnotifrob', streetName, atmCoords)
end)

-- Gets the player's current street.
-- Aaalso get the current player gender
Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(3000)

		local playerCoords = GetEntityCoords(PlayerPedId())
		streetName,_ = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		streetName = GetStreetNameFromHashKey(streetName)
	end
end)



AddEventHandler('skinchanger:loadSkin', function(character)
	playerGender = character.sex
end)

function refreshPlayerWhitelisted()
	if not ESX.PlayerData then
		return false
	end

	if not ESX.PlayerData.job then
		return false
	end

	for k,v in ipairs(Config.WhitelistedCops) do
		if v == ESX.PlayerData.job.name then
			return true
		end
	end

	return false
end


RegisterNetEvent('esx_outlawalert:outlawNotify')
AddEventHandler('esx_outlawalert:outlawNotify', function(type, data, length)
	if isPlayerWhitelisted then
		SendNUIMessage({action = 'display', style = type, info = data, length = length})
    	PlaySound(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", 0, 0, 1)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)

		if DecorGetInt(PlayerPedId(), 'isOutlaw') == 2 then
			Citizen.Wait(timing)
			DecorSetInt(PlayerPedId(), 'isOutlaw', 1)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)

		-- is jackin'
		if (IsPedTryingToEnterALockedVehicle(playerPed) or IsPedJacking(playerPed)) and Config.CarJackingAlert then

			Citizen.Wait(3000)
			local vehicle = GetVehiclePedIsIn(playerPed, true)

			if vehicle and ((isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted) then
				local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))

				ESX.TriggerServerCallback('esx_outlawalert:isVehicleOwner', function(owner)
					if not owner then

						local vehicleLabel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
						vehicleLabel = GetLabelText(vehicleLabel)

						DecorSetInt(playerPed, 'isOutlaw', 2)

						TriggerServerEvent('esx_outlawalert:carJackInProgress', {
							x = ESX.Math.Round(playerCoords.x, 1),
							y = ESX.Math.Round(playerCoords.y, 1),
							z = ESX.Math.Round(playerCoords.z, 1)
						}, streetName, vehicleLabel, playerGender)
					end
				end, plate)
			end
			-- is in combat
		elseif IsPedInMeleeCombat(playerPed) and Config.MeleeAlert then

			Citizen.Wait(3000)

			if (isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted then
				DecorSetInt(playerPed, 'isOutlaw', 2)

				TriggerServerEvent('esx_outlawalert:combatInProgress', {
					x = ESX.Math.Round(playerCoords.x, 1),
					y = ESX.Math.Round(playerCoords.y, 1),
					z = ESX.Math.Round(playerCoords.z, 1)
				}, streetName, playerGender)
			end
			-- is shootin'
		elseif IsPedShooting(playerPed) and not IsPedCurrentWeaponSilenced(playerPed) and Config.GunshotAlert then

			Citizen.Wait(3000)

			if (isPlayerWhitelisted and Config.ShowCopsMisbehave) or not isPlayerWhitelisted then
				DecorSetInt(playerPed, 'isOutlaw', 2)

				TriggerServerEvent('esx_outlawalert:gunshotInProgress', {
					x = ESX.Math.Round(playerCoords.x, 1),
					y = ESX.Math.Round(playerCoords.y, 1),
					z = ESX.Math.Round(playerCoords.z, 1)
				}, streetName, playerGender)
			end

		end
	end
end)




RegisterNetEvent('esx_outlawalert:carJackInProgress')
AddEventHandler('esx_outlawalert:carJackInProgress', function(targetCoords)
	if isPlayerWhitelisted then
		if Config.CarJackingAlert then
			local alpha = 250
			local thiefBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipJackingRadius)
			clockalert = 500 pdcoords = targetCoords shelomark = true

			SetBlipHighDetail(thiefBlip, true)
			SetBlipColour(thiefBlip, 1)
			SetBlipSprite(thiefBlip,  68)
			SetBlipAlpha(thiefBlip, alpha)
			SetBlipAsShortRange(thiefBlip, true)

			while alpha ~= 0 do
				Citizen.Wait(Config.BlipJackingTime * 4)
				alpha = alpha - 1
				SetBlipAlpha(thiefBlip, alpha)

				if alpha == 0 then
					RemoveBlip(thiefBlip)
					return
				end
			end

		end
	end
end)

RegisterNetEvent('esx_outlawalert:gunshotInProgress')
AddEventHandler('esx_outlawalert:gunshotInProgress', function(targetCoords)
	if isPlayerWhitelisted and Config.GunshotAlert then
		local alpha = 250
		local gunshotBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipGunRadius)
		clockalert = 500 pdcoords = targetCoords shelomark = true

		SetBlipHighDetail(gunshotBlip, true)
		SetBlipSprite(gunshotBlip,  119)
		SetBlipColour(gunshotBlip, 1)
		SetBlipAlpha(gunshotBlip, taransG)
		SetBlipAsShortRange(gunshotBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(Config.BlipGunTime * 4)
			alpha = alpha - 1
			SetBlipAlpha(gunshotBlip, alpha)

			if alpha == 0 then
				RemoveBlip(gunshotBlip)
				return
			end
		end
	end
end)

RegisterNetEvent('esx_outlawalert:combatInProgress')
AddEventHandler('esx_outlawalert:combatInProgress', function(targetCoords)
	if isPlayerWhitelisted and Config.MeleeAlert then
		local alpha = 250
		local meleeBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, Config.BlipMeleeRadius)
		clockalert = 500 pdcoords = targetCoords shelomark = true


		SetBlipHighDetail(meleeBlip, true)
		SetBlipSprite(meleeBlip,  126)
		SetBlipColour(meleeBlip, 17)
		SetBlipAlpha(meleeBlip, alpha)
		SetBlipAsShortRange(meleeBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(Config.BlipMeleeTime * 4)
			alpha = alpha - 1
			SetBlipAlpha(meleeBlip, alpha)

			if alpha == 0 then
				RemoveBlip(meleeBlip)
				return
			end
		end
	end
end)


RegisterNetEvent('esx_outlawalert:atmblip')
AddEventHandler('esx_outlawalert:atmblip', function(targetCoords)
	if isPlayerWhitelisted then
		local alpha = 250
		local atmblip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, 0.1)
		print(targetCoords)
		clockalert = 500 pdcoords = targetCoords shelomark = true


		SetBlipHighDetail(atmblip, true)
		SetBlipSprite(atmblip,  119)
		SetBlipColour(atmblip, 1)
		SetBlipAlpha(atmblip, alpha)
		SetBlipAsShortRange(atmblip, true)

		while alpha ~= 0 do
			Citizen.Wait(45 * 5)
			alpha = alpha - 1
			SetBlipAlpha(atmblip, alpha)

			if alpha == 0 then
				RemoveBlip(atmblip)
				return
			end
		end
	end
end)

RegisterNetEvent('esx_outlawalert:speedBlip')
AddEventHandler('esx_outlawalert:speedBlip', function(targetCoords)
	if isPlayerWhitelisted then
		local alpha = 250
		local speedBlip = AddBlipForRadius(targetCoords.x, targetCoords.y, targetCoords.z, 1)
		clockalert = 500 pdcoords = targetCoords shelomark = true


		SetBlipHighDetail(speedBlip, true)
		SetBlipSprite(speedBlip,  119)
		SetBlipColour(speedBlip, 17)
		SetBlipAlpha(speedBlip, alpha)
		SetBlipAsShortRange(speedBlip, true)

		while alpha ~= 0 do
			Citizen.Wait(60 * 2)
			alpha = alpha - 1
			SetBlipAlpha(speedBlip, alpha)

			if alpha == 0 then
				RemoveBlip(speedBlip)
				return
			end
		end
	end
end)



----
---- Custom Edit By MrShelo
----

Citizen.CreateThread(function()
	while true do
		if Config.EnableTracking then


			if shelomark then
				clockalert = clockalert-1
				if(IsControlJustPressed(0, 244)) then
					SetNewWaypoint(pdcoords.x, pdcoords.y)
					PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
					shelomark = false
					clockalert = 0
				end
				if(clockalert == 0) then
					shelomark = false
				end
			end
			Citizen.Wait(1)
		end
	end
end)
