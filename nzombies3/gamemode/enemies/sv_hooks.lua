//


function nz.Enemies.Functions.OnEnemyKilled(enemy, attacker)

	if attacker:IsPlayer() then
		attacker:GivePoints(90)
		attacker:AddFrags(1)
	end
	
	nz.Rounds.Data.KilledZombies = nz.Rounds.Data.KilledZombies + 1
	//nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned - 1
	
	//Chance a powerup spawning
	if nz.PowerUps.Functions.IsPowerupActive("insta") == false then //Don't spawn powerups during instakill
		nz.PowerUps.Functions.SpawnPowerUp(enemy:GetPos())
	end
	
	print("Killed Enemy: " .. nz.Rounds.Data.KilledZombies .. "/" .. nz.Rounds.Data.MaxZombies )
end

function nz.Enemies.Functions.OnEnemyHurt(enemy, attacker)
	if attacker:IsPlayer() and enemy:IsValid() then
		attacker:GivePoints(10)
		if nz.PowerUps.Functions.IsPowerupActive("insta") then
			local insta = DamageInfo()
			insta:SetDamage(enemy:Health())
			insta:SetAttacker(attacker)
			insta:SetDamageType(DMG_BLAST_SURFACE)
			//Delay so it doesn't "die" twice
			timer.Simple(0.1, function() if enemy:IsValid() and enemy:Health() > 0 then enemy:TakeDamageInfo( insta ) end end)
		end
	end
end