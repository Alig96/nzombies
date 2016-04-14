local Spawner = {}

function Spawner:UpdateSpawnPoints()
	self.tNormalSpawns = ents.FindByClass("nz_spawn_zombie_normal")
	self.tSpecialSpawns = ents.FindByClass("nz_spawn_zombie_special")
end

function Spawner:InitializeRound(zombieCap)
	self.ZombiesToSpawn = zombieCap
end

function Spawner:GetNormalSpawns()
	return self.tNormalSpawns
end

function Spawner:GetSpecialSpawns()
	return self.tSpecialSpawns
end

function Spawner:UpdateWeights()
	local plys = player.GetAllTargetable()
	for _, spawn in pairs(self.tNormalSpawns) do
		for _, ply in pairs(plys) do
			local dist = spawn:GetPos():Distance(ply:GetPos())
			spawn:SetSpawnWeight( spawn:GetSpawnWeight() + dist )
		end
		spawn:SetSpawnWeight(spawn:GetSpawnWeight() / #plys)
	end
end

function Spawner:GetAverageWeight()
	local sum = 0
	for _, spawn in pairs(self.tNormalSpawns) do
		sum = sum + spawn:GetSpawnWeight()
	end
	return sum / #self.tNormalSpawns
end

function Spawner:GetValidSpawns()
	local result = {}
	for _, spawn in pairs(self.tNormalSpawns) do

	end
end

function Spawner:SetNormalZombieClass(class)
	for _, spawn in pairs(self.tNormalSpawns) do
		spawn:SetZombieClass(class)
	end
end
