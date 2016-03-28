//Main Tables
nz.Config = {}
//nz.Config.Functions = {}
//nz.Config.Data = {}

// Defaults 

//Zombie table - Moved to shared area for client collision prediction (barricades)
nz.Config.ValidEnemies = {
	["nz_zombie_walker"] = {
		//Set to false to disable the spawning of this zombie
		Valid = true,
		//Allow you to scale damage on a per-hitgroup basis
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			//Headshots for double damage
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		//Function runs whenever the zombie is damaged (NOT when killed)
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			//If player is playing and is not downed, give points
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		//Function is run whenever the zombie is killed
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then
					attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then
					attacker:GivePoints(100)
				else
					attacker:GivePoints(50)
				end
			end
		end
	},
	["nz_zombie_special_burning"] = {
		Valid = true,
		ScaleDMG = function(zombie, hitgroup, dmginfo)
			if hitgroup == HITGROUP_HEAD then dmginfo:ScaleDamage(2) end
		end,
		OnHit = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				attacker:GivePoints(10)
			end
		end,
		OnKilled = function(zombie, dmginfo, hitgroup)
			local attacker = dmginfo:GetAttacker()
			if attacker:IsPlayer() and attacker:GetNotDowned() then
				if dmginfo:GetDamageType() == DMG_CLUB then
					attacker:GivePoints(130)
				elseif hitgroup == HITGROUP_HEAD then
					attacker:GivePoints(100)
				else
					attacker:GivePoints(50)
				end
			end
		end
	}
}

nz.Config.DownTime = 45 				//How long time in seconds until you die from not being revived while downed

	NZ_POINT_NOTIFCATION_NET = 1 		//Net messages from the server on points gained or lost - More precise but costs net usage
	NZ_POINT_NOTIFCATION_CLIENT = 2		//Calculated client-side per frame - No constant net messages but may stack multiple in 1 frame
	
nz.Config.PointNotifcationMode = NZ_POINT_NOTIFCATION_NET

nz.Config.MaxPerks = 4					//The max perks you can BUY (You can get more in other ways) 

//Random Box

nz.Config.WeaponBlackList = {}
function nz.Config.AddWeaponToBlacklist( class, remove )
	nz.Config.WeaponBlackList[class] = remove and nil or true
end

nz.Config.AddWeaponToBlacklist( "weapon_base" )
nz.Config.AddWeaponToBlacklist( "weapon_fists" )
nz.Config.AddWeaponToBlacklist( "weapon_flechettegun" )
nz.Config.AddWeaponToBlacklist( "weapon_medkit" )
nz.Config.AddWeaponToBlacklist( "weapon_dod_sim_base" )
nz.Config.AddWeaponToBlacklist( "weapon_dod_sim_base_shot" )
nz.Config.AddWeaponToBlacklist( "weapon_dod_sim_base_snip" )
nz.Config.AddWeaponToBlacklist( "weapon_sim_admin" )
nz.Config.AddWeaponToBlacklist( "weapon_sim_spade" )
nz.Config.AddWeaponToBlacklist( "fas2_base" )
nz.Config.AddWeaponToBlacklist( "fas2_ammobox" )
nz.Config.AddWeaponToBlacklist( "fas2_ifak" )
nz.Config.AddWeaponToBlacklist( "nz_multi_tool" )
nz.Config.AddWeaponToBlacklist( "nz_grenade" )
nz.Config.AddWeaponToBlacklist( "nz_perk_bottle" )
nz.Config.AddWeaponToBlacklist( "nz_quickknife_crowbar" )
nz.Config.AddWeaponToBlacklist( "nz_tool_base" )
nz.Config.AddWeaponToBlacklist( "nz_one_inch_punch" ) -- Nope! You gotta give this with special map scripts

nz.Config.WeaponWhiteList = {
	"fas2_", "m9k_",
}
nz.Config.UseWhiteList = true -- Whether to load only from the whitelist (still bans from the blacklist)

-- Whether to replace the white- and blacklist with the config's Map Settings list - turn off to always use the above lists
nz.Config.UseMapWeaponList = true

