AddCSLuaFile( )

-- Register teh trap
nzTraps:Register("nz_trap_turret")
ENT.PrintName = "Turret"
ENT.SpawnIcon = "models/weapons/w_mach_m249para.mdl"
ENT.Description = "Simple Turret trap that will attack zombies around it."

ENT.Type = "anim"
ENT.Base = "nz_trapbase"

DEFINE_BASECLASS("nz_trapbase")

function ENT:Initialize()
	self:SetModel( "models/props_trainstation/trainstation_ornament001.mdl" )
	self:SetModelScale(0.5)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	phys:EnableMotion(false)

	if SERVER then
		timer.Simple(0.1, function()
			self.Gun = ents.Create("nz_trap_turret_gun")
			self.Gun:SetParent(self)
			self.Gun:SetPos(self:GetPos() + Vector(0, 0, 45))
			self.Gun:Spawn()
		end)
	end
end

-- IMPLEMENT ME
function ENT:OnActivation()
	self.Gun:SetActive(true)
end

function ENT:OnDeactivation()
	self.Gun:SetActive(false)
end

function ENT:OnReady() end
