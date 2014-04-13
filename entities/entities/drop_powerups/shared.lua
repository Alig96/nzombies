AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "drop_powerups"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

	validPowerups = {}
	
	validPowerups["dp"] = {"models/props_c17/gravestone003a.mdl", function(self)
		if !bnpvbWJpZXM.Rounds.Effects["dp"] then
			bnpvbWJpZXM.Rounds.Effects["dp"] = true
			PrintMessage( HUD_PRINTTALK, "Double Points!" )
			timer.Simple(30, function() 
				bnpvbWJpZXM.Rounds.Effects["dp"] = false 		
				PrintMessage( HUD_PRINTTALK, "Double Points has ended!" )
			end)
		end
		timer.Destroy(self:EntIndex().."_deathtimer")
		self:Remove()
	end}
	
	validPowerups["ammobuff"] = {"models/Items/BoxSRounds.mdl", function(self)
		if !self.Used then
			self.Used = true
			for k,v in pairs(player.GetAll()) do
				for k2,v2 in pairs(v:GetWeapons()) do
					v:GiveAmmo( bnpvbWJpZXM.Config.BaseStartingAmmoAmount, v2.Primary.Ammo)
				end
			end
			PrintMessage( HUD_PRINTTALK, "Ammo Buff!" )
			timer.Destroy(self:EntIndex().."_deathtimer")
			self:Remove()
		end
	end}

	function ENT:Initialize()
	 
		
		self:SetModelScale( 0.5, 0 )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_VPHYSICS )
		self.Used = false
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
	function ENT:Touch( hitEnt )
		if ( hitEnt:IsValid() and hitEnt:IsPlayer() ) then
			if !self.Used then
				validPowerups[self.Buff][2](self)
			end
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
		halo.Add( ents.FindByClass( "drop_powerups" ), Color( 0, 255, 0 ), 2, 2, 2 )
	end )
end