AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Hellhound"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

--ENT.Models = { "models/boz/killmeplease.mdl" }
ENT.Models = { "models/nz_zombie/zombie_hellhound.mdl" }

ENT.AttackRange = 80
ENT.DamageLow = 30
ENT.DamageHigh = 40

ENT.AttackSequences = {
	"nz_attack1",
	"nz_attack2",
	"nz_attack3",
}

ENT.DeathSequences = {
	"nz_death1",
	"nz_death2",
	"nz_death3",
}

ENT.AttackSounds = {
	"nz/hellhound/attack/attack_00.wav",
	"nz/hellhound/attack/attack_01.wav",
	"nz/hellhound/attack/attack_02.wav",
	"nz/hellhound/attack/attack_03.wav",
	"nz/hellhound/attack/attack_04.wav",
	"nz/hellhound/attack/attack_05.wav",
	"nz/hellhound/attack/attack_06.wav"
}

ENT.AttackHitSounds = {
	"nz/hellhound/bite/bite_00.wav",
	"nz/hellhound/bite/bite_01.wav",
	"nz/hellhound/bite/bite_02.wav",
	"nz/hellhound/bite/bite_03.wav",
}

ENT.WalkSounds = {
	"nz/hellhound/dist_vox_a/dist_vox_a_00.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_01.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_02.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_03.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_04.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_05.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_06.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_07.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_08.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_09.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_10.wav",
	"nz/hellhound/dist_vox_a/dist_vox_a_11.wav"
}

ENT.PainSounds = {
	"physics/flesh/flesh_impact_bullet1.wav",
	"physics/flesh/flesh_impact_bullet2.wav",
	"physics/flesh/flesh_impact_bullet3.wav",
	"physics/flesh/flesh_impact_bullet4.wav",
	"physics/flesh/flesh_impact_bullet5.wav"
}

ENT.DeathSounds = {
	"nz/hellhound/death2/death0.wav",
	"nz/hellhound/death2/death1.wav",
	"nz/hellhound/death2/death2.wav",
	"nz/hellhound/death2/death3.wav",
	"nz/hellhound/death2/death4.wav",
	"nz/hellhound/death2/death5.wav",
	"nz/hellhound/death2/death6.wav",
}

ENT.SprintSounds = {
	"nz/hellhound/close/close_00.wav",
	"nz/hellhound/close/close_01.wav",
	"nz/hellhound/close/close_02.wav",
	"nz/hellhound/close/close_03.wav",
}

