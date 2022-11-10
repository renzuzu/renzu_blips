ESX = nil
ObjectList = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj 
end)
local playercache = {}
local playercaches = {}
local delveh = {}
GlobalState.PlayerBlips = {}
Citizen.CreateThread(function()
	local xPlayers = ESX.GetPlayers()
	local Players = GlobalState.PlayerBlips
    for i=1, #xPlayers, 1 do
        local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		local src = xPlayer.source
        if config[xPlayer.job.name] then
			if Players[xPlayer.job.name] == nil then
				Players[xPlayer.job.name] = {}
			end
			if Players[xPlayer.job.name][src] == nil then
				Players[xPlayer.job.name][src] = {src = src, name = xPlayer.getPlayerInfo('playerName'), invehicle = false, coord = GetEntityCoords(GetPlayerPed(src))}
			elseif Players[xPlayer.job.name][src] then
				Players[xPlayer.job.name][src].coord = GetEntityCoords(GetPlayerPed(src))
			end
		end
    end
	GlobalState.PlayerBlips = Players
	playercache = Players

	while true do
		local cache = GlobalState.PlayerBlips
		for job,v in pairs(cache) do
			for k,v in pairs(v) do
				local ped = GetPlayerPed(v.src)
				if DoesEntityExist(ped) then
					local coord = GetEntityCoords(ped)
					cache[job][v.src].coord = coord
					cache[job][v.src].invehicle = GetVehiclePedIsIn(ped) ~= 0 and GetVehicleType(GetVehiclePedIsIn(ped)) or false
				end
			end
		end
		GlobalState.PlayerBlips = cache
		Wait(5000)
	end
end)


RegisterServerEvent("esx_multicharacter:relog")
AddEventHandler('esx_multicharacter:relog', function()
	local source = source
	local Players = GlobalState.PlayerBlips
	local new = false
	for job,v in pairs(Players) do
		for k,v in pairs(v) do
			if source == k then
				Players[job][source] = nil
			end
		end
	end
	GlobalState.PlayerBlips = Players
end)

AddEventHandler("playerDropped",function()
	local source = source
	local Players = GlobalState.PlayerBlips
	local new = false
	for job,v in pairs(Players) do
		for k,v in pairs(v) do
			if source == k then
				Players[job][source] = nil
			end
		end
	end
	GlobalState.PlayerBlips = Players
end)

AddEventHandler('esx:onPlayerJoined', function(src, char, data)
	local src = src
	local char = char
	local data = data
	Wait(1000)
	local xPlayer = ESX.GetPlayerFromId(src)
	local Players = GlobalState.PlayerBlips
	if config[xPlayer.job.name] then
		if Players[xPlayer.job.name] == nil then
			Players[xPlayer.job.name] = {}
		end
		if Players[xPlayer.job.name][src] == nil then
			Players[xPlayer.job.name][src] = {src = src, name = xPlayer.getPlayerInfo('playerName'), invehicle = false, coord = GetEntityCoords(GetPlayerPed(src))}
		elseif Players[xPlayer.job.name][src] then
			Players[xPlayer.job.name][src].coord = GetEntityCoords(GetPlayerPed(src))
		end
		GlobalState.PlayerBlips = Players
		playercache = Players
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(src,j,old)
	local xPlayer = ESX.GetPlayerFromId(src)
	local Players = GlobalState.PlayerBlips
	local new = false
	for job,v in pairs(Players) do
		if old.name == job and xPlayer.job.name ~= old.name then
			new = true
			Players[job][src] = nil
		end
	end
	if new then
		GlobalState.PlayerBlips = Players
		playercache = Players
		Wait(500)
		Players = GlobalState.PlayerBlips
	end
	if config[xPlayer.job.name] then
		if Players[xPlayer.job.name] == nil then
			Players[xPlayer.job.name] = {}
		end
		if Players[xPlayer.job.name][src] == nil then
			Players[xPlayer.job.name][src] = {src = src, name = xPlayer.getPlayerInfo('playerName'), invehicle = false, coord = GetEntityCoords(GetPlayerPed(src))}
		elseif Players[xPlayer.job.name][src] then
			Players[xPlayer.job.name][src].coord = GetEntityCoords(GetPlayerPed(src))
		end
	end
	GlobalState.PlayerBlips = Players
	playercache = Players
end)