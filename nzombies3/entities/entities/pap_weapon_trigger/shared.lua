AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "pap_weapon_trigger"
ENT.Author			= "Zet0r"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "WepClass")

end

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_OBB )
	self:SetModel("models/hunter/blocks/cube05x1x025.mdl")
	self:DrawShadow(false)

	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Use( activator, caller )
	if activator == self.Owner then
		local class = self:GetWepClass()
		local wep = activator:Give(class)
		nz.Weps.Functions.GiveMaxAmmoWep(activator, class)
		nz.Weps.Functions.ApplyPaP(activator, wep)
		if activator:HasPerk("speed") and nz.Weps.Functions.IsFAS2(wep) then
			nz.Weps.Functions.ApplySleight( activator, wep )
		end
		if activator:HasPerk("dtap") and nz.Weps.Functions.IsFAS2(wep) then
			nz.Weps.Functions.ApplyDTap( activator, wep )
		end
		if IsValid(self.wep) then
			self.wep.machine:SetBeingUsed(false)
			self.wep:Remove()
		end
		self:Remove()
	else
		if IsValid(self.Owner) then
			activator:PrintMessage( HUD_PRINTTALK, "This is " .. self.PapOwner:Nick() .. "'s gun. You cannot take it." )
		end
	end
end

if CLIENT then
	function ENT:Draw()
		return
	end
end
