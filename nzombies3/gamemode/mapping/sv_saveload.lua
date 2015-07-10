//

nz.Mapping.Data.Version = 300 //Note to Ali; Any time you make an update to the way this is saved, increment this.

function nz.Mapping.Functions.SaveConfig()

	local main = {}
	
	//Check if the nz folder exists
	if !file.Exists( "nz/", "DATA" ) then
		file.CreateDir( "nz" )
	end
	
	main.version = nz.Mapping.Data.Version
	
	local zed_spawns = {}
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		table.insert(zed_spawns, {
		pos = v:GetPos(),
		link = v.link
		})
	end
	
	local player_spawns = {}
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		table.insert(player_spawns, {
		pos = v:GetPos(),
		})
	end
	
	local wall_buys = {}
	for k,v in pairs(ents.FindByClass("wall_buys")) do
		table.insert(wall_buys, {
		pos = v:GetPos(),
		wep = v.WeaponGive,
		price = v.Price,
		angle = v:GetAngles( ),
		})
	end
	
	local buyableprop_spawns = {}
	for k,v in pairs(ents.FindByClass("prop_buys")) do
		table.insert(buyableprop_spawns, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		flags = v.Data,
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
	
	local block_spawns = {}
	for k,v in pairs(ents.FindByClass("wall_block")) do
		table.insert(block_spawns, {
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
	
	//Normal Map doors
	local door_setup = {}
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		v = nz.Doors.Functions.doorIndexToEnt(k)
		if v:IsDoor() then
			door_setup[k] = {
			flags = v.Data,
			}
		end
	end
	
	main["ZedSpawns"] = zed_spawns
	main["PlayerSpawns"] = player_spawns
	main["WallBuys"] = wall_buys
	main["BuyablePropSpawns"] = buyableprop_spawns
	main["ElecSpawns"] = elec_spawn
	main["BlockSpawns"] = block_spawns
	main["RandomBoxSpawns"] = randombox_spawn
	main["PerkMachineSpawns"] = perk_machinespawns
	main["DoorSetup"] = door_setup
	
	file.Write( "nz/nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt", util.TableToJSON( main ) )
	PrintMessage( HUD_PRINTTALK, "[NZ] Saved to garrysmod/data/nz/".."nz_"..game.GetMap( ).."_"..os.date("%H_%M_%j")..".txt" )
	
end

function nz.Mapping.Functions.ClearConfig()
	print("[NZ] Clearing current map")
	
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		v:Remove()
	end

	for k,v in pairs(ents.FindByClass("wall_buys")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("prop_buys")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("button_elec")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("wall_block")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("random_box_spawns")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:Remove()
	end
	
	//Normal Map doors
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		nz.Doors.Functions.RemoveMapDoorLink( k )
	end
	
	//Sync
	nz.Rounds.Functions.SendSync()
	nz.Doors.Functions.SendSync()
end

function nz.Mapping.Functions.LoadConfig( name )

	local filepath = "nz/"..name
	
	if file.Exists( filepath, "DATA" ) then
		print("[NZ] MAP CONFIG FOUND!")
		
		
		
		local data = util.JSONToTable( file.Read( filepath, "DATA" ) )
		
		local version = data.version
		
		//Check the version of the config.
		if version == nil then
			print("This map config is too out of date to be used. Sorry about that!")
			return
		end
		
		if version < nz.Mapping.Data.Version then
			print("Warning: This map config was made with an older version of nZombies. After this has loaded, use the save command to save a newer version.")
		end
		
		if version < 300 then
			print("Warning: Inital Version: No changes have been made.")
		end

		nz.Mapping.Functions.ClearConfig()
		
		print("[NZ] Loading " .. filepath .. "...")
		
		
		//Start sorting the data
		
		for k,v in pairs(data.ZedSpawns) do
			nz.Mapping.Functions.ZedSpawn(v.pos, v.link)
		end
		
		for k,v in pairs(data.PlayerSpawns) do
			nz.Mapping.Functions.PlayerSpawn(v.pos)
		end
		
		for k,v in pairs(data.WallBuys) do
			nz.Mapping.Functions.WallBuy(v.pos,v.wep, v.price, v.angle)
		end
		
		for k,v in pairs(data.BuyablePropSpawns) do
			nz.Mapping.Functions.PropBuy(v.pos, v.angle, v.model, v.flags)
		end
		
		for k,v in pairs(data.ElecSpawns) do
			nz.Mapping.Functions.Electric(v.pos, v.angle, v.model)
		end
		
		for k,v in pairs(data.BlockSpawns) do
			nz.Mapping.Functions.BlockSpawn(v.pos, v.angle, v.model)
		end
			
		for k,v in pairs(data.RandomBoxSpawns) do
			nz.Mapping.Functions.BoxSpawn(v.pos, v.angle)
		end
		
		for k,v in pairs(data.PerkMachineSpawns) do
			nz.Mapping.Functions.PerkMachine(v.pos, v.angle, v.id)
		end
		
		//Normal Map doors
		for k,v in pairs(data.DoorSetup) do
			nz.Doors.Functions.CreateMapDoorLink(k, v.flags)
		end
		
		print("[NZ] Finished loading map config.")
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