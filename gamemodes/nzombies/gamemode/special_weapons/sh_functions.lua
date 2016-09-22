game.AddAmmoType( {
	name = "nz_grenade",
} )
game.AddAmmoType( {
	name = "nz_specialgrenade",
} )

function nzSpecialWeapons:AddKnife( class, drawonequip, attackholstertime, drawholstertime )
	local wep = weapons.Get(class)
	if wep then
		self.Weapons[class] = {id = "knife", drawonequip = drawonequip}
		
		local oldattack = wep.PrimaryAttack
		function wep:PrimaryAttack()
			if self.nzCanAttack then
				oldattack(self)
				self.nzCanAttack = false
			end
		end
		
		--local olddeploy = wep.Deploy
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			if !self.nzIsDrawing then
				self.nzCanAttack = true
				self.nzHolsterTime = ct + attackholstertime
				self:SendWeaponAnim(ACT_VM_IDLE)
				self:PrimaryAttack()
			else
				self.nzHolsterTime = ct + drawholstertime
			end
			self.nzIsDrawing = nil
		end
	
		local oldthink = wep.Think
		function wep:Think()
			local ct = CurTime()
			
			--[[if self.nzAttackTime and ct > self.nzAttackTime then
				self:PrimaryAttack()
				self.nzAttackTime = nil
			end]]
			
			if self.nzHolsterTime and ct > self.nzHolsterTime then
				self:Holster()
				self.Owner:SetUsingSpecialWeapon(false)
				self.Owner:EquipPreviousWeapon()
				self.nzHolsterTime = nil
			end
			
			oldthink(self)
		end
		
		local oldholster = wep.Holster
		function wep:Holster( wep2 )
			self.Owner:SetUsingSpecialWeapon(false)
			return oldholster(self, wep2)
		end
		
		weapons.Register(wep, class)
	end
end

