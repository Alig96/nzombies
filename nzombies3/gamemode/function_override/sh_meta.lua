local playerMeta = FindMetaTable("Player")
local wepMeta = FindMetaTable("Weapon")

if SERVER then
	
	function ReplaceReloadFunction(wep)
		//Either not a weapon, doesn't have a reload function, or is FAS2
		if nz.Weps.Functions.IsFAS2(wep) then return end
		local oldreload = wep.Reload
		
		--print("Weapon reload modified")
		
		wep.Reload = function()
			if wep.ReloadFinish and wep.ReloadFinish > CurTime() then return end
			if wep.Owner:HasPerk("speed") then
				print("Hasd perk")
				local cur = wep:Clip1()
				if cur >= wep:GetMaxClip1() then return end
				
				wep:SendWeaponAnim(ACT_VM_RELOAD)
				oldreload(wep)
				local rtime = wep:SequenceDuration(wep:SelectWeightedSequence(ACT_VM_RELOAD))/2
				wep:SetPlaybackRate(2)
				wep.Owner:GetViewModel():SetPlaybackRate(2)

				local nexttime = CurTime() + rtime

				wep:SetNextPrimaryFire(nexttime)
				wep:SetNextSecondaryFire(nexttime)
				wep.ReloadFinish = nexttime
				
				timer.Simple(rtime, function()
					if IsValid(wep) and wep.Owner:GetActiveWeapon() == wep then
						wep:SetPlaybackRate(1)
						wep.Owner:GetViewModel():SetPlaybackRate(1)
						wep:SendWeaponAnim(ACT_VM_IDLE)
						wep:SetClip1(wep:GetMaxClip1())
						wep.Owner:RemoveAmmo(wep:GetMaxClip1() - cur, wep:GetPrimaryAmmoType())
						wep:SetNextPrimaryFire(0)
						wep:SetNextSecondaryFire(0)
					end
				end)
			else
				oldreload(wep)
			end
		end
	end
	hook.Add("WeaponEquip", "ModifyWeaponReloads", ReplaceReloadFunction)
	
	function ReplacePrimaryFireCooldown(wep)
		local oldfire = wep.PrimaryAttack
		
		--print("Weapon fire modified")
		
		wep.PrimaryAttack = function()
			oldfire(wep)
			
			//FAS2 weapons have built-in DTap functionality
			if nz.Weps.Functions.IsFAS2(wep) then return end
			//With double tap, reduce the delay for next primary fire to 2/3
			if wep.Owner:HasPerk("dtap") then
				local delay = (wep:GetNextPrimaryFire() - CurTime())*0.66
				wep:SetNextPrimaryFire(CurTime() + delay)
			end
		end
	end
	hook.Add("WeaponEquip", "ModifyWeaponNextFires", ReplacePrimaryFireCooldown)
	
else
	
	
	
end

local olddefreload = wepMeta.DefaultReload
function wepMeta:DefaultReload(act)
	if IsValid(self.Owner) and self.Owner:HasPerk("speed") then return end
	olddefreload(self, act)
end

function GM:EntityFireBullets(ent, data)

	//Fire the PaP shooting sound if the weapon is PaP'd
	--print(wep, wep.pap)
	if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon().pap then
		wep:EmitSound("nz/effects/pap_shoot_glock20.wav", 105, 100)
	end

	//Perform a trace that filters out wall blocks
	local tr = util.TraceLine({
		start = data.Src,
		endpos = data.Src + (data.Dir*data.Distance),
		filter = function(ent) 
			if ent:GetClass() == "wall_block" then
				return false
			else
				return true
			end 
		end
	})
	
	--PrintTable(tr)
	
	//If we hit anything, move the source of the bullets up to that point
	if tr.Hit and tr.HitPos then
		data.Src = tr.HitPos - data.Dir
		return true
	end
end