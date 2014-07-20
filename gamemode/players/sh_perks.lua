// RAWR!
local playerMeta = FindMetaTable("Player")
if SERVER then
	util.AddNetworkString("nz_Perks_Sync")
	function playerMeta:SetPerk(id, img)
		self.Perks = self.Perks or {}
		self.Perks[id] = {material = img}
		net.Start("nz_Perks_Sync")
			net.WriteTable(self.Perks)
		net.Send(self)
	end
	
	function playerMeta:RemovePerk(id)
		self.Perks[id] = {}
		net.Start("nz_Perks_Sync")
			net.WriteTable(self.Perks)
		net.Send(self)
	end
	
	function playerMeta:RemovePerks()
		if (!self:GetPerks()) then return end
		for id, data in pairs(self:GetPerks()) do
			self.Perks[id] = {}
		end
		net.Start("nz_Perks_Sync")
			net.WriteTable(self.Perks)
		net.Send(self)
	end
	
	hook.Add("PlayerDeath", "nz_Perks_Death", function(ply)
		ply:RemovePerks()
	end)
else
	net.Receive("nz_Perks_Sync", function()
		LocalPlayer().Perks = net.ReadTable()
	end)
end

function playerMeta:HasPerk(id)
	if (self.Perks&&self.Perks[id]) then
		return true
	end
	return false
end

function playerMeta:GetPerk(id)
	if (self.Perks&&self.Perks[id]) then
		return self.Perks[id]
	end
	return false
end

function playerMeta:GetPerks(id)
	if (self.Perks) then
		return self.Perks
	end
	return false
end