SWEP.PrintName	= "Random Box Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 5	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.BoxSpawn(trace.HitPos,Angle(0,0,0))
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "random_box_spawns" then
			trace.Entity:Remove()
		end
	end
	
	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "random_box_spawns" then
			trace.Entity:SetAngles(trace.Entity:GetAngles()+Angle(0,90,0))
		end
	end
	
end