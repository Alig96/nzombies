--//Written by Logan - written for Zet0r to (hopefully) be included in the official gamemode
--//This of course may be edited to work better, I ain't no great coder

--[[
TO-DO:	In-game
		- Find remaining navmesh bugs and finalize navmesh
			- Primarily, fix zombies getting stuck on spawn level - get a second player to help and watch how they path
		- Find and block cheat areas
		- Replace invisible walls once the lag-bug fix has been found
		- Find possible areas for traps (turret or electric)
		- Replace the song EE spots and find a suitable song to play
		- I think I have 2 of the same wallbuy, UMP .45 in both power switch room and foreman's office level?

		Mixed or Misc.
		- Collect and queue for download special sounds players may be missing (generator sounds for example)
		- Find the correct placement for C4 on the build table
		- Find good spots for camera pans when game ends

		Code-related
		Done - Combine consoles should be seperately activateable when their respective battery nodes have been attached
		Done - Fix the broken text with the combine consoles, fix the combine console that opens the garage sideroom
		Done - Disallow returning power after failing the EE
		Done - Prevent players from being able to reactivate power on power-failure rounds
		Done - Play the "cracking knuckles" animation on power switch repair
		Test - line 1276 - Fix the broken explosion effect on C4 explosion
		Test - Prevent double-tapping on train console activation
		Test - lines 889 & 1084, 872 - Fix any functions that continue post game-end (generator sounds, for example)
		Test - Garage doors don't work on failed EE step
		- Play a destruction sound when padlock is shot by PaPed weapon, line 944
		- Soul Catcher needs to properly animate soul-catching, starts at line 1237
		- Find good plug insertion sound to play, line 1196
		- Force knuckle-cracking animation to play while E is held down, ask zet0r for help

		Done, added reduntancies - Why aren't EE objects resetting when game ends?
		** Could I edit the map .bsp and remove all the lights?
			If possible:
			- Room lights should only turn on when each's generator has been filled - areas without a generator will turn on with reguler power
		** Could I replace my C4 EE item with CoD C4, or some throwable grenade replacement?

EE Overview (not necessarily done in this exact order) - 8 significant steps, with many smaller inbetween:
		- Find the missing power lever, and repair the power switch
			- Beware the faulty power, it will go out, after enough time
		- Find and attach the two (2) missing battery nodes above the two (2) combine consoles located on the roof of the warehouse
			- Requires a PaPed weapon to access one of the battery nodes
		- Activate the 5 combine consoles and open the storage room located in the garage
		- Find the 5 gas cans, and fuel the 5 generators
		- Activating the base station before each, activate the 5 outlier links
		- Following the order hinted at, activate the 5 console buttons
			- If these are activated incorrectly, the EE will FAIL
			- If the EE fails, the following happens:
				- Game (permanently) enters round infinity
				- 4 Panzer bosses spawn in front of the (new) map exit: the garage doors leading outside the map
				- Zombies will spawn outside of their normal spawn areas, i.e. everywhere
				- The EE can no longer be completed normally (progress can also no longer be continued, you must "win" via the garage doors)
				- In order to "escape" the map, players must open the garage doors and run out
		- Find the 4 components needed to craft plastic explosive, and craft the plastic explosive in the crafting table
			The components:
			- Tire, used for its rubber
			- Impact grenade, used for its blasting cap to ignite the plastic explosive
			- Nitroamine powder, the main explosive property in plastic explosives
			- Server box, used to create a timer for the blasting cap; must be charged before it can be used
		- Place the plastic explosive on the weak part of the fence by the train station (it will prompt)
		- Escape the map through the exposed tunnel

lua_run print( player.GetAll()[1]:GetEyeTrace().Entity:GetPos() )
lua_run print( player.GetAll()[1]:GetEyeTrace().Entity:GetAngles() )
lua_run print( player.GetAll()[1]:GetEyeTrace().HitPos )
]]
local mapscript = {}

--//Positions of generators
local generators = {
	{ pos = Vector( -324.481293, 985.716675, 27.194300 ), ang = Angle( -0.008, -1.304, 0.013 ) },
	{ pos = Vector( -2503.098877, -637.548645, 146.832428 ), ang = Angle( -0.000, 180.000, 0.000 ) },
	{ pos = Vector( -530.526611, -1575.066895, -121.032532 ), ang = Angle( -0.000, -180.000, -0.000 ) },
	{ pos = Vector( -2768.641113, -1372.191284, -369.08517 ), ang = Angle( -0.000, -180.000, -0.000 ) },
	{ pos = Vector( -2061.307373, 1403.317261, -157.157211 ), ang = Angle( -0.000, 180.000, 0.000 ) }
}

--//Possible positions of the Gas Cans
local gascanspawns = {
	{ { pos = Vector( 281.657257, -1538.109131, 122.891541 ), ang = Angle( 0.000, 90.000, 0.000 ) }, --Power Switch Room
		{ pos = Vector( -956.488892, -1478.487671, 123.242821 ), ang = Angle( -0.000, -180.000, 0.000 ) }, 
		{ pos = Vector( -501.245422, -1974.201050, 123.098961 ), ang = Angle( -0.000, -90.000, 0.000 ) } },
	{ { pos = Vector( -2614.193604, -792.145874, 6.813320 ), ang = Angle( -30.955, 92.504, -0.018 ) }, --PaP Floor
		{ pos = Vector( -2678.300049, -1757.024292, 49.664085 ), ang = Angle( 22.865, -164.534, 0.364 ) }, 
		{ pos = Vector( -2209.789795, -816.475830, 7.266649 ), ang = Angle( 0.000, 90.000, -0.000 ) } },
	{ { pos = Vector( -1882.064575, -2003.087524, -384.468384 ), ang = Angle( 23.955, -0.368, 0.070 ) }, --Warehouse
		{ pos = Vector( -2674.887939, -740.855103, -416.867920 ), ang = Angle( 31.790, -93.012, 0.072 ) }, 
		{ pos = Vector( -1876.407104, -618.244568, -128.735123 ), ang = Angle( -0.000, 0.000, -0.000 ) } },
	{ { pos = Vector( -663.979797, -1431.645508, -385.301178 ), ang = Angle( -0.000, -0.000, 0.000 ) }, --Garage
		{ pos = Vector( -817.737732, -1425.805420, -387.532410 ), ang = Angle( 89.700, -67.723, -111.667 ) }, 
		{ pos = Vector( -1334.050049, -2262.879395, -357.792572 ), ang = Angle( 62.510, -101.852, 12.076 ) } },
	{ { pos = Vector( -730.634888, -2468.336182, -5.215676 ), ang = Angle( -35.735, -90.746, 0.077 ) }, --Prison Cell Block
		{ pos = Vector( -60.586754, -2005.164673, -132.757187 ), ang = Angle( 0.000, -180.000, -0.000 ) }, 
		{ pos = Vector( 300.146576, -1618.740967, -132.940964 ), ang = Angle( 33.083, 5.192, -0.155 ) } },
}
local gascanlist = { }

--//Position of outer links
local links = {
	{ pos = Vector( -485.073120, 714.775635, 37.296597 ), ang = Angle( -2.823, -7.083, 0.082 ) }, --On desk
	{ pos = Vector( -2060.613037, -2014.947021, 175.752914 ), ang = Angle( -8.780, 97.645, -1.173 ) }, --Steam room
	{ pos = Vector( 190.453674, -1582.523315, -110.206749 ), ang = Angle( -0.665, -134.111, -0.199 ) }, --Foreman
	{ pos = Vector( -2342.335205, -239.686722, -386.362579 ), ang = Angle( -0.300, 42.795, 0.052 ) }, --Jugg
	{ pos = Vector( -1885.892090, 1419.159180, -420.200226 ), ang = Angle( -0.446, -46.191, 0.104 ) } --Under radiation
}

