if SERVER then
	AddCSLuaFile("nz_monkey_bomb.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Monkey Bomb"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Throws a monkey bomb if you have any"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "grenade"

SWEP.ViewModel	= "models/weapons/c_grenade.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextReload				= 1

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:PrimaryAttack()
	
end

function SWEP:ThrowBomb(force)
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self:SendWeaponAnim(ACT_VM_THROW)
	
	local nade = ents.Create("nz_monkeybomb")
	nade:SetPos(self.Owner:EyePos() + (self.Owner:GetAimVector() * 20))
	nade:Spawn()
	nade:Activate()
	nade:SetOwner(self.Owner)
	
	local nadePhys = nade:GetPhysicsObject()
		if !IsValid(nadePhys) then return end
	nadePhys:ApplyForceCenter(self.Owner:GetAimVector():GetNormalized() * force + self.Owner:GetVelocity())
	
	nade:SetExplosionTimer(10)
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()

end

function SWEP:OnRemove()
	
end

if engine.ActiveGamemode() == "nzombies3" then 
	SpecialWeapons:AddWeapon( "nz_monkey_bomb", "specialgrenade", function(ply) -- Use function
		if SERVER then
			if ply:GetAmmoCount("nz_specialgrenade") <= 0 then return end
			local prevwep = ply:GetActiveWeapon():GetClass()
			ply.UsingSpecialWep = true
			ply:SelectWeapon("nz_monkey_bomb")
			timer.Simple(0.5, function()
				if IsValid(ply) then
					local wep = ply:GetActiveWeapon()
					wep:ThrowBomb(700)
					ply:SetAmmo(ply:GetAmmoCount("nz_specialgrenade") - 1, "nz_specialgrenade")
				end
			end)
			timer.Simple(1, function()
				if IsValid(ply) then
					ply.UsingSpecialWep = nil
					ply:SelectWeapon(prevwep)
				end
			end)
		end
	end, function(ply) -- Equip Function
		ply:SetAmmo(3, "nz_specialgrenade")
	end, function(ply) -- Max Ammo function
		ply:SetAmmo(3, "nz_specialgrenade")
	end)
end