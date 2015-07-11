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
	
	//make a table of valid spawns
	for k,v in pairs(ents.FindByClass("zed_spawns")) do
		local link = v.link
		if link != nil then
			if nz.Doors.Data.OpenedLinks[tonumber(v.link)] then //Zombie Links
				for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 1000)) do
					if v2:IsPlayer() then
						table.insert(valids, v:GetPos())
						break
					end
				end
			end
		else
			for k2,v2 in pairs(ents.FindInSphere(v:GetPos(), 1000)) do
				if v2:IsPlayer() then
					table.insert(valids, v:GetPos())
					break
				end
			end
		end
	end	
	
	return valids
end

function nz.Enemies.Functions.SpawnZombie(pos)
	if nz.Rounds.Data.ZombiesSpawned < 100 then
		local ent = "nut_zombie"
		
		//Get the latest round number from the table
		for i = nz.Rounds.Data.CurrentRound, 0, -1 do 
			if nz.Config.EnemyTypes[i] != nil then
				ent = nz.Misc.Functions.WeightedRandom(nz.Config.EnemyTypes[i])
				break
			end
		end
	
		local zombie = ents.Create(ent)
		zombie:SetPos(pos)
		zombie:Spawn()
		zombie:Activate()
		nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned + 1
		print("Spawning Enemy: " .. nz.Rounds.Data.ZombiesSpawned .. "/" .. nz.Rounds.Data.CurrentZombies )
	else
		print("Limit of Zombies Reached!")
	end
end


function nz.Enemies.Functions.ZombieSpawner()	
	//Not enough Zombies
	if nz.Rounds.Data.ZombiesSpawned < nz.Rounds.Data.CurrentZombies then
		if nz.Rounds.Data.CurrentState == ROUND_PROG then
		
			local valids = nz.Enemies.Functions.ValidSpawns()
				
			if valids[1] == nil then
				print("No valid spawns were found!")
				return
				--Since we couldn't find a valid spawn, just back out for now.
			end
			
			local pos = table.Random(valids)
			
			if nz.Enemies.Functions.CheckIfSuitable(pos) then
				nz.Enemies.Functions.SpawnZombie(pos)
			end
		end
	end
end

timer.Create("nz.Rounds.ZombieSpawner", 1, 0, nz.Enemies.Functions.ZombieSpawner)