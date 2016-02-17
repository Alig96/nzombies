//

function nz.PowerUps.Functions.Nuke()
	//Kill them all
	for k,v in pairs(nz.Config.ValidEnemies) do
		for k2,enemy in pairs(ents.FindByClass(v)) do
			if enemy:IsValid() then
				local insta = DamageInfo()
				insta:SetDamage(enemy:Health())
				insta:SetAttacker(Entity(0))
				insta:SetDamageType(DMG_BLAST_SURFACE)
				//Delay so it doesn't "die" twice
				timer.Simple(0.1, function() if enemy:IsValid() then enemy:TakeDamageInfo( insta ) end end)
			end
		end	
	end
	
	//Give the players a set amount of points
	for k,v in pairs(player.GetAll()) do
		if v:IsPlayer() then
			v:GivePoints(500)
		end
	end
end

function nz.PowerUps.Functions.CleanUp()
	//Clear all powerups
	for k,v in pairs(ents.FindByClass("drop_powerup")) do
		v:Remove()
	end
	
	//Turn off all modifiers
	table.Empty(nz.PowerUps.Data.ActivePowerUps)
	//Sync
	nz.PowerUps.Functions.SendSync()
end