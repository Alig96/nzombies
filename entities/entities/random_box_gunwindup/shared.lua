AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "random_box_windup"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		if SERVER then
			self:SetModel(GenList()[1].WorldModel)
		end
		self:DrawShadow( false )
		self.Winding = true
		self.c = 0
		self.s = -20
		timer.Simple(7, function() self.Winding = false  end)
		if SERVER then
			timer.Simple(18, function() if self:IsValid() then self:Remove() end end)
		end
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
end

function ENT:Use( activator, caller )
	if !self.Winding then
		activator:Give(self.Gun.ClassName)
		activator:GiveAmmo(bnpvbWJpZXM.Config.BaseStartingAmmoAmount, weapons.Get(self.Gun.ClassName).Primary.Ammo)
		self:Remove()
	end
end

function GenList( )
	local guns = {}
	for k,v in pairs( weapons.GetList() ) do 
		if !table.HasValue(bnpvbWJpZXM.Config.WeaponBlackList, v.ClassName) then
			table.insert(guns, v)
		end
	end 
	return guns
end

function ENT:WindUp( )
	local gun = table.Random(GenList())
	if gun.WorldModel != nil then
		self.Gun = gun
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
		if self.Winding then
			self:WindUp()
		else
			self:WindDown()
		end
		self:SetModel(self.Gun.WorldModel)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end