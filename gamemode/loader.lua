//Main Tables
nz = {}
nz.Config = {}
nz.Doors = {}
nz.Rounds = {}

//End Tables

//Load all files recursively 

local gmfolder = "nzombies"

local _,dirs = file.Find( gmfolder.."/gamemode/*", "LUA" )

function RecInclude(name, dir)
	local sep = string.Explode("_", name)
	name = dir..name
	if sep[1] == "sv" then
		if SERVER then
			include(name)
		end
	elseif sep[1] == "sh" then
		if SERVER then
			AddCSLuaFile(name)
			include(name)
		else
			include(name)
		end
	elseif sep[1] == "cl" then
		if SERVER then
			AddCSLuaFile(name)
		else
			include(name)
		end
	end
	print("Including: "..name)
end

if SERVER then
	for k,v in pairs(dirs) do
		local f2,d2 = file.Find( gmfolder.."/gamemode/"..v.."/*", "LUA" )
		for k2,v2 in pairs(f2) do
			RecInclude(v2, v.."/")
		end
	end
end

if CLIENT then
	for k,v in pairs(dirs) do
		local f2,d2 = file.Find( gmfolder.."/gamemode/"..v.."/*", "LUA" )
		for k2,v2 in pairs(f2) do
			RecInclude(v2, v.."/")
		end
	end
end



