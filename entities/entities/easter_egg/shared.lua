ENT.Type = "anim"
 
ENT.PrintName		= "easter_egg"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


AddCSLuaFile()



function ENT:Initialize()

	self:SetModel( "models/props_lab/huladoll.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Used = false
	if SERVER then
		self:SetUseType(SIMPLE_USE)
	end
end
	 
function ENT:Use( activator, caller )
	if !self.Used and (nz.Rounds.CurrentState == ROUND_PROG or nz.Rounds.CurrentState == ROUND_PREP) then
		self.Used = true
		self:EmitSound("WeaponDissolve.Dissolve", 100, 100)
		nz.Rounds.EggCount = nz.Rounds.EggCount + 1
		if nz.Rounds.EggCount == #ents.FindByClass("easter_egg") then
			hook.Call( "nzombies_ee_active" )
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end
