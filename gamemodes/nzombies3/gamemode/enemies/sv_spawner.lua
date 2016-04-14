if Spawner == nil then
	_G.Spawner = class({
		constructor = function(self, spointClass, data, zombiesToSpawn)
			self.sSpointClass = spointClass or "nz_spawn_zombie_normal"
			self.tData = data or {["nz_zombie_walker"] = {chance = 100}}
			self.iZombiesToSpawn = zombiesToSpawn or 5
			self.tSpawns = ents.FindByClass(self.sSpointClass)
			self.tValidSpawns = {}
			self:SetZombieData(self.tData)

			timer.Create("nzZombieSpawnThink" .. self, 1, 0, function() self:Update() end)
		end
	})
end

function Spawner:DecrementZombiesToSpawn()
	self.iZombiesToSpawn = self.iZombiesToSpawn - 1
end

function Spawner:IncrementZombiesToSpawn()
	self.iZombiesToSpawn = self.iZombiesToSpawn + 1
end

function Spawner:GetZombiesToSpawn()
	return self.iZombiesToSpawn
end

function Spawner:GetSpawns()
	return self.tSpawns
end

function Spawner:Update()
	-- garbage collect the spawner object if a round is over
	if Round:InState(ROUND_PREP) and timer.Exists("nzZombieSpawnThink" .. self) then
		timer.Remove("nzZombieSpawnThink" .. self)
		self = nil
	end

	self:UpdateWeights()
	self:UpdateValidSpawns()
end

function Spawner:UpdateWeights()
	local plys = player.GetAllTargetable()
	for _, spawn in pairs(self.tSpawns) do
		for _, ply in pairs(plys) do
			local dist = spawn:GetPos():Distance(ply:GetPos())
			spawn:SetSpawnWeight(spawn:GetSpawnWeight() + dist)
		end
		spawn:SetSpawnWeight(spawn:GetSpawnWeight() / #plys)
	end
end

function Spawner:UpdateValidSpawns()

	-- reset
	self.tValidSpawns = {}

	local average = self:GetAverageWeight()
	for _, spawn in pairs(self.tSpawns) do
		-- reset the zombiesToSpawn value on every Spawnpoint
		spawn:SetZombiesToSpawn(0)
		if spawn:GetSpawnWeight() <= average then
			if spawn.link == nil or Doors.OpenedLinks[tonumber(spawn.link)] then
				table.insert(self.tValidSpawns, spawn)
			end
		end
	end
	table.sort(self.tValidSpawns, function(a, b) return a:GetSpawnWeight() < b:GetSpawnWeight() end )

	-- distri bute zombies to spawn on to the valid spawnpoints
	local zombiesToSpawn = self.iZombiesToSpawn / 2
	local totalDistributed = 0
	for k, vspawn in pairs(self.tValidSpawns) do
		if k < #self.tValidSpawns then
			vspawn:SetZombiesToSpawn(math.ceil(zombiesToSpawn))
			totalDistributed = totalDistributed + math.ceil(zombiesToSpawn)

			if zombiesToSpawn / 2 < 1 then -- failsafe not sure if its even needed but whatever
				zombiesToSpawn = 1
			else
				zombiesToSpawn = math.floor(zombiesToSpawn / 2)
			end
		else
			-- add the remaining zombies to the last spawn in list
			vspawn:SetZombiesToSpawn(self.iZombiesToSpawn - totalDistributed)
		end
	end
end

function Spawner:GetAverageWeight()
	local sum = 0
	for _, spawn in pairs(self.tSpawns) do
		sum = sum + spawn:GetSpawnWeight()
	end
	return sum / #self.tSpawns
end

function Spawner:GetValidSpawns()
	return self.tValidSpawns
end

function Spawner:SetZombieData(data)
	for _, spawn in pairs(self.tSpawns) do
		spawn:SetZombieData(data)
	end
end

function Spawner:TotalCurrentEnemies()
	local c = 0

	-- Count
	for k,v in pairs(nz.Config.ValidEnemies) do
		c = c + #ents.FindByClass(k)
	end

	return c
end
