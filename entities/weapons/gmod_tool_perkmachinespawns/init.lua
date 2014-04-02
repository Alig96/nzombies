AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

util.AddNetworkString( "tool_perk_net" )

net.Receive( "tool_perk_net", function( length, client )
	--validate
	local gun = client:GetWeapon("gmod_tool_perkmachinespawns")
	gun.PerkID = net.ReadString()
end )