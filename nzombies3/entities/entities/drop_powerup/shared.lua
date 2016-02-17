AddCSLuaFile()

ENT.Type = "anim"
 
ENT.PrintName		= "drop_powerups"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "PowerUp" )
	
end

function ENT:Initialize()

	//self:SetPowerUp("dp")
	self:SetModelScale(nz.PowerUps.Functions.Get(self:GetPowerUp()).scale, 0)
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self.DeathTimer = 30
	if SERVER then
		self:SetUseType(SIMPLE_USE)
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			--phys:EnableCollisions(false)
		end
	end
	timer.Create( self:EntIndex().."_deathtimer", 0.1, 300, function()
		if self:IsValid() then
			self.DeathTimer = self.DeathTimer - 0.1
			if self.DeathTimer <= 0 then
				timer.Destroy(self:EntIndex().."_deathtimer")
				if SERVER then
					self:Remove()
				end
			end				
		end
	end)
end

if SERVER then
	function ENT:StartTouch(hitEnt)
		if (hitEnt:IsValid() and hitEnt:IsPlayer()) then
			nz.PowerUps.Functions.Activate(self:GetPowerUp(), hitEnt)
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:Draw()
	
	local modi,modf = math.modf(self.DeathTimer)
		if modi > 10 then
			self:DrawModel()
		elseif modi > 5 and modi <= 10 then
			if modi % 2 == 0  then
				self:DrawModel()
			end
		else
			if math.Round(modf*10) % 2 == 0 then
				self:DrawModel()
			end
		end
	end
	local num = 0
	function ENT:Think()
		local var = math.sin( CurTime() * 3 )
		self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z +1*var))
	end
	hook.Add( "PreDrawHalos", "drop_powerups_halos", function()
		halo.Add( ents.FindByClass( "drop_powerup" ), Color( 0, 255, 0 ), 2, 2, 2 )
	end )
end