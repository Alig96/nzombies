AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "buy_gun_area"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "EntName" )
	self:NetworkVar( "String", 1, "Price" )
end

if SERVER then
	function ENT:Initialize()
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType(SIMPLE_USE)
	end
	
	function ENT:SetWeapon(weapon, price)
		//Add a special check for FAS weps
		if weapons.Get(weapon).Category == "FA:S 2 Weapons" then
			//self:SetModel( weapons.Get(weapon).WM )
			self:SetModel( weapons.Get(weapon).WorldModel )
		else
			self:SetModel( weapons.Get(weapon).WorldModel )
		end
		self:SetModelScale( 1.5, 0 )
		self.WeaponGive = weapon
		self.Price = price
		self:SetEntName(weapon)
		self:SetPrice(price)
	end
	 
	function ENT:Use( activator, caller )
		if activator:CanAfford(self.Price) then
			activator:TakePoints(self.Price)
			activator:Give(self.WeaponGive)
			activator:GiveAmmo(nz.Config.BaseStartingAmmoAmount, weapons.Get(self.WeaponGive).Primary.Ammo)
		else
			print("Can't afford!")
		end
		return
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end
