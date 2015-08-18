AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Zombie"
ENT.Category = "Dissolution"
ENT.Author = "Chessnut"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.FollowingWaypoints = nil
ENT.CurWaypoint = nil

ENT.RouteStack = {}
ENT.AllRouteStacks = {}
ENT.CurrentStackTarget = 0
ENT.RouteStackBuffer = false

ENT.HasBeen		= {}

for i = 2, 4 do
	util.PrecacheModel("models/zed/malezed_0"..(i * 2)..".mdl")
end

function ENT:Initialize()
	self:SetModel("models/zed/malezed_0"..(math.random(2, 4) * 2)..".mdl")
	self.breathing = CreateSound(self, "npc/zombie_poison/pz_breathe_loop1.wav")
	self.breathing:Play()
	self.breathing:ChangePitch(60, 0)
	self.breathing:ChangeVolume(0.1, 0)
	self.loco:SetDeathDropHeight(700)
	if SERVER then
		self:SetHealth(nz.Curves.Data.Health[nz.Rounds.Data.CurrentRound])
	end
	self:SetCollisionBounds(Vector(-12,-12, 0), Vector(12, 12, 64))
	self:SetSkin(math.random(0, self:SkinCount() - 1))

	hook.Add("EntityRemoved", self, function()
		if (self.breathing) then
			self.breathing:Stop()
			self.breathing = nil
		end
	end)
	
	hook.Add("nz_EntityChangedRoom", self, function(self, ent, oldroom, newroom, navgate)
		--print("HOOK INFO ON ZOMBIE", ent, oldroom, newroom, navgate)
		if nz.Config.NavMode == NAV_MODE_PLAYER_ROOM_CHANGE and IsValid(ent) and ent:IsPlayer() and ent:Alive() then
			self:GetAllWaypointRoutes()
		end
	end)
	
end

function ENT:SpawnNavigate()
	//Call this function from the spawner after it is spawned - this is where CurrentRoom is assigned
	if nz.Config.NavMode == NAV_MODE_PLAYER_ROOM_CHANGE then
		self:GetAllWaypointRoutes()
	end
end

function ENT:TimedEvent(time, callback)
	timer.Simple(time, function()
		if (IsValid(self)) then
			callback()
		end
	end)
end

function ENT:GetPriorityEnemy()
	local pos = self:GetPos()

	local min_dist, closest_target = -1, nil

	for _, target in pairs(player.GetAll()) do
		if (IsValid(target)&&target:Alive()&&target:GetNotDowned()) then
			local dist = target:NearestPoint(pos):Distance(pos)
			if ((dist < min_dist||min_dist==-1)) then
				closest_target = target
				min_dist = dist
			end
		end
	end

	return closest_target
end

