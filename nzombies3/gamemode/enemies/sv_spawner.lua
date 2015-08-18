//

function nz.Enemies.Functions.CheckIfSuitable(pos)

	local Ents = ents.FindInBox( pos + Vector( -16, -16, 0 ), pos + Vector( 16, 16, 64 ) )
	local Blockers = 0
	if Ents == nil then return true end
	for k, v in pairs( Ents ) do
		if ( IsValid( v ) and (v:GetClass() == "player" or table.HasValue(nz.Config.ValidEnemies, v:GetClass()) ) ) then 
			Blockers = Blockers + 1
		end
	end
	
	if Blockers == 0 then
		return true
	end
	
	return false
	
end

function nz.Enemies.Functions.ValidSpawns()

	local valids = {}
	local spawns = {}
	
	//Make a table of spawns
	for k,v in pairs(team.GetPlayers(TEAM_PLAYERS)) do
		//Get all spawns in the range
		for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 1200)) do
			if v2:GetClass() == "zed_spawns" then
				table.insert(spawns, v2)
			end
		end
		//Remove all spawns that are too close
		for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 200)) do
			if table.HasValue(spawns, v2) then
				table.RemoveByValue(spawns, v2)
			end
		end
	end
	
	//Removed unopened linked doors
	for k,v in pairs(spawns) do
		if v.link != nil then
			if nz.Doors.Data.OpenedLinks[tonumber(v.link)] == nil then //Zombie Links
				spawns[k] = nil
			end
		end
	end
	
	//Get positions
	for k,v in pairs(spawns) do
		table.insert(valids, v)
	end
	//Edited to get spawn point entites instead - for CurrentRoom setting - Nav
	
	return valids
end

function nz.Enemies.Functions.TotalCurrentEnemies()
	local c = 0
	
	//Count
	for k,v in pairs(nz.Config.ValidEnemies) do
		for k2,v2 in pairs(ents.FindByClass(v)) do
			c = c + 1
		end	
	end
	
	return c
end

function nz.Enemies.Functions.SpawnZombie(spawnpoint)
	if nz.Enemies.Functions.TotalCurrentEnemies() < 100 then
		local ent = "nut_zombie"
		
		//Get the latest round number from the table
		for i = nz.Rounds.Data.CurrentRound, 0, -1 do 
			if nz.Config.EnemyTypes[i] != nil then
				ent = nz.Misc.Functions.WeightedRandom(nz.Config.EnemyTypes[i])
				break
			end
		end
	
		local zombie = ents.Create(ent)
		zombie:SetPos(spawnpoint:GetPos())
		zombie:Spawn()
		zombie:Activate()
		//Set a zombies current room to the one he spawns in
		if IsValid(spawnpoint.OwnerRoom) then
			zombie.CurrentRoom = spawnpoint.OwnerRoom
		end
		zombie:SpawnNavigate()
		nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned + 1
		print("Spawning Enemy: " .. nz.Rounds.Data.ZombiesSpawned .. "/" .. nz.Rounds.Data.MaxZombies )
	else
		print("Limit of Zombies Reached!")
	end
end


function nz.Enemies.Functions.ZombieSpawner()	
	//Not enough Zombies
	if nz.Rounds.Data.ZombiesSpawned < nz.Rounds.Data.MaxZombies then
		if nz.Rounds.Data.CurrentState == ROUND_PROG then
		
			local valids = nz.Enemies.Functions.ValidSpawns()
				
			if valids[1] == nil then
				print("No valid spawns were found!")
				return
				--Since we couldn't find a valid spawn, just back out for now.
			end
			
			local spawnpoint = table.Random(valids)
			
			if nz.Enemies.Functions.CheckIfSuitable(spawnpoint:GetPos()) then
				nz.Enemies.Functions.SpawnZombie(spawnpoint)
			end
		end
	end
end

timer.Create("nz.Rounds.ZombieSpawner", 1, 0, nz.Enemies.Functions.ZombieSpawner)