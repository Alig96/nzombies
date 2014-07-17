local _PLAYER = FindMetaTable("Player")

function _PLAYER:GetPoints()
	return self:GetNWInt("points") or 0
end

function _PLAYER:HasPoints(amount)
	return self:GetPoints() >= amount
end

function _PLAYER:CanAfford(amount)
	return (self:GetPoints() - amount) >= 0
end

if (SERVER) then
	-- Sets the character's amount of currency to a specific value.
	function _PLAYER:SetPoints(amount)
		amount = math.Round(amount, 2)
		self:SetNWInt("points", amount)
	end

	-- Quick function to set the money to the current amount plus an amount specified.
	function _PLAYER:GivePoints(amount)
		if nz.Rounds.Effects["dp"] == true then
			amount = amount * 2
		end
		self:SetPoints(self:GetPoints() + amount)
	end

	-- Takes away a certain amount by inverting the amount specified.
	function _PLAYER:TakePoints(amount)
		//Changed to prevent double points from removing double the points. - Don't even think of changing this back Ali, Love Ali.
		self:SetPoints(self:GetPoints() - amount)
	end
end
