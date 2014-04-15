AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "zed_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetColor(255, 0, 0, 255) 
	self:DrawShadow( false )
end

if CLIENT then
	function ENT:Draw()
		if ROUND_STATE == ROUND_CREATE then
			self:DrawModel()
		end
	end
	hook.Add( "PreDrawHalos", "zed_spawns_halos", function()
		if ROUND_STATE == ROUND_CREATE then
			halo.Add( ents.FindByClass( "zed_spawns" ), Color( 255, 0, 0 ), 0, 0, 0.1, 0, 1 )
		end
	end )
end
