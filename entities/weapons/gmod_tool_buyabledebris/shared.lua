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
SWEP.Rot = 0

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

SWEP.BlockModel = "models/props_c17/fence03a.mdl"

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
	if SERVER then
		local tr	= util.GetPlayerTrace( self.Owner )
		local pos = self.Owner:GetShootPos()
		local ang = self.Owner:GetAimVector()
		tr.start = pos
		tr.endpos = pos+(ang*200)
		local trace	= util.TraceLine( tr )
		
		if self.Rot then
			i = 0
		else
			i = 1
		end
		
		local vec = trace.HitPos + trace.HitNormal * 8
		self.Owner:PrintMessage(HUD_PRINTTALK, "You must save & reload the map config before applying a door tool flag to this entity. Otherwise the flag will be lost. It is recommended to place all the debris first, save, then reload and apply the door flags.")
		BuyableBlockSpawn(vec, trace.HitNormal:Angle() - Angle( 90, 90*i, 0 ), self.BlockModel)
		self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

	end
end


--[[---------------------------------------------------------
	SecondaryAttack - Reset everything to how it was
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	local tr = util.GetPlayerTrace( self.Owner )
	--tr.mask = bit.bor( CONTENTS_SOLID, CONTENTS_MOVEABLE, CONTENTS_MONSTER, CONTENTS_WINDOW, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_AUX )
	local trace = util.TraceLine( tr )
	if (!trace.Hit) then return end
	
	self:DoShootEffect( trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone, IsFirstTimePredicted() )

	if trace.Entity:GetClass() == "wall_block_buy" and SERVER then
		if table.HasValue(bnpvbWJpZXM.Rounds.BuyableBlocks, trace.Entity) then
			table.remove(bnpvbWJpZXM.Rounds.BuyableBlocks, table.KeyFromValue(bnpvbWJpZXM.Rounds.BuyableBlocks, trace.Entity))
			trace.Entity:Remove()
		end
	end
end

function SWEP:MakeGhostEntity( model, pos, angle )

	util.PrecacheModel( model )

	-- We do ghosting serverside in single player
	-- It's done clientside in multiplayer
	if (SERVER && !game.SinglePlayer()) then return end
	if (CLIENT && game.SinglePlayer()) then return end

	-- Release the old ghost entity
	self:ReleaseGhostEntity()

	-- Don't allow ragdolls/effects to be ghosts
	if (!util.IsValidProp( model )) then return end

	if ( CLIENT ) then
		self.GhostEntity = ents.CreateClientProp( model )
	else
		self.GhostEntity = ents.Create( "prop_physics" )
	end

	-- If there's too many entities we might not spawn..
	if (!self.GhostEntity:IsValid()) then
		self.GhostEntity = nil
		return
	end

	self.GhostEntity:SetModel( model )
	self.GhostEntity:SetPos( pos )
	self.GhostEntity:SetAngles( angle )
	self.GhostEntity:Spawn()

	self.GhostEntity:SetSolid( SOLID_VPHYSICS );
	self.GhostEntity:SetMoveType( MOVETYPE_NONE )
	self.GhostEntity:SetNotSolid( true );
	self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.GhostEntity:SetColor( Color( 255, 255, 255, 150 ) )

end

--[[---------------------------------------------------------
   Releases up the ghost entity
-----------------------------------------------------------]]
function SWEP:ReleaseGhostEntity()

	if ( self.GhostEntity ) then
		if (!self.GhostEntity:IsValid()) then self.GhostEntity = nil return end
		self.GhostEntity:Remove()
		self.GhostEntity = nil
	end

	if ( self.GhostEntities ) then

		for k,v in pairs( self.GhostEntities ) do
			if ( v:IsValid() ) then v:Remove() end
			self.GhostEntities[k] = nil
		end

		self.GhostEntities = nil
	end

	if ( self.GhostOffset ) then

		for k,v in pairs( self.GhostOffset ) do
			self.GhostOffset[k] = nil
		end

	end

end

function SWEP:Think()

	if ( !IsValid( self.GhostEntity ) ) then
		self:MakeGhostEntity( self.BlockModel, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )

end

function SWEP:UpdateGhostEntity( ent, player )

	if ( !IsValid( ent ) ) then return end

	local tr	= util.GetPlayerTrace( player )
	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:GetAimVector()
	tr.start = pos
	tr.endpos = pos+(ang*200)
	local trace	= util.TraceLine( tr )
	--if ( !trace.Hit ) then return end

	if ( trace.Entity:IsPlayer() ) then

		ent:SetNoDraw( true )
		return

	end
	local vec = trace.HitPos + trace.HitNormal * 8
	
	ent:SetPos( vec )
	if self.Rot then
		i = 0
	else
		i = 1
	end
	ent:SetAngles( trace.HitNormal:Angle() - Angle( 90, 90*i, 0 )  )

	ent:SetNoDraw( false )

end

function SWEP:Reload()
	self.Rot = !self.Rot
end