function ENT:StatsInitialize()
	if SERVER then
		local ply
		local lowest
		local players = player.GetAllTargetable()

		-- Loop through all targetable players
		for k,v in pairs(players) do
			if !lowest then lowest = v.hellhoundtarget end -- Set the lowest variable if not yet
			if lowest and (!v.hellhoundtarget or v.hellhoundtarget <= lowest) then -- If the variable exists and this player is on par with that amount
				ply = v -- Mark him for the potential target
				lowest = v.hellhoundtarget -- And set the new lowest to continue the loop with
			end
		end
		if !lowest then -- If no players had any target values (lowest was never set)
			ply = players[math.random(#players)] -- Then pick a random player
		end
		ply.hellhoundtarget = ply.hellhoundtarget and ply.hellhoundtarget + 1 or 1
		self.playertarget = ply -- Set the target

		self:SetRunSpeed(250)
		self:SetHealth( 100 )
	end
	self:SetSolid(SOLID_OBB)
	self:SetCollisionBounds(Vector(-16,-16, 0), Vector(16, 16, 48))

	--PrintTable(self:GetSequenceList())
end

function ENT:OnSpawn()
	local effectData = EffectData()
	-- startpos
	effectData:SetStart( self:GetPos() + Vector(0, 0, 1000) )
	-- end pos
	effectData:SetOrigin( self:GetPos() )
	-- duration
	effectData:SetMagnitude( 0.75 )
	util.Effect("lightning_strike", effectData)

	Round:SetNextSpawnTime(CurTime() + 2) -- This one spawning delays others by 3 seconds
end

function ENT:OnKilled(dmgInfo)

	self:SetRunSpeed(0)
	self.loco:SetVelocity(Vector(0,0,0))
	self:Stop()
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local seq, dur = self:LookupSequence(self.DeathSequences[math.random(#self.DeathSequences)])
	self:ResetSequence(seq)
	self:SetCycle(0)

	timer.Simple(dur + 1, function()
		if IsValid(self) then
			self:Remove()
		end
	end)
	self:EmitSound( self.DeathSounds[ math.random( #self.DeathSounds ) ], 100)

end

function ENT:BodyUpdate()

	self.CalcIdeal = ACT_IDLE

	local velocity = self:GetVelocity()

	local len2d = velocity:Length2D()

	if ( len2d > 150 ) then self.CalcIdeal = ACT_RUN elseif ( len2d > 50 ) then self.CalcIdeal = ACT_WALK_ANGRY elseif ( len2d > 5 ) then self.CalcIdeal = ACT_WALK end

	if self:IsJumping() and self:WaterLevel() <= 0 then
		self.CalcIdeal = ACT_JUMP
	end

	if self:GetActivity() != self.CalcIdeal and !self:IsAttacking() and !self:GetStop() then self:StartActivity(self.CalcIdeal) end

	if ( self.CalcIdeal and !self:GetAttacking() ) then

		self:BodyMoveXY()

	end

	self:FrameAdvance()

end

function ENT:OnTargetInAttackRange()
    local atkData = {}
    atkData.dmglow = 20
    atkData.dmghigh = 30
    atkData.dmgforce = Vector( 0, 0, 0 )
	atkData.dmgdelay = 0.3
    self:Attack( atkData )
end

-- Hellhounds target differently
function ENT:GetPriorityTarget()

	if GetConVar( "nz_zombie_debug" ):GetBool() then
		print(self, "Retargeting")
	end

	self:SetLastTargetCheck( CurTime() )

	-- Well if he exists and he is targetable, just target this guy!
	if IsValid(self.playertarget) and self.playertarget:GetTargetPriority() > 0 then
		local dist = self:GetRangeSquaredTo( self.playertarget:GetPos() )
		if dist < 1000 then
			if !self.sprinting then
				self:EmitSound( self.SprintSounds[ math.random( #self.SprintSounds ) ], 100 )
				self.sprinting = true
			end
			self:SetRunSpeed(250)
			self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		elseif !self.sprinting then
			self:SetRunSpeed(100)
			self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		end
		return self.playertarget
	end

	-- Otherwise, we just loop through all to try and target again
	local allEnts = ents.GetAll()

	local bestTarget = nil
	local maxdistsqr = self:GetTargetCheckRange()^2
	local targetDist = maxdistsqr + 10

	--local possibleTargets = ents.FindInSphere( self:GetPos(), self:GetTargetCheckRange())

	for _, target in pairs(allEnts) do
		if self:IsValidTarget(target) then
			if target:GetTargetPriority() == TARGET_PRIORITY_ALWAYS then return target end
			local dist = self:GetRangeSquaredTo( target:GetPos() )
			if maxdistsqr <= 0 or dist <= maxdistsqr then -- 0 distance is no distance restrictions
				local priority = target:GetTargetPriority()
				if priority == TARGET_PRIORITY_PLAYER then -- We can only target players (and ALWAYS-targets)!
					if targetDist > dist then
						highestPriority = priority
						bestTarget = target
						targetDist = dist
					end
				end
				--print(highestPriority, bestTarget, targetDist, maxdistsqr)
			end
		end
	end

	if IsValid(bestTarget) then
		if targetDist < 1000 then
			self:EmitSound( self.SprintSounds[ math.random( #self.SprintSounds ) ], 100 )
			self.sprinting = true
			self:SetRunSpeed(250)
		else
			self:SetRunSpeed(100)
			self.sprinting = nil
		end
		self.loco:SetDesiredSpeed( self:GetRunSpeed() )
		self.playertarget = bestTarget
	end

	return bestTarget
end
