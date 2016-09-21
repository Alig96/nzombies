AddCSLuaFile( )

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "nz_button"
ENT.Model = "models/maxofs2d/button_04.mdl"

DEFINE_BASECLASS("nz_activatable")

function ENT:SetupDataTables()

	BaseClass.SetupDataTables( self )

	--the name of the linked ents
	self:NetworkVar( "String", 1, "LinkedEntName1", {KeyName = "linked_ent_name1", Edit = {order = 9, type = "Generic"}} )
	self:NetworkVar( "String", 2, "LinkedEntName2", {KeyName = "linked_ent_name2", Edit = {order = 10, type = "Generic"}} )
	self:NetworkVar( "String", 3, "LinkedEntName3", {KeyName = "linked_ent_name3", Edit = {order = 11, type = "Generic"}} )

	if SERVER then
		self:NetworkVarNotify( "LinkedEntName1", self.OnLinkedEntChange )
		self:NetworkVarNotify( "LinkedEntName2", self.OnLinkedEntChange )
		self:NetworkVarNotify( "LinkedEntName3", self.OnLinkedEntChange )
	end

end

function ENT:OnLinkedEntChange(name, old, new)
	self.tLinkedEnts = {}
	table.insert(self.tLinkedEnts, ents.FindByName(self:GetLinkedEntName1()))
	table.insert(self.tLinkedEnts, ents.FindByName(self:GetLinkedEntName2()))
	table.insert(self.tLinkedEnts, ents.FindByName(self:GetLinkedEntName3()))
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
end

function ENT:Activation(caller)
	BaseClass.Activation(self)

	for _, lEnt in pairs(self.tLinkedEnts) do
		if isstring(lEnt) then
			nzDoors.OpenLinkedDoors(lEnt, activator)
		elseif IsValid(lEnt) and !lEnt:IsPlayer() then
			lEnt:Activation(caller, self:GetCooldown(), self:GetDuration())
		end
	end

	timer.Create("button.timer." .. self:EntIndex(), self:GetDuration(), 1, function() self:Deactivation() end)
end

function ENT:Deactivation()
	BaseClass.Deactivation(self)

	timer.Create("button.timer." .. self:EntIndex(), self:GetCooldown(), 1, function() self:Ready() end)
end

function ENT:Ready()
	BaseClass.Ready(self)
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end
