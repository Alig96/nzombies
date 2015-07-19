AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "random_box_windup"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Winding" )
	self:NetworkVar( "String", 0, "WepClass")

end

function ENT:Initialize()

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )

	self:SetWinding(true)
	self.c = 0
	self.s = -20
	self:SetModel("models/weapons/w_rif_ak47.mdl")

	if SERVER then
		//Stop winding up
		timer.Simple(7, function() self:SetWinding(false) self:SetModel(weapons.Get(self:GetWepClass()).WorldModel) end)
		//If we time out, remove the object
		timer.Simple(18, function() if self:IsValid() then self:GetParent():Close() self:Remove() end end)
	end
end

function ENT:Use( activator, caller )
	if !self:GetWinding() then
		if activator == self.Buyer then
			local class = self:GetWepClass()
			activator:Give(class)
			nz.Weps.Functions.GiveMaxAmmoWep(activator, class)
			self:GetParent():Close()
			self:Remove()
		else
			if self.Buyer:IsValid() then
				activator:PrintMessage( HUD_PRINTTALK, "This is " .. self.Buyer:Nick() .. "'s gun. You cannot take it." )
			end
		end
	end
end

function ENT:WindUp( )
	local gun = table.Random(weapons.GetList())
	if gun.WorldModel != nil then
		self:SetModel(gun.WorldModel)
	end
	self.c = self.c + 1
	if self.c > 7 then
		self.c = 7
	end
	self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + 0.1*self.c))
end

function ENT:WindDown( )
	self.s = self.s + 1
	if self.s > 7 then
		self.s = 7
	end
	if self.s >= 0 then
		self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z - 0.1*self.s))
	end
end

function ENT:Think()
	if SERVER then
		if self:GetWinding() then
			self:WindUp()
		else
			self:WindDown()
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
