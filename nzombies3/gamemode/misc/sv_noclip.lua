function GM:PlayerNoClip( ply, desiredState )
	if ply:Alive() and nz.Rounds.Data.CurrentState == ROUND_CREATE then
		return ply:IsSuperAdmin()
	end
end