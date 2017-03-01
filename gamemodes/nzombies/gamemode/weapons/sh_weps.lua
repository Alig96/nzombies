local wepMeta = FindMetaTable("Weapon")

function wepMeta:NZPerkSpecialTreatment( )
	if self:IsFAS2() or self:IsCW2() or self:IsTFA() then
		return true
	end

	return false
end

function wepMeta:IsFAS2()
	if self.Category == "FA:S 2 Weapons" or self.Base == "fas2_base" then
		return true
	else
		local base = weapons.Get(self.Base)
		if base and base.Base == "fas2_base" then
			return true
		end
	end

	return false
end

function wepMeta:IsCW2()
	if self.Category == "CW 2.0" or self.Base == "cw_base" then
		return true
	else
		local base = weapons.Get(self.Base)
		if base and base.Base == "cw_base" then
			return true
		end
	end

	return false
end

function wepMeta:IsTFA()
	if self.Category == "TFA" or self.Base == "tfa_gun_base" or string.sub(self:GetClass(), 1, 3) == "tfa" then
		return true
	else
		local base = weapons.Get(self.Base)
		if base and base.Base == "tfa_gun_base" then
			return true
		end
	end

	return false
end

function wepMeta:CanRerollPaP()
	return (wep.OnRePaP or (wep.Attachments and ((wep:IsCW2() and CustomizableWeaponry) or wep:IsTFA()) or wep:IsFAS2()))
end

local old = wepMeta.GetPrintName
function wepMeta:GetPrintName()
	local name = old(wep)
	if !name or name == "" then name = wep:GetClass() end
	if wep:HasNZModifier("pap") then
		name = wep.NZPaPName or nz.Display_PaPNames[wep:GetClass()] or nz.Display_PaPNames[name] or "Upgraded "..name
	end
	return name
end