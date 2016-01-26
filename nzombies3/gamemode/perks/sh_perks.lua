//

function nz.Perks.Functions.NewPerk(id, data)
	if SERVER then
		//Sanitise any client data.
	else
		data.Func = nil
	end
	nz.Perks.Data[id] = data
end

function nz.Perks.Functions.Get(id)
	return nz.Perks.Data[id]
end

function nz.Perks.Functions.GetList()
	local tbl = {}

	for k,v in pairs(nz.Perks.Data) do
		tbl[k] = v.name
	end

	return tbl
end

nz.Perks.Functions.NewPerk("jugg", {
	name = "Juggernog",
	off_model = "models/alig96/perks/jugg/jugg_off.mdl",
	on_model = "models/alig96/perks/jugg/jugg_on.mdl",
	price = 2500,
	func = function(self, ply, machine)
			ply:SetMaxHealth(250)
			ply:SetHealth(250)
			ply:Give("zombies_perk_juggernog_nz")
			return true
	end,
})

nz.Perks.Functions.NewPerk("dtap", {
	name = "Double Tap",
	off_model = "models/alig96/perks/doubletap/doubletap_off.mdl",
	on_model = "models/alig96/perks/doubletap/doubletap_on.mdl",
	price = 2000,
	func = function(self, ply, machine)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if nz.Weps.Functions.IsFAS2( v ) then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			local str = ""
			for k,v in pairs(tbl) do
				nz.Weps.Functions.ApplyDTap( ply, v )
				str = str .. v.ClassName .. ", "
			end
			--ply:PrintMessage( HUD_PRINTTALK, "Double Tap Applied to: " .. str)
			--[[ply:Give("zombies_perk_juggernog_nz")
			return true
		else
			ply:PrintMessage( HUD_PRINTTALK, "You don't have a weapon that is compatible with this perk. (Requires a FAS2 weapon)")
			return true]]
		end
		ply:Give("zombies_perk_juggernog_nz")
		return true
	end,
})

nz.Perks.Functions.NewPerk("revive", {
	name = "Quick Revive",
	off_model = "models/alig96/perks/revive/revive_off.mdl",
	on_model = "models/alig96/perks/revive/revive_on.mdl",
	price = 1500,
	func = function(self, ply, machine)
			print(self)
			ply:PrintMessage( HUD_PRINTTALK, "You've got Quick Revive!")
			ply:Give("zombies_perk_juggernog_nz")
			return true
	end,
})

nz.Perks.Functions.NewPerk("speed", {
	name = "Speed Cola",
	off_model = "models/alig96/perks/sleight/sleight_off.mdl",
	on_model = "models/alig96/perks/sleight/sleight_on.mdl",
	price = 3000,
	func = function(self, ply, machine)
		local tbl = {}
		for k,v in pairs(ply:GetWeapons()) do
			if nz.Weps.Functions.IsFAS2( v ) then
				table.insert(tbl, v)
			end
		end
		if tbl[1] != nil then
			local str = ""
			for k,v in pairs(tbl) do
				nz.Weps.Functions.ApplySleight( ply, v )
				str = str .. v.ClassName .. ", "
			end
			--ply:PrintMessage( HUD_PRINTTALK, "Speed Cola Applied to: " .. str)
		--[[else
			ply:PrintMessage( HUD_PRINTTALK, "You don't have a weapon that is compatible with this perk. (Requires a FAS2 weapon)")
			return false]]
		end
		ply:Give("zombies_perk_juggernog_nz")
		return true
	end,
})

nz.Perks.Functions.NewPerk("pap", {
	name = "Pack-a-Punch",
	off_model = "models/alig96/perks/packapunch/packapunch.mdl", //Find a new model.
	on_model = "models/alig96/perks/packapunch/packapunch.mdl",
	price = 5000,
	func = function(self, ply, machine)
		local wep = ply:GetActiveWeapon()
		if wep.pap != true and !machine:GetBeingUsed() then
			machine:SetBeingUsed(true)
			machine:EmitSound("nz/machines/pap_up.wav")
			local class = wep:GetClass()
			
			wep:Remove()
			local wep = ents.Create("pap_weapon_fly")
			wep:SetPos(machine:GetPos() + machine:GetAngles():Forward()*30 + machine:GetAngles():Up()*25 + machine:GetAngles():Right()*-3)
			wep:SetAngles(machine:GetAngles() + Angle(0,90,0))
			wep.WepClass = class
			wep:Spawn()
			local model = weapons.Get(class) and weapons.Get(class).WorldModel or "models/weapons/w_rif_ak47.mdl"
			if !util.IsValidModel(model) then model = "models/weapons/w_rif_ak47.mdl" end
			wep:SetModel(model)
			wep.machine = machine
			wep.Owner = ply
			wep:SetMoveType( MOVETYPE_FLY )
			
			--wep:SetNotSolid(true)
			--wep:SetGravity(0.000001)
			--wep:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
			timer.Simple(0.5, function()
				if IsValid(wep) then
					wep:SetLocalVelocity(machine:GetAngles():Forward()*-30)
				end
			end)
			timer.Simple(1.8, function()
				if IsValid(wep) then
					wep:SetMoveType(MOVETYPE_NONE)
					wep:SetLocalVelocity(Vector(0,0,0))
				end
			end)
			timer.Simple(3, function()
				if IsValid(wep) then
					machine:EmitSound("nz/machines/pap_ready.wav")
					wep:SetCollisionBounds(Vector(0,0,0), Vector(0,0,0))
					wep:SetMoveType(MOVETYPE_FLY)
					wep:SetGravity(0.000001)
					wep:SetLocalVelocity(machine:GetAngles():Forward()*30)
					--print(machine:GetAngles():Forward()*30, wep:GetVelocity())
					wep:CreateTriggerZone()
				end
			end)
			timer.Simple(4.2, function()
				if IsValid(wep) then
					--print("YDA")
					--print(wep:GetMoveType())
					--print(machine:GetAngles():Forward()*30, wep:GetVelocity())
					wep:SetMoveType(MOVETYPE_NONE)
					wep:SetLocalVelocity(Vector(0,0,0))
				end
			end)
			timer.Simple(10, function()
				if IsValid(wep) then
					wep:SetMoveType(MOVETYPE_FLY)
					wep:SetLocalVelocity(machine:GetAngles():Forward()*-2)
				end
			end)
			timer.Simple(25, function()
				if IsValid(wep) then
					wep:Remove()
					machine:SetBeingUsed(false)
				end
			end)
			
			--nz.Weps.Functions.ApplyPaP( ply, wep )
			timer.Simple(2, function() ply:RemovePerk("pap") end)
			return true
		else
			ply:PrintMessage( HUD_PRINTTALK, "This weapon is already Pack-a-Punched")
			return false
		end
	end,
})
