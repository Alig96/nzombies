SWEP.PrintName	= "Prop Modifier Tool"	
SWEP.Author		= "Alig96"		
SWEP.Slot		= 2	
SWEP.SlotPos	= 10
SWEP.Base 		= "nz_tool_base"

if SERVER then
	function SWEP:OnPrimaryAttack( trace )
		if trace.Entity:GetClass() == "prop_buys" then
			trace.Entity:SetAngles(Angle(0,0,0))
		end
	end

	function SWEP:OnSecondaryAttack( trace )
		if trace.Entity:GetClass() == "prop_buys" then
			trace.Entity:Remove()
		end
	end
	function SWEP:OnReload( trace )
		if trace.Entity:GetClass() == "prop_buys" then
			trace.Entity:SetAngles(trace.Entity:GetAngles()+Angle(0,90,0))
		end
	end
end