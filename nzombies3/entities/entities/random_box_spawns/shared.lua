AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "random_box_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
	self:SetModel( "models/hoff/props/mysterybox/box.mdl" )
	self:SetColor( 255, 255, 255 )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:DrawShadow( false )
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end