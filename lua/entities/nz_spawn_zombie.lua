AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "nz_spawn_zombie"

AccessorFunc(ENT, "iSpawnWeight", "SpawnWeight", FORCE_NUMBER)
AccessorFunc(ENT, "sZombieClass", "ZombieClass", FORCE_STRING)
AccessorFunc(ENT, "iZombiesToSpawn", "ZombiesToSpawn", FORCE_NUMBER)

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Link" )

end

function ENT:Initialize()
	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(0, 255, 0))
	self:DrawShadow( false )
	self:SetSpawnWeight(0)
	self:SetZombiesToSpawn(0)
end

function ENT:CheckIfSuitable()
	local tr = util.TraceHull( {
		start = self:GetPos(),
		endpos = self:GetPos(),
		filter = self,
		mins = Vector( -20, -20, -0 ),
		maxs = Vector( 20, 20, 70 ),
		mask = MASK_NPCSOLID
	} )

	return !tr.HitNonWorld
end

if CLIENT then
	function ENT:Draw()
		if Round:InState( ROUND_CREATE ) then
			self:DrawModel()
		end
	end
end
