//Main Tables
nz.Rounds.Functions = {}

//Round Variables
nz.Rounds.CurrentState = ROUND_INIT
nz.Rounds.CurrentRound = 0
nz.Rounds.CurrentZombies = 0
nz.Rounds.ZombiesSpawned = 0

//Difficulty Curves
nz.Rounds.Curve = {}
nz.Rounds.Curve.SpawnRate = {}
nz.Rounds.Curve.Health = {}
nz.Rounds.Curve.Speed = {}

//Misc
nz.Rounds.Elec = false
nz.Rounds.PlayerSpawns = {}
nz.Rounds.Effects = {}
nz.Rounds.EggCount = 0


//Generate Curve
function nz.Rounds.Functions.GenerateCurve()
	for i=1, 100 do
		nz.Rounds.Curve.SpawnRate[i-1] = math.Round(nz.Config.BaseDifficultySpawnRateCurve*math.pow(i-1,nz.Config.DifficultySpawnRateCurve))
		nz.Rounds.Curve.Health[i-1] = math.Round(nz.Config.BaseDifficultyHealthCurve*math.pow(i-1,nz.Config.DifficultyHealthCurve))
		nz.Rounds.Curve.Speed[i-1] = math.Round(nz.Config.BaseDifficultySpeedCurve*math.pow(i-1,nz.Config.DifficultySpeedCurve))
	end
end

function nz.Rounds.Functions.CheckPrerequisites()	
	
	if #player.GetAll() >= 1 then
		local count = 0
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 and v:IsValid() and v:Alive() then
				count = count + 1
			end
		end
		if count / #player.GetAll() < nz.Config.ReadyupPerc then
			return false
		end
	else
		return false
	end
	//Check Player spawns
	if #ents.FindByClass("player_spawns") == 0 then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the map does have any player spawns placed." )
			end
		end
		return false
	end
	//Check Zombie Spawns
	if #ents.FindByClass("zed_spawns") == 0 then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the map does have any zombie spawns placed." )
			end
		end
		return false
	end
	//Check guns
	for k2,v2 in pairs(nz.Config.BaseStartingWeapons) do
		if !weapons.Get(v2) then
			for k,v in pairs(player.GetAll()) do
				if v.Ready == 1 then
					v.Ready = 0
					v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the starting weapons have not been set or invalid." )
				end
			end
			return false
		end
	end
	
	return true
end

//Client Side Syncing
util.AddNetworkString( "nz_Round_Sync" )
util.AddNetworkString( "nz_Elec_Sync" )

hook.Add( "nz_elec_active", "activate_all_elec", function()
	PrintMessage( HUD_PRINTTALK, "[NZ] Electricity is now on!" )
	nz.Rounds.Elec = true
	nz.Rounds.Functions.SyncClients()
	//Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() then
			if v.price == 0 and v.elec == 1 then 
				v:DoorUnlock()
			end
		end
	end
end )

function nz.Rounds.Functions.SyncClients()
	net.Start( "nz_Round_Sync" )
		net.WriteString( nz.Rounds.CurrentState )
		net.WriteString( nz.Rounds.CurrentRound )
	net.Broadcast()
	
	if nz.Rounds.Elec then
		net.Start( "nz_Elec_Sync" )
		net.Broadcast()
	end
end


function nz.Rounds.Functions.PrepareRound()
	nz.Rounds.CurrentState = ROUND_PREP
	nz.Rounds.Functions.SyncClients()
	nz.Rounds.CurrentRound = nz.Rounds.CurrentRound + 1
	nz.Rounds.CurrentZombies = nz.Rounds.Curve.SpawnRate[nz.Rounds.CurrentRound]
	
	timer.Simple(nz.Config.PrepareTime / 2, function() 
		//Remove All bodies
		for k, v in pairs(ents.FindByClass("prop_ragdoll")) do
			v:Remove()
		end
	end)
	
	PrintMessage( HUD_PRINTTALK, "ROUND: "..nz.Rounds.CurrentRound.." preparing" )
	//Spawn all dead players
	if (!nz.Config.Hardcore) then
		for k,v in pairs(player.GetAll()) do
			if (nz.Config.AllowDropins) then
				if (v:Team()!=TEAM_PLAYERS) then
					player_manager.SetPlayerClass( v, "player_ingame" )	
				end
			end
			if !(v:Alive()) then
				v:Spawn()
			end
		end
	end
	
	timer.Simple(nz.Config.PrepareTime, function() nz.Rounds.Functions.StartRound() end)
	
	local function checkVer()
		http.Fetch( "https://raw.githubusercontent.com/Alig96/nzombies/master/version.txt",
			function( body, len, headers, code )
				if tonumber(file.Read( "gamemodes/nzombies/version.txt", "GAME" )) < tonumber(body) then
					print("Your version of nZombies is outdated. Please update via Github.")
				end
			end,
			function( error )
				print("Version Check Failed!")
			end
		)
	end
	checkVer()

