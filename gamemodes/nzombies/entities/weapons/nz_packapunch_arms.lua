if SERVER then
	AddCSLuaFile("nz_packapunch_arms.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Hands"			
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

SWEP.ViewModel	= "models/weapons/c_packapunch_arms.mdl"
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
SWEP.NZTotalBlacklist = true

function SWEP:Initialize()

	self:SetHoldType( "slam" )

end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	
	timer.Simple(0.5,function()
		if IsValid(self) and IsValid(self.Owner) then
			if self.Owner:Alive() then
				self:EmitSound("nz/perks/knuckle_00.wav")
			end
		end
	end)

	timer.Simple(1.3,function()
		if IsValid(self) and IsValid(self.Owner) then
			if self.Owner:Alive() then
				self:EmitSound("nz/perks/knuckle_01.wav")
			end
		end
	end)
end

function SWEP:Equip( owner )
	
	--timer.Simple(3.2,function() self:Remove() end)
	--owner:SetActiveWeapon("nz_packapunch_arms")
	
end

function SWEP:PrimaryAttack()
	
end

function SWEP:PostDrawViewModel()

end

function SWEP:DrawWorldModel()

end

function SWEP:OnRemove()
	
end

function SWEP:GetViewModelPosition( pos, ang )
 
 	local newpos = LocalPlayer():EyePos()
	local newang = LocalPlayer():EyeAngles()
	local up = newang:Up()
	
	newpos = newpos + LocalPlayer():GetAimVector()*6 - up*63
	
	return newpos, newang
 
end