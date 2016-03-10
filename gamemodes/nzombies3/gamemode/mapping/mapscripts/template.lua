local customHooks = {}

--Will be called once when the first round starts
function customHooks.RoundInit()
	--print("Custom map script init called")

end

--Will be called at the start of each round
function customHooks.RoundStart()

end

--Will be called every second if a roudn is in prgress (zombies are alive)
function customHooks.RoundThink()

end

--Will be called after each round
function customHooks.RoundEnd()

end

return customHooks
