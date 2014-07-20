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