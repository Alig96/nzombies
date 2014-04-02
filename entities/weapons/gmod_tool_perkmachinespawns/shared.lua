-- Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact			= ""
SWEP.Purpose			= ""
SWEP.Instructions		= ""

SWEP.ViewModel			= "models/weapons/c_toolgun.mdl"
SWEP.WorldModel			= "models/weapons/w_toolgun.mdl"
SWEP.AnimPrefix			= "python"

SWEP.UseHands			= true
SWEP.PerkID = "jug"

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

SWEP.SwitchModel = PerksColas[SWEP.PerkID].Model

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
		local trace	= util.TraceLine( tr )
		if ( !trace.Hit ) then return end
		
		local vec = trace.HitPos + trace.HitNormal * -54
		
		PerkMachineSpawn(vec, trace.HitNormal:Angle(), PerksColas[self.PerkID])
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

	if trace.Entity:GetClass() == "perk_machine" and SERVER then
		//search for the entity spawn
		for k,v in pairs(bnpvbWJpZXM.Rounds.PerkMachines) do
			if v[4] == trace.Entity then
				table.remove(bnpvbWJpZXM.Rounds.PerkMachines, k)
				break
			end
		end
		trace.Entity:Remove()
	end
end

function SWEP:Reload()
	if CLIENT then
		if derm == nil or !derm:IsValid() then 
			local w,h = 110,55
			local x,y = ScrW()/2 - w/2, ScrH()/2 - h/2
			derm = vgui.Create( "DFrame" ) -- Creates the frame itself
			derm:SetPos( x,y ) -- Position on the players screen
			derm:SetSize( w,h ) -- Size of the frame
			derm:SetTitle( "" ) -- Title of the frame
			derm:SetVisible( true )
			derm:SetDraggable( false ) -- Draggable by mouse?
			derm:ShowCloseButton( true ) -- Show the close button?
			derm:MakePopup() -- Show the frame
			
			local choices = vgui.Create( "DComboBox", derm )
			choices:SetPos( 5, 30 )
			choices:SetSize( 100, 20 )
			for k,v in pairs(PerksColas) do
				choices:AddChoice( v.ID )
			end
			choices.OnSelect = function( panel, index, value, data )
				self.SwitchModel = PerksColas[value].Model
				self:ReleaseGhostEntity()
				net.Start( "tool_perk_net" )
					net.WriteString( value )
				net.SendToServer()
				derm:Close()
			end
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
		self:MakeGhostEntity( self.SwitchModel, Vector( 0, 0, 0 ), Angle(270,180,90) )
	end

	self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )

end

function SWEP:UpdateGhostEntity( ent, player )

	if ( !IsValid( ent ) ) then return end

	local tr	= util.GetPlayerTrace( player )
	local pos = self.Owner:GetShootPos()
	local trace	= util.TraceLine( tr )
	if ( !trace.Hit ) then return end

	if ( trace.Entity:IsPlayer() ) then

		ent:SetNoDraw( true )
		return

	end
	local vec = trace.HitPos + trace.HitNormal * -54
	
	ent:SetPos( vec )
	
	ent:SetAngles( trace.HitNormal:Angle() )

	ent:SetNoDraw( false )

end