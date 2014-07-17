function GM:PlayerDeath( ply, wep, killer )

	if ply:Team() != TEAM_SPECS then 
		ply:SetTeam(TEAM_SPECS) 
	end
		
	ply.SpecID = 1
	ply.SpecType = 5
	ply:Spectate( OBS_MODE_CHASE )
	ply:SpectateEntity( killer )
end

function GM:PlayerDeathThink( ply )
	local players = team.GetPlayers( TEAM_PLAYERS )
	
	if ply:KeyPressed( IN_JUMP ) then
		ply.SpecType = ply.SpecType + 1
		if ply.SpecType > 6 then ply.SpecType = 4 end
		ply:Spectate( ply.SpecType )
	elseif ply:KeyPressed( IN_ATTACK ) then
		if !ply.SpecID then ply.SpecID = 1 end
		ply.SpecID = ply.SpecID + 1
		if ply.SpecID > #players then ply.SpecID = 1 end
		ply:SpectateEntity( players[ ply.SpecID ] )
	elseif ply:KeyPressed( IN_ATTACK2 ) then
		if !ply.SpecID then ply.SpecID = 1 end
		ply.SpecID = ply.SpecID - 1
		if ply.SpecID <= 0 then ply.SpecID = #players end
		ply:SpectateEntity( players[ ply.SpecID ] )
	end
end