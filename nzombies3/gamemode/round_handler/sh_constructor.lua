//Main Tables
nz.Rounds = {}
nz.Rounds.Functions = {}
nz.Rounds.Data = {}

//Round Variables
nz.Rounds.Data.CurrentState = ROUND_INIT
nz.Rounds.Data.CurrentRound = 0

//Misc
nz.Rounds.StartingPlayers = {} //No reason to be shared, but maybe in the future we will show the players clientside for scoreboard or smth
nz.Rounds.Elec = false

if SERVER then

	//Round Variables
	nz.Rounds.Data.CurrentZombies = 0
	nz.Rounds.Data.ZombiesSpawned = 0
	
end