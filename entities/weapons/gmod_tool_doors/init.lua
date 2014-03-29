AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

util.AddNetworkString( "tool_door_net" )

net.Receive( "tool_door_net", function( length, client )
	--validate
	DoorSpawn(net.ReadString(), net.ReadString())
	bnpvbWJpZXM.Rounds.Functions.SyncClients()
end )