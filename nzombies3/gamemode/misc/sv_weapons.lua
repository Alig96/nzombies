//Functions
function nz.Misc.Functions.CalculateMaxAmmo(class)
	local wep = weapons.Get(class)
	local clip = wep.Primary.ClipSize
	
	return clip * 10
end

function nz.Misc.Functions.GiveMaxAmmoWep(ply, class)

	local wep = weapons.Get(class)
	local ammo_type = wep.Primary.Ammo
	local max_ammo = nz.Misc.Functions.CalculateMaxAmmo(class)
	
	local ply_weps = ply:GetWeapons()
	local multi = 0
	
	for k,v in pairs(ply_weps) do
		local in_wep = weapons.Get(v:GetClass())
		if in_wep != nil then
			if in_wep.Primary.Ammo == ammo_type then
				multi = multi + 1
			end
		end
	end

	max_ammo = max_ammo * multi
	
	ply:SetAmmo(max_ammo * multi, ammo_type)
	
end
