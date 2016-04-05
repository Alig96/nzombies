--Name: Lightning strike using midpoint displacement
--Author: Lolle

EFFECT.Mat = Material( "trails/electric" )

--[[---------------------------------------------------------
   Init( data table )
-----------------------------------------------------------]]
function EFFECT:Init( data )

	self.StartPos = data:GetStart()
	self.EndPos = data:GetOrigin() + VectorRand() * 10
	self.Duration = data:GetMagnitude() or 2
	self.Count = self.Duration * 40
	self.MaxArcs = 2
	self.Scale = 2
	self.Radius = 30

	self.Flash = DynamicLight( LocalPlayer():EntIndex() )

	self.Flash.pos = self.StartPos
	self.Flash.r = 255
	self.Flash.g = 255
	self.Flash.b = 255
	self.Flash.brightness = 10
	self.Flash.Decay = 200
	self.Flash.Size = 2048
	self.Flash.DieTime = CurTime() + 0.2


	self.Alpha = 255
	self.Life = 0
	self.NextArc = 0
	self.Arcs = {}
	self.Queue = 1

	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	sound.Play("nz/hellhound/spawn/strike.wav", self.EndPos, 100, 100, 1)

end

--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think()


	self.Life = self.Life + FrameTime()
	--self.Alpha = 255 * ( 1 - self.Life )

	if self.NextArc <= self.Life then

		local size = table.Count(self.Arcs)
		--add a arc to the array
		self.Arcs[size + 1] = self:GenerateArc(4)
		self.NextArc = self.NextArc + 0.05

		self.MaxArcs = self.MaxArcs * self.Scale

		if size >= self.MaxArcs then
			local i = 1
			while not self.Arcs[i] and i <= size do
				i = i + 1
			end
			self.Arcs[i] = nil
		end
	end

	return ( self.Life < self.Duration )
end

function EFFECT:GenerateArc(detail)
	-- MidPoint Displacement for arc lines
	local points = {}
	local maxPoints = 2^detail

	if maxPoints % 2 != 0 then
		maxPoints = maxPoints + 1
	end

	points[0] = self.StartPos + VectorRand() * 2

	points[maxPoints] = self.EndPos + VectorRand()

	local i = 1

	while i < maxPoints do
		local j = (maxPoints / i) / 2
		while j < maxPoints do
			points[j] = ((points[j - (maxPoints / i) / 2] + points[j + (maxPoints / i) / 2]) / 2);
			points[j] = points[j] + VectorRand() * 25
			j = j + maxPoints / i
		end
		i = i * 2
	end

	return points
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	if ( self.Alpha < 1 ) then return end

	render.SetMaterial( self.Mat )
	local texcoord = math.Rand( 0, 1 )

	for _, arc in pairs(self.Arcs) do
		for j = 1, #arc - 1 do

			local startPos = arc[j]
			local endPos = arc[j + 1]

			render.DrawBeam( startPos,
							endPos,
							16,
							texcoord,
							texcoord + ((startPos - endPos):Length() / 128),
							Color( 255, 255, 255, 128 * ( 1 - self.Life ) ) )

		end
	end

end
