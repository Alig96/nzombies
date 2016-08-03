AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "nz_activatable"

ENT.PrintName = "nz_trapbase"

DEFINE_BASECLASS("nz_activatable")

function ENT:Activation(caller, dur, cd)
	BaseClass.Activation(self)
	if dur then self:SetDuration(dur) end
	if cd then self:SetCooldown(cd) end

	timer.Create("trap.disarm.timer." .. self:EntIndex(), self:GetDuration(), 1, function() self:Deactivation() end)
end

function ENT:Deactivation()
	BaseClass.Deactivation(self)
	timer.Create("trap.cooldown.timer." .. self:EntIndex(), self:GetCooldown(), 1, function() self:Ready() end)
end

function ENT:Ready()
	BaseClass.Ready(self)
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
