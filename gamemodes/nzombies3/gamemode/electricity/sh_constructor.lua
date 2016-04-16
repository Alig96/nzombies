-- Main Tables
Elec = Elec or {}

-- Variables
Elec.Active = false

function Elec.IsOn()
	return Elec.Active
end

IsElec = Elec.IsOn
