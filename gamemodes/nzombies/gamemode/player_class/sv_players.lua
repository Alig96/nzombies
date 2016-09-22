//

function nz.Players.Functions.PlayerNoClip( ply, desiredState )
	if ply:Alive() and nzRound:InState( ROUND_CREATE ) then
		return ply:IsInCreative()
	end
end

function nz.Players.Functions.FullSync( ply )
	--Electric
	--nzElec:SendSync()
	--PowerUps
	--nzPowerUps:SendSync()
	--Doors
	--nzDoors.SendSync( ply )
	--Perks
	--nz.Perks.Functions.SendSync()
	--Rounds
	--nzRound:SendSync( ply ) --handled differently since feb 2016
	--Revival System
	--nz.Revive.Functions.SendSync() -- Now sends full sync using the module below
	
	-- Looks like all old modules now have their FullSync functions instead

	-- A full sync module using the new rewrites
	if IsValid(ply) then
		ply:SendFullSync()
	end
end

local function initialSpawn( ply )
	timer.Simple(1, function()
		-- Fully Sync
		nz.Players.Functions.FullSync( ply )
	end)
end

local function playerLeft( ply )
	-- this was previously hooked to PlayerDisconnected
	-- it will now detect leaving players via entity removed, to take kicking banning etc into account.
	if ply:IsPlayer() then
		ply:DropOut()
	end
end

local function friendlyFire( ply, ent )
	if !ply:GetNotDowned() then return false end
	if ent:IsPlayer() then
		if ent == ply then
			-- You can damage yourself as long as you don't have PhD
			return !ply:HasPerk("phd") and !ply.SELFIMMUNE
		else
			--Friendly fire is disabled for all other players TODO make hardcore setting?
			return false
		end
	elseif ent:IsValidZombie() then
		if ply:HasPerk("widowswine") and ply:GetAmmoCount("nz_grenade") > 0 then -- WIDOWS WINE TAKE DAMAGE EFFECT
			local pos = ply:GetPos()
			
			ply.SELFIMMUNE = true
			util.BlastDamage(ply, ply, pos, 350, 50)
			ply.SELFIMMUNE = nil
		
			local zombls = ents.FindInSphere(pos, 350)
				
			local e = EffectData()
			e:SetMagnitude(1.5)
			e:SetScale(20) -- The time the effect lasts
			
			local fx = EffectData()
			fx:SetOrigin(pos)
			fx:SetMagnitude(1)
			util.Effect("web_explosion", fx)
			
			for k,v in pairs(zombls) do
				if IsValid(v) and v:IsValidZombie() then
					ApplyWebFreeze(20)
				end
			end
			
			ply:SetAmmo(ply:GetAmmoCount("nz_grenade") - 1, "nz_grenade")
		end
	end
end

function GM:PlayerNoClip( ply, desiredState )
	return nz.Players.Functions.PlayerNoClip(ply, desiredState)
end

hook.Add( "PlayerInitialSpawn", "nzPlayerInitialSpawn", initialSpawn )
hook.Add( "PlayerShouldTakeDamage", "nzFriendlyFire", friendlyFire )
hook.Add( "EntityRemoved", "nzPlayerLeft", playerLeft )
