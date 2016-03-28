//

function nz.Elec.Functions.Activate(nochat)

	nz.Elec.Data.Active = true
	nz.Elec.Functions.SendSync()
	
	-- Open all doors with no price and electricity requirement
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() or v:IsBuyableProp() then
			if v.price == 0 and v.elec == 1 then 
				Doors:OpenDoor( v )
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
	if prevs[1] != nil then
		prevs[1]:SetSwitch(false)
	end
	
	nz.Elec.Functions.SendSync()
	
end