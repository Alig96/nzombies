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
		--self:SetModel( "models/props_interiors/BathTub01a.mdl" )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
		self:SetUseType(SIMPLE_USE)
	end
	
	function ENT:SetWeapon(weapon, price)
		self:SetModel( weapons.Get(weapon).WorldModel )
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
			activator:GiveAmmo(bnpvbWJpZXM.Config.BaseStartingAmmoAmount, weapons.Get(self.WeaponGive).Primary.Ammo)
		else
			print("Can't afford!")
		end
		return
	end
	 
	function ENT:Think()
		-- We don't need to think, we are just a prop after all!
	end
end

if CLIENT then
	function ENT:Draw()
		-- self.BaseClass.Draw(self)
		self:DrawModel()
	end
	hook.Add( "PreDrawHalos", "wall_buy_halos", function()
		halo.Add( ents.FindByClass( "wall_buy" ), Color( 255, 255, 255 ), 0, 0, 0.1 )
	end )
end
