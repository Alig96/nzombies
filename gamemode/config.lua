if SERVER then
	//Main Tables
	conv={}

	bnpvbWJpZXM = {}
	bnpvbWJpZXM.Config = {}
	
//Downloads
	resource.AddWorkshop("182104437")
	--resource.AddWorkshop("132835998")

	//Random Box
	resource.AddFile( "models/toybox.mdl" )
	resource.AddFile( "materials/models/toybox/zombie_treasure_box_c.vmt" )
	resource.AddFile( "materials/models/toybox/zombie_treasure_box_c.vtf" )
	resource.AddFile( "materials/models/toybox/zombie_treasure_fill_c.vmt" )
	resource.AddFile( "materials/models/toybox/zombie_treasure_fill_c.vtf" )
	resource.AddFile( "materials/models/toybox/zombie_treasure_fill_c.vtf" )
	
	//Fonts
	resource.AddFile( "resource/fonts/BOYCOTT_.ttf" )
	
	//Perkacola & PP
	resource.AddFile( "models/perkacola/dtap.mdl" )
	resource.AddFile( "models/perkacola/jug.mdl" )
	resource.AddFile( "models/perkacola/packapunch.mdl" )
	resource.AddFile( "models/perkacola/revive.mdl" )
	resource.AddFile( "models/perkacola/sleight.mdl" )
	resource.AddFile( "materials/models/perkacola/pack_a_punch_c.vmt" )
	resource.AddFile( "materials/models/perkacola/pack_a_punch_c.vtf" )
	resource.AddFile( "materials/models/perkacola/pack_a_punch_moving_c.vmt" )
	resource.AddFile( "materials/models/perkacola/pack_a_punch_moving_c.vtf" )
	resource.AddFile( "materials/models/perkacola/pack_a_punch_moving_n.vtf" )
	resource.AddFile( "materials/models/perkacola/pack_a_punch_n.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_perkbottle_jugg_n.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_perkbottle_sleight_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_perkbottle_sleight_c.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_doubletap_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_doubletap_c.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_doubletap_n.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_jugg_col.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_jugg_col.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_jugg_norm.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_revive_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_revive_c.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_revive_n.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_revsign_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_revsign_c.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_revsign_n.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_c.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_gc.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_gc.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_logo_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_logo_c.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_sleight_n.vtf" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_vent_power_on_c.vmt" )
	resource.AddFile( "materials/models/perkacola/zombie_vending_vent_power_on_c.vtf" )
	
	
	
	//MAIN CONFIG
	
	//The first wave of zombies
	bnpvbWJpZXM.Config.BaseDifficultySpawnRateCurve = 5
	//Difficulty of the curve
	bnpvbWJpZXM.Config.DifficultySpawnRateCurve = 1.01
	//Base health at level 1
	bnpvbWJpZXM.Config.BaseDifficultyHealthCurve = 75
	//Difficulty of the curve
	bnpvbWJpZXM.Config.DifficultyHealthCurve = 0.6
	
	//Max amount of zombies at the same time
	bnpvbWJpZXM.Config.MaxZombiesSim = 100
	
	//Self Explanitory
	bnpvbWJpZXM.Config.BaseStartingPoints = 500
	bnpvbWJpZXM.Config.BaseStartingWeapon = "weapon_sim_colt1911"
	bnpvbWJpZXM.Config.BaseStartingAmmoAmount = 120
	
	//Change name variables
	//Setting this to true allows for the gamemode change the name to have a tag in front while its going on
	bnpvbWJpZXM.Config.AllowServerName = true
	bnpvbWJpZXM.Config.ServerName =	GetHostName()
	bnpvbWJpZXM.Config.ServerNameProg = "[In Progress] "
	//Similar to Allow Server name, but it also locks the server.
	bnpvbWJpZXM.Config.AllowServerPasswordLocking = false
	
	//Guns that are NOT allowed in the random box. You should add things such as weapon bases here.
	bnpvbWJpZXM.Config.WeaponBlackList = {"gmod_tool_wepbuy", "gmod_tool_playerspawns", 
	"gmod_tool_zedspawns", "gmod_tool_doors", "gmod_tool_block", 
	"gmod_tool_elec", "gmod_tool_randomboxspawns",
	"weapon_dod_sim_base", "weapon_dod_sim_base_shot",
	"weapon_dod_sim_base_snip", "weapon_sim_admin",
	"medikit", "weapon_sim_spade", "gmod_tool_buyabledebris", "gmod_tool_perkmachinespawns"
	}
	//The Speed curve 
	bnpvbWJpZXM.Config.BaseDifficultySpeedCurve = 60
	bnpvbWJpZXM.Config.DifficultySpeedCurve = 0.55
	
	//Paths of player models that will be set as soon as a round starts. Leave empty if you want to keep it as sandbox models.
	bnpvbWJpZXM.Config.PlayerModels = {
	"models/player/Group01/Male_01.mdl",
	--"models/player/Group01/Male_01.mdl",
	}
	
	//Should it choose the player models systematically(true) or randomly (false)
	//Systematically would be:
	//Player 1 gets the first model, Player 2 gets the second model and so on.
	bnpvbWJpZXM.Config.PlayerModelsSystem = false
	
	//The Percentage (out of a 100) of players that must be ready before the game will start
	bnpvbWJpZXM.Config.ReadyupPerc = 0.68
	
end

//Shared
PerksColas = {}

PerksColas["jug"] = {
	["ID"] = "jug",
	["Name"] = "Juggernog",
	["Model"] = "models/perkacola/jug.mdl",
	["Price"] = 100,
	["Function"] = function(ply) 
		if ply:Health() < 200 then 
			ply:SetHealth(200) 
			return true 
		else 
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You already have 200 health!") 
		end 
	end
}

PerksColas["dtap"] = {
	["ID"] = "dtap",
	["Name"] = "Double Tap",
	["Model"] = "models/perkacola/dtap.mdl",
	["Price"] = 1000,
	["Function"] = function(ply) 
		ply:PrintMessage( HUD_PRINTTALK, "This perk has not been configured. Please consult the server admin.") 
	end
}

PerksColas["pap"] = {
	["ID"] = "pap",
	["Name"] = "Pack-a-Punch",
	["Model"] = "models/perkacola/packapunch.mdl",
	["Price"] = 100,
	["Function"] = function(ply) 
		local gun = ply:GetActiveWeapon()
		if gun.PaP == nil then
			gun.PaP = true
			ply:PrintMessage( HUD_PRINTTALK, "This perk is a WIP. Your weapon has been given extra damage, but there are no visual effects.") 
			return true 
		end
	end
}

hook.Add("EntityFireBullets", "nzombies_pap_firebullets", function( ent, data )
	local gun = ent:GetActiveWeapon()
	if gun.PaP != nil then
		if gun.PaP then
			data.Damage = data.Damage * 100
			return true
		end
	end
end)

if CLIENT then

end
