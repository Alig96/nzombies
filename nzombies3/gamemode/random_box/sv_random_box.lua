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