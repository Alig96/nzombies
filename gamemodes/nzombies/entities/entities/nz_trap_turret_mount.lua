AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Turret mounting"
ENT.Category = "Brainz"
ENT.Author = "Lolle"

function ENT:Initialize()
	self:SetModel( "models/props_trainstation/trainstation_ornament001.mdl" )
	self:SetModelScale(0.6)

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
end
