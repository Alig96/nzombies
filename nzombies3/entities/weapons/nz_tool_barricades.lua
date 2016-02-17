SWEP.PrintName	= "Barricade Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 1	
SWEP.SlotPos	= 9
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		nz.Mapping.Functions.BreakEntry(trace.HitPos,Angle(0,0,0))
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "breakable_entry" then
			trace.Entity:Remove()
		end
	end
end