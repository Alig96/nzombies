//    nZombies - Zombie Survival Garry's Mod 13 Gamemode
//    Copyright (C) 2014  Ali Aslam (Alig96)
//    Contact Information: aliaslam191919@gmail.com
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//   This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

// Defaults

if SERVER then
	//conv = {}
	//MAIN CONFIG
	//Disable player respawns?
	nz.Config.Hardcore = false
	//Allow players to spawn in directly after round, before game is over?
	nz.Config.AllowDropins = false
	//Time inbetween each round
	nz.Config.PrepareTime = 10
	
	//The first wave of zombies
	nz.Config.BaseDifficultySpawnRateCurve = 5
	//Difficulty of the curve
	nz.Config.DifficultySpawnRateCurve = 1.01
	//Base health at level 1
	nz.Config.BaseDifficultyHealthCurve = 75
	//Difficulty of the curve
	nz.Config.DifficultyHealthCurve = 0.4
	
	//Max amount of zombies at the same time
	nz.Config.MaxZombiesSim = 100
	
	//Self Explanitory
	nz.Config.BaseStartingPoints = 500
	nz.Config.PerRoundPoints = 50

	nz.Config.BaseStartingAmmoAmount = 120
	nz.Config.MaxAmmo = 120
	nz.Config.MaxWeapons = 2
	
	nz.Config.BaseStartingWeapons = {"fas2_p226", "fas2_ots33"}
	nz.Config.CustomConfigStartingWeps = true -- If this is set to false, the gamemode will avoid using custom weapons in configs

	//Change name variables
	//Setting this to true allows for the gamemode change the name to have a tag in front while its going on
	nz.Config.AllowServerName = true
	nz.Config.ServerName =	GetHostName()
	nz.Config.ServerNameProg = "[In Progress] "
	//Similar to Allow Server name, but it also locks the server.
	nz.Config.AllowServerPasswordLocking = false
	
	//Guns that are NOT allowed in the random box. You should add things such as weapon bases here.
	nz.Config.WeaponBlackList = {"gmod_tool_base", "gmod_tool_wepbuy", "gmod_tool_playerspawns", 
	"gmod_tool_zedspawns", "gmod_tool_doors", "gmod_tool_block", 
	"gmod_tool_elec", "gmod_tool_randomboxspawns", "gmod_tool_ee",
	"weapon_dod_sim_base", "weapon_dod_sim_base_shot",
	"weapon_dod_sim_base_snip", "weapon_sim_admin",
	"weapon_medkit", "weapon_sim_spade", "gmod_tool_buyabledebris", "gmod_tool_perkmachinespawns",
	"fas2_base", "fas2_ammobox", "weapon_base", "weapon_fists", "flechette_gun", "fas2_ifak",
	"fas2_base_shotgun"
	}
	//The Speed curve 
	nz.Config.BaseDifficultySpeedCurve = 60
	nz.Config.DifficultySpeedCurve = 0.55
	
	//Paths of player models that will be set as soon as a round starts. Leave empty if you want to keep it as sandbox models.
	nz.Config.PlayerModels = {
	"models/player/Group01/Male_01.mdl",
	--"models/player/Group01/Male_01.mdl",
	}
	
	//Should it choose the player models systematically(true) or randomly (false)
	//Systematically would be:
	//Player 1 gets the first model, Player 2 gets the second model and so on.
	nz.Config.PlayerModelsSystem = false
	
	//The Percentage (out of a 100) of players that must be ready before the game will start
	nz.Config.ReadyupPerc = 0.68
	
	
	//Example
	//What to do when the easter eggs of the map has been found!
	hook.Add("nzombies_ee_active", "nzombies_ee_MapActivate", function( )
		local map = game.GetMap()
		
		print("Yay! All Easter Eggs found!")
	end)
	
	//Custom enemy setup
	
	nz.Config.ValidEnemies = {"nut_zombie", "nut_ex_zombie", "npc_zombie_test_752"}
	
	nz.Config.UseCustomEnemies = true
	
	nz.Config.EnemyTypes = {}
	//Index is the round that it starts to spawn them
	//The value is a table of all the zombie types that will spawn on that round
	//The first value of the table is the name of the npc/next bot that will be used.
	//The second is the weighting out of 100%
	//Distribute it as you wish, but make sure it adds up to 100 
	nz.Config.EnemyTypes[1] = {["nut_zombie"] = 100}
	nz.Config.EnemyTypes[4] = {["nut_ex_zombie"] = 100}
	nz.Config.EnemyTypes[5] = {["nut_zombie"] = 90, ["nut_ex_zombie"] = 10}
	nz.Config.EnemyTypes[10] = {["nut_ex_zombie"] = 100}
	nz.Config.EnemyTypes[11] = {["nut_ex_zombie"] = 20, ["nut_zombie"] = 80}
	nz.Config.EnemyTypes[14] = {["nut_ex_zombie"] = 30, ["nut_zombie"] = 70}
	
end

//Shared

//Power Ups
nz.PowerUps.Add({
	id = "dp",
	name = "Double Points",
	model = "models/props_c17/gravestone003a.mdl",
	scale = 0.5,
	chance = 30,
	effect = {time = 30, material = "mkservers/nz/powerups/dp.png"}
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

//Perks
nz.Perks.Add({
	id = "jug",
	name = "Juggernog",
	model = "models/perkacola/jug.mdl",
	material = "mkservers/nz/perks/juggernog.png",
	scale = 1,
	price = 2000,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		ply:SetHealth(200)
		return false
	end),
})
nz.Perks.Add({
	id = "dtap",
	name = "Double Tap",
	model = "models/perkacola/dtap.mdl",
	material = "mkservers/nz/perks/doubletap.png",
	scale = 1,
	price = 1500,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		return false
	end),
})
nz.Perks.Add({
	id = "speedcola",
	name = "Speed Cola",
	model = "models/perkacola/sleight.mdl",
	material = "mkservers/nz/perks/speedcola.png",
	scale = 1,
	price = 3000,
	snd = {"nz_juggernog", 1},
	func = function(self, ply)
		return false
	end,
})
nz.Perks.Add({
	id = "pap",
	name = "Pack A Punch",
	model = "models/perkacola/pap.mdl",
	scale = 1,
	price = 2000,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		return false
	end),
})
nz.Perks.Add({
	id = "revive",
	name = "Quick Revive",
	model = "models/perkacola/revive.mdl",
	material = "mkservers/nz/perks/quickrevive.png",
	scale = 1,
	price = 2000,
	snd = {"nz_juggernog", 1},
	func = (function(self, ply)
		return false
	end),
})

hook.Add("EntityFireBullets", "nzombies_pap_firebullets", function( ent, data )
	local gun = ent:GetActiveWeapon()
	if gun.PaP != nil then
		if gun.PaP then
			data.Damage = data.Damage * 10
			return true
		end
	end
end)
