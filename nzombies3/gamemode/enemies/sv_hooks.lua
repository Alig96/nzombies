//


function nz.Enemies.Functions.OnEnemyKilled(enemy, attacker)

	if attacker:IsPlayer() then
		attacker:GivePoints(90)
		attacker:AddFrags(1)
	end
	
	nz.Rounds.Data.CurrentZombies = nz.Rounds.Data.CurrentZombies - 1
	nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned - 1
	
end

function nz.Enemies.Functions.OnEnemyHurt(enemy, attacker)
	if attacker:IsPlayer() then
		attacker:GivePoints(10)
	end
end