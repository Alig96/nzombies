//Chat Commands
//Setup
nz.ChatCommands = {}

function NewChatCommand(text, func)
	table.insert(nz.ChatCommands, {text, func})
end

hook.Add( "PlayerSay", "chatCommand", function( ply, text, public )
	local text = string.lower(text)
	for k,v in pairs(nz.ChatCommands) do
		if (string.sub(text, 1, string.len(v[1])) == v[1]) then
			v[2](ply, text)
			return false
		end
	end
end )

// Actual Chat Commands

NewChatCommand("/ready", function(ply, text) 
	PrintMessage( HUD_PRINTTALK, ply:Nick().." is ready!" )
	ply.Ready = 1
end)

NewChatCommand("/unready", function(ply, text) 
	PrintMessage( HUD_PRINTTALK, ply:Nick().." is no longer ready!" )
	ply.Ready = 0
end)

NewChatCommand("/create", function(ply, text) 
	if ply:IsSuperAdmin() then
		nz.Rounds.Functions.CreateMode()
	end
end)

NewChatCommand("/generate", function(ply, text) 
	if ply:IsSuperAdmin() then
		if #ents.FindByClass("info_player_start") > 0 then
			navmesh.BeginGeneration( )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] There were no walkable seeds found. Please stand on the ground, and use /forcegenerate." )
		end
	end
end)

NewChatCommand("/save", function(ply, text) 
	if ply:IsSuperAdmin() then
		if nz.Rounds.CurrentState == ROUND_CREATE then 
			nz.Mapping.Functions.SaveConfig()
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't save outside of create mode." )
		end
	end
end)

NewChatCommand("/forcegenerate", function(ply, text) 
	if ply:IsSuperAdmin() then
		local ent = ents.Create("info_player_start")
		ent:SetPos(ply:GetPos())
		ent:Spawn()
		navmesh.BeginGeneration( )
	end
end)

NewChatCommand("/load", function(ply, text) 
	if ply:IsSuperAdmin() then
		if nz.Rounds.CurrentState == ROUND_CREATE or nz.Rounds.CurrentState == ROUND_INIT then 
			nz.Interface.ReqMapConfig( ply )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't load while playing!" )
		end
	end
end)

NewChatCommand("/loadold", function(ply, text) 
	if ply:IsSuperAdmin() then
		if nz.Rounds.CurrentState == ROUND_CREATE or nz.Rounds.CurrentState == ROUND_INIT then 
			nz.Interface.ReqMapConfigOld( ply )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't load while playing!" )
		end
	end
end)

NewChatCommand("/config", function(ply, text) 
	if ply:IsSuperAdmin() then
		if nz.Rounds.CurrentState == ROUND_CREATE or nz.Rounds.CurrentState == ROUND_INIT then 
			nz.Interface.ReqConfigChange( ply )
		else
			ply:PrintMessage( HUD_PRINTTALK, "[NZ] You can't modify the config while in game." )
		end
	end
end)
