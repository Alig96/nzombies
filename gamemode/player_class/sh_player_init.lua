DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 


PLAYER.DisplayName			= "Init Class"

PLAYER.WalkSpeed 			= 200		-- How fast to move when not running
PLAYER.RunSpeed				= 400		-- How fast to move when running

function PLAYER:Loadout()

end

function PLAYER:Spawn()
	//Determine if they should spectate
	//Blah
	print("Yay base class")
end

player_manager.RegisterClass( "player_init", PLAYER, "player_default" )
