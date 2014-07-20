// RAWR!
nz.PowerUps.buffer = nz.PowerUps.buffer or {}
nz.PowerUps.data = nz.PowerUps.data or {}
if (SERVER) then
	util.AddNetworkString("nz_PowerUps_Sync")
	function nz.PowerUps.Set(id, bool, time, name, material)
		local data = nz.PowerUps.GetBuffer(id) or {}
		data.id = id
		data.bool = bool
		data.time = time or data.time or -1
		data.name = name or data.name or "*UNKNOWN*"
		data.material = material or data.material or false
		nz.PowerUps.data[id] = data
		net.Start("nz_PowerUps_Sync")
			net.WriteString(name)
			net.WriteTable(data)
		net.Broadcast()
	end
end

function nz.PowerUps.Add(powerData)
	powerData.snd = powerData.snd or false
	powerData.effect = powerData.effect or {}
	powerData.effect.time = powerData.effect.time or 0
	powerData.effect.material = powerData.effect.material or false
	nz.PowerUps.buffer[powerData.id] = powerData
	if (SERVER) then
		nz.PowerUps.Set(powerData.id, false, powerData.effect.time, powerData.name, powerData.effect.material)
	end
end

function nz.PowerUps.GetBufferAll()
	return nz.PowerUps.buffer
end

function nz.PowerUps.GetBuffer(id)
	return nz.PowerUps.buffer[id]
end

function nz.PowerUps.GetAll()
	return nz.PowerUps.data
end

function nz.PowerUps.Get(id)
	return nz.PowerUps.data[id]
end

nz.PowerUps.Add({
	id = "dp",
	name = "Double Points",
	model = "models/props_c17/gravestone003a.mdl",
	scale = 0.5,
	chance = 30,
	effect = {time = 30},
	snd = {"mkservers/nz/powerups/dp.mp3", 0.5},
	func = (function(self, ply)
	end),
})
nz.PowerUps.Add({
	id = "maxammo",
	name = "Max Ammo",
	model = "models/Items/BoxSRounds.mdl",
	scale = 1.5,
	chance = 30,
	snd = {"mkservers/nz/powerups/maxammo.mp3", 0.5},
	func = (function(self, ply)
		for k,v in pairs(player.GetAll()) do
			for k2,v2 in pairs(v:GetWeapons()) do
				v:GiveAmmo(nz.Config.BaseStartingAmmoAmount, v2.Primary.Ammo)
			end
		end
	end),
})