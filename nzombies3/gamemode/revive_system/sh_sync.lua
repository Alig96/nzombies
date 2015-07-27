//Client Server Syncing

if SERVER then

	//Server to client (Server)
	util.AddNetworkString( "nz.Revive.Sync" )
	
	function nz.Revive.Functions.SendSync()
		local data = table.Copy(nz.Revive.Data.Players)
		
		net.Start( "nz.Revive.Sync" )
			net.WriteTable( data )
		net.Broadcast()
	end

end

if CLIENT then
	
	//Server to client (Client)
	function nz.Revive.Functions.ReceiveSync( length )
		print("Received Player Revival Sync")
		nz.Revive.Data.Players = net.ReadTable()
		PrintTable(nz.Revive.Data.Players)
		
		for k,v in pairs(player.GetAll()) do
			if nz.Revive.Data.Players[v] then
				v:AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_SIT_PISTOL)
			else
				v:AnimResetGestureSlot(GESTURE_SLOT_GRENADE)
				if v == LocalPlayer() then nz.Revive.Functions.ResetColorFade() end
			end
		end
	end
	
	//Receivers
	net.Receive( "nz.Revive.Sync", nz.Revive.Functions.ReceiveSync )
end
