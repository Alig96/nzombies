local META = FindMetaTable( "Player" )

local createWeps = {
	"weapon_physgun",
	"gmod_tool_wepbuy",
	"gmod_tool_playerspawns",
	"gmod_tool_zedspawns",
	"gmod_tool_doors",
	"gmod_tool_block",
	"gmod_tool_elec",
	"gmod_tool_randomboxspawns",
	"gmod_tool_perkmachinespawns",
	"gmod_tool_buyabledebris",
	"gmod_tool_ee",
}

function META:GiveCreateWeps()
	for k,v in pairs(createWeps) do
		self:Give(v)
	end
end

function META:StripCreateWeps()
	for k,v in pairs(createWeps) do
		self:StripWeapon(v)
	end
end

hook.Add("PlayerInitialSpawn", "nz_First_Spawn", function( ply ) 
	player_manager.SetPlayerClass( ply, "player_init" )
	nz.Rounds.Functions.SyncClients()
	nz.Doors.Functions.SyncClients()
end)


function GM:OnReloaded( )
	//Reload the data from the entities back into the tables
	//Door data
	local doors = {}
	for k,v in pairs(ents.GetAll()) do
		if v:IsDoor() then
			local data = v.Data
			if data != nil then
				if v:GetClass() != "wall_block_buy" then
					//Regular Doors
					local doorID = v:doorIndex()
					nz.Doors.Functions.CreateLink(doorID, data)
				else
					//Buyable Blocks
					nz.Doors.Functions.CreateLinkSpec(v, data)
				end
			end
		end
	end
	nz.Rounds.Functions.SyncClients()
	nz.Doors.Functions.SyncClients()
end

//Friendly Fire
hook.Add("EntityTakeDamage", "nz_friendlyfire", function( target, dmginfo )
    if ( target:IsPlayer() and dmginfo:GetAttacker():IsPlayer() ) then
		dmginfo:ScaleDamage( 0 )
    end
	return dmginfo
end)