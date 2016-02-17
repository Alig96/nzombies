//

if SERVER then
	function nz.PowerUps.Functions.Activate(id, ply)
		local powerupData = nz.PowerUps.Functions.Get(id)

		if powerupData.duration != 0 then
			//Activate for a certain time
			nz.PowerUps.Data.ActivePowerUps[id] = CurTime() + powerupData.duration
		//else
			//Activate Once

		end

		//Notify

		powerupData.func(id, ply)

		//Sync
		nz.PowerUps.Functions.SendSync()
	end

	function nz.PowerUps.Functions.SpawnPowerUp(pos)
		local choices = {}
		local total = 0

		//Chance it
		for k,v in pairs(nz.PowerUps.Data) do
			if k != "ActivePowerUps" then
				choices[k] = v.chance
				total = total + v.chance
			end
		end

		//Insert a blank // Change 100 to increase the blank
		choices["null"] = 500 - total

		local id = nz.Misc.Functions.WeightedRandom(choices)
		if id == "null" then return end // Back out

		//Spawn it
		local powerupData = nz.PowerUps.Functions.Get(id)

		local pos = pos+Vector(0,0,50)
		local ent = ents.Create("drop_powerup")
		ent:SetPowerUp(id)
		pos.z = pos.z - ent:OBBMaxs().z
		ent:SetModel(powerupData.model)
		ent:SetPos(pos)
		ent:Spawn()
	end

end

function nz.PowerUps.Functions.IsPowerupActive(id)

	local time = nz.PowerUps.Data.ActivePowerUps[id]

	if time != nil then
		//Check if it is still within the time.
		if CurTime() > time then
			//Expired
			nz.PowerUps.Data.ActivePowerUps[id] = nil
		else
			return true
		end
	end

	return false

end

function nz.PowerUps.Functions.AllActivePowerUps()

	return nz.PowerUps.Data.ActivePowerUps

end

function nz.PowerUps.Functions.NewPowerUp(id, data)
	if SERVER then
		//Sanitise any client data.
	else
		data.Func = nil
	end
	nz.PowerUps.Data[id] = data
end

function nz.PowerUps.Functions.Get(id)
	return nz.PowerUps.Data[id]
end

//Double Points
nz.PowerUps.Functions.NewPowerUp("dp", {
	name = "Double Points",
	model = "models/props_c17/gravestone003a.mdl",
	scale = 0.5,
	chance = 5,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/double_points.mp3", 1)
	end),
})

//Max Ammo
nz.PowerUps.Functions.NewPowerUp("maxammo", {
	name = "Max Ammo",
	model = "models/Items/BoxSRounds.mdl",
	scale = 1.5,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/max_ammo.mp3", 2)
		//Give everyone ammo
		for k,v in pairs(player.GetAll()) do
			nz.Weps.Functions.GiveMaxAmmo(v)
		end
	end),
})

//Insta Kill
nz.PowerUps.Functions.NewPowerUp("insta", {
	name = "Insta Kill",
	model = "models/Gibs/HGIBS.mdl",
	scale = 3,
	chance = 5,
	duration = 30,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/insta_kill.mp3", 1)
	end),
})

//Nuke
nz.PowerUps.Functions.NewPowerUp("nuke", {
	name = "Nuke",
	model = "models/props_junk/watermelon01.mdl",
	scale = 1.5,
	chance = 5,
	duration = 0,
	func = (function(self, ply)
		nz.Notifications.Functions.PlaySound("nz/powerups/nuke.mp3", 1)
		nz.PowerUps.Functions.Nuke()
	end),
})
