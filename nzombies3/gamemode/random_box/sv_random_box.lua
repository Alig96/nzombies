//

function nz.RandomBox.Functions.SpawnBox()
	//Get all spawns
	local all = ents.FindByClass("random_box_spawns")
	local rand = table.Random(all)

	if rand != nil then
		local box = ents.Create( "random_box" )
		box:SetPos( rand:GetPos() )
		box:SetAngles( rand:GetAngles() )
		box:Spawn()
		box:PhysicsInit( SOLID_VPHYSICS )

		local phys = box:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	else
		print("No random box spawns have been set.")
	end
end

function nz.RandomBox.Functions.RemoveBox()
	//Get all spawns
	local all = ents.FindByClass("random_box")
	//Loop just incase
	for k,v in pairs(all) do
		v:Remove()
	end
end

function nz.RandomBox.Functions.DecideWep(ply)

	local guns = {}
	local blacklist = table.Copy(nz.Config.WeaponBlackList)

	//Add all our current guns to the black list
	if ply:IsValid() then
		for k,v in pairs( ply:GetWeapons() ) do
			table.insert(blacklist, v.ClassName)
		end
	end

	//Add all guns with no model to the blacklist
	for k,v in pairs( weapons.GetList() ) do
		if !table.HasValue(blacklist, v.ClassName) then
			if v.WorldModel == nil then
				table.insert(blacklist, v.ClassName)
			end
		end
	end
	
	if IsValid(ents.FindByClass("random_box_handler")[1]) then
		//Only add guns found in the Random Box Handler
		for k,v in pairs( ents.FindByClass("random_box_handler")[1]:GetWeaponsList() ) do
			if !table.HasValue(blacklist, v) then
				table.insert(guns, v)
			end
		end
	else
		//It doesn't exist, add all guns
		for k,v in pairs( weapons.GetList() ) do
			if !table.HasValue(blacklist, v.ClassName) then
				table.insert(guns, v.ClassName)
			end
		end
	end

	return table.Random(guns)
end
