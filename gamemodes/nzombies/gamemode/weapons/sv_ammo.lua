-- Create new ammo types for each weapon slot; that way all 3 weapons have seperate ammo even if they share type

game.AddAmmoType( {
	name = "nz_weapon_ammo_1",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

game.AddAmmoType( {
	name = "nz_weapon_ammo_2",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

-- Third one is pretty much only used with Mule Kick
game.AddAmmoType( {
	name = "nz_weapon_ammo_3",
	dmgtype = DMG_BULLET,
	tracer = TRACER_LINE,
	plydmg = 0,
	npcdmg = 0,
	force = 2000,
	minsplash = 10,
	maxsplash = 5
} )

-- Functions
function nzWeps:CalculateMaxAmmo(class, pap)
	local wep = weapons.Get(class)
	local clip = wep.Primary.ClipSize
	
	if pap then
		return math.Round((clip *1.5)/5)* 5 * 10
	else
		return clip * 10
	end
end

function nzWeps:GiveMaxAmmoWep(ply, class, papoverwrite)

	local wep
	for k,v in pairs(ply:GetWeapons()) do
		if v:GetClass() == class then wep = v break end
	end
	if !wep then wep = weapons.Get(class) end
	if !wep then return end
	local ammo_type = wep.Primary.Ammo
	print(ammo_type)
	local max_ammo = nzWeps:CalculateMaxAmmo(class, (IsValid(ply:GetWeapon(class)) and ply:GetWeapon(class).pap) or papoverwrite)

	local ply_weps = ply:GetWeapons()
	local multi = 0

	--[[for k,v in pairs(ply_weps) do
		local in_wep = weapons.Get(v:GetClass())
		if in_wep != nil then
			if in_wep.Primary.Ammo == ammo_type then
				multi = multi + 1
			end
		end
	end]]

	--max_ammo = max_ammo * multi

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo
	
	print(give_ammo)

	//Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end

function nzWeps:GiveMaxAmmo(ply)
	for k,v in pairs(ply:GetWeapons()) do
		if !v:IsSpecial() then
			nzWeps:GiveMaxAmmoWep(ply, v:GetClass())
		else
			if nzSpecialWeapons.Weapons[v:GetClass()].maxammo then
				nzSpecialWeapons.Weapons[v:GetClass()].maxammo(ply, v)
			end
		end
	end
end
