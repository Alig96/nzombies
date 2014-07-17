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
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self.Boundone,self.Boundtwo = self:GetCollisionBounds()
	end
	self:BlockLock()
end

function ENT:BlockUnlock()
	self.Locked = false
	--self:SetNoDraw( true )
	if SERVER then
		self:SetCollisionBounds( Vector(-4, -4, 0), Vector(4, 4, 64) )
	end
	self:SetSolid( SOLID_NONE )
	self:SetLocked(false)
end

function ENT:BlockLock()
	self.Locked = true
	--self:SetNoDraw( false )
	if SERVER then
		self:SetCollisionBounds( self.Boundone, self.Boundtwo )
	end
	self:SetSolid( SOLID_VPHYSICS )
	self:SetLocked(true)
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.CurrentState == ROUND_CREATE then 
			self:DrawModel()
		elseif (nz.Rounds.CurrentState == ROUND_PROG or nz.Rounds.CurrentState == ROUND_PREP) then
			if self:GetLocked() then
				self:DrawModel()
			end
		end
	end
end
