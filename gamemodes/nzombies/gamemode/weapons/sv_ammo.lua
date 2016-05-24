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

	for k,v in pairs(ply:GetWeapons()) do
		-- If the weapon entity exist, just give ammo on that
		if v:GetClass() == class then v:GiveMaxAmmo() return end
	end
	
	-- Else we'll have to refer to the old system (for now, this should never happen)
	local wep = weapons.Get(class)
	if !wep then return end
	
	-- Weapons can have their own Max Ammo functions that are run instead
	if wep.NZMaxAmmo then wep:NZMaxAmmo() return end
	
	if !wep.Primary then return end
	
	local ammo_type = wep.Primary.Ammo
	local max_ammo = nzWeps:CalculateMaxAmmo(class, (IsValid(ply:GetWeapon(class)) and ply:GetWeapon(class).pap) or papoverwrite)

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo
	
	--print(give_ammo)

	-- Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end

function nzWeps:GiveMaxAmmo(ply)
	for k,v in pairs(ply:GetWeapons()) do
		if !v:IsSpecial() then
			v:GiveMaxAmmo()
		else
			if nzSpecialWeapons.Weapons[v:GetClass()].maxammo then
				nzSpecialWeapons.Weapons[v:GetClass()].maxammo(ply, v)
			end
		end
	end
end

local meta = FindMetaTable("Weapon")

function meta:CalculateMaxAmmo()
	local clip = self.Primary and self.Primary.ClipSize or nil
	-- When calculated directly on a weapon entity, its clipsize will already have changed from PaP
	return clip and clip * 10 or 0
end

function meta:GiveMaxAmmo()

	if self.NZMaxAmmo then self:NZMaxAmmo() return end

	local ply = self.Owner
	if !IsValid(ply) then return end
	
	local ammo_type = self.Primary.Ammo
	local max_ammo = self:CalculateMaxAmmo()

	local curr_ammo = ply:GetAmmoCount( ammo_type )
	local give_ammo = max_ammo - curr_ammo

	-- Just for display, since we're setting their ammo anyway
	ply:GiveAmmo(give_ammo, ammo_type)
	ply:SetAmmo(max_ammo, ammo_type)
	
end