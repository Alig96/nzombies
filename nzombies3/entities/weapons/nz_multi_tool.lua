SWEP.PrintName			= "Create Mode Toolgun"
SWEP.Author				= "Zet0r"
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
SWEP.AnimPrefix			= "python"

SWEP.Slot				= 5
SWEP.SlotPos			= 1

SWEP.UseHands			= true

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

SWEP.ShootSound			= Sound( "Airboat.FireGunRevDown" )

SWEP.Tool				= {}

SWEP.Primary = 
{
	ClipSize 	= -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.Secondary = 
{
	ClipSize 	= -1,
	DefaultClip = -1,
	Automatic = false,
	Ammo = "none"
}

SWEP.CanHolster			= true
SWEP.CanDeploy			= true

--[[---------------------------------------------------------
	Initialize
-----------------------------------------------------------]]
function SWEP:Initialize()
	self.Primary = 
	{
		ClipSize 	= -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}
	
	self.Secondary = 
	{
		ClipSize 	= -1,
		DefaultClip = -1,
		Automatic = false,
		Ammo = "none"
	}
	
	self.ToolMode = "default"
end

--[[---------------------------------------------------------
   Precache Stuff
-----------------------------------------------------------]]
function SWEP:Precache()

	util.PrecacheSound( self.ShootSound )
	
end

--[[---------------------------------------------------------
	The shoot effect
-----------------------------------------------------------]]
function SWEP:DoShootEffect( hitpos, hitnormal, entity, physbone, bFirstTimePredicted )

	self.Weapon:EmitSound( self.ShootSound	)
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if ( !bFirstTimePredicted ) then return end
	
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetNormal( hitnormal )
		effectdata:SetEntity( entity )
		effectdata:SetAttachment( physbone )
	util.Effect( "selection_indicator", effectdata )	
	
	local effectdata = EffectData()
		effectdata:SetOrigin( hitpos )
		effectdata:SetStart( self.Owner:GetShootPos() )
		effectdata:SetAttachment( 1 )
		effectdata:SetEntity( self.Weapon )
	util.Effect( "ToolTracer", effectdata )
	
end

--[[---------------------------------------------------------
	Switch to another toolmode
-----------------------------------------------------------]]
function SWEP:SwitchTool(id)
	
	//Only allow if the condition has been met
	if nz.Tools.ToolData[id].condition(self, self.Owner) then
		self.ToolMode = id
		
		//Update the server with the newly equipped tool
		nz.Tools.Functions.SendData( nz.Tools.SavedData[id], id )
	end
	
end


--[[---------------------------------------------------------
	Trace a line then send the result to a mode function
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )
	
	if SERVER and nz.Tools.ToolData[self.ToolMode] then
		nz.Tools.ToolData[self.ToolMode].PrimaryAttack(self, self.Owner, trace, self.Owner.NZToolData)
	end
end


--[[---------------------------------------------------------
	SecondaryAttack - Reset everything to how it was
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

	if SERVER and nz.Tools.ToolData[self.ToolMode] then
		nz.Tools.ToolData[self.ToolMode].SecondaryAttack(self, self.Owner, trace, self.Owner.NZToolData)
	end
	
end

local reload_cd = CurTime()

function SWEP:Reload()
	if reload_cd < CurTime() then
		local tr = util.GetPlayerTrace( self.Owner )
		tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
		local trace = util.TraceLine( tr )
		if (!trace.Hit) then return end
		
		self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

		if SERVER and nz.Tools.ToolData[self.ToolMode] then
			nz.Tools.ToolData[self.ToolMode].Reload(self, self.Owner, trace, self.Owner.NZToolData)
		end
		
		reload_cd = CurTime() + 0.3
	end
end

function SWEP:Deploy()
	if SERVER and nz.Tools.ToolData[self.ToolMode] then
		nz.Tools.ToolData[self.ToolMode].OnEquip(self, self.Owner, self.Owner.NZToolData)
	end
end

function SWEP:Holster()
	if SERVER and nz.Tools.ToolData[self.ToolMode] then
		nz.Tools.ToolData[self.ToolMode].OnHolster(self, self.Owner, self.Owner.NZToolData)
	end
	return true
end