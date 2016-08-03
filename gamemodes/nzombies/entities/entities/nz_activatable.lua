AddCSLuaFile( )

-- Interface for stuff taht cna be activated by the player DO NOT USE THIS CLASS create subclasses!

ENT.Type = "anim"
ENT.Base = "nz_activatable"

ENT.PrintName = "nz_trapbase"

ENT.bIsActivatable = true

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Active" )
	self:NetworkVar( "Bool", 1, "CooldownActive" )
	self:NetworkVar( "Bool", 2, "ElectircityNeeded" )
	self:NetworkVar( "Bool", 3, "SingleUse" )
	self:NetworkVar( "Bool", 4, "RemoteActivated" )

	self:NetworkVar( "Float", 0, "Duration" )
	self:NetworkVar( "Float", 1, "Cooldown" )
	self:NetworkVar( "Float", 2, "Cost" )

	self:NetworkVar( "String", 0, "Name" )

	if SERVER then
		self:SetActive(false)
		self:SetDuration(60)
		self:SetCooldown(30)
		self:SetCost(0)
		self:SetCooldownActive(false)
		self:SetElectircityNeeded(true)
		self:SetSingleUse(false)
		self:SetRemoteActivated(false)
		self:SetUseType(SIMPLE_USE)
	end

end

function ENT:IsActive() return self:GetActive() end

function ENT:IsCooldownActive() return self:GetCooldownActive() end

function ENT:IsElectircityNeeded() return self:GetElectircityNeeded() end

function ENT:IsSingleUse() return self:GetSingleUse() end

function ENT:IsRemoteActivated() return self:GetRemoteActivated() end

function ENT:Activation(activator)
	self:SetActive(true)
	self:OnActivation()
end

function ENT:Deactivation()
	self:SetCooldownActive(true)
	self:SetActive(false)
	self:OnDeactivation()
end

function ENT:Ready()
	self:SetCooldownActive(false)
	self:OnReady()
end

function ENT:Use( act, caller, type, value )
	if IsValid(caller) and caller:IsPlayer() and not self:IsRemoteActivated() and not self:IsCooldownActive() then
		if caller:CanAfford(self:GetCost()) then
			self:Activation(caller)
			if SERVER then
				caller:RemovePoints(self:GetCost())
			end
		end
	end
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
