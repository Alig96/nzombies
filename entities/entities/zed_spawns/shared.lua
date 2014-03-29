AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "zed_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
	 
		self:SetModel( "models/player/odessa.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetColor(255, 0, 0, 255) 
		self:DrawShadow( false )
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
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