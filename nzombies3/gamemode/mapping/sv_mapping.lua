//

function nz.Mapping.Functions.ZedSpawn(pos, link)

	local ent = ents.Create("zed_spawns") 
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	ent.link = link
	//For the link displayer
	if link != nil then
		ent:SetLink(link)	
	end
end

function nz.Mapping.Functions.PlayerSpawn(pos)

	local ent = ents.Create("player_spawns") 
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	
end

function nz.Mapping.Functions.WallBuy(pos, gun, price, angle)

	if weapons.Get(gun) != nil then
	
		local ent = ents.Create("wall_buys") 
		ent:SetAngles(angle)
		pos.z = pos.z - ent:OBBMaxs().z
		ent:SetWeapon(gun, price)
		ent:SetPos( pos )
		ent:Spawn()
		ent:PhysicsInit( SOLID_VPHYSICS )
		
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		
	else
		print("SKIPPED: " .. gun .. ". Are you sure you have it installed?")
	end
	
end

function nz.Mapping.Functions.PropBuy(pos,ang,model,flags)
	local prop = ents.Create( "prop_buys" )
	prop:SetModel( model )
	prop:SetPos( pos )
	prop:SetAngles( ang )
	prop:Spawn()
	prop:PhysicsInit( SOLID_VPHYSICS )
	
	//REMINDER APPY FLAGS
	if flags != nil then
		nz.Doors.Functions.CreateLink( prop, flags )
	end
	
	local phys = prop:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

function nz.Mapping.Functions.Electric(pos,ang,model)
	//THERE CAN ONLY BE ONE TRUE HERO
	local prevs = ents.FindByClass("button_elec")
	if prevs[1] != nil then
		prevs[1]:Remove()
	end
	
	local ent = ents.Create( "button_elec" )
	ent:SetPos( pos )
	ent:SetAngles( ang )
	ent:Spawn()
	ent:PhysicsInit( SOLID_VPHYSICS )
		
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

function nz.Mapping.Functions.BlockSpawn(pos,ang,model)
	local block = ents.Create( "wall_block" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = block:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end

function nz.Mapping.Functions.BoxSpawn(pos,ang)
	local box = ents.Create( "random_box_spawns" )
	box:SetPos( pos )
	box:SetAngles( ang )
	box:Spawn()
	box:PhysicsInit( SOLID_VPHYSICS )
end

function nz.Mapping.Functions.PerkMachine(pos, ang, id)
	local perkData = nz.Perks.Functions.Get(id)
	
	local perk = ents.Create("perk_machine")
	perk:SetPerkID(id)
	perk:TurnOff()
	perk:SetPos(pos)
	perk:SetAngles(ang)
	perk:Spawn()
	perk:Activate()
	perk:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = perk:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end



//Physgun Hooks
function nz.Mapping.Functions.OnPhysgunPickup( ply, ent )

	if ( ent:GetClass() == "prop_buys" or ent:GetClass() == "wall_block"  ) then 
		//Ghost the entity so we can put them in walls.
		local phys = ent:GetPhysicsObject()
		phys:EnableCollisions(false)
	end
	
end

function nz.Mapping.Functions.OnPhysgunDrop( ply, ent )

	if ( ent:GetClass() == "prop_buys" or ent:GetClass() == "wall_block" ) then 
		//Unghost the entity so we can put them in walls.
		local phys = ent:GetPhysicsObject()
		phys:EnableCollisions(true)
	end
	
end

hook.Add( "PhysgunPickup", "nz.OnPhysPick", nz.Mapping.Functions.OnPhysgunPickup )
hook.Add( "PhysgunDrop", "nz.OnDrop", nz.Mapping.Functions.OnPhysgunDrop )