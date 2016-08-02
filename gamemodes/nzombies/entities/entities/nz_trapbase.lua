AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "nz_trapbase"

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Active" )
	self:NetworkVar( "Bool", 1, "CooldownActive" )
	self:NetworkVar( "Bool", 2, "ElectircityNeeded" )

	self:NetworkVar( "Float", 0, "Duration" )
	self:NetworkVar( "Float", 1, "Cooldown" )

	if SERVER then
		self:SetActive(false)
		self:SetDuration(60)
		self:Cooldown(30)
		self:CooldownActive(false)
		self:ElectircityNeeded(true)
	end

end

function ENT:IsActive() return self:GetActive()  end

function ENT:IsCooldownActive() return self:GetCooldownActive()  end

function ENT:IsElectircityNeeded() return self:GetElectircityNeeded()  end

function ENT:Activation()
	self:SetActive(true)
	self:OnActivation()
	timer.Create("trap.disarm.timer." .. self:EntIndex(), self.fDuration, 1, function() self:Deactivation() end)
end

function ENT:Deactivation()
	self:SetCooldownActive(true)
	self:SetActive(false)

	self:OnDeactivation()
	timer.Create("trap.cooldown.timer." .. self:EntIndex(), self.fCooldown, 1, function() self:Ready() end)
end

function ENT:Ready()
	self:SetCooldownActive(false)
	self:OnReady()
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