function nzSpecialWeapons:AddGrenade( class, ammo, drawact, throwtime, throwfunc, holstertime )
	local wep = weapons.Get(class)
	if wep then
		self.Weapons[class] = {id = "grenade", maxammo = ammo}
		
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			self.nzThrowTime = ct + throwtime
			
			if !drawact then
				self:EquipDraw() -- Use normal draw animation/function for not specifying throw act
			else
				self:SendWeaponAnim(drawact) -- Otherwise play the act (preferably pull pin act)
			end
			
		end
	
		local oldthink = wep.Think
		
		if throwfunc then
			function wep:Think()
				local ct = CurTime()
				
				if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
					self.nzThrowTime = nil
					self.nzHolsterTime = ct + holstertime
					throwfunc(self) -- If a function was specified (e.g. to run a certain func on the weapon), then do that
					-- The above function needs to subtract the grenade ammo (unless they're going for something special)
				end
				
				if self.nzHolsterTime and ct > self.nzHolsterTime then
					self.nzHolsterTime = nil
					self.Owner:SetUsingSpecialWeapon(false)
					self:Holster()
					self.Owner:EquipPreviousWeapon()
				end
				
				oldthink(self)
			end
		else
			function wep:Think()
				local ct = CurTime()
				
				if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
					self.nzThrowTime = nil
					self.nzHolsterTime = ct + holstertime
					self:PrimaryAttack()
					self.Owner:SetAmmo(self.Owner:GetAmmoCount("nz_grenade") - 1, "nz_grenade")
				end
				
				if self.nzHolsterTime and ct > self.nzHolsterTime then
					self.nzHolsterTime = nil
					self.Owner:SetUsingSpecialWeapon(false)
					self:Holster()
					self.Owner:EquipPreviousWeapon()
				end
				
				oldthink(self)
			end
		end
		
		weapons.Register(wep, class)
	end
end

function nzSpecialWeapons:AddSpecialGrenade( class, ammo, drawact, throwtime, throwfunc, holstertime )
	local wep = weapons.Get(class)
	if wep then
		self.Weapons[class] = {id = "specialgrenade", maxammo = ammo}
		
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			
			if !drawact then
				self:EquipDraw() -- Use normal draw animation/function for not specifying throw act
			else
				self:SendWeaponAnim(drawact) -- Otherwise play the act (preferably pull pin act)
			end
			self.nzThrowTime = ct + throwtime
			
		end
	
		local oldthink = wep.Think
		
		if throwfunc then
			function wep:Think()
				local ct = CurTime()
				
				if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
					self.nzThrowTime = nil
					self.nzHolsterTime = ct + holstertime
					throwfunc(self)
				end
				
				if self.nzHolsterTime and ct > self.nzHolsterTime then
					self.nzHolsterTime = nil
					self.Owner:SetUsingSpecialWeapon(false)
					self:Holster()
					self.Owner:EquipPreviousWeapon()
				end
				
				oldthink(self)
			end
		else
			function wep:Think()
				local ct = CurTime()
				
				if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
					self.nzThrowTime = nil
					self.nzHolsterTime = ct + holstertime
					self:PrimaryAttack()
					self.Owner:SetAmmo(self.Owner:GetAmmoCount("nz_specialgrenade") - 1, "nz_specialgrenade")
				end
				
				if self.nzHolsterTime and ct > self.nzHolsterTime then
					self.nzHolsterTime = nil
					self.Owner:SetUsingSpecialWeapon(false)
					self:Holster()
					self.Owner:EquipPreviousWeapon()
				end
				
				oldthink(self)
			end
		end
		
		weapons.Register(wep, class)
	end
end

function nzSpecialWeapons:AddDisplay( class, drawfunc, returnfunc )
	local wep = weapons.Get(class)
	if wep then
		self.Weapons[class] = {id = "display"}
		
		wep.EquipDraw = wep.Deploy
		
		if drawfunc then
			function wep:Deploy()
				local ct = CurTime()
				drawfunc(self) -- Drawfunc specified, overwrite deploy with this function
				self.nzDeployTime = ct -- Time when it was equipped, can be used for time comparisons
			end
		else
			function wep:Deploy()
				local ct = CurTime()
				self:EquipDraw() -- Not specified, use deploy function
				self.nzDeployTime = ct -- Time when it was equipped, can be used for time comparisons
			end
		end
	
		local oldthink = wep.Think
		
		function wep:Think()
			if returnfunc(self) then
				if SERVER then
					self.Owner:SetUsingSpecialWeapon(false)
				end
				self:Holster()
				self.Owner:EquipPreviousWeapon()
				if SERVER then
					self.Owner:StripWeapon(self:GetClass()) -- Always stripped when done with use
				end
			end
			
			oldthink(self)
		end
		
		weapons.Register(wep, class)
	end
end



CreateClientConVar("nz_key_knife", KEY_V, true, true, "Sets the key that triggers Knife. Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY")
CreateClientConVar("nz_key_grenade", KEY_G, true, true, "Sets the key that throws Grenades. Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY")
CreateClientConVar("nz_key_specialgrenade", KEY_B, true, true, "Sets the key that throws Special Grenades. Uses numbers from gmod's KEY_ enums: http://wiki.garrysmod.com/page/Enums/KEY")

--[[local buttonids = {
	[KEY_V] = "knife",
	[KEY_G] = "grenade",
	[KEY_B] = "specialgrenade",
}]]

local usesammo = {
	["grenade"] = "nz_grenade",
	["specialgrenade"] = "nz_specialgrenade",
}

hook.Add("PlayerButtonDown", "nzSpecialWeaponsHandler", function(ply, but)
	--local id = buttonids[but]
	local id
	if but == ply:GetInfoNum("nz_key_knife", KEY_V) then id = "knife"
	elseif but == ply:GetInfoNum("nz_key_grenade", KEY_G) then id = "grenade"
	elseif but == ply:GetInfoNum("nz_key_specialgrenade", KEY_B) then id = "specialgrenade" end
	if id and (ply:GetNotDowned() or id == "knife") and !ply:GetUsingSpecialWeapon() then
		local ammo = usesammo[id]
		if !ammo or ply:GetAmmoCount(ammo) >= 1 then
			local wep = ply:GetSpecialWeaponFromCategory( id )
			if IsValid(wep) then
				if SERVER then
					ply:SetUsingSpecialWeapon(true)
					ply:SetActiveWeapon(nil)
				end
				ply:SelectWeapon(wep:GetClass())
				ply.nzSpecialButtonDown = true
			end
		end
	end
end)

hook.Add("PlayerButtonUp", "nzSpecialWeaponsThrow", function(ply, but)
	--local id = buttonids[but]
	local id = but == ply:GetInfoNum("nz_key_knife", KEY_V) or but == ply:GetInfoNum("nz_key_grenade", KEY_G) or but == ply:GetInfoNum("nz_key_specialgrenade", KEY_B)
	if id and ply.nzSpecialButtonDown then
		ply.nzSpecialButtonDown = false
	end
end)

local wep = FindMetaTable("Weapon")
local ply = FindMetaTable("Player")

function wep:IsSpecial()
	return (self.NZSpecialCategory or nzSpecialWeapons.Weapons[self:GetClass()]) and true or false
end

function wep:GetSpecialCategory()
	return self.NZSpecialCategory or nzSpecialWeapons.Weapons[self:GetClass()].id
end

function ply:GetSpecialWeaponFromCategory( id )
	if !self.NZSpecialWeapons then self.NZSpecialWeapons = {} end
	return self.NZSpecialWeapons[id] or nil
end

function ply:EquipPreviousWeapon()
	if IsValid(self.NZPrevWep) then -- If the previously used weapon is valid, use that
		self:SetActiveWeapon(nil)
		self:SelectWeapon(self.NZPrevWep:GetClass())
	else
		for k,v in pairs(self:GetWeapons()) do -- And pick the first one that isn't special
			if !v:IsSpecial() then
				self:SetActiveWeapon(nil)
				self:SelectWeapon(v:GetClass())
				return
			end
		end
		self:SetActiveWeapon(nil)
	end
end

if SERVER then
	function ply:AddSpecialWeapon(wep)
		if !self.NZSpecialWeapons then self.NZSpecialWeapons = {} end
		local id = wep:GetSpecialCategory()
		self.NZSpecialWeapons[id] = wep
		nzSpecialWeapons:SendSpecialWeaponAdded(self, wep, id)
		
		local data = nzSpecialWeapons.Weapons[wep:GetClass()]
		
		if !data then return end -- No nothing more if it doesn't have data supplied (e.g. specially added thingies)
		
		local ammo = usesammo[id]
		local maxammo = data.maxammo
		if ammo and maxammo then
			self:SetAmmo(maxammo, ammo)
		end
		
		if data.drawonequip then
			wep.nzIsDrawing = true
			self:SetUsingSpecialWeapon(true)
			self:SetActiveWeapon(nil)
			self:SelectWeapon(wep:GetClass())
			wep:EquipDraw()
		end
	end

	-- This hook only works server-side
	hook.Add("WeaponEquip", "nzSetSpecialWeapons", function(wep)
		if wep:IsSpecial() then
			-- 0 second timer for the next tick where wep's owner is valid
			timer.Simple(0, function()
				local ply = wep:GetOwner()
				if IsValid(ply) then
					local oldwep = ply:GetSpecialWeaponFromCategory( wep:GetSpecialCategory() )
					print(wep, oldwep)
					if IsValid(oldwep) then
						ply:StripWeapon(oldwep:GetClass())
					end
					ply:AddSpecialWeapon(wep)
				end		
			end)
		end
	end)
end

-- Prevent players from manually switching to the weapon if it is special - it is handled by the bind
function GM:PlayerSwitchWeapon(ply, oldwep, newwep)
	-- In case a player is trying to switch both to and from a non-special weapon, but their status is stuck to true
	if IsValid(ply) and ply:GetUsingSpecialWeapon() and (!IsValid(oldwep) or !oldwep:IsSpecial()) and !newwep:IsSpecial() then
		-- It should never happen as a player shouldn't be able to use non-special weapons with the status on, but it may get stuck
		ply:SetUsingSpecialWeapon(false)
		print(ply:Nick().."'s UsingSpecialWeapon status was true but he isn't equipped with a special weapon and isn't trying to. Resetting ...")
	end
	if IsValid(oldwep) and IsValid(newwep) then
		if (!ply:GetUsingSpecialWeapon() and newwep:IsSpecial()) then return true end
		if (ply:GetUsingSpecialWeapon() and oldwep:IsSpecial()) then
			if oldwep.NZSpecialHolster then
				local allow = oldwep:NZSpecialHolster(newwep)
				if allow then
					ply:SetUsingSpecialWeapon(false)
				end
				return !allow
			end
		end
		if oldwep != newwep and !oldwep:IsSpecial() then
			ply.NZPrevWep = oldwep
		end
	end
end