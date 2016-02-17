//Client Server Syncing

if CLIENT then

	//Client to Server (Client)
	function nz.PropsMenu.Functions.Request( model )
		net.Start( "nz.PropsMenu.Request" )
			net.WriteString( model )
		net.SendToServer()
	end

end

if SERVER then

	//Client to Server (Server)
	util.AddNetworkString( "nz.PropsMenu.Request" )

	function nz.PropsMenu.Functions.HandleRequest( len, ply )
		local model = net.ReadString()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			print(ply:Nick() .. " requested prop " .. model)
			if ply:IsSuperAdmin() then
				local tr = util.GetPlayerTrace( ply )
				tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
				local trace = util.TraceLine( tr )

				nz.Mapping.Functions.PropBuy(trace.HitPos,Angle(0,0,0),model)
				//Since we're adding a prop, lets switch to the phys gun for convenience
				ply:SelectWeapon( "weapon_physgun" )
			else
				print("Denied request from " .. ply:Nick())
			end
		end
	end

	//Receivers
	net.Receive( "nz.PropsMenu.Request", nz.PropsMenu.Functions.HandleRequest )

end