--//The lights above the Link Base
local lights1 = {
	{ pos = Vector( -575, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -555, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -535, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -595, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
	{ pos = Vector( -615, -1467, 220.0 ), ang = Angle( 0.000, -90.000, -0.000 ) },
}

--//The lights above the console buttons (by trains)
local lights2 = {
	{ pos = Vector( -912.5, -130, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, -82, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, -35, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, 13, -263 ), ang = Angle( 0, 0, 0 ) },
	{ pos = Vector( -912.5, 60, -263 ), ang = Angle( 0, 0, 0 ) },
}

--//The detonator to be charged; can spawn in any of the 3 places randomly
local detonatorspawn = {
	{ pos = Vector( -2002.968750, -553.781860, -394.328888 ), ang = Angle( -0.025, 99.925, 0.077 ) },
	{ pos = Vector( 187.443161, 1128.233643, 54.083485 ), ang = Angle( -0.233, 89.339, 0.178 ) },
	{ pos = Vector( -724.184204, -237.450592, -354.308746 ), ang = Angle( -2.876, 169.066, -0.773 ) },
}

--//Possible spawns for the power lever
local leverspawns = {
	{ pos = Vector( -2674.851563, -1690.906860, 21.732672 ), ang = Angle( -0.000, 18.880, 0.000 ) },
	{ pos = Vector( -2402.280762, -1964.696533, -378.522614 ), ang = Angle( -0.000, 176.260, 0.000 ) },
	{ pos = Vector( -715.065002, 1163.287354, -386.674530 ), ang = Angle( -45.000, 0.880, 0.000 ) },
	{ pos = Vector( -746.653564, -2736.561768, -18.268938 ), ang = Angle( -0.000, -142.120, 0.000 ) }
}

--//The 2 plugs that must be inserted into the outlets
local plugspawns = {
	{ pos = Vector( 22.798779, -1860.214111, -116.672722 ), ang = Angle( -88.753, -157.286, 141.505 ) }, --Foreman's office
	{ pos = Vector( -644.315369, 1170.212524, -183.919693 ), ang = Angle( -90.000, -47.860, 180.000 ) } --Bottom of elevator shaft
}

--//The 2 plug outlets that spawn on the roof
local plugoutletspawns = {
	{ pos = Vector( -2689.773682, -1538.550171, 427.433868 ), ang = Angle( 0.000, 0.000, -0.000 ) },
	{ pos = Vector( -2689.815186, -1384.584351, 445.547668 ), ang = Angle( -0.000, -0.000, 180.000 ) }
}

--The plug's position when inserted onto the outlets
local plugsonoutlets = {
	{ pos = Vector( -2685.263916, -1525.525757, 437.388794 ), ang = Angle( 0.000, 0.440, 0.000 ) },
	{ pos = Vector( -2684.125977, -1397.601318, 435.448975 ), ang = Angle( -0.000, -0.440, 180.000 ) }
}

--//The combine consoles that must be pushed to open garage sideroom - the console in the garage is done seperately as it has it's own logic
local breenconsolespawns = {
	{ pos = Vector( -2676.411865, -1543.952881, 375.467041 ), ang = Angle( -0.000, 90.000, 0.000 ) }, --Roof left side (when facing both)
	{ pos = Vector( -2678.811523, -1392.534058, 374.113800 ), ang = Angle( -0.000, 90.000, 0.000 ) }, --Roof right side
	{ pos = Vector( 99.254143, 1312.770020, -0.181114 ), ang = Angle( 0.000, 0.000, 0.000 ) }, --Computer room
	{ pos = Vector( -1883.329346, -639.092712, -433.118835 ), ang = Angle( -0.000, -90.000, -0.000 ) }, --Warehouse
	{ pos = Vector( -916.903503, -1956.711060, -148.039734 ), ang = Angle( 0.000, 180.000, 0.000 ) } --Foreman's floor
}

	--//These are the props used for the EE hinting with console buttons. Hint#a is the outlying prop w/ hint text, 
	--//hint#b is the prop above the console buttons, hint#a will electrocute when the respective button needs pushing
	--//This could have been one giant "for" statement with outlying tables... buuuuuuuuuuuuuut...
local prophints = { }
	local hint1a = ents.Create( "nz_script_prop" )
	hint1a:SetPos( Vector( -281.893066, -1002.959473, 9.120822 ) ) --By the rubble where the crashed helicopter normally lies
	hint1a:SetAngles( Angle( -0.000, -12.150, 0.168 ) )
	hint1a:SetModel( "models/props_c17/BriefCase001a.mdl" )
	hint1a:Spawn()
	hint1a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 1 ] = hint1a

	local hint1b = ents.Create( "nz_script_prop" )
	hint1b:SetPos( Vector( -885.444214, -128.211121, -346.147583 ) )
	hint1b:SetAngles( Angle( 0.000, -98.560, -93.304 ) )
	hint1b:SetModel( "models/props_c17/BriefCase001a.mdl" )
	hint1b:Spawn()

	--//--

	local hint2a = ents.Create( "nz_script_prop" )
	hint2a:SetPos( Vector( -1983.612427, -2021.229980, -102.058907 ) ) --In the Warehouse, on the rafters above
	hint2a:SetAngles( Angle( -48.433, 87.870, 90.805 ) )
	hint2a:SetModel( "models/props_c17/doll01.mdl" )
	hint2a:Spawn()
	hint2a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 2 ] = hint2a

	local hint2b = ents.Create( "nz_script_prop" )
	hint2b:SetPos( Vector( -913.857971, -79.409180, -334.235504 ) )
	hint2b:SetAngles( Angle( 58.459, 179.829, -91.969 ) )
	hint2b:SetModel( "models/props_c17/doll01.mdl" )
	hint2b:Spawn()

	--//--

	local hint3a = ents.Create( "nz_script_prop" )
	hint3a:SetPos( Vector( -718.101379, 907.215454, -380.273407 ) ) --By the accessible elevator shafts near the bottom-most entrance
	hint3a:SetAngles( Angle( 4.376, 100.548, -13.520 ) )
	hint3a:SetModel( "models/props_junk/watermelon01.mdl" )
	hint3a:Spawn()
	hint3a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 3 ] = hint3a

	local hint3b = ents.Create( "nz_script_prop" )
	hint3b:SetPos( Vector( -888.274048, -36.890865, -342.155243 ) )
	hint3b:SetAngles( Angle( 4.749, -112.861, 172.102 ) )
	hint3b:SetModel( "models/props_junk/watermelon01.mdl" )
	hint3b:Spawn()

	--//--

	local hint4a = ents.Create( "nz_script_prop" )
	hint4a:SetPos( Vector( -2556.203369, -2012.717529, 125.299492 ) ) --Next to the second computer in Steam room
	hint4a:SetAngles( Angle( -0.159, -149.331, 1.211 ) )
	hint4a:SetModel( "models/props_junk/Shoe001a.mdl" )
	hint4a:Spawn()
	hint4a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 4 ] = hint4a

	local hint4b = ents.Create( "nz_script_prop" )
	hint4b:SetPos( Vector( -874.233643, 13.012714, -382.704803 ) )
	hint4b:SetAngles( Angle( -0.132, 123.661, 1.303 ) )
	hint4b:SetModel( "models/props_junk/Shoe001a.mdl" )
	hint4b:Spawn()

	--//--

	local hint5a = ents.Create( "nz_script_prop" )
	hint5a:SetPos( Vector( -1313.937622, -2223.339844, -367.152771 ) ) --In one of the cars outside
	hint5a:SetAngles( Angle( -5.747, -14.542, -26.477 ) )
	hint5a:SetModel( "models/props_lab/binderblue.mdl" )
	hint5a:Spawn()
	hint5a:SetNWString( "NZText", "It seems strange for this to just be lying here..." )
	prophints[ 5 ] = hint5a

	local hint5b = ents.Create( "nz_script_prop" )
	hint5b:SetPos( Vector( -894.307007, 78.609192, -344.923279 ) )
	hint5b:SetAngles( Angle( 37.427, -26.780, 75.820 ) )
	hint5b:SetModel( "models/props_lab/binderblue.mdl" )
	hint5b:Spawn()

	--//--

--//Build Table Information
local buildabletbl = {
	model = "models/weapons/w_c4.mdl",
	pos = Vector( 10, 10, 10 ), --C4 Position, relative to the table
	ang = Angle( 0, 0, 0 ), --C4 Angles
	parts = {
		[ "charged_detonator" ] = { 0, 1 },
		[ "tire" ] = { 2 },
		[ "nitroamine" ] = { 3 },
		[ "blastcap" ] = { 4 }
	},
	usefunc = function( self, ply ) -- When it's completed and a player presses E
		if !ply:HasCarryItem( "c4" ) then
			ply:GiveCarryItem( "c4" )
		end
	end,
	--[[partadded = function(table, id, ply) -- When a part is added (optional)
		
	end,
	finishfunc = function(table) -- When all parts have been added (optional)
		
	end,]]
	text = "Press E to pick up the plastic explosive."
}

