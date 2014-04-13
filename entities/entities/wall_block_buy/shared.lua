AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "wall_block_buy"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Locked" )
	
end

function ENT:Initialize()
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self.Boundone,self.Boundtwo = self:GetCollisionBounds()
		self:SetCustomCollisionCheck( true )
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
		self.Collidegroup = self:GetCollisionGroup()
	end
	self:BlockLock()
end

function ENT:BlockUnlock()
	self.Locked = false
	--self:SetNoDraw( true )
	if SERVER then
		self:SetCollisionBounds( Vector(-4, -4, 0), Vector(4, 4, 64) )
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	end
	self:SetSolid( SOLID_NONE )
	self:SetLocked(false)
end

function ENT:BlockLock()
	self.Locked = true
	--self:SetNoDraw( false )
	if SERVER then
		self:SetCollisionBounds( self.Boundone, self.Boundtwo )
		self:SetCollisionGroup(self.Collidegroup)
	end
	self:SetSolid( SOLID_VPHYSICS )
	self:SetLocked(true)
end

if CLIENT then
	function ENT:Draw()
		if ROUND_STATE == ROUND_CREATE then 
			self:DrawModel()
		elseif (ROUND_STATE == ROUND_PROG or ROUND_STATE == ROUND_PREP) then
			if self:GetLocked() then
				self:DrawModel()
			end
		end
	end
	hook.Add( "PreDrawHalos", "wall_block_buy_halos", function()
		if ROUND_STATE == ROUND_CREATE then
			halo.Add( ents.FindByClass( "wall_block_buy" ), Color( 255, 230, 255 ), 0, 0, 0.1 )
		end
	end )
end
