AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "player_handler"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Weapons			= {}

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "StartWep" )
	self:NetworkVar( "Int", 0, "StartPoints" )
	self:NetworkVar( "Int", 1, "NumWeps" )
	self:NetworkVar( "String", 1, "EEURL" )
	
end

function ENT:Initialize()

	self:SetModel( "models/player/odessa.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:SetColor(Color(0, 255, 255, 255)) 
	self:DrawShadow( false )
	
end

function ENT:SetData(points, weapon, numweps, eeurl)

	self:SetStartPoints(points)
	self:SetStartWep(weapon)
	self:SetNumWeps(numweps)
	self:SetEEURL(eeurl)

end

if SERVER then util.AddNetworkString("EasterEggSong") end

hook.Add("nz.EE.EasterEgg", "PlayEESong", function()
	net.Start("EasterEggSong")
	net.Broadcast()
end)

if CLIENT then
	function ENT:Draw()
		if nz.Rounds.Data.CurrentState == ROUND_CREATE then
			self:DrawModel()
		end
	end
	net.Receive("EasterEggSong", function()
		local ent = ents.FindByClass("player_handler")[1]
		ent:ParseSong()
	end)
	
	function ENT:ParseSong()
		local url = self:GetEEURL()
		if string.find( url, "soundcloud.com/" ) and string.find( url, "api." ) == nil then
			http.Fetch( "https://api.soundcloud.com/resolve.json?url=" .. url .. "&client_id=" .. "b45b1aa10f1ac2941910a7f0d10f8e28",
			function( body, len, headers, code )
				local tbl = util.JSONToTable( body )
				if tbl and tbl["stream_url"] and tbl["title"] then
					self:PlaySong( tbl["stream_url"] .. "?client_id=" .. "b45b1aa10f1ac2941910a7f0d10f8e28" )
				else
					Error( "[SOUNDCLOUD] Failed to fetch song No Steam_URL. Please input a new song/same song\n" )
				end
			end, 
			function( error )
				Error( "[SOUNDCLOUD] Failed to fetch song error " .. error .. ". Please input a new song/same song\n" )
			end )
		end

		if string.find( url, "youtu.be/" ) then
			url = url .. "&"
			local videoid = string.match(url, "%?v=(.-)&")
			http.Fetch( "http://www.youtube-mp3.org/a/itemInfo/?video_id=" .. videoid .. "&ac=www&t=grp&r=" .. os.time(),
			function( body, len, headers, code )
				if body == "$$$ERROR$$$" then
					Error( "Failed to fetch song from YouTube!" )
					return
				end

				local _, hashStart = string.find( body, '"h" : "', titleEnd, true )
				if !hashStart then
					Error( "Failed to fetch song from YouTube!" )
					return
				end
				hashStart = hashStart + 1
				local hashEnd, _ = string.find( body, '"', hashStart, true )
				hashEnd = hashEnd - 1
				local hash = string.sub( body, hashStart, hashEnd )
				local time = os.time()
				local time2 = self:_cc( videoid .. time )
				self:PlaySong("http://www.youtube-mp3.org/get?ab=128&video_id=" .. videoid .. "&h=" .. hash .. "&r=" .. time .. "." .. time2)
			end, 
			function( error )
				Error( "Failed to fetch song! Error: " .. error )
			end )
		end
	end
	
	function ENT:PlaySong(song)
		sound.PlayURL( song, "", function() end)
	end
end
