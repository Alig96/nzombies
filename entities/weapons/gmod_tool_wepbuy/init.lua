AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

util.AddNetworkString( "tool_wepbuy_net" )

net.Receive( "tool_wepbuy_net", function( length, client )
	--validate
	WeaponBuySpawn(net.ReadVector(), net.ReadString(), tonumber(net.ReadString()), net.ReadAngle())
end )