if SERVER then

	//Zombie path retargeting
	//Whether zombies and spawnpoints will check if Nav Group IDs are the same as their target player's before spawning
	nz.Config.NavGroupTargeting = true
	
	//Curves

	nz.Config.MaxRounds = 100 // How much round data should we load?

	//Spawn Rate Curve
	nz.Config.BaseDifficultySpawnRateCurve = 5
	nz.Config.DifficultySpawnRateCurve = 1.01
	//Health Curve
	nz.Config.BaseDifficultyHealthCurve = 75
	nz.Config.DifficultyHealthCurve = 1.1 -- +10% each round
	//Speed curve
	nz.Config.BaseDifficultySpeedCurve = 60
	nz.Config.DifficultySpeedCurve = 0.5

	//Display

	//Door_System

	//Electricity

	//Enemies
	nz.Config.SpecialRoundInterval = 6
	nz.Config.SpecialRoundData = {
		types = {
			["nz_zombie_special_burning"] = {
				chance = 100,
			}
		},
		modifycount = function(original) -- Modify the count of zombies on special rounds
			return original * 0.5
		end
	}
	
	nz.Config.EnemyTypes = {}
	--nz.Config.EnemyTypes[1] = {["nz_zombie_walker"] = 100}
	
	nz.Config.EnemyTypes[1] = { 
		types = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nz.Config.EnemyTypes[2] = { 
		types = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nz.Config.EnemyTypes[6] = { 
		types = {
			["nz_zombie_special_burning"] = {
				chance = 100,
				count = 20,
				speeds = { -- The speeds table can be autogenerated, but a different one can be provided as well like here
					[70] = 10,
					[80] = 80,		-- This table takes priority over the generated one
					[95] = 10		-- These zombies subtract 20 from the speed as they move slower, set these 20 higher than you want
				},
			},
		},
		special = true
	}
	nz.Config.EnemyTypes[7] = { 
		types = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nz.Config.EnemyTypes[13] = { 
		types = {
			["nz_zombie_walker"] = {
				chance = 80,
			},
			["nz_zombie_special_burning"] = {
				chance = 20,
			},
		},
	}
	nz.Config.EnemyTypes[14] = { 
		types = {
			["nz_zombie_walker"] = {
				chance = 100,
			},
		},
	}
	nz.Config.EnemyTypes[23] = { 
		types = {
			["nz_zombie_walker"] = {
				chance = 90,
			},
			["nz_zombie_special_burning"] = {
				chance = 10,
			},
		},
	}
	
	--[[nz.Config.EnemyTypes[6] = {["nz_zombie_special_burning"] = 100, count = 20}
	nz.Config.EnemyTypes[7] = {["nz_zombie_walker"] = 100}
	nz.Config.EnemyTypes[13] = {["nz_zombie_walker"] = 80, ["nz_zombie_special_burning"] = 20}
	nz.Config.EnemyTypes[18] = {["nz_zombie_special_burning"] = 100}
	nz.Config.EnemyTypes[19] = {["nz_zombie_walker"] = 70, ["nz_zombie_special_burning"] = 30}
	//nz.Config.EnemyTypes[4] = {["hellhounds"] = 100}
	//nz.Config.EnemyTypes[4] = {["nz_zombie_walker"] = 80, ["hellhounds"] = 20}]]

	//Max amount of zombies at the same time
	nz.Config.MaxZombiesSim = 100

	//Interfaces

	//Mapping

	//Misc
	nz.Config.Halos = false

	//Perks

	//Player Class
	nz.Config.BaseStartingWeapons = {"fas2_glock20"} //"fas2_p226", "fas2_ots33", "fas2_glock20" "weapon_pistol"
	//nz.Config.CustomConfigStartingWeps = true -- If this is set to false, the gamemode will avoid using custom weapons in configs

	//Points
	nz.Config.BaseStartingPoints = 500

	//Powerups
	nz.Config.PowerUpChance = 100 // Chance is 1 in X (Default: 1 in 100 chance)

	//Props_Menu

	//Round Handler

	//Time Between rounds
	nz.Config.PrepareTime = 10

	//Spectator

	nz.Config.AllowDropins = true

	//Weapons
	nz.Config.MaxWeps = 2

end

//Shared

//Barricades
nz.Config.MaxPlanks = 6
