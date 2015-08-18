//

nz.Mapping.Data.Version = 381 //Note to Ali; Any time you make an update to the way this is saved, increment this.

function nz.Mapping.Functions.SaveConfig()

	local main = {}
	
	//Check if the nz folder exists
	if !file.Exists( "nz/", "DATA" ) then
		file.CreateDir( "nz" )
	end
	
	main.version = nz.Mapping.Data.Version
	
	local easter_eggs = {}
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		table.insert(easter_eggs, {
		pos = v:GetPos(),
		angle = v:GetAngles(),
		model = v:GetModel(),
		})
	end
	
	local player_handler = {}
	for k,v in pairs(ents.FindByClass("player_handler")) do
		table.insert(player_handler, {
		pos = v:GetPos(),
		startwep = v:GetStartWep(),
		startpoints = v:GetStartPoints(),
		numweps = v:GetNumWeps(),
		eeurl = v:GetEEURL(),
		angle = v:GetAngles( ),
		})
	end
	
	local random_box_handler = {}
	for k,v in pairs(ents.FindByClass("random_box_handler")) do
		table.insert(random_box_handler, {
		pos = v:GetPos(),
		guns = v:GetWeaponsList(),
		angle = v:GetAngles( ),
		})
	end
	
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
	
	//barricades
	local break_entry = {}
	for k,v in pairs(ents.FindByClass("breakable_entry")) do
		table.insert(break_entry, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
		})
	end
	
	//Navigation (Room Controllers first)
	local nav_rooms = {}
	for k,v in pairs(ents.FindByClass("nav_room_controller")) do
		v.SaveIndex = table.insert(nav_rooms, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
		})
		print(v, v.SaveIndex)
	end
	
	//Navigation (Nav Gates)
	local nav_gates = {}
	for k,v in pairs(ents.FindByClass("nav_gate")) do
		v.SaveIndex = table.insert(nav_gates, {
			pos = v:GetPos(),
			angle = v:GetAngles(),
			model = v.CurModelNum,
			doorlink = nz.Nav.Data[v.OwnerRoom][v].doorlink,
			open = nz.Nav.Data[v.OwnerRoom][v].open,
			targetroom = nz.Nav.Data[v.OwnerRoom][v].targetroom.SaveIndex,
			ownerroom = v.OwnerRoom.SaveIndex
		})
		print(v, v.SaveIndex)
	end
	//Do a second loop through gates where they have all got their SaveIndex
	for k,v in pairs(ents.FindByClass("nav_gate")) do
		nav_gates[v.SaveIndex].navlink = nz.Nav.Data[v.OwnerRoom][v].navlink.SaveIndex
	end
	
	PrintTable(nav_gates)
	PrintTable(nav_rooms)
	
	main["ZedSpawns"] = zed_spawns
	main["PlayerSpawns"] = player_spawns
	main["WallBuys"] = wall_buys
	main["BuyablePropSpawns"] = buyableprop_spawns
	main["ElecSpawns"] = elec_spawn
	main["BlockSpawns"] = block_spawns
	main["RandomBoxSpawns"] = randombox_spawn
	main["PerkMachineSpawns"] = perk_machinespawns
	main["DoorSetup"] = door_setup
	main["BreakEntry"] = break_entry
	main["RBoxHandler"] = random_box_handler
	main["PlayerHandler"] = player_handler
	main["EasterEggs"] = easter_eggs
	main["NavRooms"] = nav_rooms
	main["NavGates"] = nav_gates
	
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
	
	for k,v in pairs(ents.FindByClass("player_handler")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("random_box_handler")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v:Remove()
	end
	
	//Normal Map doors
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		nz.Doors.Functions.RemoveMapDoorLink( k )
	end
	
	for k,v in pairs(ents.FindByClass("breakable_entry")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("nav_gate")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("nav_room_controller")) do
		v:Remove()
	end
	
	//Reset Navigation table
	nz.Nav.Data = {}
	
	//Sync
	nz.Rounds.Functions.SendSync()
	nz.Doors.Functions.SendSync()
end

function nz.Mapping.Functions.LoadConfig( name )

	local filepath = "nz/"..name
	
	if file.Exists( filepath, "DATA" )then
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
		
		if version < 350 then
			print("Warning: This map config does not contain any set barricades.")
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
		
		for k,v in pairs(data.RBoxHandler) do
			nz.Mapping.Functions.RBoxHandler(v.pos, v.guns, v.angle)
		end
		
		for k,v in pairs(data.PlayerHandler) do
			nz.Mapping.Functions.PlayerHandler(v.pos, v.angle, v.startwep, v.startpoints, v.numweps, v.eeurl)
		end
		
		for k,v in pairs(data.EasterEggs) do
			nz.Mapping.Functions.EasterEgg(v.pos, v.angle, v.model)
		end
		
		//Normal Map doors
		for k,v in pairs(data.DoorSetup) do
			nz.Doors.Functions.CreateMapDoorLink(k, v.flags)
		end
		
		if version >= 350 then
			//Barricades
			for k,v in pairs(data.BreakEntry) do
				nz.Mapping.Functions.BreakEntry(v.pos, v.angle)
			end
		end
		
		timer.Simple(0.1, function()
		//Navigation - Room Entites
		if data.NavRooms then
			for k,v in pairs(data.NavRooms) do
				local room = ents.Create("nav_room_controller")
				room:SetPos(v.pos)
				room:Spawn()
				nz.Nav.Data[room] = {}
				room.LoadIndex = k
				print("Created", room, room.LoadIndex)
			end
		end
		
		//Navigation - Nav Gates + Linking
		if data.NavGates then
			for k,v in pairs(data.NavGates) do
				local gate = ents.Create("nav_gate")
				gate:SetPos(v.pos)
				gate:SetAngles(v.angle)
				gate:Spawn()
				gate:CycleModel(model)
				gate.LoadIndex = k
			end
			
			//Take a second cycle where everyone has their LoadIndex
			for k,v in pairs(ents.FindByClass("nav_gate")) do
				//Cycle through room controllers and set up Ownership and tables
				for i, q in pairs(ents.FindByClass("nav_room_controller")) do
					if IsValid(q) and q.LoadIndex == data.NavGates[v.LoadIndex].ownerroom then
						v.OwnerRoom = q
						nz.Nav.Data[q][v] = {}
						nz.Nav.Data[q][v].open = data.NavGates[v.LoadIndex].open
						nz.Nav.Data[q][v].doorlink = data.NavGates[v.LoadIndex].doorlink
					end
				end
				//We need another cycle where every Gate has their Owner Room so we can set Target Room
				for i, q in pairs(ents.FindByClass("nav_room_controller")) do
					if q.LoadIndex == data.NavGates[v.LoadIndex].targetroom then
						nz.Nav.Data[v.OwnerRoom][v].targetroom = q
					end
				end
				//One final cycle for the navlinks
				for i, q in pairs(ents.FindByClass("nav_gate")) do
					if q.LoadIndex == data.NavGates[v.LoadIndex].navlink then
						nz.Nav.Data[v.OwnerRoom][v].navlink = q
					end
				end
			end
		end
		end)
		
		print("[NZ] Finished loading map config.")
	else
		print(filepath)
		print("[NZ] Warning: NO MAP CONFIG FOUND! Make a config in game using the /create command, then use /save to save it all!")
	end
	
end

function nz.Mapping.Functions.CleanUpMap()
	game.CleanUpMap(true, {
		"breakable_entry",
		"breakable_entry_plank",
		"button_elec",
		"perk_machine",
		"player_handler",
		"player_spawns",
		"prop_buys",
		"random_box_spawns",
		"random_box_handler",
		"wall_block",
		"wall_buys",
		"zed_spawns",
		"easter_egg",
		"nav_gate",
		"nav_room_controller"
	})
	//Gotta reset the doors and other entites' values!
	for k,v in pairs(nz.Doors.Data.LinkFlags) do
		local door = nz.Doors.Functions.doorIndexToEnt(k)
		door.elec = tonumber(v.elec)
		door.price = tonumber(v.price)
		door.link = tonumber(v.link)
		door.buyable = tonumber(v.buyable)
		door.Locked = true
		if door:IsDoor() then
			door:DoorLock()
		elseif door:IsButton() then
			door:ButtonLock()
		end
	end
end

hook.Add("Initialize", "nz_Loadmaps", function()
	timer.Simple(5, function()
		nz.Mapping.Functions.LoadConfig("nz_"..game.GetMap()..".txt")
	end)
end)