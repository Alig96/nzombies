local mapscript = {}

local gens = {Vector(470, -850, 215), Vector(1855, -365, 225), Vector(1555, 885, 190)}
local gen_ents = {}

function mapscript.OnGameBegin()
	local completed = 1
	for k,v in pairs(gens) do
		local gen
		if IsValid(gen_ents[k]) then
			gen = gen_ents[k]
		else
			gen = ents.Create("nz_script_soulcatcher")
		end
		gen:SetNoDraw(true)
		gen:SetPos(v)
		gen:Spawn() -- Spawn before setting variables or they'll become the default
		gen:SetTargetAmount(20)
		gen:SetRange(200)
		gen:SetReleaseOverride( function(self, z)
			if self.CurrentAmount >= self.TargetAmount then return end
			
			local e = EffectData()
			e:SetOrigin(self:GetPos())
			e:SetStart(z:GetPos())
			e:SetMagnitude(0.3)
			util.Effect("lightning_strike", e)
			self.CurrentAmount = self.CurrentAmount + 1
			self:CollectSoul()
		end)
		gen:SetCompleteFunction( function(self)
			nzDoors:OpenLinkedDoors("gen"..completed)
			if completed == 3 then
				nzDoors:OpenLinkedDoors("10") -- Enables the spawnpoints by PaP
			end
			completed = completed + 1
		end)
		gen:SetCondition( function(self, z, dmg)
			return nzElec.Active
		end)
		gen_ents[k] = gen
		print(gen_ents[k], k, IsValid(gen_ents[k]), gen_ents[k] and gen_ents[k].NZMapScriptCreated or "nil")
	end
end

function mapscript.ScriptUnload()
	for k,v in pairs(gen_ents) do
		if IsValid(v) then
			v:Remove()
		end
	end
	gen_ents = nil
end

function mapscript.ElectricityOn()
	for k,v in pairs(gen_ents) do
		--print(k,v)
		v:SetEnabled(true)
		v:Reset()
	end
end

function mapscript.ElectricityOff()
	for k,v in pairs(gen_ents) do
		--print(k,v)
		v:SetEnabled(false)
	end
end

-- Always return the mapscript table. This gives it on to the gamemode so it can use it.
return mapscript
