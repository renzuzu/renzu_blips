ESX						= nil
local addstamina = false
local regenhealth = false
local strongfist = false
local onSpawn = false
local player = nil
local HandObject = {}

viewer = false
local loaded = false
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	ESX.PlayerData = ESX.GetPlayerData()
	PlayerData = ESX.PlayerData
	player = LocalPlayer.state
	Wait(2000)
	loaded = ESX.PlayerLoaded
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    loaded = true
end)

local sprite = {
	['bike'] = 226,
	['automobile'] = 225,
	['boat'] = 427,
	['heli'] = 43,
	['plane'] = 307
}
RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	loaded = true
end)

local blips = {}
myblip = false
AddStateBagChangeHandler("PlayerBlips", "global", function(bagName, key, value)
	Wait(0)
	if loaded or ESX and ESX.PlayerLoaded then
		local myid = GetPlayerServerId(PlayerId())
		local haveblip = false
		for k,v in pairs(blips) do
			if DoesBlipExist(v.blip) then
				RemoveBlip(v.blip)
				blips[k] = nil
			end
		end
		blips = {}
		for job,v in pairs(value) do
			if job == PlayerData.job.name then
				for src,v in pairs(v) do
					if myid ~= src and v.coord.x ~= 0.0 then
					if myid == src then haveblip = true end
					local blipid = RemoveBlipOld(src)
					local nearestped, myped = isPedisNear(src)
					local near = false
					if nearestped or not nearestped and myped then
						near = true
					else
						near = false
					end
					if blips[src] and blips[src].near ~= near then
						if DoesBlipExist(blips[src].blip) then
							RemoveBlip(blips[src].blip)
							blips[src] = nil
						else
							blips[src] = nil
						end
					end
					if not blipid then
						local blip = nil
						
						if nearestped or not nearestped and myped then
							if not nearestped and myped then
								nearestped = PlayerPedId()
							end
							if not blips[src] then
								blip = AddBlipForEntity(nearestped)
							end
							BlipOption(blip,job,v.name,v.invehicle)
							near = true
						elseif not blips[src] then
							blip = AddBlipForCoord(v.coord.x,v.coord.y,v.coord.z)
							BlipOption(blip,job,v.name,v.invehicle)
							near = false
						end
						if not blips[src] and blip then
							blips[src] = {blip = blip, near = near}
						end
					elseif blipid then
						BlipOption(blipid,job,v.name,v.invehicle,v.coord)
					end
				    end
				end
			end
		end
		local remove = {}
		for k,v in pairs(blips) do
			remove[k] = true
			for job,v in pairs(value) do
				if job == PlayerData.job.name then
					for src,v in pairs(v) do
						if k == src then
							remove[k] = false
						end
					end
				end
			end
			if remove[k] and DoesBlipExist(v.blip) then
				RemoveBlip(v.blip)
				blips[k] = nil
			end
		end
	end
end)

isPedisNear = function(src)
	local player = GetPlayerFromServerId(src)
	local playerped = GetPlayerPed(player)
	return playerped ~= 0 and playerped ~= PlayerPedId() and playerped or false, src == GetPlayerServerId(PlayerId())
end

RemoveBlipOld = function(src)
	for k,v in pairs(blips) do
		if k == src and DoesBlipExist(v.blip) then
			return v.blip
		end
	end
	return false
end

BlipOption = function(blip,job,name,veh,coord)
	SetBlipCategory(blip,7)
	--SetBlipHiddenOnLegend(blip,true)
	if coord then
		SetBlipDisplay(blip, 6)
		SetBlipCoords(blip,coord.x,coord.y,coord.z)
		SetBlipSprite(blip, veh and sprite[veh] or config[job].sprite)
		SetBlipColour(blip, config[job].color)
	else
		--SetBlipHiddenOnLegend(blip,true)
		SetBlipSprite(blip, veh and sprite[veh] or config[job].sprite)
		SetBlipDisplay(blip, 6)
		SetBlipScale(blip, config[job].scale or 1.0)
		SetBlipColour(blip, config[job].color)
		SetBlipFlashes(blip, false)
		SetBlipAsShortRange(blip,true)
		SetBlipShowCone(blip, config[job].cone)
	end
	BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(name)
		EndTextCommandSetBlipName(blip)
end

RegisterCommand('testevent4', function(source,args)
	TriggerEvent('testevent','waw','gago')
end)

local performanceModIndices = {11,12,13,16}
function PerformanceUpgradeVehicle(vehicle, customWheels)
    customWheels = customWheels or false
    local max
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        SetVehicleModKit(vehicle, 0)
        for i = 0, 49 do
            local modType = i
            max = GetNumVehicleMods(vehicle, modType) - 1
            SetVehicleMod(vehicle, tonumber(modType), tonumber(max), customWheels)
        end
        ToggleVehicleMod(vehicle, 18, true) -- Turbo
    end
end

RegisterCommand('testupgrade', function(source, args, raw)
    PerformanceUpgradeVehicle(GetVehiclePedIsIn(PlayerPedId(), false), false)
end)