SWEP.PrintName	= "Zombie Spawn Placer Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 1	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.ZedSpawn(trace.HitPos)
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "zed_spawns" then
			trace.Entity:Remove()
		end
	end
	
	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "zed_spawns" then
			nz.Interfaces.Functions.SendInterface("ZombLink", {ent = trace.Entity, link = trace.Entity.link})
		end
	end
end