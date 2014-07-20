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
	self:SetModel(self.model or "models/perkacola/jug.mdl")
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE)
	
	phy = self:GetPhysicsObject();
	if phy and phy:IsValid() then
		phy:EnableGravity(false);
		phy:EnableMotion(false);
	end
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