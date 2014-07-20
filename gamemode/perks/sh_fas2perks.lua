//Override the function for Speed Cola / Double Tap
function FAS2_PlayAnim(wep, anim, speed, cyc, time)
	speed = speed and speed or 1
	cyc = cyc and cyc or 0
	time = time or 0
	local owner = wep:GetOwner( )

	if type(anim) == "table" then
		anim = table.Random(anim)
	end
	
	if IsValid(owner) then
		anim = string.lower(anim)
		//print(anim)
		//if owner:HasPerk("speed") then
			if string.find(anim, "reload") != nil or string.find(anim, "insert") != nil then
				speed = 2
			end
		//elseif owner:HasPerk("dtap") then
			if string.find(anim, "fire") != nil or string.find(anim, "cock") != nil or string.find(anim, "pump") != nil then
				speed = 1.25
			end
		//end
	end	
	
	if game.SinglePlayer() then
		if SERVER then
			if wep.Sounds[anim] then
				wep.CurSoundTable = wep.Sounds[anim]
				wep.CurSoundEntry = 1
				wep.SoundSpeed = speed
				wep.SoundTime = CurTime() + time
			end
		end
			/*if wep.Sounds[anim] then
				for k, v in pairs(wep.Sounds[anim]) do
					timer.Simple(v.time, function()
						if IsValid(ply) and ply:Alive() and IsValid(wep) and wep == ply:GetActiveWeapon() then
							wep:EmitSound(v.sound, 70, 100)
						end
					end)
				end
			end
		end*/
	else
		if wep.Sounds[anim] then
			wep.CurSoundTable = wep.Sounds[anim]
			wep.CurSoundEntry = 1
			wep.SoundSpeed = speed
			wep.SoundTime = CurTime() + time
		end
		
		/*if wep.Sounds[anim] then
			for k, v in pairs(wep.Sounds[anim]) do
				timer.Simple(v.time, function()
					wep:EmitSound(v.sound, 70, 100)
				end)
			end
		end*/
	end
	
	if SERVER and game.SinglePlayer() then
		ply = Entity(1)
		
		umsg.Start("FAS2ANIM", ply)
			umsg.String(anim)
			umsg.Float(speed)
			umsg.Float(cyc)
		umsg.End()
	end
		
	if CLIENT then
		vm = wep.Wep
		
		wep.CurAnim = string.lower(anim)
		
		if vm then
			vm:SetCycle(cyc)
			vm:SetSequence(anim)
			vm:SetPlaybackRate(speed)
		end
	end
end
//Sync the speed
if SERVER then
	util.AddNetworkString( "nz_sync_speedweps" )
	util.AddNetworkString( "nz_sync_dtapweps" )
	//Call this function when the player buys a new gun or gets a new gun
	function UpdatePerkWeps( ply )
		FAS2_SPEEDCOLA( ply )
		FAS2_DTAPCOLA( ply )
	end
	
	function FAS2_SPEEDCOLA( ply )
		//Check if they have the perk
		//if ply:HasPerk("speed") then
			for _,gun in pairs(ply:GetWeapons()) do	
				local sep = string.Explode("_", gun:GetClass())
				//Add a special check for FAS weps
				if sep[1] == "fas2" then
					if gun.Speed != true then
						gun.Speed = true
						//Normal
						if gun.ReloadTime != nil then gun.ReloadTime = gun.ReloadTime / 2 end
						if gun.ReloadTime_Nomen != nil then gun.ReloadTime_Nomen = gun.ReloadTime_Nomen / 2 end
						if gun.ReloadTime_Empty != nil then gun.ReloadTime_Empty = gun.ReloadTime_Empty / 2 end
						if gun.ReloadTime_Empty_Nomen != nil then gun.ReloadTime_Empty_Nomen = gun.ReloadTime_Empty_Nomen / 2 end
						//BiPod
						if gun.ReloadTime_Bipod != nil then gun.ReloadTime_Bipod = gun.ReloadTime_Bipod / 2 end
						if gun.ReloadTime_Bipod_Nomen != nil then gun.ReloadTime_Bipod_Nomen = gun.ReloadTime_Bipod_Nomen / 2 end
						if gun.ReloadTime_Bipod_Empty != nil then gun.ReloadTime_Bipod_Empty = gun.ReloadTime_Bipod_Empty / 2 end
						if gun.ReloadTime_Bipod_Empty_Nomen != nil then gun.ReloadTime_Bipod_Empty_Nomen = gun.ReloadTime_Bipod_Empty_Nomen / 2 end
					end
				end
			end
			//Send a sync to the client
			net.Start( "nz_sync_speedweps" )
			net.Send( ply )
		//end
	end
	
	function FAS2_DTAPCOLA( ply )
		//Check if they have the perk
		//if ply:HasPerk("dtap") then
			for _,gun in pairs(ply:GetWeapons()) do	
				local sep = string.Explode("_", gun:GetClass())
				//Add a special check for FAS weps
				if sep[1] == "fas2" then
					if gun.Dtap != true then
						gun.Dtap = true
						if gun.FireDelay != nil then gun.FireDelay = gun.FireDelay / 1.25 end
					end
				end
			end
			//Send a sync to the client
			net.Start( "nz_sync_dtapweps" )
			net.Send( ply )
		//end
	end
else
	net.Receive( "nz_sync_speedweps", function( len )
		for _,gun in pairs(LocalPlayer():GetWeapons()) do	
			local sep = string.Explode("_", gun:GetClass())
			//Add a special check for FAS weps
			if sep[1] == "fas2" then
				if gun.Speed != true then
					gun.Speed = true
					//Normal
					if gun.ReloadTime != nil then gun.ReloadTime = gun.ReloadTime / 2 end
					if gun.ReloadTime_Nomen != nil then gun.ReloadTime_Nomen = gun.ReloadTime_Nomen / 2 end
					if gun.ReloadTime_Empty != nil then gun.ReloadTime_Empty = gun.ReloadTime_Empty / 2 end
					if gun.ReloadTime_Empty_Nomen != nil then gun.ReloadTime_Empty_Nomen = gun.ReloadTime_Empty_Nomen / 2 end
					//BiPod
					if gun.ReloadTime_Bipod != nil then gun.ReloadTime_Bipod = gun.ReloadTime_Bipod / 2 end
					if gun.ReloadTime_Bipod_Nomen != nil then gun.ReloadTime_Bipod_Nomen = gun.ReloadTime_Bipod_Nomen / 2 end
					if gun.ReloadTime_Bipod_Empty != nil then gun.ReloadTime_Bipod_Empty = gun.ReloadTime_Bipod_Empty / 2 end
					if gun.ReloadTime_Bipod_Empty_Nomen != nil then gun.ReloadTime_Bipod_Empty_Nomen = gun.ReloadTime_Bipod_Empty_Nomen / 2 end
				end
			end
		end
	end )
	net.Receive( "nz_sync_dtapweps", function( len )
		for _,gun in pairs(LocalPlayer():GetWeapons()) do	
			local sep = string.Explode("_", gun:GetClass())
			//Add a special check for FAS weps
			if sep[1] == "fas2" then
				if gun.Dtap != true then
					gun.Dtap = true
					if gun.FireDelay != nil then gun.FireDelay = gun.FireDelay / 1.25 end
				end
			end
		end
	end )
end