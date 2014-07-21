AddCSLuaFile()

ENT.Type			= "anim"

ENT.PrintName		= "perk_machine"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "PerkID")
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	if (SERVER) then
		self:SetUseType(SIMPLE_USE)
	end
	/*
	local phys = self:GetPhysicsObject();
	if phys and phys:IsValid() then
		phys:EnableGravity(false);
		phys:EnableMotion(false);
	end*/
	self:DrawShadow(false)
end

function ENT:Use(activator, caller)
	if (table.Count(ents.FindByClass("button_elec"))==0||nz.Rounds.Elec) then
		nz.Perks.Activate(self:GetPerkID(), self, activator)
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end