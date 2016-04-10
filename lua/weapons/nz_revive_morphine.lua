if SERVER then
	AddCSLuaFile("nz_revive_morphine.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Morphine"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Fancy Viewmodel Animations"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "slam"

SWEP.ViewModel	= "models/weapons/c_revive_morphine.mdl"
SWEP.WorldModel	= ""
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

function SWEP:Initialize()

	self:SetHoldType( "slam" )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	print(self.Owner)
	self.WepOwner = self.Owner
end

function SWEP:Equip( owner )
	
	local wep = owner:GetActiveWeapon()
	if IsValid(wep) then
		local class = wep:GetClass()
		owner.oldwep = class
	end
	owner:SetActiveWeapon("nz_revive_morphine")
	print(owner)
	
end

function SWEP:PrimaryAttack()
	
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()

end

function SWEP:OnRemove()
	if SERVER then
		self.WepOwner:SetActiveWeapon(nil)
		self.WepOwner:SelectWeapon(self.WepOwner.oldwep)
	end
end

function SWEP:GetViewModelPosition( pos, ang )
 
 	local newpos = LocalPlayer():EyePos()
	local newang = LocalPlayer():EyeAngles()
	local up = newang:Up()
	
	newpos = newpos + LocalPlayer():GetAimVector()*6 - up*63
	
	return newpos, newang
 
end

if engine.ActiveGamemode() == "nzombies3" then 
	SpecialWeapons:AddWeapon( "nz_revive_morphine", "display", nil, function(ply, wep)
		if SERVER then
			ply.UsingSpecialWep = true
			ply:SelectWeapon("nz_revive_morphine")
		end
	end)
end