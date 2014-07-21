function OnEnemyKilled(enemy, attacker)
	if attacker:IsPlayer() then
		attacker:GivePoints(90)
		attacker:AddFrags(1)
	end
	nz.Rounds.CurrentZombies = nz.Rounds.CurrentZombies - 1
	nz.Rounds.ZombiesSpawned = nz.Rounds.ZombiesSpawned - 1

	local powerData = false
	for id,data in pairs(nz.PowerUps.GetBufferAll()) do
		if (math.Rand(0, 100) <= data.chance) then
			powerData = data
			break
		end
	end
	if (powerData) then
		local pos = enemy:GetPos()+Vector(0,0,50)
		local ent1 = ents.Create("drop_powerups")
		ent1.Buff = powerData.id
		pos.z = pos.z - ent1:OBBMaxs().z
		ent1:SetModel(powerData.model)
		ent1:SetPos(pos)
		ent1:Spawn()
	end
end

function OnEnemyHurt(enemy, attacker)
	if attacker:IsPlayer() then
		attacker:GivePoints(10)
	end
end

hook.Add("ScaleNPCDamage","nz_npc_hurt", function( npc, hitgroup, dmginfo )
	OnEnemyHurt( npc, dmginfo:GetAttacker(), hitgroup)
	print(npc:Health() - dmginfo:GetDamage())
	if (npc:Health() - dmginfo:GetDamage()) <= 0 then
		OnEnemyKilled( npc, dmginfo:GetAttacker())
	end
end)

hook.Add("OnNPCKilled","nz_npc_kill", function( npc, attacker, inflictor )
	OnEnemyKilled( npc, attacker)
end)