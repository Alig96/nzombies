hook.Add("InitPostEntity", "EnableNLHHClientEffects", function()
    if engine.ActiveGamemode() == "nzombies" and game.GetMap() == "rp_neverlosehopehospital_v2u" then
        enableHudEffects = true
    end
end)

--Snagged off the gmod wiki
function draw.Circle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end

--Snagged off a github page
function draw.Arc(cx, cy, radius, thickness, startang, endang, roughness, color)
    local triarc = {}
    -- local deg2rad = math.pi / 180
    
    -- Define step
    local roughness = math.max(roughness or 1, 1)
    local step = roughness
    
    -- Correct start/end ang
    local startang,endang = startang or 0, endang or 0
    
    if startang > endang then
        step = math.abs(step) * -1
    end
    
    -- Create the inner circle's points.
    local inner = {}
    local r = radius - thickness
    for deg=startang, endang, step do
        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
        table.insert(inner, {
            x=ox,
            y=oy,
            u=(ox-cx)/radius + .5,
            v=(oy-cy)/radius + .5,
        })
    end	
    
    -- Create the outer circle's points.
    local outer = {}
    for deg=startang, endang, step do
        local rad = math.rad(deg)
        -- local rad = deg2rad * deg
        local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
        table.insert(outer, {
            x=ox,
            y=oy,
            u=(ox-cx)/radius + .5,
            v=(oy-cy)/radius + .5,
        })
    end	
    
    -- Triangulize the points.
    for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
        local p1,p2,p3
        p1 = outer[math.floor(tri/2)+1]
        p3 = inner[math.floor((tri+1)/2)+1]
        if tri%2 == 0 then --if the number is even use outer.
            p2 = outer[math.floor((tri+1)/2)]
        else
            p2 = inner[math.floor((tri+1)/2)]
        end
    
        table.insert(triarc, {p1,p2,p3})
    end

    surface.SetDrawColor(color)
    for k, v in ipairs(triarc) do
        surface.DrawPoly(v)
    end
end

net.Receive("RunFireOverlay", function()
    Screen = vgui.Create("DFrame")
    Screen:SetSize(ScrW(), ScrH())
    Screen:SetPos(0, 0)
    Screen:SetTitle("")
    Screen:SetVisible(true)
    Screen:SetDraggable(false)
    Screen:ShowCloseButton(false)
    Screen.Paint = function()
    end

    local overlay = surface.GetTextureID("effects/fire/napalm_aoe")
    overlayPanel = vgui.Create("DPanel", Screen)
    overlayPanel:SetSize(Screen:GetWide(), Screen:GetTall())
    overlayPanel:SetPos(0, 0)
    overlayPanel.Paint = function()
        if overlay then
            surface.SetDrawColor(255, 255, 255)
            surface.SetTexture(overlay)
            surface.DrawTexturedRect(0, 0, overlayPanel:GetWide(), overlayPanel:GetTall())
        end
    end
end)

