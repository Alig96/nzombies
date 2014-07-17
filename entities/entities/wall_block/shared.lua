AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "wall_block"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:Initialize()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self:SetColor(Color(255, 255, 255, 0))
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.CurrentState == ROUND_CREATE then
			self:SetColor(Color(255, 255, 255, 255))
			self:DrawModel()
		end
	end
end