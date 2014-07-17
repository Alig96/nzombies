function WeaponBuySpawn(position, gun, price, angle)
	if weapons.Get(gun) != nil then
		local ent1 = ents.Create("wall_buy") 
		ent1:SetAngles(angle)
		local pos = position
		pos.z = pos.z - ent1:OBBMaxs().z
		ent1:SetWeapon(gun, price)
		ent1:SetPos( pos )
		ent1:Spawn()
	else
		print("SKIPPED "..gun.. ". Are you sure you have it installed?")
	end
end

function ZedSpawn(position, link)
	local ent1 = ents.Create("zed_spawns") 
	local pos = position
	pos.z = pos.z - ent1:OBBMaxs().z
	ent1:SetPos( pos )
	ent1:Spawn()
	ent1.Link = link
end

function PlayerSpawn(position)
	local ent1 = ents.Create("player_spawns") 
	local pos = position
	pos.z = pos.z - ent1:OBBMaxs().z
	ent1:SetPos( pos )
	ent1:Spawn()
end

function RandomBoxSpawn(position, angle)
	local gun = ents.Create( "random_box_spawns" )
	gun:SetPos( position )
	gun:SetAngles( angle )
	gun:Spawn()
	gun:SetSolid( SOLID_VPHYSICS )
	gun:SetMoveType( MOVETYPE_NONE )
end

function ElecSpawn(pos, ang)
	//THERE CAN ONLY BE ONE TRUE HERO
	local prevs = ents.FindByClass("button_elec")
	if prevs[1] != nil then
		prevs[1]:Remove()
	end
	
	local ent1 = ents.Create( "button_elec" )
	ent1:SetPos( pos )
	ent1:SetAngles( ang )
	ent1:Spawn()
end

function DoorSpawn(doorID,flagsStr)
	nz.Doors.Functions.CreateLink(doorID, flagsStr)
end

function BlockSpawn(pos,ang,model)
	local block = ents.Create( "wall_block" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:SetSolid( SOLID_VPHYSICS )
	block:SetMoveType( MOVETYPE_NONE )
end

function BuyableBlockSpawn(pos,ang,model,flagsStr)
	if flagsStr == nil then flagsStr = "" end
	local block = ents.Create( "wall_block_buy" )
	block:SetModel( model )
	block:SetPos( pos )
	block:SetAngles( ang )
	block:Spawn()
	block:SetSolid( SOLID_VPHYSICS )
	block:SetMoveType( MOVETYPE_NONE )
	//Delay before setting flags
	timer.Simple(1, function() nz.Doors.Functions.CreateLinkSpec(block, flagsStr) end)
end

function PerkMachineSpawn(position, angle, data)
	local perk = ents.Create( "perk_machine" )
	perk:SetPos( position )
	perk:SetAngles( angle )
	perk:Spawn()
	perk:SetSolid( SOLID_VPHYSICS )
	perk:SetMoveType( MOVETYPE_NONE )
	perk:SetTheMachine(data)
end

function EasterEggSpawn(pos,ang,model)
	local egg = ents.Create( "easter_egg" )
	egg:SetModel( model )
	egg:SetPos( pos )
	egg:SetAngles( ang )
	egg:Spawn()
end

hook.Add( "InitPostEntity", "test_spawnents", function()
	//ZedSpawn(Vector(-159.803314, -615.409302, 128.031250), 0)
	//PlayerSpawn(Vector(-201.604568, -281.750580, 128.031250))
	//WeaponBuySpawn(Vector(271.441559,-631.911804,136.031250), "fas2_sg550", 100, Angle(2.816000,-41.491978,0.000000))
	//ElecSpawn(Vector(280.441559,-631.911804,136.031250), Angle(2.816000,-41.491978,0.000000))
end )
