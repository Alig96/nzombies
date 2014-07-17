DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 100
PLAYER.RunSpeed				= 200
PLAYER.CanUseFlashlight     = true

//Don't forget Colours

function PLAYER:Loadout()

	self.Player:SetTeam(TEAM_PLAYERS)
	if self.Player:GetPoints() == 0 then
		if nz.Rounds.CurrentRound != 1 then
			self.Player:SetPoints(nz.Config.BaseStartingPoints + (nz.Rounds.CurrentRound * nz.Config.PerRoundPoints))
		else
			self.Player:SetPoints(nz.Config.BaseStartingPoints)
		end
	end
	
	for k2,v2 in pairs(nz.Config.BaseStartingWeapons) do
		self.Player:Give(v2)
		self.Player:SetAmmo(nz.Config.BaseStartingAmmoAmount, weapons.Get(v2).Primary.Ammo)
	end
	for k,v in pairs(FAS2_Attachments) do
		self.Player:FAS2_PickUpAttachment(v.key)
	end
end

function PLAYER:Spawn()
	
	//Get player number
	for k,v in pairs(player.GetAll()) do
		if v == self.Player then
			//Set their position
			if nz.Rounds.PlayerSpawns[1] != nil then
				if #nz.Rounds.PlayerSpawns >= #player.GetAll() then
					v:SetPos(nz.Rounds.PlayerSpawns[k] + Vector(0,0,20))
				else
					print("Not enough player spawns! Not forcing player spawns.")
				end
			else
				print("Not enough player spawns! Not forcing player spawns.")
			end
		end
	end
	
end

function PLAYER:SetModel()

	local cl_playermodel = self.Player:GetInfo( "cl_playermodel" )
	
	//Get player number
	for k,v in pairs(player.GetAll()) do
		if v == self.Player then
			if nz.Config.PlayerModels[1] != nil then
				if nz.Config.PlayerModelsSystem then
					if nz.Config.PlayerModels[k] != nil then
						cl_playermodel = nz.Config.PlayerModels[k]
					else
						//Fall back if there's not enough models
						cl_playermodel = table.Random(nz.Config.PlayerModels)
					end
				end
			end
		end
	end					
	
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

player_manager.RegisterClass( "player_ingame", PLAYER, "player_default" )