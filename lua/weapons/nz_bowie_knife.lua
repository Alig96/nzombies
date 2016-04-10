if SERVER then
	AddCSLuaFile("nz_bowie_knife.lua")
	SWEP.Weight			= 5
	SWEP.AutoSwitchTo	= false
	SWEP.AutoSwitchFrom	= true
end

if CLIENT then

	SWEP.PrintName     	    = "Bowie Knife"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 1
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= true
	
	SWEP.Category			= "nZombies"

end


SWEP.Author			= "Zet0r"
SWEP.Contact		= "youtube.com/Zet0r"
SWEP.Purpose		= "Stab Stab Stab!"
SWEP.Instructions	= "Let the gamemode give you it"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.HoldType = "knife"

SWEP.ViewModel	= "models/weapons/c_bowie_knife.mdl"
SWEP.WorldModel	= "models/weapons/w_bowie_knife.mdl"
SWEP.UseHands = true
SWEP.vModel = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.DamageType		= DMG_CLUB
SWEP.Primary.Force			= 0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.NextReload				= 1

SWEP.Primary.Damage 		= 200
SWEP.Range					= 100


function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()
	--self:SendWeaponAnim(ACT_VM_DRAW)
	--self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack()
	// Only the player fires this way so we can cast

	
	local pPlayer		= self.Owner;

	if ( !pPlayer ) then
		return;
	end
	
	print("something")

	local vecSrc		= pPlayer:GetShootPos();
	local vecDirection	= pPlayer:GetAimVector();

	local trace			= {}
		trace.start		= vecSrc
		trace.endpos	= vecSrc + ( vecDirection * self.Range)
		trace.filter	= pPlayer

	local traceHit		= util.TraceLine( trace )

	if ( traceHit.Hit ) then

		--self.Weapon:EmitSound( self.Primary.Hit );

		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER );
		pPlayer:SetAnimation( PLAYER_ATTACK1 );

		self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
		self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

		local vecSrc = pPlayer:GetShootPos();

		if ( SERVER ) then
			pPlayer:TraceHullAttack( vecSrc, traceHit.HitPos, Vector( -5, -5, -5 ), Vector( 5, 5, 36 ), self.Primary.Damage, self.Primary.DamageType, self.Primary.Force );
		end

		return

	end

	--self.Weapon:EmitSound( self.Primary.Sound );

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	pPlayer:SetAnimation( PLAYER_ATTACK1 );

	self.Weapon:SetNextPrimaryFire( CurTime() + 1 );
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Weapon:SequenceDuration() );

	return
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
	
	newpos = newpos + LocalPlayer():GetAimVector()*6 - up*65
	
	return newpos, newang
 
end

if engine.ActiveGamemode() == "nzombies3" then 
	SpecialWeapons:AddWeapon( "nz_bowie_knife", "knife", function(ply, wep) -- Use function
		if SERVER then
			local prevwep = ply:GetActiveWeapon():GetClass()
			ply.UsingSpecialWep = true
			ply:SetActiveWeapon(wep)
			timer.Simple(0.05, function()
				if IsValid(ply) then
					wep:PrimaryAttack()
				end
			end)
			timer.Simple(0.5, function()
				if IsValid(ply) then
					ply.UsingSpecialWep = nil
					ply:SelectWeapon(prevwep)
				end
			end)
		end
	end, function(ply, wep)
		if SERVER then
			local prevwep = ply:GetActiveWeapon():GetClass()
			ply.UsingSpecialWep = true
			ply:SelectWeapon("nz_bowie_knife")
			timer.Simple(2, function()
				if IsValid(ply) then
					ply.UsingSpecialWep = nil
					ply:SelectWeapon(prevwep)
				end
			end)
		end
	end)
end