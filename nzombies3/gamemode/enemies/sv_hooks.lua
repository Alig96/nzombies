//


function nz.Enemies.Functions.OnEnemyKilled(enemy, attacker)

	if attacker:IsPlayer() then
		--attacker:GivePoints(90)
		attacker:AddFrags(1)
	end

	nz.Rounds.Data.KilledZombies = nz.Rounds.Data.KilledZombies + 1
	//nz.Rounds.Data.ZombiesSpawned = nz.Rounds.Data.ZombiesSpawned - 1

	//Chance a powerup spawning
	if nz.PowerUps.Functions.IsPowerupActive("insta") == false and enemy:IsValid() then //Don't spawn powerups during instakill
		nz.PowerUps.Functions.SpawnPowerUp(enemy:GetPos())
	end

	print("Killed Enemy: " .. nz.Rounds.Data.KilledZombies .. "/" .. nz.Rounds.Data.MaxZombies )
end

function GM:EntityTakeDamage(zombie, dmginfo)
	if IsValid(zombie) and nz.Config.ValidEnemies[zombie:GetClass()] and nz.Config.ValidEnemies[zombie:GetClass()].Valid then
		local hitgroup = util.QuickTrace( dmginfo:GetDamagePosition( ), dmginfo:GetDamagePosition( ) ).HitGroup
		
		if nz.PowerUps.Functions.IsPowerupActive("insta") then
			dmginfo:SetDamage(zombie:Health())
			nz.Config.ValidEnemies[zombie:GetClass()].OnKilled(zombie, dmginfo:GetAttacker(), hitgroup)
			nz.Enemies.Functions.OnEnemyKilled(zombie, dmginfo:GetAttacker())
		return end
		
		--print(dmginfo:GetDamage(), 1)
		nz.Config.ValidEnemies[zombie:GetClass()].ScaleDMG(zombie, hitgroup, dmginfo)
		--print(dmginfo:GetDamage(), 2)
		if zombie:Health() > dmginfo:GetDamage() then
			if zombie.HasTakenDamageThisTick then return end
			nz.Config.ValidEnemies[zombie:GetClass()].OnHit(zombie, dmginfo:GetAttacker(), hitgroup)
			zombie.HasTakenDamageThisTick = true
			//Prevent multiple damages in one tick (FA:S 2 Bullet penetration makes them hit 1 zombie 2-3 times per bullet)
			timer.Simple(0, function() if IsValid(zombie) then zombie.HasTakenDamageThisTick = false end end)
		else
			nz.Config.ValidEnemies[zombie:GetClass()].OnKilled(zombie, dmginfo:GetAttacker(), hitgroup)
			nz.Enemies.Functions.OnEnemyKilled(zombie, dmginfo:GetAttacker())
		end
	end
end

function nz.Enemies.Functions.OnEntityCreated( ent )
	if ( ent:GetClass() == "prop_ragdoll" ) then
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end
end
hook.Add("OnEntityCreated", "nz.Enemies.OnEntityCreated", nz.Enemies.Functions.OnEntityCreated)