net.Receive("RunTeleportOverlay", function()
    Screen = vgui.Create("DFrame")
    Screen:SetSize(ScrW(), ScrH())
    Screen:SetPos(0, 0)
    Screen:SetTitle("")
    Screen:SetVisible(true)
    Screen:SetDraggable(false)
    Screen:ShowCloseButton(false)
    Screen.Paint = function()
    end

    local overlay = surface.GetTextureID("effects/electricity/bolt_sizzle")
    overlayPanel = vgui.Create("DPanel", Screen)
    overlayPanel:SetSize(Screen:GetWide(), Screen:GetTall())
    overlayPanel:SetPos(0, 0)
    overlayPanel.Paint = function()
        if overlay and overlayPanel and overlayPanel:IsValid() then
            surface.SetDrawColor(255, 255, 255)
            surface.SetTexture(overlay)
            surface.DrawTexturedRect(0, 0, overlayPanel:GetWide(), overlayPanel:GetTall())
        end
    end

    overlayPanel2 = vgui.Create("DPanel", Screen)
    overlayPanel2:SetSize(Screen:GetWide(), Screen:GetTall())
    overlayPanel2:SetPos(0, 0)
    overlayPanel2.Paint = function()
    end

    LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1.5, 2.5)
    surface.PlaySound("teleporter/teleport_sound.ogg")
    
    timer.Simple(2, function()
        local funcCalls, startBlur = {}, SysTime()
        for i = 0, 30 do 
            timer.Simple(math.random(0.05, 0.15) * i, function() funcCalls[i] = 0 end)
        end
        timer.Create("EffectTimer", 1 / 60, 120, function()
            for k, v in pairs(funcCalls) do
                funcCalls[k] = math.Approach(v, 1, 0.01)
            end
        end)
        
        overlayPanel.Paint = function()
            draw.NoTexture()

            for k, v in pairs(funcCalls) do
                surface.SetDrawColor(50, 50, 255 * funcCalls[k], 255)
                draw.Circle(overlayPanel:GetWide() / 2, overlayPanel:GetTall() / 2, math.sin(v) * 1920, 128)
            end
        end
        overlayPanel2.Paint = function()
            Derma_DrawBackgroundBlur(overlayPanel2, startBlur)
            draw.NoTexture()
            
            for k, v in pairs(funcCalls) do
                --funcCalls[k] = math.Approach(v, 1, 0.01)
                surface.SetTexture(surface.GetTextureID("models/props_combine/com_shield001a"))
                surface.SetDrawColor(255, 255, 255, 255)
                draw.Circle(overlayPanel2:GetWide() / 2, overlayPanel2:GetTall() / 2, math.sin(v) * 1920, 128)
            end
        end

        timer.Simple(2, function()
            Screen:Remove()
        end)
    end)
end)

net.Receive("StopOverlay", function()
    if Screen and ispanel( Screen ) then Screen:Remove() end
end)

net.Receive("RunSound", function()
    local soundToRun = tostring(net.ReadString())
    local soundLevel = net.ReadInt(16)
    --surface.PlaySound(tostring(soundToRun))
    LocalPlayer():EmitSound(soundToRun, soundLevel or 75)
end)

drawMessages = false
net.Receive("StartBloodCount", function()
    drawMessages = true
end)

--When we need to update the blood god ee kill count
net.Receive("UpdateBloodCount", function()
    local updateTo = net.ReadInt(16)
    if updateTo != chalkMessages.counter.num then --Only because I want the bell to play when kills have been added
        chalkMessages.counter.num = updateTo
        surface.PlaySound("ambient/alarms/warningbell1.wav")
    end
end)

--Resets all chalk messages on game start after a loss
net.Receive("ResetChalkMessages", function()
    chalkMessages = table.Copy(chalkBackup)
end)

--Converts all chalk messages to RUN, COWARD for extra sp00kiness
net.Receive("RunCoward", function()
    for k, v in pairs(chalkMessages) do
        v.msg = "RUN, COWARD"
    end
end)

--Starts drawing the HUD timer-circle-thing
net.Receive("StartTeleportTimer", function()
    totalTime = net.ReadInt(16)
    drawTimer = true
    timeLeft = 0
end)

--Received every second while LocalPlayer is going to be teleported
net.Receive("UpdateTeleportTimer", function()
    local updateTo = net.ReadInt(16)
    timeLeft = math.Round((totalTime - math.Clamp(updateTo, 0, totalTime)) / totalTime * 360)
    if updateTo == 0 then
        drawTimer = false
    end
end)

batteryLevel = 0
batteryIMG = Material("hud/flashlight.png")
--Received every second while LocalPLayer has his flashlight on
net.Receive("SendBatteryLevel", function()
    local newLevel = net.ReadInt(16)
    if newLevel > batteryLevel then
        --play some sound
    end
    --Play a sound when it runs out?
    batteryLevel = math.Clamp(newLevel, 0, 100)
end)

