AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "breakable_entry"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""
//models/props_interiors/elevatorshaft_door01a.mdl
//models/props_debris/wood_board02a.mdl
function ENT:Initialize()

	self:SetModel("models/props_c17/fence01b.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetHealth(0)
	self:SetCustomCollisionCheck(true)
	self.NextPlank = CurTime()

	self.Planks = {}

	if SERVER then
		self:ResetPlanks()
	end
end

function ENT:AddPlank()
	self:SpawnPlank()
	self:SetHealth(self:Health()+10)
	print("Health: " .. self:Health())
end

function ENT:RemovePlank()

	local plank = table.Random(self.Planks)
	if plank != nil then
		table.RemoveByValue(self.Planks, plank)
		self:SetHealth(self:Health()-10)

		//Drop off
		plank:SetParent(nil)
		plank:PhysicsInit(SOLID_VPHYSICS)
		local entphys = plank:GetPhysicsObject()
		if entphys:IsValid() then
			 entphys:EnableGravity(true)
			 entphys:Wake()
		end
		plank:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
		//Remove
		timer.Simple(2, function() plank:Remove() end)
	end
end

function ENT:ResetPlanks()
	for i=1, nz.Config.MaxPlanks do
		self:RemovePlank()
	end
	for i=1, nz.Config.MaxPlanks do
		self:AddPlank()
	end
end

function ENT:Use( activator, caller )
	if CurTime() > self.NextPlank then
		if self:Health() < nz.Config.MaxPlanks * 10 then
			self:AddPlank()
                  activator:GivePoints(10)
			self.NextPlank = CurTime() + 1
		end
	end
end

function ENT:SpawnPlank()
	//Spawn
	local angs = {-60,-70,60,70}
	local plank = ents.Create("breakable_entry_plank")
	plank:SetPos( self:GetPos()+Vector(0,0, math.random( -45, 45 )) )
	plank:SetAngles( Angle(0,self:GetAngles().y, table.Random(angs)) )
	plank:Spawn()
	plank:SetParent(self)
	plank:SetCollisionGroup( COLLISION_GROUP_DEBRIS )
	table.insert(self.Planks, plank)
end

hook.Add("ShouldCollide", "zCollisionHook", function(ent1, ent2)
	if ent1:GetClass() == "breakable_entry" and  ent2:GetClass() == "nut_zombie" then
		if ent1:IsValid() and ent1:Health() == 0 then
			ent1:SetSolid(SOLID_NONE)
			timer.Simple(0.1, function() if ent1:IsValid() then ent1:SetSolid(SOLID_VPHYSICS) end end)
		end
		return false
	end
	if ent2:GetClass() == "breakable_entry" and ent1:GetClass() == "nut_zombie" then
		if ent2:IsValid() and ent2:Health() == 0 then
			ent2:SetSolid(SOLID_NONE)
			timer.Simple(0.1, function() if ent2:IsValid() then ent2:SetSolid(SOLID_VPHYSICS) end end)
		end
		return false
	end
end)

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
end
