AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Turret gun"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

ENT.fAttackRange = 600

function ENT:Initialize()
    self:SetModel( "models/weapons/w_mach_m249para.mdl" )
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "PerkOwner")
end

function ENT:Think()
	if self:GetLastTargetCheck() + 1 < CurTime() then
		self:SetTarget(self:GetPriorityTarget())
	end

end

function ENT:RunBehaviour()
	while (true) do
        coroutine.wait(60)
    end
end

function ENT:SetTarget( target )
	self.Target = target
	if self.Target != target then
		self:SetLastTargetChange(CurTime())
	end
end

--Target and pathfidning
function ENT:GetPriorityTarget()

	self:SetLastTargetCheck( CurTime() )

	local possibleTargets = ents.FindInSphere( self:GetPos(), self.fAttackRange )


end
