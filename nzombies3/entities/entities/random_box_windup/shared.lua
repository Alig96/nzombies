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
	if SERVER then
		self:SetModel(table.Random(self:GenList()).WorldModel)
	end
	self:DrawShadow( false )
	//self.Winding = true
	self:SetWinding(true)
	self:SetWepClass("zzz")
	self.c = 0
	self.s = -20
	timer.Simple(7, function() 
	//self.Winding = false 
	self:SetWinding(false)  end)
	if SERVER then
		timer.Simple(18, function() if self:IsValid() then self:GetParent():Close() self:Remove() end end)
	end
end

function ENT:Use( activator, caller )
	if !self:GetWinding() then
		activator:Give(self.Gun.ClassName)
		//Just for display, since we're setting their ammo anyway
		activator:GiveAmmo(nz.Misc.Functions.CalculateMaxAmmo(self.Gun.ClassName), weapons.Get(self.Gun.ClassName).Primary.Ammo)
		nz.Misc.Functions.GiveMaxAmmoWep(activator, self.Gun.ClassName)
		self:GetParent():Close()
		self:Remove()
	end
end

function ENT:GenList( )
	local guns = {}
	local blacklist = nz.Config.WeaponBlackList
	if IsValid(self.Buyer) then
		for k,v in pairs( self.Buyer:GetWeapons() ) do 
			table.insert(blacklist, v.ClassName)
		end
	end
	for k,v in pairs( weapons.GetList() ) do 
		if !table.HasValue(blacklist, v.ClassName) then
			if v.WorldModel != nil then
				table.insert(guns, v)
				print(v.ClassName)
			end
		end
	end 
	return guns
end

function ENT:WindUp( )
	local gun = table.Random(self:GenList())
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
	if self:GetWepClass() == "zzz" then self:SetWepClass(self.Gun.ClassName) end
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
		self:SetModel(self.Gun.WorldModel)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end