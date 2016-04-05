AddCSLuaFile()

ENT.Base = "nz_zombiebase"
ENT.PrintName = "Hellhound"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.Models = { "models/boz/killmeplease.mdl" }

ENT.AttackRange = 80

ENT.AttackSequences = {
	"attack"
}

ENT.DeathSequences = {
	"death1",
	"death2",
	"death3",
	"death4"
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

function ENT:StatsInit()
	if SERVER then
		--self:SetRunSpeed( nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] )

		self:SetRunSpeed( 200)

		self:SetHealth( 100 )

	end
	self:SetSolid(SOLID_OBB)
	self:SetCollisionBounds(Vector(-16,-16, 0), Vector(16, 16, 48))

	PrintTable(self:GetSequenceList())
end

function ENT:OnSpawn()
	local effectData = EffectData()
	-- startpos
	effectData:SetStart( self:GetPos() + Vector(0, 0, 1000) )
	-- end pos
	effectData:SetOrigin( self:GetPos() )
	-- duration
	effectData:SetMagnitude( 1 )
	util.Effect("lightning_strike", effectData)
end

function ENT:OnKilled(dmgInfo)

	self:SetRunSpeed(0)
	self.loco:SetVelocity(Vector(0,0,0))
	self:Stop()
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

	if ( len2d > 5 ) then self.CalcIdeal = ACT_WALK end

	if self:IsJumping() and self:WaterLevel() <= 0 then
		self.CalcIdeal = ACT_JUMP
	end

	if self:GetActivity() != self.CalcIdeal and !self:IsAttacking() and !self:GetStop() then self:StartActivity(self.CalcIdeal) end

	if ( self.CalcIdeal and !self:GetAttacking() ) then

		self:BodyMoveXY()

	end

	self:FrameAdvance()

end
