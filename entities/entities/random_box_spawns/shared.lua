AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "random_box_spawns"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
	 
		self:SetModel( "models/toybox.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetColor( 255, 255, 255 )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
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
end