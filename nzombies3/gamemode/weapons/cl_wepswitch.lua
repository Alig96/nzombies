local plyMeta = FindMetaTable( "Player" )
AccessorFunc( plyMeta, "iLastWeaponSlot", "LastWeaponSlot", FORCE_NUMBER)
function plyMeta:SelectWeapon( class )
	if ( !self:HasWeapon( class ) ) then return end
	self.DoWeaponSwitch = self:GetWeapon( class )
end

hook.Add( "CreateMove", "WeaponSwitch", function( cmd )
	if ( !IsValid( LocalPlayer().DoWeaponSwitch ) ) then return end

	cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )

	if ( LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch ) then
		LocalPlayer().DoWeaponSwitch = nil
	end
end )

function GM:PlayerBindPress( ply, bind, pressed )
	local slot
	if ( string.find( bind, "slot1" ) ) then slot = 1 end
	if ( string.find( bind, "slot2" ) ) then slot = 2 end
	if ( string.find( bind, "slot3" ) ) then slot = 3 end
	if ( string.find( bind, "+menu" ) and pressed ) then slot = ply:GetLastWeaponSlot() or 1 print(slot) end
	if slot then
		ply:SetLastWeaponSlot( ply:GetActiveWeapon():GetNWInt( "SwitchSlot", 1) )
		for k,v in pairs( ply:GetWeapons() ) do
			if v:GetNWInt( "SwitchSlot", 1) == slot then
				ply:SelectWeapon( v:GetClass() )
				return true
			end
		end
	end
	if ( string.find( bind, "slot" ) ) then return true end
end
