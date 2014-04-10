AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

SWEP.Weight			= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

util.AddNetworkString( "tool_zombies_net" )

net.Receive( "tool_zombies_net", function( length, client )
	--validate
	local ent = net.ReadEntity()
	local lin = net.ReadString()
	
	ent.Link = lin
	
	print(ent)
	print("Link Set: "..lin)
end )