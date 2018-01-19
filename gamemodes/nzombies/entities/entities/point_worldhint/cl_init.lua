include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
end

local GripMaterial = Material( "sprites/grip" )
function ENT:Draw()
	if !nzRound:InState( ROUND_CREATE ) then return end
	render.SetMaterial( GripMaterial )
	render.DrawSprite( self:GetPos(), 16, 16, color_white )
	--self:DrawHint()
end

function ENT:DrawHint()
	-- Only if set to ALL or HUMANS
	if self:GetViewable() == 0 or self:GetViewable() == 4 then
		local pos = self:GetPos()
		local eyepos = EyePos()
		local range = self:GetRange()

		if range <= 0 then
			DrawWorldHint(self:GetHint(), pos)
		else
			local dist = pos:Distance(eyepos)
			if dist <= range then
				--[[local fadeoff = range * 0.75
				if dist >= fadeoff then
					DrawWorldHint(self:GetHint(), pos, 1 - (dist - fadeoff) / range)
				else]]
					DrawWorldHint(self:GetHint(), pos)
				--end
			end
		end
	end
end
