AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "nz_trapbase"

ENT.PrintName = "Turret"

DEFINE_BASECLASS("nz_trapbase")

function ENT:Initialize()
	if SERVER then
		timer.Simple(0.1, function()
			local mount = ents.Create("nz_trap_turret_mount")
			mount:SetPos(self:GetPos())
			mount:Spawn()
			local gun = ents.Create("nz_trap_turret_gun")
			gun:SetPos(self:GetPos() + Vector(0, 0, 56))
			gun:Spawn()
		end)
	end
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
