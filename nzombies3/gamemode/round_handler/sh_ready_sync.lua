-- Client Server Syncing

if SERVER then

	-- Server to client (Server)
	util.AddNetworkString( "nz.Round.ReadySync" )
	
	function nz.Rounds.Functions.SendReadySync()
		local tbl = {}
		for k,v in pairs(player.GetAll()) do
			if v.Ready and v:IsValid() and !v:IsPermSpec() then
				tbl[v:EntIndex()] = true
			else
				tbl[v:EntIndex()] = false
			end
		end
		net.Start( "nz.Round.ReadySync" )
			net.WriteTable(tbl)
		net.Broadcast()
	end

end

if CLIENT then
	nz.Rounds.ReadyPlayers = {}
	
	-- Server to client (Client)
	function nz.Rounds.Functions.ReceiveReadySync( length )
		--print("Received Round Ready Sync")
		tbl = net.ReadTable()
		nz.Rounds.ReadyPlayers = tbl
		
		--PrintTable(tbl)
	end
	
	
	-- Receivers 
	net.Receive( "nz.Round.ReadySync", nz.Rounds.Functions.ReceiveReadySync )


end