function Mapping:LoadScript( name )

	local filePath = "nzombies3/gamemode/mapping/mapscripts/" .. string.StripExtension(name) .. ".lua"

	if !file.Exists( filePath, "LUA") then return false end

	local hooks = include( filePath )

	hook.Add("OnRoundInit", "nzmapscriptinit", hooks.RoundInit)
	hook.Add("OnRoundStart", "nzmapscriptstart", hooks.RoundStart)
	hook.Add("OnRoundThink", "nzmapscriptthink", hooks.RoundThink)
	hook.Add("OnRoundEnd", "nzmapscriptend", hooks.RoundEnd)

	return true

end

function Mapping:UnloadScript()

	hook.Remove("OnRoundInit", "nzmapscriptinit")
	hook.Remove("OnRoundStart", "nzmapscriptstart")
	hook.Remove("OnRoundThink", "nzmapscriptthink")
	hook.Remove("OnRoundEnd", "nzmapscriptend")

end
