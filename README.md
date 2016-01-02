nZombies
========

A GM13 Nazi Zombies style (WIP) gamemode

place in gamemodes/nzombies/

This is an edited version featuring these changes:

- Revival System
	- You get downed by losing all HP
	- CalcView low angle for being downed, screen slowly fades to black until you die
	- Hold E on a downed friend to revive, 45 seconds without revival kills the downed player
	- Quick Revive now works; 5 seconds to revive without, 2 seconds with
	- Zombies ignore downed players
	- Downed players also count as 'dead' towards ending the game
	- Upon being downed, you equip a pistol if available
		-(Planned: If no pistol, give starting pistol for the duration of being downed)

- Navigation Gates Creator Tool [BETA]
	- Create and Link Nav Gates and Room Controllers
		- These will make Zombies able to know which doors are open and which 'rooms' they link to
		- They function sort of like waypoints that can only be used if the linked door is open
		- This is in Beta as of now and is an Advanced tool (There's a small in-game help menu)
	- Zombies can now navigate with the use of the Nav Gates and Room Controllers (Still need navmeshes)
		- Only normal zombies can as of now
	- A setting in the config file will allow you to change the mode this is run
	
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

- To-do list:
	- Make point distribution by hook instead of on-zombie functions
	- Fix special wave spawn breaking
	- Better HUD elements and revival icon
	- Revival progress bar
	- Change nav-gate tool to navmesh editing (possible?)
	- All references of zombies should reference the ValidEnemies table in config
	- Better movement stopping for downed players (block key inputs instead of movetype_none, stops weapon sway)
	- Invisible blockers to have more models (like navgates) + blocking filter
	- Make Pack-a-Punch a global damage multiplier by hook?
	- Try to work around a way for Speed Cola and Double Tap (Double Tap v2?) to work on all weapons
	- Add Black Ops and Black Ops 2 perks?
	- Carpenter powerup
	- Correcting points (hit = 10, kill = 50, headshot kill = 100)
