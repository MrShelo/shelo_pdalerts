ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_outlawalert:carJackInProgress')
AddEventHandler('esx_outlawalert:carJackInProgress', function(targetCoords, streetName, vehicleLabel, playerGender)
    mytype = 'police'
    data = {["code"] = '10-73', ["name"] = 'Kradzież pojazdu '..vehicleLabel..'.', ["loc"] = streetName , ["gpstrack"] = "Wciśnij <b style='color:#d11563'>[M]</b> , aby zaznaczyć gps"}
    length = 3500
    TriggerClientEvent('esx_outlawalert:outlawNotify', -1, mytype, data, length)
    TriggerClientEvent('esx_outlawalert:combatInProgress', -1, targetCoords)
    TriggerClientEvent('esx_outlawalert:carJackInProgress', -1, targetCoords)
end, false)

RegisterServerEvent('esx_outlawalert:combatInProgress')
AddEventHandler('esx_outlawalert:combatInProgress', function(targetCoords, streetName, playerGender)
	mytype = 'police'
    data = {["code"] = '10-70', ["name"] = 'Bójka ', ["loc"] = streetName , ["gpstrack"] = "Wciśnij <b style='color:#d11563'>[M]</b> , aby zaznaczyć gps"}
    length = 3500
    TriggerClientEvent('esx_outlawalert:outlawNotify', -1, mytype, data, length)
    TriggerClientEvent('esx_outlawalert:combatInProgress', -1, targetCoords)
end, false)

RegisterServerEvent('esx_outlawalert:gunshotInProgress')
AddEventHandler('esx_outlawalert:gunshotInProgress', function(targetCoords, streetName, playerGender)
	mytype = 'police'
    data = {["code"] = '10-71', ["name"] = 'Oddano Strzały', ["loc"] = streetName , ["gpstrack"] = "Wciśnij <b style='color:#d11563'>[M]</b> , aby zaznaczyć gps"}
    length = 3500
    TriggerClientEvent('esx_outlawalert:outlawNotify', -1, mytype, data, length)
    TriggerClientEvent('esx_outlawalert:gunshotInProgress', -1, targetCoords)
end, false)


RegisterServerEvent('esx_outlawalert:atmrob')
AddEventHandler('esx_outlawalert:atmrob', function(targetCoords, streetName)
	mytype = 'police'
    data = {["code"] = '10-90', ["name"] = 'Aktywowany alarm w Bankomacie', ["loc"] = streetName , ["gpstrack"] = "Wciśnij <b style='color:#d11563'>[M]</b> , aby zaznaczyć gps"}
    length = 3500
    TriggerClientEvent('esx_outlawalert:outlawNotify', -1, mytype, data, length)
    TriggerClientEvent('esx_outlawalert:atmblip', -1, targetCoords)
end, false)



RegisterServerEvent('esx_outlawalert:speed')
AddEventHandler('esx_outlawalert:speed', function(targetCoords, streetName)
	mytype = 'police'
    data = {["code"] = '10-30', ["name"] = 'Przekroczona prędkość ', ["loc"] = streetName ,["gpstrack"] = "Wciśnij <b style='color:#d11563'>[M]</b> , aby zaznaczyć gps"}
    length = 3500
    TriggerClientEvent('esx_outlawalert:outlawNotify', -1, mytype, data, length)
    TriggerClientEvent('esx_outlawalert:speedBlip', -1, targetCoords)
end, false)


ESX.RegisterServerCallback('esx_outlawalert:isVehicleOwner', function(source, cb, plate)
	local identifier = GetPlayerIdentifier(source, 0)

	MySQL.Async.fetchAll('SELECT owner FROM owned_vehicles WHERE owner = @owner AND plate = @plate', {
		['@owner'] = identifier,
		['@plate'] = plate
	}, function(result)
		if result[1] then
			cb(result[1].owner == identifier)
		else
			cb(false)
		end
	end)
end)