function ENT:RunBehaviour()
	while (true) do
		local target = self.target

		if (IsValid(target) and target:Alive()) then
			local data = {}
				data.start = self:GetPos()
				data.endpos = self:GetPos() + self:GetForward()*128
				data.filter = self
				data.mins = self:OBBMins() * 0.65
				data.maxs = self:OBBMaxs() * 0.65
			local trace = util.TraceHull(data)
			local entity = trace.Entity

			//Barricades
			if (IsValid(entity) and entity:GetClass() == "breakable_entry" ) then
				if entity:Health() != 0 then
					timer.Simple(0.3, function()

						entity:EmitSound("physics/wood/wood_plank_break"..math.random(1, 4)..".wav", 100, math.random(90, 130))

						entity:RemovePlank()

					end)

					self:PlaySequenceAndWait("swing", 1)
				end
			end
		end

		if (IsValid(target) and target:Alive()  ) then --and self:GetRangeTo(target) <= 1500
			self.loco:FaceTowards(target:GetPos())

			if (self:GetRangeTo(target) <= 42) then
				self:EmitSound("npc/zombie_poison/pz_throw2.wav", 50, math.random(75, 125))

				self:TimedEvent(0.3, function()
					self:EmitSound("npc/vort/claw_swing"..math.random(1, 2)..".wav")
				end)

				self:TimedEvent(0.4, function()
					if (IsValid(target) and self:GetRangeTo(target) <= 50) then
						local damageInfo = DamageInfo()
							damageInfo:SetAttacker(self)
							damageInfo:SetDamage(math.random(5, 10))
							damageInfo:SetDamageType(DMG_CLUB)

							local force = target:GetAimVector() * -300
							force.z = 16

							damageInfo:SetDamageForce(force)
						target:TakeDamageInfo(damageInfo)
						target:EmitSound("npc/zombie/zombie_hit.wav", 50, math.random(80, 160))
						target:ViewPunch(VectorRand():Angle() * 0.05)
						target:SetVelocity(force)
					end
				end)

				self:TimedEvent(0.45, function()
					if (IsValid(target) and !target:Alive()) then
						target.target = nil
					end
				end)

				self:PlaySequenceAndWait("swing", 1)
			else
				if nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound] >= 160 then
					self:StartActivity(ACT_RUN)
				else
					self:StartActivity(ACT_WALK)
				end
				if (self.breathing) then
					self.breathing:ChangePitch(80, 1)
					self.breathing:ChangeVolume(1.25, 1)
				end

				if (math.random(1, 2) == 2 and (self.nextYell or 0) < CurTime()) then
					self:EmitSound("npc/zombie_poison/pz_pain"..math.random(1, 3)..".wav", 40, math.random(30, 50))
					self.nextYell = CurTime() + math.random(4, 8)
				end

				self.loco:SetDesiredSpeed(nz.Curves.Data.Speed[nz.Rounds.Data.CurrentRound])
				if self.FollowingWaypoints then
					if self:GetRangeTo(self:GetNextWaypoint()) <= 20 then
						self:InitiateNextWaypoint()
					end
				end
				if self.FollowingWaypoints then
					self:MoveToPos(self:GetNextWaypoint():NearestPoint(self:GetPos()), {
						maxage = 0.67
					})
				else
					self:MoveToPos(target:GetPos(), {
						maxage = 0.67
					})
				end
			end
		else
			self.target = nil
			self:StartActivity(ACT_WALK)
			self.loco:SetDesiredSpeed(40)
			self:MoveToPos(self:GetPos() + Vector(math.random(-256, 256), math.random(-256, 256), 0), {
				repath = 3,
				maxage = 2
			})

			if (math.random(1, 8) == 2) then
				self:EmitSound("npc/zombie/zombie_voice_idle"..math.random(2, 7)..".wav", 50, 60)

				if (math.random(1, 2) == 2) then
					self:PlaySequenceAndWait("scaredidle")
				else
					self:PlaySequenceAndWait("photo_react_startle")
				end
			end
			//New AI Stuffz
			if (!self.target) then
				local v = self:GetPriorityEnemy()
				self.target = v
				self:AlertNearby(v)
				self.target = v
				self:PlaySequenceAndWait("wave_smg1", 0.9)
			end
		end
		coroutine.yield()
	end
end

function ENT:Think()
	//Retarget closest players. Don't put this in the function above or else mass lag due to constant rethinking of target
	if nz.Config.NavMode == NAV_MODE_THINK then
		self:GetAllWaypointRoutes()
	else
		self.target = IsValid(self.FollowingWaypoints) and self.FollowingWaypoints or self:GetPriorityEnemy()
	end
	self:NextThink(4)
end

function ENT:OnStuck()
	--print("Now I'm stuck", self)
	//Check for routes when stuck
	if nz.Config.NavMode == NAV_MODE_ON_STUCK then
		self:GetAllWaypointRoutes()
	end
end

function ENT:AlertNearby(target, range, noNoise)
	range = range or 2400
	noNoise = noNoise or (#ents.FindByClass("nut_zombie") < 1)

	if (IsValid(self.target)) then
		return
	end

	for k, v in pairs(ents.FindByClass("nut_zombie")) do
		if (self != v and !IsValid(v.target) and self:GetRangeTo(v) <= range) then
			timer.Create("zombieAlert_"..v:EntIndex(), self:GetRangeTo(v) / 800, 1, function()
				if (!IsValid(v) or !IsValid(target)) then
					return
				end

				v.target = target
				v:EmitSound("npc/zombie/zombie_alert"..math.random(1, 3)..".wav", 50, math.random(60, 120))
				v:AlertNearby(target, range + 640)
			end)

			noNoise = false
		end
	end

	if (!noNoise) then
		self:EmitSound("npc/zombie_poison/pz_call1.wav", 50, 120)
	end
end

function ENT:OnLandOnGround()
	self:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 6)..".wav")
