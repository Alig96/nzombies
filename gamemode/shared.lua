GM.Name = "nZombies"
GM.Author = "N/A"
GM.Email = "N/A"
GM.Website = "N/A"

--Round
--0 = Initialize
--1 = Preparing
--2 = In Progress

ROUND_INIT = 0
ROUND_PREP = 1
ROUND_PROG = 2
ROUND_CREATE = 3
ROUND_GO = 4

TEAM_SPECS = 1
TEAM_PLAYERS = 2

team.SetUp( TEAM_SPECS, "Spectators", Color( 255, 255, 255 ) )
team.SetUp( TEAM_PLAYERS, "Players", Color( 255, 0, 0 ) )

//DeriveGamemode("sandbox")