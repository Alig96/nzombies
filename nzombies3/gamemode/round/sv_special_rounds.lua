hook.Add("OnRoundStart", "nzSpecialZombies", function()
	if Round:GetNumber() == 6 or Round:GetNumber() >= 18 then
		nz.Fog.Functions.Enable( true )
	elseif Round:GetNumber() >= 18 then
		nz.Fog.Functions.SetColor( Color(190, 60, 40) )
		nz.Fog.Functions.Enable( true )
	else
		nz.Fog.Functions.Enable( false )
	end
end)
