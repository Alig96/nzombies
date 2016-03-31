//

function nz.Elec.Functions.Activate(nochat)

	nz.Elec.Data.Active = true
	nz.Elec.Functions.SendSync()
	
	-- Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsBuyableEntity() then
			local data = v:GetDoorData()
			if data then
				if tonumber(data.price) == 0 and tobool(data.elec) == true then
					Doors:OpenDoor( v )
				end
			end
		end
	end
	
	-- Turn on all perk machines
	for k,v in pairs(ents.FindByClass("perk_machine")) do
		v:TurnOn()
	end
	
	-- Inform players
	if !nochat then
		PrintMessage(HUD_PRINTTALK, "[NZ] Electricity is on!")
	end
	
end

function nz.Elec.Functions.Reset()
	
	nz.Elec.Data.Active = false
	-- Reset the button aswell
	local prevs = ents.FindByClass("power_box")
	for k,v in pairs(prevs) do
		v:SetSwitch(false)
	end
	
	nz.Elec.Functions.SendSync()
	
end