-- Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
SWEP.AnimPrefix			= "python"

SWEP.UseHands			= true

-- Be nice, precache the models
util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )

-- Todo, make/find a better sound.
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
	
	-- We create these here. The problem is that these are meant to be constant values.
	-- in the toolmode they're not because some tools can be automatic while some tools aren't.
	-- Since this is a global table it's shared between all instances of the gun.
	-- By creating new tables here we're making it so each tool has its own instance of the table
	-- So changing it won't affect the other tools.
	
	self.Primary = 
	{
		-- Note: Switched this back to -1.. lets not try to hack our way around shit that needs fixing. -gn
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
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 	-- View model animation
	
	-- There's a bug with the model that's causing a muzzle to 
	-- appear on everyone's screen when we fire this animation. 
	self.Owner:SetAnimation( PLAYER_ATTACK1 )			-- 3rd Person Animation
	
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
	Trace a line then send the result to a mode function
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	local tr = util.GetPlayerTrace( self.Owner )
	tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end

	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )
	if CLIENT then
		if trace.HitWorld then
			if derm == nil or !derm:IsValid() then 
				derm = Derma_StringRequest("Entity", "What weapon entity would you like to place here?", "weapon_sim_colt1911", function(text) Derma_StringRequest("Price", "How many points should it cost?", "500", 
					function(text2) 
						if text != nil or text2 != nil then
							local validvalues = weapons.GetList()
							PrintTable(validvalues)
							for k,v in pairs( validvalues ) do
								if v.ClassName == text then
									net.Start( "tool_wepbuy_net" )
										net.WriteVector( trace.HitPos + trace.HitNormal * 8 )
										net.WriteString( text )
										net.WriteString( text2 )
										net.WriteAngle( self.Owner:GetForward():Angle()+Angle(0,180,0) )
									net.SendToServer()
									return
								end
							end
							print("Invalid gun")
						end
					end)
			   end)
		   end
		end
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
	if trace.Entity:GetClass() == "wall_buy" and SERVER then
		trace.Entity:Remove()
	end
end