local finalround = 0
local function MyStartTouch( self, ply )
	if not ply:IsPlayer() and not ply:Alive() then return end
	finalround = nzRound:GetNumber()
	local escaped, escapednames = {}, {}
	ply:GodEnable() --Because cheeky nandos will try to break immersion by throwing explosives into the end area
	ply:SetTargetPriority( TARGET_PRIORITY_NONE )
	ply:Freeze( true )
	--//It was suggested to use GetAllPlayingAndAlive, but I want to avoid spectators doing nothing waiting for game to end
	if #player.GetAll() == 1 then
		nzEE.Cam:QueueView( 1, nil, nil, nil, true, nil, ply ) --Fade for aesthetics
		nzEE.Cam:QueueView( 15, Vector( -400.915161, -1325.068115, -380.741180 ), nil, Angle( 0.000, 91.500, 0.000 ), nil, nil, ply ) --Black screen
		nzEE.Cam:Music( "nz/easteregg/motd_good.wav", ply )
		nzEE.Cam:Text( "You escaped after ".. finalround .." rounds!", ply )
		--nzEE.Cam:QueueView( 0, Vector(  ), nil, Angle(  ), nil, nil, ply ) --Final Scene
		timer.Simple( 16, function()
			nzRound:Win( "Congratulations on escaping!", false )
			if ply:Alive() then ply:KillSilent() end
			ply:Freeze( false )
			ply:SetTargetPriority( TARGET_PRIORITY_PLAYER )
		end )
		nzEE.Cam:Begin()
		return
	end
	if not timer.Exists( "EscapeTimer" ) then
		timer.Create( "EscapeTimer", 30, 1, function()
			nzRound:Freeze( true )
			--//nzEE includes capability to target every player, but that leaves me without a way to target the players for Freezing and SetTargetPriority
			--//I don't know if including every nzEE function within the k, v is more or less efficient than not
			for k, v in pairs( player.GetAll() ) do
				v:Freeze( true )
				v:SetTargetPriority( TARGET_PRIORITY_NONE )
				nzEE.Cam:QueueView( 1, nil, nil, nil, true, nil, ply ) --Fade for aesthetics
				nzEE.Cam:QueueView( 15, Vector( -1243.480469, 668.968994, -176.465607 ), Vector( -1250.941895, -1273.481445, -164.941498 ), Angle( 0.000, -89.560, 0.000 ), true, nil, ply )
				if not escaped[ ply ] then
					nzEE.Cam:Music( "nz/easteregg/motd_bad.wav", ply )
					nzEE.Cam:Text( "You did not escape the facility...", ply )
				else
					nzEE.Cam:Music( "nz/easteregg/motd_good.wav", ply )
					nzEE.Cam:Text( "You escaped after ".. finalround .." rounds!", ply )
				end
				--[[nzEE.Cam:QueueView( 15, Vector(  ), Vector(  ), Angle(  ), true, nil, ply ) --Pan 1
				nzEE.Cam:Text( "Escapees: " .. table.concat( escapednames, ", " ) .. ".", ply ) 
				nzEE.Cam:QueueView( 15, Vector(  ), Vector(  ), Angle(  ), true, nil, ply ) --Pan 2
				nzEE.Cam:Text( "Thank you for playing!", ply )
				nzEE.Cam:QueueView( 0, Vector(  ), Vector(  ), Angle(  ), true, nil, ply ) --Final Scene]]
			end
			timer.Simple( 46, function() --After 20 more seconds, actually end the game
				nzRound:Win( "Congratulations to everyone who escaped!", false )
				for k, v in pairs( player.GetAllPlayingAndAlive() ) do
					v:Freeze( false )
					v:SetTargetPriority( TARGET_PRIORITY_PLAYER )
					if v:Alive() then v:KillSilent() end
				end
			end )
			timer.Destroy( "EscapeTimer" )
		end )
	end

	nzEE.Cam:QueueView( timer.TimeLeft( "EscapeTimer" ), Vector( -400.915161, -1325.068115, -380.741180 ), nil, Angle( 0.000, 91.500, 0.000 ), true, nil, ply )
	nzEE.Cam:Text( "Waiting for the rest of the players...", ply )
	PrintMessage( HUD_PRINTTALK, ply:Nick() .. " has escaped the map! All remaining players have " .. math.Round( timer.TimeLeft( "EscapeTimer" ) ) .. " seconds to follow suit!" ) --This should always be 30 the first time
	escaped[ ply ] = true --Used for logic
	table.insert( escapednames, ply:Nick() ) --Used for the end message
	nzEE.Cam:Begin()
end

--//Entity where train used to be
local escapeDetector = ents.Create( "nz_script_prop" )
escapeDetector:SetPos( Vector( -1060.883667, 848.851624, -393.830139 ) )
escapeDetector:SetModel( "models/hunter/blocks/cube2x2x2.mdl" )
escapeDetector:SetTrigger( true ) --Required for an entity to make use of StartTouch
escapeDetector:SetNoDraw( true )
escapeDetector:SetNotSolid( true )
escapeDetector:Spawn()
escapeDetector.StartTouch = MyStartTouch

--//Entity outside of garage doors
local escapeDetector2 = ents.Create( "nz_script_prop" )
escapeDetector2:SetPos( Vector( 362.214935, -1753.718994, -359.844818 ) )
escapeDetector2:SetModel( "models/hunter/blocks/cube1x8x1.mdl" )
escapeDetector2:SetTrigger( true ) --Required for an entity to make use of StartTouch
escapeDetector2:SetNoDraw( true )
escapeDetector2:Spawn()
escapeDetector2:SetNotSolid( true )
escapeDetector2.StartTouch = MyStartTouch

--//Console buttons, from left to right
local consolebuttons = { 2335, 2337, 2338, 2339, 2340 }

--//Setting up some extra variables
local poweredgenerators, establishedlinks, buttonorder, activatedconsoles, insertedplugs = { }, { }, { }, { }, { }

--//Creates the plug used to activate the breen consoles on roof
local plug = nzItemCarry:CreateCategory( "plug" )
plug:SetIcon( "spawnicons/models/props_lab/tpplug.png" )
plug:SetText( "Press E to pick up the battery plug." )
plug:SetDropOnDowned( true )
plug:SetShowNotification( true )
plug:SetResetFunction( function( self )
	for k, v in pairs( plugspawns ) do
		local ent = ents.Create( "nz_script_prop" )
		ent:SetModel( "models/props_lab/tpplug.mdl" )
		ent:SetPos( v.pos )
		ent:SetAngles( v.ang )
		ent:Spawn()
		v.ent = ent
		self:RegisterEntity( ent )
	end
end )
plug:SetDropFunction( function( self, ply )
	for k, v in pairs( plugspawns ) do
		if v.held == ply then -- If this is the one we're carrying
			local ent = ents.Create( "nz_script_prop" )
			ent:SetModel( "models/props_lab/tpplug.mdl" )
			ent:SetPos( ply:GetPos() )
			ent:SetAngles( Angle( 0, 0, 0 ) )
			ent:Spawn()
			ent:DropToFloor()
			ply:RemoveCarryItem( "plug" )
			v.held = nil
			ply.ent = nil
			self:RegisterEntity( ent )
			break
		end
	end
end )
plug:SetPickupFunction( function( self, ply, ent )
	for k, v in pairs( plugspawns ) do
		if v.ent == ent then
			ply:GiveCarryItem( self.id )
			ent:Remove()
			ply.ent = ent 
			break
		end
	end
end )
plug:SetCondition( function( self, ply )
	return !ply:HasCarryItem( "plug" )
end )
plug:Update()

--//Creates all of the gas cans
local gascans = nzItemCarry:CreateCategory( "gascan" )
gascans:SetIcon( "spawnicons/models/props_junk/metalgascan.png" ) --spawnicons/models/props_junk/gascan001a.png
gascans:SetText( "Press E to pick up the gas can." )
gascans:SetDropOnDowned( true )
gascans:SetShowNotification( true )
gascans:SetResetFunction( function( self )
    for k, v in pairs( gascanspawns ) do --Resets the spawn point for all gas cans
        gascanlist[ k ] = v[ math.random( 3 ) ]
    end
	for k, v in pairs( gascanlist ) do
		if v.ent then
			v.ent:Remove()
		end
		local ent = ents.Create( "nz_script_prop" )
		ent:SetModel( "models/props_junk/metalgascan.mdl" )
		ent:SetPos( v.pos )
		ent:SetAngles( v.ang )
		ent:Spawn()
		v.ent = ent --Sets each gascan in gascanlist as a unique entity
		self:RegisterEntity( ent )
	end
end )
gascans:SetDropFunction( function( self, ply )
	for k, v in pairs( gascanlist ) do -- Loop through all gascans
		if v.held == ply then -- If this is the one we're carrying
			local ent = ents.Create( "nz_script_prop" )
			ent:SetModel( "models/props_junk/metalgascan.mdl" )
			ent:SetPos( ply:GetPos() )
			ent:SetAngles( Angle( 0, 0, 0 ) )
			ent:Spawn()
			ent:DropToFloor()
			ply:RemoveCarryItem( "gascan" )
			v.held = nil
			ply.ent = nil
			self:RegisterEntity( ent )
			break
		end
	end
end )
gascans:SetPickupFunction( function( self, ply, ent )
	for k, v in pairs( gascanlist ) do
		if v.ent == ent then --If this is the correct gas can
			ply:GiveCarryItem( self.id )
			ent:Remove()
			v.held = ply --Save the player who's holding the can
			ply.ent = ent --Because I didn't know how to access player held objects and I'm too lazy to change it now
			break
		end
	end
end )
gascans:SetCondition( function( self, ply )
	return !ply:HasCarryItem( "gascan" )
end )
gascans:Update()