end

local deathSounds = {
	"npc/zombie_poison/pz_die1.wav",
	"npc/zombie_poison/pz_die2.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die3.wav"
}

function ENT:OnKilled(damageInfo)
	local attacker = damageInfo:GetAttacker()

	if (IsValid(attacker) and self:GetRangeTo(attacker) <= 4800) then
		self:AlertNearby(attacker, 1600, true)
	else
		local entities = ents.FindInSphere(self:GetPos(), 2400)

		for k, v in pairs(entities) do
			if (v:IsPlayer()) then
				self:AlertNearby(v, 2400, true)

				break
			end
		end
	end

	self:EmitSound(table.Random(deathSounds), 50, math.random(75, 130))
	self:BecomeRagdoll(damageInfo)

	nz.Enemies.Functions.OnEnemyKilled( self, attacker )
	
	//Delete tables of routestacks to clear them
	if nz.Nav.RouteStacks[self] then nz.Nav.RouteStacks[self] = nil end
	if nz.Nav.SelectedRouteStacks[self] then nz.Nav.SelectedRouteStacks[self] = nil end

end

local painSounds = {
	"npc/zombie_poison/pz_pain1.wav",
	"npc/zombie_poison/pz_pain2.wav",
	"npc/zombie_poison/pz_pain3.wav",
	"npc/zombie/zombie_die1.wav",
	"npc/zombie/zombie_die2.wav",
	"npc/zombie/zombie_die3.wav"
}

function ENT:OnInjured(damageInfo)
	local attacker = damageInfo:GetAttacker()
	local hitgroup = util.QuickTrace( damageInfo:GetDamagePosition( ), damageInfo:GetDamagePosition( ) ).HitGroup
	local range = self:GetRangeTo(attacker)
	//Deal an double damage if headshot
	if hitgroup == HITGROUP_HEAD then
		if self:IsValid() and damageInfo:GetDamageType() != DMG_BLAST_SURFACE then
			local headshot = DamageInfo()
			headshot:SetDamage(damageInfo:GetDamage( ))
			headshot:SetAttacker(attacker)
			headshot:SetDamageType(DMG_BLAST_SURFACE)
			print("Headshot! ", headshot:GetDamage( ))
			//Delay so it doesn't "die" twice
			timer.Simple(0.1, function() if self:IsValid() then self:TakeDamageInfo( headshot ) end end)
		end
	end
	self:EmitSound(table.Random(painSounds), 50, math.random(50, 130))
	self.target = attacker
	self:AlertNearby(attacker, 1000)

	nz.Enemies.Functions.OnEnemyHurt( self, attacker, hitgroup )
end

function ENT:GetNextWaypoint()
	if nz.Nav.SelectedRouteStacks[self] then
		return nz.Nav.SelectedRouteStacks[self].points[self.CurrentStackTarget]
	end
end

function ENT:InitiateNextWaypoint()
	if IsValid(nz.Nav.SelectedRouteStacks[self].points[self.CurrentStackTarget + 1]) then
		self.CurrentStackTarget = self.CurrentStackTarget + 1
		--print("Proceeding to target "..self.CurrentStackTarget)
		PrintTable(nz.Nav.SelectedRouteStacks[self])
	else
		self.FollowingWaypoints = nil
		--print("Proceeding with regular targeting")
	end
end

