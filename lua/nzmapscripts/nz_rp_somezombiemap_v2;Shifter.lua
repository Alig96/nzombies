--// Written by Logan (Deathking15, SwagalfThePink, and other names), contact me through steam or email me @ lobsterlogan43@yahoo.com
--// The script is REQUIRED for the map to work properly

--[[
TO-DO:
    - Decide whether I 
    want the poison gas to move on its own throughout the map and activating ALL the generators gets rid of it all at once
        OR
    want the poison gas to be everywhere and activating the generator creates safe zones
        AND
    - Decide whether the gas should
    Deal very slight and slow amount of damage
        OR
    Deal a lot but infrequent amounts of damage (play a cough sound to signify when the poison has damage the players)

EE Explanation:
    - Each time you play through the map
        - An unchanging set of non-PaP perks will be randomly assigned to the map's perk machine spots
        - The spawn area, some EE items, PaP, the power lever, and the wall buys will be chosen randomly from 1 of 3 precreated sets of spawn locations
    - There is a "poisonous" fog that travels through the map, slowly damaging players caught inside it, and blocking escape from the area
    - To escape the map, players must get rid the area of the poisonous fog, which can be accomplished by crafting an air-purifier, attaching one to several generators, and purifying the air

EE Steps
    - Find the 5 parts to craft the air pufifier
        - The 5 parts to be somewhat randomly distributed
    - Attach and activate the air purifier to the 4 seperate generators found throughout the map
        - One will be activated by pouring in 3 cans of gas
        - One will be activated as a normal soul-catcher
        - One...
        - One...
]]

local mapscript = { }

local variant = math.random( 3 )

local MasterTable = {
    [1] = {
        ["power_box"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["perk_machine"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false},
        ["wall_buys"] = {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), wep = "", price = 0, flipped = false}
    },
    [2] = {

    },
    [3] = {

    },
    ["pap"] = {
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), id = "pap"},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), id = "pap"},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 ), id = "pap"}        
    }
    ["AvailablePerks"] = {"jugg", "dtap2", "revive", "speed", "staminup", "mulekick", "deadshot"},
    ["Generators"] = {
        [1] = {
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )}
        },
        [2] = {
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )}
        },
        [3] = {
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )}
        },
        [4] = {
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
            {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )}
        }
    },
    ["GasCans"] = { --We only spawn 3
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
        {pos = Vector( 0, 0, 0 ), ang = Angle( 0, 0, 0 )},
    }

}

--//Build Table Information
local buildtbl = {
	model = "",
	pos = Vector( 10, 10, 10 ), --Position, relative to the table
	ang = Angle( 0, 0, 0 ), --Angles, also relative
	parts = {
		[""] = { 0, 1 },
		[""] = { 2 },
		[""] = { 3 },
		[""] = { 4 },
        [""] = {5}
	},
	usefunc = function( self, ply ) -- When it's completed and a player presses E
		if !ply:HasCarryItem( "" ) then
			ply:GiveCarryItem( "" )
		end
	end,
	--[[partadded = function(table, id, ply) -- When a part is added (optional)
		
	end,
	finishfunc = function(table) -- When all parts have been added (optional)
		
	end,]]
	text = ""
}

local EntDeletionTable = { } --Created ents are saved here for deletion after a game finishes, that way you don't have to refresh the map to get a new set of spawns
function mapscript.OnGameBegin()

    for k, v in pairs(MasterTable[variant]) do --This handles perk machines, wallbuys, and the lever
        local ent = ents.Create("")
        table.insert(EntDeletionTable, ent)
    end
    
end

return mapscript