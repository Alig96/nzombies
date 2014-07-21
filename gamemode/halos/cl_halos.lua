// TODO: Tidy up similar to chat commands.

//Zombie Spawns
hook.Add( "PreDrawHalos", "zed_spawns_halos", function()
	if nz.Rounds.CurrentState == ROUND_CREATE then
		halo.Add( ents.FindByClass( "zed_spawns" ), Color( 255, 0, 0 ), 0, 0, 0.1, 0, 1 )
	end
end )

hook.Add( "PreDrawHalos", "player_spawns_halos", function()
	if nz.Rounds.CurrentState == ROUND_CREATE then
		halo.Add( ents.FindByClass( "player_spawns" ), Color( 0, 255, 0 ), 0, 0, 0.1, 0, 1 )
	end
end )

hook.Add( "PreDrawHalos", "door_spawns_halos", function()
	if nz.Rounds.CurrentState == ROUND_CREATE then
		local doors = {}
		for k,v in pairs(nz.Doors.Data.EaDI) do
			table.insert(doors, ents.GetByIndex(k))
		end
		for k,v in pairs(nz.Doors.Data.BuyableBlocks) do
			table.insert(doors, ents.GetByIndex(k))
		end
		halo.Add( doors, Color( 0, 0, 255 ), 0, 0, 0.1, 0, 1 )
	end
end )

hook.Add( "PreDrawHalos", "wall_block_buy_halos", function()
	if nz.Rounds.CurrentState == ROUND_CREATE then
		local doors = ents.FindByClass( "wall_block_buy" )
		for k,v in pairs(nz.Doors.Data.BuyableBlocks) do
			table.RemoveByValue(doors, ents.GetByIndex(k))
		end
		halo.Add( doors, Color( 255, 230, 255 ), 0, 0, 0.1 )
	end
end )

hook.Add( "PreDrawHalos", "wall_buy_halos", function()
	halo.Add( ents.FindByClass( "wall_buy" ), Color( 255, 255, 255 ), 0, 0, 0.1 )
end )

hook.Add( "PreDrawHalos", "wall_block_halos", function()
	if nz.Rounds.CurrentState == ROUND_CREATE then
		halo.Add( ents.FindByClass( "wall_block" ), Color( 0, 255, 255 ), 0, 0, 0.1 )
	end
end )

hook.Add( "PreDrawHalos", "button_elec_halos", function()
	halo.Add( ents.FindByClass( "button_elec" ), Color( 255, 0, 255 ), 0, 0, 0.1 )
end )