//

function nz.Mapping.Functions.CheckSpawns()

	//Check Player spawns
	if #ents.FindByClass("player_spawns") == 0 then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the map does not have any player spawns placed." )
			end
		end
		return false
	end
	
	//Check Zombie Spawns
	if #ents.FindByClass("zed_spawns") == 0 then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the map does not have any zombie spawns placed." )
			end
		end
		return false
	end
	
	return true
end

function nz.Mapping.Functions.CheckEnoughPlayerSpawns()

	//Check Player spawns
	if #ents.FindByClass("player_spawns") < #player.GetAll() then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the map does not have enough player spawns." )
			end
		end
		return false
	end
	
	return true
end