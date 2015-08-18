SWEP.PrintName	= "Invisible Block Spawn Placer Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 4	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.BlockSpawn(trace.HitPos,Angle(90,(trace.HitPos - self.Owner:GetPos()):Angle()[2] + 90,90), "models/hunter/plates/plate2x2.mdl")
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "wall_block" then
			trace.Entity:Remove()
		end
	end
end