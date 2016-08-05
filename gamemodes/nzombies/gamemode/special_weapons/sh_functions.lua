--[[function nzSpecialWeapons:CreateCategory(id, bind, useammo)
	self.Categories[id] = {
		bind = bind,
		--use = useFunc
	}
	if useammo then
		game.AddAmmoType( {
			name = "nz_"..id,
		} )
	end
	self.Keys[bind] = id
end

function nzSpecialWeapons:AddWeapon( wepclass, id, use, equip, maxammo )
	self.Weapons[wepclass] = {id = id, use = use, equip = equip, maxammo = maxammo}
end

hook.Add("KeyPress", "SpecialWeaponsUsage", function(ply, key)
	local id = nzSpecialWeapons.Keys[key]
	if id and ply:GetNotDowned() then -- Can't use grenades and stuff while downed
		local wep = ply:GetSpecialWeaponFromCategory( id )
		if IsValid(wep) and !ply:GetUsingSpecialWeapon() and nzSpecialWeapons.Weapons[wep:GetClass()].use then
			nzSpecialWeapons.Weapons[wep:GetClass()].use(ply, wep)
		end
	end
end)]]

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
		
		--local olddeploy = wep.Deploy
		wep.EquipDraw = wep.Deploy
		
		function wep:Deploy()
			local ct = CurTime()
			if !self.nzIsDrawing then
				self:SendWeaponAnim(ACT_VM_IDLE)
				self:PrimaryAttack()
				self.nzHolsterTime = ct + attackholstertime
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
			
			if !drawact then
				self:EquipDraw() -- Use normal draw animation/function for not specifying throw act
			else
				self:SendWeaponAnim(throwact) -- Otherwise play the act (preferably pull pin act)
			end
			self.nzThrowTime = ct + throwtime
			
		end
	
		local oldthink = wep.Think
		
		if throwfunc then
			function wep:Think()
				local ct = CurTime()
				
				if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
					throwfunc(self) -- If a function was specified (e.g. to run a certain func on the weapon), then do that
					self.nzThrowTime = nil
					self.nzHolsterTime = ct + holstertime
				end
				
				if self.nzHolsterTime and ct > self.nzHolsterTime then
					self:Holster()
					self.Owner:SetUsingSpecialWeapon(false)
					self.Owner:EquipPreviousWeapon()
					self.nzHolsterTime = nil
				end
				
				oldthink(self)
			end
		else
			function wep:Think()
				local ct = CurTime()
				
				if self.nzThrowTime and ct > self.nzThrowTime and (!self.Owner.nzSpecialButtonDown or !self.Owner:GetNotDowned()) then
					self:PrimaryAttack()
					self.nzThrowTime = nil
					self.nzHolsterTime = ct + holstertime
				end
				
				if self.nzHolsterTime and ct > self.nzHolsterTime then
					self:Holster()
					self.Owner:SetUsingSpecialWeapon(false)
					self.Owner:EquipPreviousWeapon()
					self.nzHolsterTime = nil
				end
				
				oldthink(self)
			end
		end
		
		weapons.Register(wep, class)
	end
end

function nzSpecialWeapons:AddSpecialGrenade( class, drawonequip )
	self.Weapons[class] = {id = "specialgrenade", drawonequip = drawonequip}
end

function nzSpecialWeapons:AddDisplay( class, hold )
	self.Weapons[class] = {id = "display", hold = hold}
end

local buttonids = {
	[KEY_H] = "knife",
	[KEY_G] = "grenade",
	[KEY_B] = "specialgrenade",
}

hook.Add("PlayerButtonDown", "nzSpecialWeaponsHandler", function(ply, but)
	local id = buttonids[but]
	if id and (ply:GetNotDowned() or but == KEY_V) and !ply:GetUsingSpecialWeapon() then
		local wep = ply:GetSpecialWeaponFromCategory( id )
		if IsValid(wep) then
			ply:SetUsingSpecialWeapon(true)
			ply:SetActiveWeapon(nil)
			ply:SelectWeapon(wep:GetClass())
			ply.nzSpecialButtonDown = true
		end
	end
end)

hook.Add("PlayerButtonUp", "nzSpecialWeaponsThrow", function(ply, but)
	local id = buttonids[but]
	if id and ply.nzSpecialButtonDown then
		ply.nzSpecialButtonDown = false
	end
end)