AddCSLuaFile( )

ENT.Type = "anim"

ENT.PrintName		= "random_box"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Open" )

end

function ENT:Initialize()

	self:SetModel( "models/hoff/props/mysterybox/box.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:DrawShadow( false )
	self:AddEffects( EF_ITEM_BLINK )
	self:SetOpen(false)
	self.Moving = false
	self:Activate()
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Use( activator, caller )
	if self:GetOpen() == true or self.Moving then return end
	self:BuyWeapon(activator)
	//timer.Simple(5,function() self:MoveAway() end)
end

function ENT:BuyWeapon(ply)
	if ply:CanAfford(950) then
        local class = nz.RandomBox.Functions.DecideWep(ply)
        if class != nil then
      		ply:TakePoints(950)
      		self:Open()
      		local wep = self:SpawnWeapon( ply, class )
        else
            ply:PrintMessage( HUD_PRINTTALK, "No available weapons left!")
        end
	else
		ply:PrintMessage( HUD_PRINTTALK, "You can't afford this!")
	end
end


function ENT:Open()
	local sequence = self:LookupSequence("Close")
	self:ResetSequence(sequence)
	self:RemoveEffects( EF_ITEM_BLINK )

	self:SetOpen(true)
end

function ENT:Close()
	local sequence = self:LookupSequence("Open")
	self:ResetSequence(sequence)
	self:AddEffects( EF_ITEM_BLINK )

	self:SetOpen(false)
end

function ENT:SpawnWeapon(activator, class)
	local wep = ents.Create("random_box_windup")
	wep:Spawn()
	wep:SetPos( self:GetPos( ) - Vector(0,0,-10) )
	wep.Buyer = activator
	wep:SetParent( self )
	wep:SetAngles( self:GetAngles() )
	wep:SetWepClass(class)

	return wep
end

function ENT:Think()
	self:NextThink(CurTime())
	return true
end

function ENT:MoveAway()
	self.Moving = true
	local s = 0
	//Shake Effect
	timer.Create( "shake", 0.1, 300, function()
		if s < 30 then
			if s % 2 == 0 then
				if self:IsValid() then
					self:SetAngles(Angle(10, 0, 0))
				end
			else
				if self:IsValid() then
					self:SetAngles(Angle(-10, 0, 0))
				end
			end
		else
			timer.Destroy("shake")
		end
		s = s + 1
	end)

	//Move Up
	timer.Simple( 1, function()
			local c = 0
			timer.Create( "moveAway", 0.1, 300, function()
				if c == 65 then
					self.Moveing = false
					timer.Destroy("moveAway")
					timer.Destroy("shake")

					self:Remove()
				else
					if c < 30 then
					c = c + 1
					else
					c = c + 5
					end
					self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + c))
				end
			end )
		end)


end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end

	hook.Add( "PostDrawOpaqueRenderables", "random_box_beam", function()
		for k,v in pairs(ents.FindByClass("random_box")) do
			if ( LocalPlayer():GetPos():Distance( v:GetPos() ) ) > 750 then
				local Vector1 = v:LocalToWorld( Vector( 0, 0, -200 ) )
				local Vector2 = v:LocalToWorld( Vector( 0, 0, 5000 ) )
				render.SetMaterial( Material( "cable/redlaser" ) )
				render.DrawBeam( Vector1, Vector2, 300, 1, 1, Color( 255, 255, 255, 255 ) )
			end
		end
	end )
end
