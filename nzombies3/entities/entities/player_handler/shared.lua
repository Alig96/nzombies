AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "player_handler"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Weapons			= {}

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "StartWep" )
	self:NetworkVar( "Int", 0, "StartPoints" )
	self:NetworkVar( "Int", 1, "NumWeps" )
	self:NetworkVar( "String", 1, "EEURL" )
	
end

function ENT:Initialize()

	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(0, 255, 255, 255)) 
	self:DrawShadow( false )
	
end

function ENT:SetData(points, weapon, numweps, eeurl)

	self:SetStartPoints(points)
	self:SetStartWep(weapon)
	self:SetNumWeps(numweps)
	self:SetEEURL(eeurl)

end

hook.Add("nz.EE.EasterEgg", "PlayEESong", function()
	net.Start("EasterEggSong")
	net.Broadcast()
end)

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
	net.Receive("EasterEggSong", function()
		if self:GetEEURL() != "" and string.Left(self:GetEEURL(), 4) == "http" then
			sound.PlayURL( self:GetEEURL(), "", function() end)
		end
	end)
end
