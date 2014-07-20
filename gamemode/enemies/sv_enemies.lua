function OnEnemyKilled( enemy, attacker )

	if attacker:IsPlayer() then
		attacker:GivePoints(90)
	end
	nz.Rounds.CurrentZombies = nz.Rounds.CurrentZombies - 1
	nz.Rounds.ZombiesSpawned = nz.Rounds.ZombiesSpawned - 1

	local function createPowerup(pos)
		local ent1 = ents.Create("drop_powerups") 
		local powerups = {}
		for k,_ in pairs(nz.PowerUps.GetBufferAll()) do
			table.insert(powerups, k)
		end
		local rand = table.Random(powerups) or "dp"
		ent1.Buff = rand
		ent1:SetModel( nz.PowerUps.GetBuffer(rand).model )
		pos.z = pos.z - ent1:OBBMaxs().z
		ent1:SetPos( pos )
		ent1:Spawn()
	end
	if math.random(1,25) == 1 then createPowerup(enemy:GetPos()+Vector(0,0,50)) end

end


function OnEnemyHurt( enemy, attacker, hitgroup )
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