end

function nz.Rounds.Functions.StartRound()
	if nz.Rounds.CurrentState != ROUND_GO then
		nz.Rounds.CurrentState = ROUND_PROG
		nz.Rounds.Functions.SyncClients()
		nz.Rounds.ZombiesSpawned = 0
		PrintMessage( HUD_PRINTTALK, "ROUND: "..nz.Rounds.CurrentRound.." started" )
		//Add a hook or something
	end
end

function nz.Rounds.Functions.ResetGame()
	PrintMessage( HUD_PRINTTALK, "GAME READY!" )
	nz.Rounds.CurrentState = ROUND_INIT
	nz.Rounds.Functions.SyncClients()
	nz.Rounds.CurrentRound = 0
	nz.Rounds.CurrentZombies = 0
	nz.Rounds.ZombiesSpawned = 0
	nz.Rounds.Elec = false 
	
	//Empty All the tables
	table.Empty(nz.Rounds.PlayerSpawns)
	//Reset all opened doors
	table.Empty(nz.Doors.Data.OpenedLinks)
	//Unlock all doors
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() then
			v:SetUseType( SIMPLE_USE )
			v:DoorUnlock()
			v:SetKeyValue("wait",-1)
		end
	end
	//Relock the buyable-blockers all doors
	for k,v in pairs(ents.FindByClass("wall_block_buy")) do
		v:DoorLock()
	end
	
	//Replace with init player class
	for k,v in pairs(player.GetAll()) do
		player_manager.SetPlayerClass( v, "player_init" )
		v.Ready = 0
		v:SetPoints(0)
		v:Spawn()
		v:SendLua('RunConsoleCommand("stopsound")')
	end
	for k,v in pairs(nz.Config.ValidEnemies) do
		for k2,v2 in pairs(ents.FindByClass(v)) do
			v2:Remove()
		end
	end
	//Reset easter eggs
	for k,v in pairs(ents.FindByClass("easter_egg")) do
		v.Used = false
	end
	nz.Rounds.EggCount = 0 
end

function nz.Rounds.Functions.EndRound()
	if nz.Rounds.CurrentState != ROUND_GO then
		nz.Rounds.CurrentState = ROUND_GO
		nz.Rounds.Functions.SyncClients()
		nz.Rounds.ZombiesSpawned = 0
		
		PrintMessage( HUD_PRINTTALK, "GAME OVER!" )
		PrintMessage( HUD_PRINTTALK, "Restarting in 10 seconds!" )
		timer.Simple(10, function()
			nz.Rounds.Functions.ResetGame()
		end)
	else
		//This if statement is to prevent the game from ending twice if all players die during preparing 
	end
end

function nz.Rounds.Functions.CreateMode()
	if nz.Rounds.CurrentState == ROUND_INIT then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to creative mode!" )
		nz.Rounds.CurrentState = ROUND_CREATE
		nz.Rounds.CurrentZombies = 0
		nz.Rounds.Functions.SyncClients()
	elseif nz.Rounds.CurrentState == ROUND_CREATE then
		PrintMessage( HUD_PRINTTALK, "The mode has been set to play mode!" )
		nz.Rounds.CurrentState = ROUND_INIT
		nz.Rounds.CurrentZombies = 0
		for k,v in pairs(player.GetAll()) do
			v:StripCreateWeps()
		end
		nz.Rounds.Functions.SyncClients()
	else
		return
	end
end

function nz.Rounds.Functions.SetupGame()

	//Create a list of all valid player spawns
	for k,v in pairs(ents.FindByClass("player_spawns")) do
		table.insert(nz.Rounds.PlayerSpawns, v:GetPos())
	end
	//Set everyone's player class
	for k,v in pairs(player.GetAll()) do
		player_manager.SetPlayerClass( v, "player_ingame" )
		v:Spawn()
	end
	
	//Spawn a random box
	if #ents.FindByClass("random_box") == 0 and #ents.FindByClass("random_box_spawns") > 0 then
		local rand = table.Random(ents.FindByClass("random_box_spawns"))
		RandomBoxSpawn(rand:GetPos(), rand:GetAngles())
	end
	

	
	//Force all doors to lock and stay open when opened
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() then
			v:SetUseType( SIMPLE_USE )
			v:DoorLock()
			v:SetKeyValue("wait",-1)
		end
	end	
	
	//Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() then
			if v.price == 0 and v.elec == 0 then 
				
				v:DoorUnlock()
			end
		end
	end
	
	//All doors with Link 0 (No Link)
	nz.Doors.Data.OpenedLinks[0] = true
	
	timer.Simple(5, function() PrintMessage( HUD_PRINTTALK, "You are playing nZombies V2.0 BETA Revision "..file.Read( "gamemodes/nzombies/version.txt", "GAME" )) end)
