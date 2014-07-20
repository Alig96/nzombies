AddCSLuaFile( )

ENT.Type = "anim"
 
ENT.PrintName		= "random_box"
ENT.Author			= "Alig96"
ENT.Contact			= "Don't"
ENT.Purpose			= ""
ENT.Instructions	= ""


function ENT:Initialize()
	self:SetModel( "models/toybox.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	self.Uses = 0
	
	if SERVER then
		self:SetUseType( SIMPLE_USE )
	end
end

function ENT:Use( activator, caller )
	//Work ateleast once before moving
	if self.Uses > 0 then	
		//Ensure there is actually another place to move to
		if math.random(self.Uses, 10) == 10 and #ents.FindByClass( "random_box_spawns" ) > 1 then
			self:MoveAway()
		end
	end
	
	if !self.Moveing then
		if #ents.FindByClass( "random_box_gunwindup" ) == 0 then
			if activator:CanAfford(950) then
				activator:TakePoints(950)
				local gun = ents.Create( "random_box_gunwindup" )
				gun:SetPos( self:GetPos() + Vector(0,0,30) )
				gun:SetAngles( self:GetAngles() + Angle(0,90,0) )
				gun:Spawn()
				gun:SetSolid( SOLID_VPHYSICS )
				gun:SetMoveType( MOVETYPE_NONE )
				gun.Buyer = activator
				
				self.Uses = self.Uses + 1
			end
		end
	end
end

function ENT:MoveAway( )
	self.Moveing = true
	local c = 0
	timer.Create( "moveAway", 0.1, 300, function()
		if c == 30 then
			local all = ents.FindByClass("random_box_spawns")
			//Remove the old spot
			table.RemoveByValue( all, self.BoxEnt )
			local rand = table.Random(all)
			self:SetPos( rand:GetPos() )
			self:SetAngles( rand:GetAngles() )
			self.BoxEnt = rand
			self.Uses = 0
			self.Moveing = false
			timer.Destroy("moveAway")
		else
			c = c + 1
			self:SetPos(Vector(self:GetPos().X, self:GetPos().Y, self:GetPos().Z + 2*c))
		end
	end )
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