AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "zed_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Link" )
	
end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(255, 0, 0, 255) 
	self:DrawShadow( false )
end

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end
