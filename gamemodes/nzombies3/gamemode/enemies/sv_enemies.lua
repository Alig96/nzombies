function Enemies:TotalAlive()
	local c = 0

	-- Count
	for k,v in pairs(Config.ValidEnemies) do
		c = c + #ents.FindByClass(k)
	end

	return c
end
