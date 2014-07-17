//Defaults
nz.Rounds.CurrentState = ROUND_INIT
nz.Rounds.CurrentRound = 0

//Misc
nz.Rounds.Elec = false

net.Receive( "nz_Round_Sync", function( length )
	print("Received Round Sync")
	nz.Rounds.CurrentState = tonumber(net.ReadString())
	nz.Rounds.CurrentRound = tonumber(net.ReadString())
	if !(nz.Rounds.CurrentState == ROUND_PREP or nz.Rounds.CurrentState == ROUND_PROG) or (nz.Rounds.CurrentRound <= 1) then
		nz.Rounds.Elec = false
	end
end )

net.Receive( "nz_Elec_Sync", function( length )
	print("Received Elec Sync")
	nz.Rounds.Elec = true
end )