chalkMessages = {
    counter = {pos1 = Vector(-513.988129, 3552.188965, 161.082184), rot = Angle(0, 0, 0), num = 0, goal = 20},
    msg1 = {pos1 = Vector(-1664.031250, 2424.160400, 112.724030), rot = Angle(0, 270, 0), msg = "I HUNGER"},
    msg2 = {pos1 = Vector(-1160.546265, 2368.251465, 138.644363), rot = Angle(0, 180, 0), msg = {"   ARCS OF BLUE", "MAKE IT TRUE"}},
    msg3 = {pos1 = Vector(-1216.598877, 2771.254150, 137.531754), rot = Angle(0, 90, 0), msg = {"BRING FORTH", "          THE   LAMBS", "               TO     SLAUGHTER"}},
    msg4 = {pos1 = Vector(-4039.113037, 1984.031250, 122.161331), rot = Angle(0, 180, 0), msg = {"WITHOUT A TORCH", "    A SOUL IS LOST"}},
    msg5 = {pos1 = Vector(-3071.968750, 1413.312500, 109.798767), rot = Angle(0, 90, 0), msg = "I REMAIN YET UNSATISFIED"},
    msg6 = {pos1 = Vector(-320.598755, 3618.671143, 112.714233), rot = Angle(0, 90, 0), msg = {"THE     STRAIN", "  BRINGS", "  IT DOWN"}}
}
chalkBackup = table.Copy(chalkMessages)

--Draw the messages along the walls
hook.Add("PostDrawOpaqueRenderables", "DrawChalkMessages", function()
    if !drawMessages or !enableHudEffects then return end
    
    for k, v in pairs(chalkMessages) do
        if !v.msg then text = v.num .. " dead"
        else text = v.msg end

        cam.Start3D2D(v.pos1, Angle(0, 0, 90) + v.rot, 0.5)
            draw.NoTexture()
            surface.SetFont("nz.display.hud.main")
            surface.SetDrawColor(255, 255, 255)
            surface.SetTextColor(255, 255, 255)
            if istable(v.msg) then
                for k, v in pairs(v.msg) do
                    surface.SetTextPos(0, 48 * (k - 1))
                    surface.DrawText(v)
                end
            else
                surface.SetTextPos(0, 0)
                surface.DrawText(text)
            end
        cam.End3D2D()
    end
end)

--Set up battery drawing on the screen here
hook.Add("HUDPaint", "BatteryDisplay", function() --HUDPaintBackground
    if !enableHudEffects or !LocalPlayer():Alive() then return end

    local w, h = ScrW(), ScrH()
    local scale = ((w / 1920) + 1) / 2
    local drawW = w - (630 * scale) - (128 / 2) + 40
    local drawH = h - ((225 / 2) * scale) - (128 / 2) + 58

    --A lot smaller since all of the code is in the draw.Arc function
    if drawTimer then
        surface.SetTexture(surface.GetTextureID("models/props_combine/com_shield001a"))
        draw.Arc(100, 100, 80, 80, 90, -270 + timeLeft, 3, Color(0, 0, 0))
    end

    --Since we're drawing the battery to the left of cod_hud, need to copy distance drawing from the gamemode's cl_hud
    if batteryLevel then
        surface.SetMaterial(batteryIMG)
        surface.SetDrawColor(150, 0, 0)
        surface.DrawTexturedRect(drawW - 25, drawH - 27, 128 / 2, 128 / 2)

        draw.NoTexture()
        draw.RoundedBox(4, drawW, drawH, 14, 28, Color(0, 0, 0))

        local fade = math.sin(CurTime() * 12)
        if batteryLevel < 25  and batteryLevel > 0 then
            draw.RoundedBox(4, drawW + 1, drawH + 28 - 8, 12, 6, Color(255 * fade, 255 * fade, 255 * fade))
        end
        if batteryLevel > 25 then
            if batteryLevel < 30 then
                draw.RoundedBox(4, drawW + 1, drawH + 28 - 8, 12, 6, Color(255 * fade, 255 * fade, 255 * fade))
            else
                draw.RoundedBox(4, drawW + 1, drawH + 28 - 8, 12, 6, Color(255, 255, 255))
            end
        end
        if batteryLevel > 50 then
            if batteryLevel < 55 then
                draw.RoundedBox(4, drawW + 1, drawH + 28 - 17, 12, 6, Color(255 * fade, 255 * fade, 255 * fade))
            else
                draw.RoundedBox(4, drawW + 1, drawH + 28 - 17, 12, 6, Color(255, 255, 255))
            end
        end
        if batteryLevel > 75 then
            if batteryLevel < 80 then
                draw.RoundedBox(4, drawW + 1, drawH + 28 - 26, 12, 6, Color(255 * fade, 255 * fade, 255 * fade))
            else
                draw.RoundedBox(4, drawW + 1, drawH + 28 - 26, 12, 6, Color(255, 255, 255))
            end
        end
    end
end)