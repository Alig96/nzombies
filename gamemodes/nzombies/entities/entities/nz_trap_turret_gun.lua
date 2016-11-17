AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Turret gun"
ENT.fFireRate = 0.1

ENT.fLastTargetCheck = CurTime()
ENT.fNextFire = CurTime()

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Active")
	self:NetworkVar("Int", 0, "AttackRange")
	self:NetworkVar("Int", 1, "DamagePerHit")

	self:SetAttackRange(1200)
	self:SetDamagePerHit(20)
end

function ENT:Initialize()
	self:SetModel( "models/weapons/w_mach_m249para.mdl" )
end

function ENT:Think()
	if SERVER then
		if not self:GetActive() then return end

		if self.fLastTargetCheck + 0.5 < CurTime() and not self:HasValidTarget() then
			self:SetTarget(self:GetPriorityTarget())
		end

		if self:HasValidTarget() then
			local targetpos = self.eTarget:GetPos() + self.eTarget:OBBCenter()
			local att = self:LookupAttachment( "muzzle" )
			local muzzlePos = self:GetAttachment( att ).Pos

			local angle = (targetpos - self:GetPos()):Angle()

			self:SetAngles(angle)

			if self.fNextFire < CurTime() then
				local bullet = {
					Damage = self:GetDamagePerHit(),
					Force = 3,
					Src = muzzlePos,
					Dir = self:GetForward(),
					Distance = self:GetAttackRange() * 2,
					Spread = Vector(0.5,0.8,0),
					AmmoType = "Pistol",
					Tracer = 1,
					TracerName
				}

				self:EmitSound("npc/sniper/sniper1.wav")

				self:FireBullets(bullet)

				self.fNextFire = CurTime() + self.fFireRate
			end
		end
	end
end

function ENT:SetTarget( target )
	self.eTarget = target
end

function ENT:GetTarget()
	return self.eTarget
end

function ENT:HasValidTarget()
	return IsValid(self:GetTarget()) and self:GetTarget():IsValidZombie() and self:GetPos():Distance(self.eTarget:GetPos()) < self:GetAttackRange() and self.eTarget:Health() > 0
end

--Targetfinding
function ENT:GetPriorityTarget()

	self.fLastTargetCheck = CurTime()

	local possibleTargets = ents.FindInSphere(self:GetPos(), self:GetAttackRange())

	local zombies = {}

	for _, ent in pairs(possibleTargets) do
		if ent:IsValidZombie() then
			table.insert(zombies, ent)
		end
	end

	return table.Random(zombies)

end
