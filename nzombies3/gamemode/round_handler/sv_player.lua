//

//Player Functions

function nz.Rounds.Functions.ReadyUp(ply)
	//check if they are set to perm spec
	if !ply:IsPermSpec() then
		PrintMessage( HUD_PRINTTALK, ply:Nick().." is ready!" )
		ply.Ready = 1
	else
		PrintMessage( HUD_PRINTTALK, ply:Nick().." is set to perm spec and cannot ready up!" )
	end
end

function nz.Rounds.Functions.UnReady(ply)
	if !ply:IsPermSpec() then
		PrintMessage( HUD_PRINTTALK, ply:Nick().." is no longer ready!" )
		ply.Ready = 0
	else
		PrintMessage( HUD_PRINTTALK, ply:Nick().." is set to perm spec and cannot ready up!" )
	end
end

function nz.Rounds.Functions.ReSpawn(ply)
	if ply:IsValid() then
		//Setup a player
		ply:SetTeam( TEAM_PLAYERS )
		player_manager.SetPlayerClass( ply, "player_ingame" )
		if !ply:Alive() then
			ply:Spawn()
		end
	end
end

function nz.Rounds.Functions.Create(ply)

	//Setup a player
	ply:SetTeam( TEAM_PLAYERS )
	player_manager.SetPlayerClass( ply, "player_create" )
	if !ply:Alive() then
		ply:Spawn()
	end
	//SetPos
	
end
