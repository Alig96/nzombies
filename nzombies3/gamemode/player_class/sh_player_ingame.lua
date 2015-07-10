DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 100
PLAYER.RunSpeed				= 200
PLAYER.CanUseFlashlight     = true

function PLAYER:Init()
	//Don't forget Colours
	//This runs when the player is first brought into the game and when they die during a round and are brought back
	
end

function PLAYER:Loadout()
	self.Player:Give( "weapon_pistol" )
	self.Player:GiveAmmo( 255, "Pistol", true )
end
function PLAYER:Spawn()

	if !self.Player:CanAfford(500) then
		//Poor guy has no money, lets start him off
		self.Player:SetPoints(500)
	end
	
	local spawns = ents.FindByClass("player_spawns")
	//Get player number
	for k,v in pairs(player.GetAll()) do
		if v == self.Player then
			if spawns[k]:IsValid() then
				v:SetPos(spawns[k]:GetPos())
			else
				print("No spawn set for player: " .. v:Nick())
			end
		end
	end
end

player_manager.RegisterClass( "player_ingame", PLAYER, "player_default" )