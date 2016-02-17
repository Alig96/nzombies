AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.PrintName = "Zombie"
ENT.Category = "Dissolution"
ENT.Author = "Chessnut"
ENT.Spawnable = true
ENT.AdminOnly = true

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
		if (IsValid(target)&&target:Alive()&&target:GetMoveType()==MOVETYPE_WALK) then
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
						target:ViewPunch(VectorRand():Angle() * 0.1)
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
				self:MoveToPos(target:GetPos(), {
					maxage = 0.67
				})
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
	self.target = self:GetPriorityEnemy()
	self:NextThink(4)
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
