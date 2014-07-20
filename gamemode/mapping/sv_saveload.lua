//Config Saver
nz.Mapping = {}
nz.Mapping.Functions = {}
nz.Mapping.LastSave = "Unsaved"

function nz.Mapping.Functions.SaveConfig()
	local main = {}

	local wall_buys = {}
	for k,v in pairs(ents.FindByClass("wall_buy")) do
		table.insert(wall_buys, {
		pos = v:GetPos(),
		wep = v.WeaponGive,
		price = v.Price,
		angle = v:GetAngles( ),
		})
	end
	
	local zed_spawns = {}
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		table.insert(zed_spawns, {
		pos = v:GetPos(),
		link = v.Link
		})
	end
	
	local player_spawns = {}
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		table.insert(player_spawns, {
		pos = v:GetPos(),
		})
	end
	
	//Normal Map doors
	local door_setup = {}
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		v = nz.Doors.Functions.doorIndexToEnt(k)
		if v:IsDoor() and v:GetClass() != "wall_block_buy" then
			door_setup[k] = {
			flags = v.Data,
			}
		end
	end
	
	local block_spawns = {}
	for k,v in pairs(ents.FindByClass("wall_block")) do
		table.insert(block_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	
	local elec_spawn = {}
	for k,v in pairs(ents.FindByClass("button_elec")) do
		table.insert(elec_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	
	local randombox_spawn = {}
	for k,v in pairs(ents.FindByClass("random_box_spawns")) do
		table.insert(randombox_spawn, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		})
	end
	
	local perk_machinespawns = {}
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		table.insert(perk_machinespawns, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			id = v:GetPerkID(),
		})
	end
	
	local buyableblock_spawns = {}
	for k,v in pairs(ents.FindByClass("wall_block_buy")) do
		table.insert(buyableblock_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		flags = v.Data,
		})
	end
	
	local eggs = {}
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		table.insert(eggs, {
		pos = v:GetPos(),
		angle = v:GetAngles( ),
		model = v:GetModel(),
		})
	end
	
	main["WallBuys"] = wall_buys
	main["ZedSpawns"] = zed_spawns
	main["PlayerSpawns"] = player_spawns
	main["DoorSetup"] = door_setup
	main["BlockSpawns"] = block_spawns
	main["BuyableBlockSpawns"] = buyableblock_spawns
	main["ElecSpawns"] = elec_spawn
	main["RandomBoxSpawns"] = randombox_spawn
	main["PerkMachineSpawns"] = perk_machinespawns
	main["EasterEggs"] = eggs
	main["StartingWep"] = nz.Config.BaseStartingWeapons
	file.Write( "nz/nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt", util.TableToJSON( main ) )
	PrintMessage( HUD_PRINTTALK, "[NZ] Saved to garrysmod/data/nz/".."nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt" )
	nz.Mapping.LastSave = "nz/nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt"
end

function nz.Mapping.Functions.ClearConfig()
	print("[NZ] Clearing current map")
	
	for k,v in pairs(ents.FindByClass("wall_buy")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		v:Remove()
	end
	
	//Normal Map doors
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		nz.Doors.Functions.RemoveLink(k)
	end
	
	for k,v in pairs(ents.FindByClass("wall_block")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("button_elec")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("random_box_spawns")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("wall_block_buy")) do
		nz.Doors.Functions.RemoveLinkSpec( v )
		v:Remove()
	end

	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v:Remove()
	end
	
	nz.Rounds.Functions.SyncClients()
	nz.Doors.Functions.SyncClients()
end

function nz.Mapping.Functions.LoadConfig( name )
	local filepath = "nz/"..name..".txt"
	if file.Exists( filepath, "DATA" ) then
		nz.Mapping.LastSave = filepath
		print("[NZ] MAP CONFIG FOUND!")
		
		nz.Mapping.Functions.ClearConfig()
		
		local data = util.JSONToTable( file.Read( filepath, "DATA" ) )
		//Start sorting the data
		for k,v in pairs(data.BuyableBlockSpawns) do
			BuyableBlockSpawn(v.pos, v.angle, v.model, v.flags)
		end
		
		for k,v in pairs(data.WallBuys) do
			WeaponBuySpawn(v.pos,v.wep, v.price, v.angle)
		end
		
		for k,v in pairs(data.ZedSpawns) do
			if v.link == nil then
				ZedSpawn(v.pos, "0")
			else
				ZedSpawn(v.pos, v.link)
			end
		end
		
		for k,v in pairs(data.PlayerSpawns) do
			PlayerSpawn(v.pos)
		end
		
		for k,v in pairs(data.DoorSetup) do
			nz.Doors.Functions.CreateLink(k, v.flags)
		end
		
		for k,v in pairs(data.BlockSpawns) do
			BlockSpawn(v.pos, v.angle, v.model)
		end
		
		for k,v in pairs(data.ElecSpawns) do
			ElecSpawn(v.pos, v.angle, v.model)
		end
		
		for k,v in pairs(data.RandomBoxSpawns) do
			RandomBoxSpawn(v.pos, v.angle)
		end

		for k,v in pairs(data.PerkMachineSpawns) do
			PerkMachineSpawn(v.pos, v.angle, v.id)
		end
		
		for k,v in pairs(data.EasterEggs) do
			EasterEggSpawn(v.pos, v.angle, v.model)
		end
		
		if data.StartingWep != nil then
			print("CHANGING")
			if nz.Config.CustomConfigStartingWeps then
				nz.Config.BaseStartingWeapons = data.StartingWep
			end
		else
			print("NOT CHANGING")
		end
		
		nz.Rounds.Functions.SyncClients()
		nz.Doors.Functions.SyncClients()
		
	else
		print(filepath)
		print("[NZ] Warning: NO MAP CONFIG FOUND! Make a config in game using the /create command, then use /save to save it all!")
	end
end

hook.Add("Initialize", "nz_Loadmaps", function()
	timer.Simple(5, function()
		nz.Mapping.Functions.LoadConfig("nz_"..game.GetMap())
	end)
end)