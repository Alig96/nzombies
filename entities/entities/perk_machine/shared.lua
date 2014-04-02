AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "perk_machine"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "PerkID" )
	
end

function ENT:Initialize()
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		if SERVER then
			self:SetUseType( SIMPLE_USE )
		end
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
		end
end

function ENT:Use( activator, caller )
	if activator:CanAfford(tonumber(self.Price)) and bnpvbWJpZXM.Rounds.Elec then
		if self.UseFunction(activator) == true then
			activator:TakePoints(tonumber(self.Price))
		end
	end
end

function ENT:SetTheMachine( data )
	self.PerkName = data.Name
	self:SetPerkID(data.ID)
	self:SetModel( data.Model )
	self.Price = data.Price
	self.UseFunction = data.Function
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end