if SERVER then
	AddCSLuaFile("nz_zombieshield.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= false
end

if CLIENT then

	SWEP.PrintName     	    = "Zombie Shield"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Your back is now protected!"
SWEP.Instructions	= "Build it by finding all its parts!"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "fist"

SWEP.ViewModel = "models/weapons/c_zombieshield.mdl"
SWEP.WorldModel = "models/weapons/w_zombieshield_equipped.mdl"
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

SWEP.NZPreventBox = true
--SWEP.NZTotalBlacklist = true
--SWEP.NZSpecialCategory = "display" -- This makes it count as special, as well as what category it replaces
-- (display is generic stuff that should only be carried temporarily and never holstered and kept)

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Electrified")
end

function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()
	if SERVER then
		if IsValid(self.Owner) and IsValid(self.Shield) then
			self.Owner.Shield:SetNoDraw(true)
		else
			self:Remove()
		end
	end
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.WepOwner = self.Owner
	self:CallOnClient("Deploy")
end

function SWEP:Holster()
	if SERVER then
		if IsValid(self.Owner) and IsValid(self.Shield) then
			self.Owner.Shield:SetNoDraw(false)
		else
			self:Remove()
		end
	end
	return true
end

function SWEP:CreateBackShield(owner)
	owner.Shield = ents.Create("nz_zombieshield_back")
	owner.Shield:SetOwner(owner)
	owner.Shield:Spawn()
	self.Shield = owner.Shield
end

function SWEP:Equip( owner )
	self:CreateBackShield(owner)
end

function SWEP:PrimaryAttack()
	
	self:SetNextPrimaryFire(CurTime() + 1)

	local vecSrc		= self.Owner:GetShootPos()
	local vecDirection	= self.Owner:GetAimVector()

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * 100)
		trace.filter	= self.Owner

	local tracehit		= util.TraceLine( trace )
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if ( tracehit.Hit ) then
		if ( SERVER ) then
			self:EmitSound("physics/metal/metal_box_impact_hard"..math.random(1,3)..".wav")
			if self:GetElectrified() then
				local ent = self.Owner:TraceHullAttack( vecSrc, tracehit.HitPos, Vector( -5, -5, -5 ), Vector( 5, 5, 36 ), 450, DMG_SHOCK, 100 )
				if IsValid(ent) then ent:EmitSound("ambient/energy/zap"..math.random(1,9)..".wav") end
			else
				self.Owner:TraceHullAttack( vecSrc, tracehit.HitPos, Vector( -5, -5, -5 ), Vector( 5, 5, 36 ), 250, DMG_CLUB, 100 )
			end
		end
	end
	
end

function SWEP:NZSpecialHolster(wep)
	return true
end

function SWEP:OnRemove()
	if SERVER then
		if IsValid(self.Shield) then
			self.Shield:Remove()
		end
	end
end

function SWEP:GetViewModelPosition( pos, ang )
 
	return pos, ang
 
end

if CLIENT then
	function SWEP:DrawWorldModel()
		self:DrawModel()
		if self:GetElectrified() then
			local pos, ang = self:GetBonePosition(1)
			nzEffects:DrawElectricArcs( self, pos, ang, 1, 1, 0.3 )
		end
	end
	
	function SWEP:PostDrawViewModel(vm)
		if self:GetElectrified() then
			local pos, ang = vm:GetBonePosition(23)
			nzEffects:DrawElectricArcs( self, pos, ang, 1, 1, 0.3 )
		end
	end

end

hook.Add("PlayerShouldTakeDamage", "nzShieldDamageHandler", function(ply, ent)
	
	if ent:IsValidZombie() and IsValid(ply.Shield) then
		local dot = (ent:GetPos() - ply:GetPos()):Dot(ply:GetAimVector())
		local wep = ply:GetActiveWeapon()
		local shield = IsValid(wep) and wep:GetClass() == "nz_zombieshield"
		if (dot < 0 and !shield) or (dot >= 0 and shield) then
			ply.Shield:TakeDamage(30, ent, ent)
			return false
		end
	end
	
end)