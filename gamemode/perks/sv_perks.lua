// RAWR!
function nz.Perks.Activate(id, ent, ply)
	local perkData = nz.Perks.Get(id)
	if (perkData&&ply:CanAfford(tonumber(perkData.price))) then
		if (perkData.OneTimeUse) then
			if (!ply:HasPerk(id)) then
				if (perkData.func(ent, ply)) then
					ply:SetPerk(id, perkData.material)
					ply:TakePoints(tonumber(self.Price))
					ply:PrintMessage(HUD_PRINTTALK, "[NZ] You have used the "..perkData.name.."!")
				else
					ply:PrintMessage(HUD_PRINTTALK, "[NZ] This perk does not seem currently setup, contact someone about it.")
				end
				if (perkData.snd) then
					ent:EmitSound(perkData.snd[1], perkData.snd[2])
				end
			else
				ply:PrintMessage(HUD_PRINTTALK, "[NZ] You already have this Perk!")
			end
		else
			if (perkData.func(ent, ply)) then
				ply:TakePoints(tonumber(self.Price))
				ply:PrintMessage(HUD_PRINTTALK, "[NZ] You have used the "..perkData.name.."!")
			else
				ply:PrintMessage(HUD_PRINTTALK, "[NZ] This perk does not seem currently setup, contact someone about it.")
			end
			if (perkData.snd) then
				ent:EmitSound(perkData.snd[1], perkData.snd[2])
			end
			ply:PrintMessage(HUD_PRINTTALK, "[NZ] You have used the "..perkData.name.."!")
		end
	end
end