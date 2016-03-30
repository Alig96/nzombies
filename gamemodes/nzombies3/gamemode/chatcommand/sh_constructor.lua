-- Chat Commands module
chatcommand = {}

chatcommand.commands = {}

-- Functions
function chatcommand.Add(text, func, adminOnly)
	table.insert(chatcommand.commands, {text, func, adminOnly or true})
end

-- Hooks
if SERVER then
	local function commandListenerSV( ply, text, public )
		text = string.lower(text)
		for k,v in pairs(chatcommand.commands) do
			if (string.sub(text, 1, string.len(v[1])) == v[1]) then
				if v[3] and !ply:IsSuperAdmin() then
					ply:ChatPrint("This command can only be used by administrators.")
					return false
				end
				v[2](ply, string.Split(string.sub(text, string.len(v[1]) + 2), " "))
				return false
			end
		end
	end
	hook.Add("PlayerSay", "nzChatCommand", commandListenerSV)
end

if CLIENT then
	local function commandListenerCL( ply, text, public, dead )
		text = string.lower(text)
		for k,v in pairs(chatcommand.commands) do
			if (string.sub(text, 1, string.len(v[1])) == v[1]) then
				if v[3] and !ply:IsSuperAdmin() then
					ply:ChatPrint("This command can only be used by administrators.")
					return true
				end
				v[2](ply, string.Split(string.sub(text, string.len(v[1]) + 2), " "))
				return true
			end
		end
	end
	hook.Add("OnPlayerChat", "nzChatCommandClient", commandListenerCL)
end
