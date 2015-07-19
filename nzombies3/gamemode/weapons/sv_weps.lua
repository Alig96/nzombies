//

function nz.Weps.Functions.IsFAS2( wep )
	if wep.Category == "FA:S 2 Weapons" then
		return true
	end

	return false
end

function nz.Weps.Functions.ApplySleight( ply, wep )
	if nz.Weps.Functions.IsFAS2( wep ) and wep.sleight != true then
		print("Applying Sleight to: " .. wep.ClassName)
		local data = {}
		//Normal
		data["ReloadTime"] = true
		data["ReloadTime_Nomen"] = true
		data["ReloadTime_Empty"] = true
		data["ReloadTime_Empty_Nomen"] = true
		//BiPod
		data["ReloadTime_Bipod"] = true
		data["ReloadTime_Bipod_Nomen"] = true
		data["ReloadTime_Bipod_Empty"] = true
		data["ReloadTime_Bipod_Empty_Nomen"] = true
		for k,v in pairs(data) do
			if wep[k] != nil then
				local val = wep[k] / 2
				wep[k] = val
				data[k] = val
			else
				data[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["sleight"] = true
		data["sleight"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.ApplyDTap( ply, wep )
	if nz.Weps.Functions.IsFAS2( wep ) and wep.dtap != true then
		print("Applying Dtap to: " .. wep.ClassName)
		local data = {}
		//Normal
		data["FireDelay"] = true
		for k,v in pairs(data) do
			if wep[k] != nil then
				local val = wep[k] / 2
				wep[k] = val
				data[k] = val
			else
				data[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["dtap"] = true
		data["dtap"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.ApplyPaP( ply, wep )
	if wep.pap != true then
		print("Applying PaP to: " .. wep.ClassName)
		ply:PrintMessage( HUD_PRINTTALK, "Damage: " .. ply:GetActiveWeapon().Damage .. " > ".. ply:GetActiveWeapon().Damage * 2)
		local data = {}
		//Normal
		data["Damage"] = true
		for k,v in pairs(data) do
			if wep[k] != nil then
				local val = wep[k] * 2
				wep[k] = val
				data[k] = val
			else
				data[k] = nil
			end
		end
		//Attach the weapon to the data
		data["wep"] = wep
		wep["pap"] = true
		data["pap"] = true
		nz.Weps.Functions.SendSync( ply, data )
	end
end

function nz.Weps.Functions.OnWepCreated( ent )
	if ent:IsWeapon() and (nz.Rounds.Data.CurrentState == ROUND_PREP or nz.Rounds.Data.CurrentState == ROUND_PROG) then
		timer.Simple(1, function()
			local ply = ent.Owner
			if ply:HasPerk("sleight") then
				nz.Weps.Functions.ApplySleight( ply, ent )
			end
			if ply:HasPerk("dtap") then
				nz.Weps.Functions.ApplyDTap( ply, ent )
			end
		end)
	end
end

hook.Add("OnEntityCreated", "nz.Weps.OnEntityCreated", nz.Weps.Functions.OnWepCreated)
