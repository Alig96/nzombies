nZombies
========

A GM13 Nazi Zombies style (WIP) gamemode

place in gamemodes/nzombies/

This is an edited version featuring these changes:

- Revival System & Health
	- You get downed by losing all HP
	- CalcView low angle for being downed, screen slowly fades to black until you die
	- Hold E on a downed friend to revive, 45 seconds without revival kills the downed player
	- Quick Revive now works; 5 seconds to revive without, 2 seconds with
	- Zombies ignore downed players
	- Downed players also count as 'dead' towards ending the game
	- Upon being downed, you equip a pistol if available
		-(Planned: If no pistol, give starting pistol for the duration of being downed)
	- Zombies now deal 50-70 damage, but you have health regen on your side!

- Navigation Locker Tool
	- Lock Navmeshes or link them to doors!
		- Zombies will not be able to pathfind through locked navmeshes
		- Opening a linked door will unlock the navmesh it was tied to
		- You need to be in a local server with sv_cheats to 1 to visualize them, however they still work without
		- Only normal zombies can, but you can copy-past the pathfinding check to any other NPC if needed
	
- Random Box Handler Tool (For Create mode)
	- Decide which weapons the box can spawn
	- If no Random Box Handler entity exists, it will assume normal behaviour
		
- Weapon Carrying
	- Max number weapons you can carry
	- You swap weapons if the max has been reached
	- You automatically equip newly gotten weapons
	
- Player Handler Tool + Entity (For Create mode)
	- Decide starting weapon
	- Decide starting points
	- Decide max number of weapons carried
	- Takes a Soundcloud URL which plays when all easter eggs have been activated
		
- Door Changes
	- func_* doors now actually trigger with E!
	- Doors that still close with triggers or buttons will unlock and open again
		- The only way to keep these doors open
		- Otherwise Triggers will close it again and because we locked it, we can't reopen
	- You can now lock buttons with a price (Say to trigger doors or elevators, or maybe even traps)
	- Doors only lock if they have a price; doors without will force themselves to stay open when they try to close
	
- Misc changes
	- Wall Buy tool weapon selection is a dropdown of all available weapons instead of text field
	- Sleight of Hand renamed to Speed Cola
	- Set the prices of the perks to what they are in the real zombies game
	- Enabled the Start Round sound on every round, like in the real game
	- Random Box weapons float up with the right angle to match the box
	- Random Box Weapons can now be picked up even with wierd models
	- Zombies now correctly give 50 points for a kill and 100 for a headshot kill
	- Point distribution works on hooks now, making it work for any NPC you add to ValidEnemies
	- ValidEnemies table setup changed to allow more customizability

- To-do list:
	- Better HUD elements and revival icon
	- Revival progress bar
	- Invisible blockers to have more models (like navgates) + blocking filter
	- Make Pack-a-Punch a global damage multiplier by hook?
	- Try to work around a way for Speed Cola and Double Tap (Double Tap v2?) to work on all weapons
	- Add Black Ops and Black Ops 2 perks?
	- Carpenter powerup
