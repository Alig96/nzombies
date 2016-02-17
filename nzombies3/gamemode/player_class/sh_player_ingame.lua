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
	//Give ammo and guns
	for k,v in pairs(nz.Config.BaseStartingWeapons) do
		self.Player:Give( v )
	end
	nz.Weps.Functions.GiveMaxAmmo(self.Player)

	if FAS2_Attachments != nil then
		for k,v in pairs(FAS2_Attachments) do
			self.Player:FAS2_PickUpAttachment(v.key)
		end
	end
	
end
function PLAYER:Spawn()

	if !self.Player:CanAfford(nz.Config.BaseStartingPoints) then //Has less than 500 points
		//Poor guy has no money, lets start him off
		self.Player:SetPoints(nz.Config.BaseStartingPoints)
	end

	//Reset their perks
	self.Player:RemovePerks()

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
