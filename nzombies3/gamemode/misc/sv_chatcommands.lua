//Chat Commands

//Setup
nz.Misc.Data.ChatCommands = {}

//Functions
function nz.Misc.Functions.NewChatCommand(text, func)
	table.insert(nz.Misc.Data.ChatCommands, {text, func})
end

//Hooks
hook.Add( "PlayerSay", "chatCommand", function( ply, text, public )
	local text = string.lower(text)
	for k,v in pairs(nz.Misc.Data.ChatCommands) do
		if (string.sub(text, 1, string.len(v[1])) == v[1]) then
			v[2](ply, text)
			return false
		end
	end
end )

//Quick Function
NewChatCommand = nz.Misc.Functions.NewChatCommand

// Actual Chat Commands

NewChatCommand("/ready", function(ply, text)
	nz.Rounds.Functions.ReadyUp(ply)
end)

NewChatCommand("/unready", function(ply, text)
	nz.Rounds.Functions.UnReady(ply)
end)

NewChatCommand("/dropin", function(ply, text)
	nz.Rounds.Functions.DropIn(ply)
end)

NewChatCommand("/dropout", function(ply, text)
	nz.Rounds.Functions.DropOut(ply)
end)

NewChatCommand("/create", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Rounds.Functions.CreateMode()
	end
end)

NewChatCommand("/generate", function(ply, text)
	if ply:IsSuperAdmin() then
		if #ents.FindByClass("info_player_start") > 0 then
			navmesh.BeginGeneration( )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] There were no walkable seeds found. Please stand on the ground, and use /forcegenerate." )
		end
	end
end)

NewChatCommand("/save", function(ply, text)
	if ply:IsSuperAdmin() then
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			nz.Mapping.Functions.SaveConfig()
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't save outside of create mode." )
		end
	end
end)

NewChatCommand("/forcegenerate", function(ply, text)
	if ply:IsSuperAdmin() then
		local ent = ents.Create("info_player_start")
		ent:SetPos(ply:GetPos())
		ent:Spawn()
		navmesh.BeginGeneration( )
	end
end)

NewChatCommand("/load", function(ply, text)
	if ply:IsSuperAdmin() then
		if nz.Rounds.Data.CurrentState == ROUND_CREATE or nz.Rounds.Data.CurrentState == ROUND_INIT then
			nz.Interfaces.Functions.SendInterface(ply, "ConfigLoader", {configs = file.Find( "nz/nz_"..game.GetMap( ).."*", "DATA" )})
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't load while playing!" )
		end
	end
end)

//Tests

NewChatCommand("/spec", function(ply, text)
	ply:PermSpec()
end)

NewChatCommand("/soundcheck", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Notifications.Functions.PlaySound("nz/powerups/double_points.mp3", 1)
		nz.Notifications.Functions.PlaySound("nz/powerups/insta_kill.mp3", 2)
		nz.Notifications.Functions.PlaySound("nz/powerups/max_ammo.mp3", 2)
		nz.Notifications.Functions.PlaySound("nz/powerups/nuke.mp3", 2)

		nz.Notifications.Functions.PlaySound("nz/round/round_start.mp3", 14)
		nz.Notifications.Functions.PlaySound("nz/round/round_end.mp3", 9)
		nz.Notifications.Functions.PlaySound("nz/round/game_over_4.mp3", 21)
	end
end)

//puts all players into creative mode regardless of rank.
NewChatCommand("/createall", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Rounds.Functions.CreateAllMode()
	end
end)

//Either readies up all players or drops them in the following round.
NewChatCommand("/readyall", function(ply, text)
	for k,v in pairs(player.GetAll()) do
			nz.Rounds.Functions.DropIn(v)
	end
	PrintMessage( HUD_PRINTTALK, "All players will drop in next round!" )
end)

//Gives all super admins 100000 points.
NewChatCommand("/givepoints", function(ply, text)
if ply:IsSuperAdmin() then
for k,v in pairs(player.GetAll()) do
		if v:IsSuperAdmin() then
			v:GivePoints(100000)

		end
		PrintMessage( HUD_PRINTTALK, "Superadmins have been given 100000 points." )
	end
end)

//Forces the round to end by killing all enemies on the map and forcing a new round. Untested, use at your own risk
NewChatCommand("/endround", function(ply, text)
if ply:IsSuperAdmin() or ply:IsAdmin() then
for k,v in pairs(nz.Config.ValidEnemies) do
		for k2,enemy in pairs(ents.FindByClass(v)) do
			if enemy:IsValid() then
				local insta = DamageInfo()
				insta:SetDamage(enemy:Health())
				insta:SetAttacker(Entity(0))
				insta:SetDamageType(DMG_DISSOLVE)
				//Delay so it doesnt "die" twice
				timer.Simple(0.1, function() if enemy:IsValid() then enemy:TakeDamageInfo( insta ) end 

end)
			end
		end	
	end
nz.Rounds.Functions.PrepareRound()
end)

//gives super admins all perks (Will only work they you have a compatible weapon, otherwise is buggy) Does give quick revive despite it not being programmed at the time of writing, for future proofing.
NewChatCommand("/allperks", function(ply, text)
if ply:IsSuperAdmin() then
	for k,v in pairs(player.GetAll()) do
		if v:IsSuperAdmin() then
		v:GivePerk("jugg")
		v:GivePerk("dtap")
		v:GivePerk("sleight")
		v:GivePerk("pap")
		v:GivePerk("revive")
		end
	end
end)

//Removes your perks
NewChatCommand("/removeperks", function(ply, text)
ply:RemovePerks()
end)

//Removes all players perks.
NewChatCommand("/removeperksall", function(ply, text)
if ply:IsSuperAdmin() or ply:IsAdmin() then
for k,v in pairs(player.GetAll()) do
		v:RemovePerks()
	end
end)

//Respawns random box. Included for debug reasons
NewChatCommand("/respawn", function(ply, text)
	if ply:IsSuperAdmin() or ply:IsAdmin() then
nz.RandomBox.Functions.RemoveBox()
nz.RandomBox.Functions.SpawnBox()
	end
end)

//Respawns the user. Not tested, use with caution.
NewChatCommand("/respawn", function(ply, text)
if ply:IsSuperAdmin() or ply:IsAdmin() then
nz.Rounds.Functions.ReSpawn(ply)
	end
end)

//total reset of game
NewChatCommand("/resetgame", function(ply, text)
	if ply:IsSuperAdmin() then
		nz.Rounds.Functions.ResetGame()
	end
end)