function ENT:GetAllWaypointRoutes(seed, specifictarget)
	local seed = seed or self.CurrentRoom
	//If people don't link spawns, zombies will still get a CurrentRoom by walking through a Nav Gate
	
	//The zombie has no current room and no seed was provided
	if !IsValid(seed) then return end
	
	self.HasBeen = {}
	routes = {}
	if specifictarget and IsValid(specifictarget) and specifictarget:IsPlayer() then
		if !IsValid(specifictarget.CurrentRoom) then
			--print("Tried to find a route to "..specifictarget:Nick()..", but he has no CurrentRoom assigned!")
			return
		end
		--print("Finding routes for", specifictarget)
		self:GetNextPoints(seed, seed, specifictarget.CurrentRoom, {points = {}, dist = 0}, v, self)
	else
		for k,v in pairs(team.GetPlayers(TEAM_PLAYERS)) do
			if !IsValid(v.CurrentRoom) then
				--print("Tried to find a route to "..v:Nick()..", but he has no CurrentRoom assigned!")
			else
				--print("Finding routes for", v)
				self:GetNextPoints(seed, seed, v.CurrentRoom, {points = {}, dist = 0, ent = self}, v, self)
			end
		end
	end
end

function ENT:GetNextPoints(seed, curroom, target, stack, ply, curgate)
	local newstack = stack and table.Copy(stack) or {}
	--table.Empty(stack)
	stack = nil
	if !newstack then return end
	--PrintTable(newstack)
	if curroom == target then
		self:ReturnStack( newstack, ply )
		newstack = {points = {}, dist = 0, ent = self} --print("RESET")
		--newstack = nil
		--print("NILLING newstack")
	else
		self.HasBeen[curroom] = true
		for k,v in pairs(nz.Nav.Data[curroom]) do
			if curroom == seed then newstack = {points = {}, dist = 0, ent = self} print("RESET ROUTESTACK") end
			--print("Looking for connection at", v, "looking from", curroom)
			if !self.HasBeen[v.targetroom] and (v.open or (nz.Doors.Data.OpenedLinks[v.doorlink])) then
				print("Tracing on from", curroom, "on to", v.targetroom, "through door", k, self)
				table.insert(newstack.points, v.navlink)
				//DistToSqr is cheaper - and it works just as well to compare what's shortest
				newstack.dist = newstack.dist + curgate:GetPos():DistToSqr(v.navlink:GetPos())
				--PrintTable(stack)
				self:GetNextPoints(seed, v.targetroom, target, newstack, ply, v.navlink)
			end
		end
	end
end

function ENT:ReturnStack(stack, ply)
	print("--- STACK FOUND ---")
	--PrintTable(stack)
	if stack.ent == self then
		if !nz.Nav.RouteStacks[stack.ent] then nz.Nav.RouteStacks[stack.ent] = {} end
		table.insert(nz.Nav.RouteStacks[stack.ent], stack)
		--print(self, "INSDFHAKUF")
		--PrintTable(nz.Nav.RouteStacks[stack.ent])
	end
	--PrintTable(self.AllRouteStacks)
	--print(self)
	
	//Make a little buffer to wait for all routes to be found
	if !self.RouteStackBuffer then
		self.RouteStackBuffer = CurTime() + 1
		hook.Add("Think", "RouteStackBuffer"..self:EntIndex(), function()
			if CurTime() >= self.RouteStackBuffer then
				hook.Remove("Think", "RouteStackBuffer"..self:EntIndex())
				self:PrioritizeStack(ply)
				self.RouteStackBuffer = false
			end
		end)
	end
end

function ENT:PrioritizeStack(ply)
	--print("Picking stack")
	--print(nz.Nav.RouteStacks[self])
	--PrintTable(nz.Nav.RouteStacks[self])
	if IsValid(self) and self.RouteStackBuffer then
		--PrintTable(self.AllRouteStacks)
		table.SortByMember(nz.Nav.RouteStacks[self], "dist", true)
		--PrintTable(self.AllRouteStacks)
		nz.Nav.SelectedRouteStacks[self] = nz.Nav.RouteStacks[self][1]
		--print("--- TARGETED ROUTESTACK ---")
		--print(self.RouteStack)
		--PrintTable(nz.Nav.RouteStacks)
		table.Empty(nz.Nav.RouteStacks[self])
		self.CurrentStackTarget = 0
		self.FollowingWaypoints = ply
		self:InitiateNextWaypoint()
	end
end