--//Creates the power switch lever
local lever = nzItemCarry:CreateCategory( "lever" )
lever:SetIcon( "spawnicons/models/nzprops/zombies_power_lever_handle.png" )
lever:SetText( "Press E to pick up the power switch lever." )
lever:SetDropOnDowned( true )
lever:SetShowNotification( true )
lever:SetDropFunction( function( self, ply )
	local lvr = ents.Create("nz_script_prop")
	lvr:SetModel( "models/nzprops/zombies_power_lever_handle.mdl" )
	lvr:SetPos( ply:GetPos() )
	lvr:SetAngles( Angle( 0, 0, 0 ) )
	lvr:Spawn()
	lvr:DropToFloor()
	ply:RemoveCarryItem( "lever" )
	self:RegisterEntity( lvr )
end )
lever:SetResetFunction( function( self )
	if lvr then lvr:Remove() end
	lvr, randomnumber = ents.Create("nz_script_prop"), math.random( 4 )
	lvr:SetModel( "models/nzprops/zombies_power_lever_handle.mdl" )
	lvr:SetPos( Vector( leverspawns[ randomnumber ].pos ) )
	lvr:SetAngles( Angle( leverspawns[ randomnumber ].ang ) )
	lvr:Spawn()
	self:RegisterEntity( lvr )
end )
lever:SetPickupFunction( function(self, ply, ent)
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
lever:Update()

--//Creates the console box which is used as the "detonator" by the C4 that is crafted
local detonator = nzItemCarry:CreateCategory( "detonator" )
detonator:SetIcon( "spawnicons/models/props_c17/consolebox05a.png" )
detonator:SetText( "Press E to pick up the console box." )
detonator:SetDropOnDowned( true )
detonator:SetShowNotification( true )
detonator:SetDropFunction( function( self, ply )
	local dtntr = ents.Create("nz_script_prop")
	dtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	dtntr:SetPos( ply:GetPos() )
	dtntr:SetAngles( Angle( 0, 0, 0 ) )
	dtntr:Spawn()
	dtntr:DropToFloor()
	ply:RemoveCarryItem( "detonator" )
	self:RegisterEntity( dtntr )
end )
detonator:SetResetFunction( function( self )
	if dtntr then
		dtntr:Remove()
	end
	local dtntr, randomnumber = ents.Create("nz_script_prop"), math.random( 3 )
	dtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	dtntr:SetPos( detonatorspawn[ randomnumber ].pos )
	dtntr:SetAngles( detonatorspawn[ randomnumber ].ang )
	dtntr:Spawn()
	self:RegisterEntity( dtntr )
end )
detonator:SetPickupFunction( function(self, ply, ent)
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
detonator:Update()

--//The entity you pick up from the soul catcher that is ACTUALLY used with the part creator table
local chargeddetonator = nzItemCarry:CreateCategory( "charged_detonator" )
chargeddetonator:SetIcon( "spawnicons/models/props_c17/consolebox05a.png" )
chargeddetonator:SetText( "Press E to pick up the charged console box." )
chargeddetonator:SetDropOnDowned( true )
chargeddetonator:SetShowNotification( true )
chargeddetonator:SetDropFunction( function( self, ply )
	local chrgddtntr = ents.Create( "nz_script_prop" )
	chrgddtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	chrgddtntr:SetPos( ply:GetPos() )
	chrgddtntr:SetAngles( Angle( 0, 0, 0 ) )
	chrgddtntr:Spawn()
	chrgddtntr:DropToFloor()
	ply:RemoveCarryItem( "charged_detonator" )
	self:RegisterEntity( chrgddtntr )
end )
chargeddetonator:SetResetFunction( function( self )
	chrgddtntr = ents.Create( "nz_script_prop" )
	chrgddtntr:SetModel( "models/props_c17/consolebox05a.mdl" )
	chrgddtntr:SetPos( Vector( -1018.099365, -1729.259888, -334.313202 ) )
	chrgddtntr:SetAngles( Angle( -90.000, 90.000, 180.000 ) )
	chrgddtntr:Spawn()
	chrgddtntr:SetNoDraw( true )
	self:RegisterEntity( chrgddtntr )
end )
chargeddetonator:SetPickupFunction( function(self, ply, ent)
	if not ent.CanPickup then return end
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
chargeddetonator:Update()

--//Tire that is used for the C4 and prop table
local rubber = nzItemCarry:CreateCategory( "tire" )
rubber:SetIcon( "spawnicons/models/props_vehicles/carparts_tire01a.png" )
rubber:SetText( "Press E to pick up the tire." )
rubber:SetDropOnDowned( true )
rubber:SetShowNotification( true )
rubber:SetDropFunction( function( self, ply )
	local rbr = ents.Create( "nz_script_prop" )
	rbr:SetModel( "models/props_vehicles/carparts_tire01a.mdl" )
	rbr:SetPos( ply:GetPos() )
	rbr:SetAngles( Angle( 0, 0, 0 ) )
	rbr:Spawn()
	rbr:DropToFloor()
	ply:RemoveCarryItem( "tire" )
	self:RegisterEntity( rbr )
end )
rubber:SetResetFunction( function( self )
	if rbr then
		rbr:Remove()
	end
	rbr = ents.Create( "nz_script_prop" )
	rbr:SetModel( "models/props_vehicles/carparts_tire01a.mdl" )
	rbr:SetPos( Vector( -2365.017578, -636.389343, 391.921906 ) )
	rbr:SetAngles( Angle( -0.486, -44.491, 0.118 ) )
	rbr:Spawn()
	self:RegisterEntity( rbr )
end )
rubber:SetPickupFunction( function(self, ply, ent)
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
rubber:Update()

--//Nitroamine powder used for the C4
local powder = nzItemCarry:CreateCategory( "nitroamine" )
powder:SetIcon( "spawnicons/models/props_lab/jar01a.png" )
powder:SetText( "Press E to pick up the nitroamine powder." )
powder:SetDropOnDowned( true )
powder:SetShowNotification( true )
powder:SetDropFunction( function( self, ply )
	local pwdr = ents.Create( "nz_script_prop" )
	pwdr:SetModel( "models/props_lab/jar01a.mdl" )
	pwdr:SetPos( ply:GetPos() )
	pwdr:SetAngles( Angle( 0, 0, 0 ) )
	pwdr:Spawn()
	pwdr:DropToFloor()
	ply:RemoveCarryItem( "nitroamine" )
	self:RegisterEntity( pwdr )
end )
powder:SetResetFunction( function( self )
	if pwdr then
		pwdr:Remove()
	end
	pwdr = ents.Create( "nz_script_prop" )
	pwdr:SetModel( "models/props_lab/jar01a.mdl" )
	pwdr:SetPos( Vector( -189.020172, -1453.000366, -392.523224 ) )
	pwdr:SetAngles( Angle( -0.000, -139.400, 0.000 ) )
	pwdr:Spawn()
	self:RegisterEntity( pwdr )
end )
powder:SetPickupFunction( function( self, ply, ent )
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
powder:Update()

--//Blasting Cap used for the C4
local blast = nzItemCarry:CreateCategory( "blastcap" )
blast:SetIcon( "spawnicons/models/Items/AR2_Grenade.png" )
blast:SetText( "Press E to pick up the impact grenade." )
blast:SetDropOnDowned( true )
blast:SetShowNotification( true )
blast:SetDropFunction( function( self, ply )
	local cap = ents.Create( "nz_script_prop" )
	cap:SetModel( "models/Items/AR2_Grenade.mdl" )
	cap:SetPos( ply:GetPos() )
	cap:SetAngles( Angle( 0, 0, 0 ) )
	cap:Spawn()
	cap:DropToFloor()
	ply:RemoveCarryItem( "blastcap" )
	self:RegisterEntity( cap )
end )
blast:SetResetFunction( function( self )
	if cap then
		cap:Remove()
	end
	cap = ents.Create( "nz_script_prop" )
	cap:SetModel( "models/Items/AR2_Grenade.mdl" )
	cap:SetPos( Vector( 271.141052, -1687.194580, -148.408340 ) )
	cap:SetAngles( Angle( 0.000, -71.610, 0.000 ) )
	cap:Spawn()
	self:RegisterEntity( cap )
end )
blast:SetPickupFunction( function( self, ply, ent )
	ply:GiveCarryItem( self.id )
	ent:Remove()
end )
blast:Update()

--//The actual C4
local actualc4 = nzItemCarry:CreateCategory( "c4" )
actualc4:SetIcon( "spawnicons/models/weapons/w_c4.png" )
actualc4:SetDropOnDowned( false )
actualc4:SetShowNotification( true )
actualc4:SetResetFunction( function( self )
	for k, v in pairs( player.GetAll() ) do
		if v:HasCarryItem( "c4" ) then
			ply:RemoveCarryItem( "c4" )
		end
	end
end )
actualc4:Update()

--//Function to be used to check for establishedlinks' or poweredgenerators' validity
local function CheckTable( tbl )
	if #tbl == 0 then return false end
	for k, v in pairs( tbl ) do
		if not v then
			return false
		end
	end
	return true
end

--//I use this to check and set text for the base link and the outlying links. Maybe not super efficient, but it should be 100% consistent, whereas it wasn't before
local function SetTexts()
	if nzElec:IsOn() then
		for k, v in pairs( links ) do
			if not poweredgenerators[ k ] then
				v.ent:SetNWString( "NZText", "You must turn on the room's generator first." )
			elseif not establishedlinks[ k ] then
				if linkstarted then
					v.ent:SetNWString( "NZText", "Press E to establish a link with the home receiver." )
				else
					v.ent:SetNWString( "NZText", "You must activate the home link first." )
				end
			else
				v.ent:SetNWString( "NZText", "" )
			end 
		end
		if not CheckTable( establishedlinks ) then
			if linkstarted then
				baselink:SetNWString( "NZText", "" )
			else
				baselink:SetNWString( "NZText", "Press E to begin linking." )
			end
		else
			baselink:SetNWString( "NZText", "All receivers have been linked." )
		end
	else
		for k, v in pairs( links ) do
			if not poweredgenerators[ k ] then
				v.ent:SetNWString( "NZText", "You must turn on the room's generator first." )
			elseif not establishedlinks[ k ] then
				v.ent:SetNWString( "NZText", "The power must be turned on before linking." )
			else
				v.ent:SetNWString( "NZText", "" )
			end 
		end
		if not CheckTable( establishedlinks ) then
			baselink:SetNWString( "NZText", "The power must be turned on before beginning linking." )
		else
			baselink:SetNWString( "NZText", "All receivers have been linked." )
		end
	end
end

--//Starts the puzzle; press the buttons in the right order or fail the EE
local nextpush = 1
function StartPuzzle()
	local onemiss = false
	for k, v in pairs( buttonorder ) do --At this point, buttonorder is a randomized table version of consolebuttons (which is all 5 console button mapspawn integers)
		local consolebutton = ents.GetMapCreatedEntity( v[ 1 ] )
		consolebutton:SetNWString( "NZText", "Press E to activate button " .. v[ 1 ] ) -- consolebuttons[ table.KeyFromValue( buttonorder, v[ 1 ] ) ] )
		consolebutton.OnUsed = function()
			if not timer.Exists( "ButtonWait" .. k ) then
				timer.Create( "ButtonWait" .. k, 1, 1, function()
					timer.Destroy( "ButtonWait" .. k )
				end )
			else
				return
			end
			print( "consolebutton.OnUsed called", k, nextpush )
			if not nzElec:IsOn() then return end
			consolebutton:EmitSound( "buttons/button9.wav" )
			--//You can push a button more than once, and it can fail the EE. This is more a "feature," not a bug.
			if k == nextpush then
				nextpush = nextpush + 1
				if nextpush == 6 then --Nextpush is only 6 if button 5 has been pushed
					timer.Simple( 1, function()
						for k, v in pairs( player.GetAll() ) do
							v:SendLua( "surface.PlaySound( \"ambient/alarms/train_horn2.wav\" ) " )
						end
					end )
					thefence.Allow = true
					ents.GetMapCreatedEntity( "2205" ):Remove() --Maybe move it then delete it?
				end
			elseif not onemiss then
				--This was originally played when the EE failed, but there are effects already implemented for the start of Round Infinity
				for k, v in pairs( player.GetAll() ) do
					v:SendLua( "surface.PlaySound( \"ambient/levels/labs/electric_explosion4.wav\" ) " )
				end
				--Create the lightning aura across all EE-related and power-related props, minus the gas generators and anything related to the C4
				for k, v in pairs( buttonorder ) do
					local ent = ents.GetMapCreatedEntity( v[ 1 ] )
					Electrify( ent )
				end
				for k, v in pairs( links ) do
					local linkprop = v.ent
					Electrify( linkprop )
				end
				for k, v in pairs( ents.FindByClass( "perk_machine" ) ) do
					Electrify( v )
				end
				Electrify( ents.FindByClass( "power_box" )[ 1 ] )
				Electrify( baselink )
				onemiss = true
			else
				FailPrimaryEE()
				nextpush = 0
			end
		end
		--//This is for the hint props
		local effecttimer = 0
		v[ 2 ].Think = function()
			if k == nextpush and effecttimer < CurTime() then
				local effect = EffectData()
				effect:SetScale( 1 )
				effect:SetEntity( v[ 2 ] )
				util.Effect( "lightning_aura", effect )
				effecttimer = CurTime() + 0.5
			end
		end
	end
end

--//All the EE items that get randomized text from this table. I have purposefully added in some EE sayings from CoD to increase sp00kiness.
local availabletext = { "A", "a", "B", "b", "C", "c", "D", "d", "E", "e", "F", "f", "G", "g", "H", "h", "I", "i", "J", "j", "K", "k", "L", "l", "M", "m",
						"N", "n", "O", "o", "P", "p", "Q", "q", "R", "r", "S", "s", "T", "t", "U", "u", "V", "v", "W", "w", "X", "x", "Y", "y", "Z", "z",
						"!", "%", "ERROR", "*", "&", "SELF-DESTRUCT", "ESCAPE", "#", "SYSTEM", "POWER", "OFF", "ON", "HUMANOID", "METRO", " ", "ENTER", "EXIT",
						"ASCEND_FROM_DARKNESS", "SAMANTHA", "FAILURE", "EVACUATE", "115", "ELEMENT", "CRITICAL", "-", "_", "RUN" } --Can we add more?

--//Function that runs when the EE fails, also sets all the fun text
local PermaOff = false
function FailPrimaryEE()
	nzElec:Reset()
	RemoveUseFunction( ents.FindByClass( "power_box" )[ 1 ] )
	PermaOff = true

	local mixedtext = ""
	--//All link outliers
	for k, v in pairs( links ) do
		for i = 1, 6 do
			mixedtext = mixedtext .. table.Random( availabletext )
		end
		v.ent:EmitSound( "ambient/energy/zap5.wav" )
		v.ent:SetNWString( "NZText", mixedtext )
		mixedtext = ""
		v.ent.OnUsed = function()
			return true
		end
		SetPermaElectrify( v.ent )
	end
	--//All console buttons
	for k, v in pairs( consolebuttons ) do
		local consolebutton = ents.GetMapCreatedEntity( v )
		for i = 1, 6 do
			mixedtext = mixedtext .. table.Random( availabletext )
		end
		consolebutton:EmitSound( "ambient/energy/zap5.wav" )
		consolebutton:SetNWString( "NZText", mixedtext )
		mixedtext = ""
		consolebutton.OnUsed = function()
			return true
		end
		SetPermaElectrify( consolebutton )
	end
	for i = 1, 6 do
		mixedtext = mixedtext .. table.Random( availabletext )
	end
	baselink:EmitSound( "ambient/energy/zap5.wav" )
	baselink:SetNWString( "NZText", mixedtext )
	mixedtext = ""
	baselink.OnUsed = function()
		return true
	end
	SetPermaElectrify( baselink )
	for k, v in pairs( ents.FindByClass( "perk_machine" ) ) do
		SetPermaElectrify( v )
	end
	SetPermaElectrify( ents.FindByClass( "power_box" )[ 1 ] )
	local bossSpawns = {
		{ pos = Vector( 178.379028, -1902.926025, -391.968750 ) },
		{ pos = Vector( 180.650421, -1782.478638, -391.968750 ) },
		{ pos = Vector( 182.273560, -1696.408691, -391.968750 ) },
		{ pos = Vector( 184.300781, -1588.911377, -391.968750 ) }
	}
	timer.Simple( 10, function()
		for k, v in pairs( bossSpawns ) do
			local zombie = ents.Create( "nz_zombie_boss_panzer" ) --This should be a boss zombie
			zombie:SetPos( v.pos )
			zombie:Spawn()
		end
	end )
	finalround = nzRound:GetNumber()
	nzDoors:OpenLinkedDoors( "20" ) --This enables the 15 bajillion extra zombie spawns
	nzRound:RoundInfinity()
	--[[ TO-DO
	- Garage Door opens after 60 seconds ( Entity:SetPlaybackRate( 0.5 ) to slow the animation down )
		- Button IDs: 5238, 5243
		- Garage door IDs: 1771, 1772
	- Create "escape" area where players screens turn back and lose control 
		- This should probably be done outside of this function ]]
end

--//Creates the lightning aura once around the given ent
function Electrify( ent )
	local effect = EffectData()
	effect:SetScale( 1 )
	effect:SetEntity( ent )
	util.Effect( "lightning_aura", effect )
end

--//Creates a never-ending lightning aura around the given ent
function SetPermaElectrify( penis )
	local function PermaElectrify( ent )
		if not game.active then --Find the appropriate variable/function return
			return false
		end
		local effecttimer = 0
		if effecttimer < CurTime() then
			local effect = EffectData()
			effect:SetScale( 1 )
			effect:SetEntity( ent )
			util.Effect( "lightning_aura", effect )
			effecttimer = CurTime() + 0.5
		end
	end
	penis.Think = PermaElectrify
end

local UseFunctions = { }
local function RemoveUseFunction( ent )
	if ent.OnUsed() or ent.OnUsed then
		UseFunctions[ #UseFunctions + 1 ] = { ent, ent.OnUsed }
		ent.OnUsed = nil
	end
end

local function ReturnUseFunction( ent )
	for k, v in pairs( UseFunctions ) do
		if v[ 1 ] = ent then
			ent.OnUsed = v[ 2 ]
			v = nil
			break
		end
	end
end

local function CleanUpMyMess()
	if buttonorder then
		for k, v in pairs( buttonorder ) do
			local ent = ents.GetMapCreatedEntity( v[ 1 ] )
			ent.Think = nil
		end
	end
	if links[ 1 ].ent then
		for k, v in pairs( links ) do
			local linkprop = v.ent
			linkprop.Think = nil
		end
	end
	for k, v in pairs( ents.FindByClass( "perk_machine" ) ) do
		v.Think = nil
	end
	ents.FindByClass( "power_box" )[ 1 ].Think = nil
	if baselink then
		baselink.Think = nil
	end

	ReturnUseFunction( ents.FindByClass( "power_box" )[ 1 ] )

	gascans:Reset()
	lever:Reset()
	detonator:Reset()
	chargeddetonator:Reset()
	rubber:Reset()
	powder:Reset()
	blast:Reset()
	plug:Reset()
	actualc4:Reset()
end

local LogansScriptRunning
function mapscript.OnGameBegin()
	--//Removes any of previous game's remaining entities, if they're still hanging around, and reset them for the next game
	CleanUpMyMess()

	--//For any players that beat the map, and continue playing a second time
	for k, v in pairs( player.GetAll() ) do
		v:GodDisable()
	end

	--//Reset important tables/vars for map re-playability
	poweredgenerators, establishedlinks, LogansScriptRunning = { }, { }, true

	--//Locks and prevents opening of the following: foreman's office door, garage side-room, EE-fail garage doors 1 & 2
	ents.GetMapCreatedEntity( "3033" ):Fire( "Lock" ) 
	ents.GetMapCreatedEntity( "2959" ):Fire( "Lock" )
	ents.GetMapCreatedEntity( "5238" ):Fire( "Lock" )
	ents.GetMapCreatedEntity( "5243" ):Fire( "Lock" )

	--//Generates the random list of console buttons and their prop hint entity
	local fakelist = table.Copy( consolebuttons )
	for i = 1, #fakelist do
		local choice = table.Random( fakelist )
		table.insert( buttonorder, { choice, prophints[ table.KeyFromValue( consolebuttons, choice ) ] } )
		table.RemoveByValue( fakelist, choice )
	end

	--//The lock on Foreman's office - can be destroyed by shooting it w/ a PaPed weapon
	lock  = ents.Create( "nz_script_prop" )
	lock:SetPos( Vector( -6.992205, -1775.884033, -107.849129 ) )
	lock:SetAngles( Angle( -0.000, -0.000, -0.000 ) )
	lock:SetModel( "models/props_wasteland/prison_padlock001a.mdl" )
	lock:Spawn()
	lock:SetNWString( "NZText", "A padlock, could probably be destroyed with a powerful enough weapon." )
	lock.OnTakeDamage = function( self, dmginfo )
		if not dmginfo or not dmginfo:GetAttacker():IsPlayer() then return end
		local wep = dmginfo:GetAttacker():GetActiveWeapon()
		if not IsValid( wep ) or not wep:HasNZModifier( "pap" ) then return end
		lock:EmitSound( "" ) --idk what sound should go here
		ents.GetMapCreatedEntity( "3033" ):Fire( "Unlock" )
		lock:Remove()
		--lock:SetNotSolid( true )
		--lock:SetNoDraw( true )
	end
	
	--//Build Table Info Continued
	tbl = ents.Create( "buildable_table" )
	tbl:AddValidCraft( "Plastic Explosive", buildabletbl )
	tbl:SetPos( Vector( -1384.457886, 971.894897, -184.897278 ) )
	tbl:SetAngles( Angle( 0.000, -90.000, 0.000 ) )
	tbl:Spawn()

	--//Creates the broken power switch
	powerswitch = ents.Create( "nz_script_prop" )
	powerswitch:SetPos( Vector( 109.952400, -1472.475220, 107.462799 ) )
	powerswitch:SetAngles( Angle( -0.000, -90.000, 0.000 ) )
	powerswitch:SetModel( "models/nzprops/zombies_power_lever.mdl" ) 
	powerswitch:SetNWString( "NZText", "You must fix the power switch before turning on the power." )
	powerswitch:SetNWString( "NZRequiredItem", "lever" )
	powerswitch:SetNWString( "NZHasText", "Press E to attach the lever onto the power switch." )
	powerswitch:Spawn()
	powerswitch:Activate()
	powerswitch.OnUsed = function( self, ply )
		if not ply:HasCarryItem( "lever" ) or activated then return end
		activated = true
		local actualpowerswitch, effecttimer2 = ents.Create( "power_box" ), 0
		actualpowerswitch:SetPos( self:GetPos() )
		actualpowerswitch:SetAngles( self:GetAngles() )
		actualpowerswitch.OnUsed = function( self, ply )
			local initialstart = true
		end
		actualpowerswitch.Think = function( )
			if initialstart and CurTime() > effecttimer2 and not nzElec.IsOn() then
				local effect = EffectData()
				effect:SetScale( 1 )
				effect:SetEntity( actualpowerswitch )
				util.Effect( "lightning_aura", effect )
				effecttimer2 = CurTime() + 0.5
			end
		end
		ply:Give( "nz_packapunch_arms" )
		timer.Simple( 1.8, function() --Cracking knuckles animation plays for 1.8 seconds
			actualpowerswitch:Spawn()
			powerswitch:Remove()
			actualpowerswitch:SetNWString( "NZText", "There's no certainty power will remain on..." )
			ply:RemoveCarryItem( "lever" )
		end )
	end

	--//The base link the must be activated before activated an outlying link
	baselink = ents.Create( "nz_script_prop" )
	baselink:SetPos( Vector( -580.019531, -1488.002930, 143.345886 ) )
	baselink:SetAngles( Angle( 0.008, -85.925, -0.133 ) )
	baselink:SetModel( "models/props_lab/reciever_cart.mdl" )
	baselink:SetNWString( "NZText", "The power must be turned on before starting the linking." )
	baselink:Spawn()
	baselink:Activate()
	baselink.OnUsed = function( self, ply )
		--//If electricity is on, link isn't currently activated, and not all of the links are established, then...
		if not nzElec.IsOn() or linkstarted or CheckTable( establishedlinks ) then return end 
		linkstarted = true
		SetTexts()
	end
	local effecttimer, stop = 0, false
	baselink.Think = function()
		if linkstarted and CurTime() > effecttimer and nzElec.IsOn() or CheckTable( establishedlinks ) and nzElec.IsOn() then
			local effect = EffectData()
			effect:SetScale( 1 )
			effect:SetEntity( baselink )
			util.Effect( "lightning_aura", effect )
			effecttimer = CurTime() + 0.5
		end
	end

	--//These are just extra entities placed inside the link base to make it more aestheticly pleasing
	extra1 = ents.Create( "nz_script_prop" )
	extra1:SetPos( Vector( -574.423828, -1495.917358, 129.057999 ) )
	extra1:SetAngles( Angle( -0.294, -88.05,5 -0.171 ) )
	extra1:SetModel( "models/props_lab/reciever01b.mdl" )
	extra1:Spawn()

	extra2 = ents.Create( "nz_script_prop" )
	extra2:SetPos( Vector( -573.884705, -1496.818726, 134.691925 ) )
	extra2:SetAngles( Angle( -1.788, -92.981, 0.029 ) )
	extra2:SetModel( "models/props_lab/reciever01d.mdl" )
	extra2:Spawn()

	extra3 = ents.Create( "nz_script_prop" )
	extra3:SetPos( Vector( -574.466370, -1495.319702, 121.456146 ) )
	extra3:SetAngles( Angle( -0.769, -86.667, -0.191 ) )
	extra3:SetModel( "models/props_lab/reciever01c.mdl" )
	extra3:Spawn()

	--//Creates all of the generators
	for k, v in pairs( generators ) do
		poweredgenerators[ k ] = false
		local gen = ents.Create( "nz_script_prop" )
		gen:SetPos( v.pos )
		gen:SetAngles( v.ang )
		gen:SetModel( "models/props_wasteland/laundry_washer003.mdl" ) --It doesn't look anything like a washing machine?! Or a geneator, tbh.
		gen:SetNWString( "NZText", "You must fill this generator with gasoline to power it." )
		gen:SetNWString( "NZRequiredItem", "gascan" )
		gen:SetNWString( "NZHasText", "Press E to fuel this generator with gasoline." )
		gen:Spawn()
		gen:Activate()
		gen.OnUsed = function( self, ply )
			if ply:HasCarryItem( "gascan" ) and not poweredgenerators[ k ] then --If ply has gas can and generator is unpowered
				for k, v in pairs( gascanspawns ) do
					if v == ply.ent then
						v.used = true
						v.held = false
						continue
					end
				end
				PrintMessage( HUD_PRINTTALK, "Generator " .. k .. " has been fueled." )
				ply:RemoveCarryItem( "gascan" )
				poweredgenerators[ k ] = true
				gen:SetNWString( "NZText", "This generator is powered on." )
				gen:SetNWString( "NZHasText", "This generator has already been fueled." )
				gen:EmitSound( "player/items/gas_can_fill_pour_01.wav" ) --gen:EmitSound( "l4d2/gas_pour.wav" )
				--Plays the generator fueling and generator humming sounds
				timer.Simple( 4, function()
					if not gen then return end
					gen:EmitSound( "level/generator_start_loop.wav" ) --gen:EmitSound( "l4d2/generator_start.wav" )
					timer.Simple( 9, function()
						timer.Create( "Gen" .. k, 3, 0, function()
							if not gen then return end
							gen:EmitSound( "l4d2/generator_humm.ogg" )
						end )
					end )
				end )
				SetTexts()
			end
		end
		gen.Think = function()
			--If a new script is loaded, destory the generator humming sounds
			if not poweredgenerators[ k ] and timer.Exists( "Gen" .. k ) then
				timer.Destroy( "Gen" .. k )
			end
		end
	end

	--Creates all of the links
	for k, v in pairs( links ) do
		establishedlinks[ k ] = false
		local link = ents.Create( "nz_script_prop" )
		v.ent = link
		link:SetPos( v.pos )
		link:SetAngles( v.ang )
		link:SetModel( "models/props_lab/reciever01b.mdl" ) 
		link:SetNWString( "NZText", "The room's generator must be powered on first." )
		link:Spawn()
		link:Activate()
		link.OnUsed = function( self, ply )
			if not linkstarted or establishedlinks[ k ] or not poweredgenerators[ k ] or not nzElec.IsOn() then return end
			PrintMessage( HUD_PRINTTALK, "Link " .. k .. " has been activated." )
			linkstarted = false
			establishedlinks[ k ] = true
			link:EmitSound( "ambient/machines/teleport1.wav" )
			lights1[ k ].ent:SetModel( "models/props_c17/light_cagelight02_on.mdl" )
			lights2[ k ].ent:SetModel( "models/props_c17/light_cagelight02_on.mdl" )
			SetTexts()
			if CheckTable( establishedlinks ) then
				StartPuzzle() --Should this be an EE step function? - Probably
			end
		end
		local effecttimer2 = 0
	end

	--//Creates the lights above the base link
	for k, v in pairs( lights1 ) do
		local light = ents.Create( "nz_script_prop" )
		v.ent = light
		light:SetPos( v.pos )
		light:SetAngles( v.ang )
		light:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end

	--//Creates the lights in the control room
	for k, v in pairs( lights2 ) do
		local light = ents.Create( "nz_script_prop" )
		v.ent = light
		light:SetPos( v.pos )
		light:SetAngles( v.ang )
		light:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end

	--//Creates all the breen consoles
	for k, v in pairs( breenconsolespawns ) do
		local breen = ents.Create( "nz_script_prop" )
		activatedconsoles[ k ] = false
		breen:SetPos( v.pos )
		breen:SetAngles( v.ang )
		breen:SetModel( "models/props_combine/breenconsole.mdl" )
		if k == 1 or k == 2 then
			breen:SetNWString( "NZText", "Powernode inlet(s) missing. Replace missing powernode inlet(s) before continuing operations." )
		else
			breen:SetNWString( "NZText", "Press E to activate the combine powernode." )
		end
		breen:Spawn()
		breen:Activate()
		breen.OnUsed = function()
			--The first and second breen consoles (which are both on the roof) require their battery outlet be plugged in above it to operate
			if ( k == 1 or k == 2 ) and not insertedplugs[ k ] or activatedconsole[ k ] then return end
			activatedconsoles[ k ] = true
			breen:EmitSound( "buttons/combine_button1.wav" )
			breen:SetNWString( "NZText", "This powernode has been activated." )
			if CheckTable( activatedconsoles ) then
				sideroomopener:SetNWString( "NZText", "Press E to open Combine Armoury." )
			end
		end
	end

	--//Creates the 2 plug outlets on the roof
	for k, v in pairs( plugoutletspawns ) do
		local outlet = ents.Create( "nz_script_prop" )
		insertedplugs[ k ] = false
		outlet:SetPos( v.pos )
		outlet:SetAngles( v.ang )
		outlet:SetModel( "models/props_lab/tpplugholder.mdl" )
		outlet:SetNWString( "NZText", "Missing powernode inlet." )
		outlet:SetNWString( "NZRequiredItem", "plug" )
		outlet:SetNWString( "NZText", "Press E to insert powernode inlet." )
		outlet:Spawn()
		outlet:Activate()
		outlet.OnUsed = function( self, ply )
			if not ply:HasCarryItem( "plug" ) then return end
			insertedplugs[ k ] = true
			outlet:SetNWString( "NZText", "" )
			ply:RemoveCarryItem( "plug" )
			self:EmitSound( "" ) --Find some electrocution sound
			local ent = ents.Create( "nz_script_prop" )
			ent:SetModel( "models/props_lab/tpplug.mdl" )
			ent:SetPos( plugsonoutlets[ k ].pos )
			ent:SetAngles( plugsonoutlets[ k ].ang )
			ent:Spawn()
		end
	end

	--//This is the breen console by the garage sideroom, can only be successfully activated once all others have
	sideroomopener = ents.Create( "nz_script_prop" ) ---294.531677 -1556.127808 -390.432404, 0.000 0.000 0.000
	sideroomopener:SetPos( Vector( -294.531677, -1556.127808, -390.432404 ) )
	sideroomopener:SetAngles( Angle( 0.000, 0.000, 0.000 ) )
	sideroomopener:SetModel( "models/props_combine/breenconsole.mdl" )
	sideroomopener:SetNWString( "NZText", "ERROR" )
	sideroomopener:Spawn()
	sideroomopener:Activate()
	sideroomopener.OnUsed = function( self, ply )
		local used = false
		if timer.Exists( "sideroomtimer" ) or used then return end
		sideroomopener:SetNWString( "NZText", "" )
		if not CheckTable( activatedconsoles ) then
			sideroomopener:EmitSound( "buttons/combine_button_locked.wav" )
			PrintMessage( HUD_PRINTTALK, "[COMBINE SECURITY] ERROR." )
			timer.Simple( 2, function()
				PrintMessage( HUD_PRINTTALK, "[COMBINE SECURITY] RE-ENABLE FACILITY POWERNODES TO RESUME DOOR FUNCTIONS." )
			end )
			timer.Create( "sideroomtimer", 3, 1 function()
				timer.Destroy( "sideroomtimer" )
				sideroomopener:SetNWString( "NZText", "ERROR" )
			end )
			return
		end
		used = true
		sideroomopener:EmitSound( "buttons/combine_button1.wav" )
		ents.GetMapCreatedEntity( "2959" ):Fire( "Unlock" )
		ents.GetMapCreatedEntity( "2959" ):Fire( "Use" )
		ents.GetMapCreatedEntity( "2959" ):Fire( "Lock" )
	end

	--//I wonder what this block of code creates...
	soulcatcher = ents.Create( "nz_script_soulcatcher" )
	soulcatcher:SetPos( Vector( -1013.565002, -1750.850830, -392.342163 ) )
	soulcatcher:SetAngles( Angle( -0.000, -0.000, 0.000 ) )
	soulcatcher:SetModel( "models/props_vehicles/generatortrailer01.mdl" )
	soulcatcher:SetNWString( "NZText", "Use this generator to charge something." )
	soulcatcher:SetNWString( "NZRequiredItem", "detonator" )
	soulcatcher:SetNWString( "NZHasText", "Press E to place and begin charging the console box battery." )
	soulcatcher:Spawn()
	soulcatcher:Activate()
	soulcatcher:SetRange( 800 )
	soulcatcher:SetTargetAmount( 30 )
	soulcatcher:SetCondition( function( self, z, dmg )
    	return soulcatcher.AllowSouls
	end)
	chrgddtntr:SetNWString( "NZText", "" )
	soulcatcher.OnUsed = function( self, ply )
		if ply:HasCarryItem( "detonator" ) then
			soulcatcher.AllowSouls = true
			ply:RemoveCarryItem( "detonator" )
			chrgddtntr:SetNoDraw( false )
			chrgddtntr:SetNWString( "NZText", "Kill zombies near this generator to charge the console box battery." )
			soulcatcher:SetNWString( "NZText", "Kill zombies near this generator to charge the console box battery." )
			soulcatcher:SetNWString( "NZHasText", "Kill zombies near this generator to charge the console box battery." )
		end
	end
	--[[soulcatcher:SetCompleteFunction( function( self )
		soulcatcher.AllowSouls = false
		chrgddtntr.CanPickup = true
		chrgddtntr:SetNWString( "NZText", "Press E to pick up the charged console box." )
		soulcatcher:SetNWString( "NZText", "" )
	end )]]
	soulcatcher:SetReleaseOverride( function(self, z)
		if self.CurrentAmount >= self.TargetAmount then return end
			
		local e = EffectData()
		e:SetOrigin(self:GetPos())
		e:SetStart(z:GetPos())
		e:SetMagnitude(0.3)
		util.Effect("lightning_strike", e)
		self.CurrentAmount = self.CurrentAmount + 1
		self:CollectSoul()
	end)
	soulcatcher:SetCompleteFunction( function(self)
		soulcatcher.AllowSouls = false
		chrgddtntr.CanPickup = true
		chrgddtntr:SetNWString( "NZText", "Press E to pick up the charged console box." )
		soulcatcher:SetNWString( "NZText", "" )
		chrgddtntr.CanPickup = true
		chrgddtntr:SetNWString( "NZText", "Press E to pick up the charged console box." )
	end)

	thefence = ents.Create( "nz_script_prop" )
	thefence:SetPos( Vector( -925.481079, -509.393311, -337.414886 ) )
	thefence:SetAngles( Angle( 0.000, 0.000, 0.000 ) )
	thefence:SetModel( "models/props_c17/fence01b.mdl" )
	thefence:SetNWString( "NZText", "This piece of fence looks oddly destructable." )
	thefence:SetNWString( "NZRequiredItem", "c4" )
	thefence:SetNWString( "NZHasText", "Press E to place the timed C4." )
	thefence:Spawn()
	thefence:Activate()
	thefence.OnUsed = function( self, ply )
		if not ply:HasCarryItem( "c4" ) or not thefence.Allow then return end
		ply:RemoveCarryItem( "c4" )
		fakec4 = ents.Create( "nz_script_prop" )
		fakec4:SetPos( Vector( -924.632385, -509.546448, -333.140533 ) )
		fakec4:SetAngles( Angle( -90.000, 0.000, 180.000 ) )
		fakec4:SetModel( "models/weapons/w_c4.mdl" )
		timer.Create( "initial5", 1, 5, function() fakec4:EmitSound( "weapons/c4/c4_beep1.wav" ) end )
		timer.Simple( 5, function() timer.Create( "final5", 0.5, 8, function() fakec4:EmitSound( "weapons/c4/c4_beep1.wav" ) end ) end )
		timer.Simple( 10, function() 
			local effect = EffectData()
			effect:SetEntity( fakec4 )
			effect:SetScale( 2 )
			util.Effect( "Explosion", effect, true, true )
			timer.Simple( 0.1, function() --It appears the fence and C4 are disappearing before the explosion has a chance to go off
				thefence:Remove()
				fakec4:Remove()
			end )
		end )
	end
	thefence.Allow = false

	--//My button by garage doors, used to open the doors on EE fail, used intead of the map's own buttons since they don't trigger properly
	escapebutton = ents.Create( "nz_script_prop" )
	escapebutton:SetPos( Vector( 305.845367, -1749.494995, -335.101746 ) )
	escapebutton:SetAngles( Angle( -0.000, -180.000, -0.000 ) )
	escapebutton:SetModel( "models/props_combine/combinebutton.mdl" )
	escapebutton:Spawn()
	escapebutton:Activate()
	escapebutton.OnUsed = function( self, ply )
		if not PermaOff or pressed then return end
		escapebutton:EmitSound( "buttons/combine_button1.wav" )
		PrintMessage( HUD_PRINTTALK, "The garage doors are opening in 60 seconds!" )
		pressed = true
		--ents.GetMapCreatedEntity( "1771" ):SetPlaybackRate( 0.5 )
		--ents.GetMapCreatedEntity( "1772" ):SetPlaybackRate( 0.5 )
		ents.GetMapCreatedEntity( "5238" ):SetPlaybackRate( 0.5 )
		ents.GetMapCreatedEntity( "5243" ):SetPlaybackRate( 0.5 )
		timer.Simple( 60, function()
			PrintMessage( HUD_PRINTTALK, "The garage doors are opening!" )
			ents.GetMapCreatedEntity( "5238" ):Fire( "Unlock" )
			ents.GetMapCreatedEntity( "5243" ):Fire( "Unlock" )
			ents.GetMapCreatedEntity( "5238" ):Fire( "Use" )
			ents.GetMapCreatedEntity( "5243" ):Fire( "Use" )
			ents.GetMapCreatedEntity( "5238" ):Fire( "Lock" )
			ents.GetMapCreatedEntity( "5243" ):Fire( "Lock" )
		end )
	end

	soulcatcher:Reset() --is this required?

	--//Fixes the bugged doorways
    local shittodelete = { 1858, 2465, 1921, 1918, 1939, 2209, 1976, 1973, 2373, 2372, 2170, 2169, 1913, 2145 } --, 2518 } This door, which is a door, bugs the :Fire() function
	for k, v in pairs( shittodelete ) do
		local ent = ents.GetMapCreatedEntity( v )
		if not ent then return end
		ent:Fire( "Open" )
		timer.Simple( 0.2, function()
			ent:Remove()
		end )
	end
end

function mapscript.ScriptUnload()
	LogansScriptRunning = false
end

--//When the electricity first turns on, we want to turn on the lights
local initialactivation = false --This may need to be set in GameStart function
function mapscript.ElectricityOn()
	SetTexts()
	--//Only run this the first time as this just turns the models to the "on" model - which is only to be done initially
	if not initialactivation then
		RemoveUseFunction( ents.FindByClass( "power_box" )[ 1 ] )
		for k, v in pairs( lights1 ) do
			v.ent:SetModel( "models/props_c17/light_cagelight01_on.mdl" )
		end
		for k, v in pairs( lights2 ) do
			v.ent:SetModel( "models/props_c17/light_cagelight01_on.mdl" )
		end
		initialactivation = true
	end
end

--//Of course, when the electricity turns off, the lights must turn off
function mapscript.ElectricityOff()
	for k, v in pairs( lights1 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end
	for k, v in pairs( lights2 ) do
		v.ent:SetModel( "models/props_c17/light_cagelight02_off.mdl" )
	end
end

--[[Here we goooooooo, (doot doot doot, doo-doo-doo-doo)
	The chance for the power to turn off is pseudo-random. After it is initially turned on, it is gauranteed to turn off once every 5 rounds, but may happen sooner.
	By default, there is a 1 and 5 chance (20%) the power will turn off (or stay off) for any given round. For every round the power DOESN'T turn off, 
	the chance increases by an additional 20% until the power WILL turn off (So 20 - 40 - 60 - 80 - 100). This can be easily adjusted if an increase in 20%
	is too much, and a 1 in 6, 7, 8+ chance is perceived to be more fun.]]
local chance, turnoff, propinfo = math.Clamp( 1, 1, 5 ), { }, { }
function mapscript.OnRoundStart()
	if not LogansScriptRunning then return end
	if PermaOff then --EE has been failed
		if nzElec:IsOn() then
			nzElec:Reset()
		end
		return
	end
	if initialactivation then --If power has been initially turned on
		for i = 1, 5 - chance do
			turnoff[ i ] = false
		end
		for i = 6 - chance, 5 do
			turnoff[ i ] = true
		end
		--//Power on/off logic ahead
		if turnoff[ math.random( 1, #turnoff ) ] then
			--//If the electricity is on, save the light colors, turn the power off, check link text, then reset power failure chance
			if nzElec.IsOn() then
				for k, v in pairs( lights1 ) do
					table.insert( propinfo, v.ent:GetModel() )
				end
				for k, v in pairs( lights2 ) do
					table.insert( propinfo, v.ent:GetModel() )
				end
				nzElec:Reset()
				SetTexts()
			end
			chance = 1
		else
			--//If the electricity is off, turn it on, set the light colors, then increase power failure chance for next round
			if not nzElec.IsOn() then
				nzElec:Activate()
				for k, v in pairs( lights1 ) do
					v.ent:SetModel( propinfo[ k ] )
				end
				for k, v in pairs( lights2 ) do
					v.ent:SetModel( propinfo[ 5 + k ] )
				end
				propinfo = { }
			end
			chance = chance + 1
		end
	end
end

--//Return that shit, yo.
return mapscript