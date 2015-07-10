//Main Tables
nz.Config = {}
//nz.Config.Functions = {}
//nz.Config.Data = {}

// Defaults
if SERVER then

	//MAIN CONFIG
	nz.Config.PrepareTime = 10

	
	//Max amount of zombies at the same time
	nz.Config.MaxZombiesSim = 100
	
	
	//Curves
	
	//Spawn Rate Curve
	nz.Config.BaseDifficultySpawnRateCurve = 5
	nz.Config.DifficultySpawnRateCurve = 1.01
	//Health Curve
	nz.Config.BaseDifficultyHealthCurve = 75
	nz.Config.DifficultyHealthCurve = 0.4
	//Speed curve 
	nz.Config.BaseDifficultySpeedCurve = 60
	nz.Config.DifficultySpeedCurve = 0.55

	//WeaponBlackList
	nz.Config.WeaponBlackList = {"gmod_tool_base", "gmod_tool_wepbuy", "gmod_tool_playerspawns", 
	"gmod_tool_zedspawns", "gmod_tool_doors", "gmod_tool_block", 
	"gmod_tool_elec", "gmod_tool_randomboxspawns", "gmod_tool_ee",
	"weapon_dod_sim_base", "weapon_dod_sim_base_shot",
	"weapon_dod_sim_base_snip", "weapon_sim_admin",
	"weapon_medkit", "weapon_sim_spade", "gmod_tool_buyabledebris", "gmod_tool_perkmachinespawns",
	"fas2_base", "fas2_ammobox", "weapon_base", "weapon_fists", "flechette_gun", "fas2_ifak",
	"fas2_base_shotgun", "nz_tool_base"
	}
	
end

//Shared