end

function nz.Rounds.Functions.RoundHandler()
	if nz.Rounds.CurrentState == ROUND_INIT then
		for k,v in pairs(player.GetAll()) do
			if !(v:Alive()) then
				v:Spawn()
			end
		end
		if nz.Rounds.Functions.CheckPrerequisites() then
			nz.Rounds.Functions.SetupGame()
			nz.Rounds.Functions.PrepareRound()
		else
			return
		end
		
	elseif nz.Rounds.CurrentState == ROUND_CREATE then
		for k,v in pairs(player.GetAll()) do
			if v.Ready == 1 then
				v.Ready = 0
				v:PrintMessage( HUD_PRINTTALK, "You have been set to un-ready since the game has been set to creative mode" )
				//v:GiveCreateWeps()
			end
			if v:IsSuperAdmin() then
				v:GiveCreateWeps()
			end
		end
		return
	end
	
	local function checkAlive()
		//Check alive players!
		for k,v in pairs(player.GetAll()) do
			if v:Alive() then
				return true
			end
		end
		return false
	end
	
	if !checkAlive() and (nz.Rounds.CurrentState == ROUND_PROG or nz.Rounds.CurrentState == ROUND_PREP) then
		nz.Rounds.Functions.EndRound()
	end
	
	//Check the NPCs on the map.
	if nz.Rounds.CurrentZombies <= 0 and nz.Rounds.CurrentState == ROUND_PROG then
		nz.Rounds.Functions.PrepareRound()
	end
end

function nz.Rounds.Functions.ZombieSpawner()
	if nz.Rounds.ZombiesSpawned >= nz.Rounds.CurrentZombies or nz.Rounds.ZombiesSpawned >= 100 then
		//Do nothing
	else
		if nz.Rounds.CurrentState == ROUND_PROG then
		
			local function CheckIfSuitable(pos)
				local Ents = ents.FindInBox( pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 64 ) )
				local Blockers = 0
				if Ents == nil then return true end
				for k, v in pairs( Ents ) do
					if ( IsValid( v ) and (v:GetClass() == "player" or table.HasValue(nz.Config.ValidEnemies, v:GetClass())) ) then
						Blockers = Blockers + 1
					end
				end
				if Blockers == 0 then
					return true
				end
				return false
			end
			
			local valids = {}
			//make a table of valid spawns
			for k,v in pairs(ents.FindByClass("zed_spawns")) do
				if nz.Doors.Data.OpenedLinks[tonumber(v.Link)] then
					for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 1000)) do
						if v2:IsPlayer() then
							table.insert(valids, v:GetPos())
							break
						end
					end
				end
			end		
			if valids[1] == nil then
				return
				--Since we couldn't find a valid spawn, just back out for now.
			end
			local position = table.Random(valids)
			if CheckIfSuitable(position) then
				local typ = "nut_zombie"
				
				//Custom enemies
				if nz.Config.UseCustomEnemies then
					for i = nz.Rounds.CurrentRound, 0, -1 do 
						if nz.Config.EnemyTypes[i] != nil then
							//http://snippets.luacode.org/snippets/Weighted_random_choice_104
							local function weighted_total(choices)
								local total = 0
								for choice, weight in pairs(choices) do
									total = total + weight
								end
								return total
							end
							local function weighted_random_choice( choices )
								local threshold = math.random(0, weighted_total(choices))
								local last_choice
								for choice, weight in pairs(choices) do
									threshold = threshold - weight
								if threshold <= 0 then return choice end
									last_choice = choice
								end
								return last_choice
							end

							typ = weighted_random_choice(nz.Config.EnemyTypes[i])
							break
						end
					end
				end
				
				local zombie = ents.Create(typ)
				zombie:SetPos(position)
				zombie:Spawn()
				zombie:Activate()
				nz.Rounds.ZombiesSpawned = nz.Rounds.ZombiesSpawned + 1
			end
		end
	end
end


timer.Simple(0, function()
	nz.Rounds.Functions.GenerateCurve()
	timer.Create("nz.Rounds.ZombieSpawner", 1, 0, nz.Rounds.Functions.ZombieSpawner)
	timer.Create("nz.Rounds.handler", 1, 0, nz.Rounds.Functions.RoundHandler)
end)
