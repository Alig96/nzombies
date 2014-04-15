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
		if ROUND_STATE == ROUND_CREATE then
			self:SetColor(Color(255, 255, 255, 255))
			self:DrawModel()
		end
	end
	hook.Add( "PreDrawHalos", "wall_block_halos", function()
		if ROUND_STATE == ROUND_CREATE then
			halo.Add( ents.FindByClass( "wall_block" ), Color( 0, 255, 255 ), 0, 0, 0.1 )
		end
	end )
end
