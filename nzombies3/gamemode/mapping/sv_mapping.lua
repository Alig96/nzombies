//

function nz.Mapping.Functions.ZedSpawn(pos, link)

	local ent = ents.Create("zed_spawns") 
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	ent.link = link
	
end

function nz.Mapping.Functions.PlayerSpawn(pos)

	local ent = ents.Create("player_spawns") 
	pos.z = pos.z - ent:OBBMaxs().z
	ent:SetPos( pos )
	ent:Spawn()
	
end

function nz.Mapping.Functions.WallBuy(pos, gun, price, angle)

	if weapons.Get(gun) != nil then
	
		local ent1 = ents.Create("wall_buys") 
		ent1:SetAngles(angle)
		pos.z = pos.z - ent1:OBBMaxs().z
		ent1:SetWeapon(gun, price)
		ent1:SetPos( pos )
		ent1:Spawn()
		
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
	prop:SetSolid( SOLID_VPHYSICS )
	prop:SetMoveType( MOVETYPE_NONE )
	
	//REMINDER APPY FLAGS
	if flags != nil then
		nz.Doors.Functions.CreateLink( prop, flags )
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
end

function nz.Mapping.Functions.BlockSpawn(pos,ang,model)
	local block = ents.Create( "wall_block" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:SetSolid( SOLID_VPHYSICS )
	block:SetMoveType( MOVETYPE_NONE )
end

function nz.Mapping.Functions.BoxSpawn(pos,ang)
	local box = ents.Create( "random_box_spawns" )
	box:SetPos( pos )
	box:SetAngles( ang )
	box:Spawn()
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
	
end