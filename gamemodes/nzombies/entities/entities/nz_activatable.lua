AddCSLuaFile( )

-- Interface for stuff taht cna be activated by the player DO NOT USE THIS CLASS create subclasses!

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.Editable = true

ENT.PrintName = "nz_trapbase"

ENT.bIsActivatable = true

function ENT:SetupDataTables()

	self:NetworkVar( "String", 0, "Name", {KeyName = "name", Edit = {order = 1, type = "Generic"}} )

	self:NetworkVar( "Bool", 0, "Active", {KeyName = "active", Edit = {order = 2, type = "Boolean"}} )
	self:NetworkVar( "Bool", 1, "CooldownActive")
	self:NetworkVar( "Bool", 2, "ElectircityNeeded", {KeyName = "electircityneeded", Edit = {order = 3, type = "Boolean"}} )
	self:NetworkVar( "Bool", 3, "SingleUse", {KeyName = "singleuse", Edit = {order = 4, type = "Boolean"}} )
	self:NetworkVar( "Bool", 4, "RemoteActivated", {KeyName = "remoteactivated", Edit = {order = 5, type = "Boolean"}} )

	self:NetworkVar( "Float", 0, "Duration", {KeyName = "duration", Edit = {order = 6, type = "Float", min = 0, max = 100000}} )
	self:NetworkVar( "Float", 1, "Cooldown", {KeyName = "cooldown", Edit = {order = 7, type = "Float", min = 0, max = 100000}} )
	self:NetworkVar( "Float", 2, "Cost", {KeyName = "cost", Edit = {order = 8, type = "Float", min = 0, max = 100000}} )

	if SERVER then
		self:SetActive(false)
		self:SetDuration(60)
		self:SetCooldown(30)
		self:SetCost(0)
		self:SetCooldownActive(false)
		self:SetElectircityNeeded(true)
		self:SetSingleUse(false)
		self:SetRemoteActivated(false)
		self:SetUseType(SIMPLE_USE)
	end

end

function ENT:IsActive() return self:GetActive() end

function ENT:IsCooldownActive() return self:GetCooldownActive() end

function ENT:IsElectircityNeeded() return self:GetElectircityNeeded() end

function ENT:IsSingleUse() return self:GetSingleUse() end

function ENT:IsRemoteActivated() return self:GetRemoteActivated() end

function ENT:Activation(activator)
	self:SetActive(true)
	self:OnActivation()
end

function ENT:Deactivation()
	self:SetCooldownActive(true)
	self:SetActive(false)
	self:OnDeactivation()
end

function ENT:Ready()
	self:SetCooldownActive(false)
	self:OnReady()
end

function ENT:Use( act, caller, type, value )
	if IsValid(caller) and caller:IsPlayer() and not self:IsRemoteActivated() and not self:IsCooldownActive() then
		if caller:CanAfford(self:GetCost()) then
			self:Activation(caller)
			if SERVER then
				caller:TakePoints(self:GetCost())
			end
		end
	end
end

-- IMPLEMENT ME
function ENT:OnActivation() end

function ENT:OnDeactivation() end

function ENT:OnReady() end

function ENT:GetTargetIDText()
	if self:IsElectircityNeeded() and not nzElec:IsOn() then
		return "Electricity required!"
	else
		if self:GetCost() > 0 then
			return "Press E to activate " .. self:GetName() .. " for " .. self:GetCost() .. "points."
		else
			return "Press E to activate " .. self:GetName() .. "."
		end
	end
end

--Default stuff
if ( CLIENT ) then

	function ENT:Draw()

		self:DrawModel()

	end

	function ENT:DrawTranslucent()

		-- This is here just to make it backwards compatible.
		-- You shouldn't really be drawing your model here unless it's translucent

		self:Draw()

	end

end

local function drawTargetID()

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine(tr)
	if (not trace.Hit) then return end
	if (not trace.HitNonWorld) then return end

	if (not trace.Entity:IsActivatable()) then return end

	local text = trace.Entity:GetTargetIDText()

	local font = "nz.display.hud.small"
	surface.SetFont( font )
	local w, h = surface.GetTextSize(text)

	local MouseX, MouseY = gui.MousePos()

	if ( MouseX == 0 && MouseY == 0 ) then

		MouseX = ScrW() / 2
		MouseY = ScrH() / 2

	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText(text, font, x+1, y+1, Color(255,255,255,255) )
end

hook.Add("HUDDrawTargetID", "activatable_target_id", drawTargetID)
