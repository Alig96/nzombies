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

    LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0), 1.5, 2)
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
    soundtoRun = net.ReadString()
    surface.PlaySound(soundToRun)
end)

net.Receive("StartBloodCount", function()
    startedChalk = true
end)

net.Receive("UpdateBloodCount", function()
    local updateTo = net.ReadInt(16)
    chalkMessages.counter.num = updateTo
    surface.PlaySound("ambient/alarms/warningbell1.wav")
end)

batteryLevel = 0
net.Receive("SendBatteryLevel", function()
    local newLevel = net.ReadInt(6)
    batteryLevel = math.Clamp(newLevel, 0, 100)
end)

chalkMessages = {
    counter = {pos1 = Vector(-568, 3552, 170.5), pos2 = Vector(-402, 3552, 137), num = 0, goal = 30},
    msg1 = {pos1 = Vector(-1664.0, 2378.5, 125.8), pos2 = Vector(-1664, 2210.75, 58.5), msg = "Blood for the Blood God"},
    msg2 = {pos1 = Vector(-751.5, 2880.2, 104.2), pos2 = Vector(-630.5, 2880.2, 59.8), msg = "Arcs of Blue Make it True"},
    msg3 = {pos1 = Vector(-1216.6, 2768.9, 94.7), pos2 = Vector(-1216.6, 2869.6, 51.8), msg = "Bring Forth the Lambs to Slaughter"}
}
local chalkmaterial = Material("chalk.png", "unlitgeneric smooth")

hook.Add("PostDrawOpaqueRenderables", "DrawChalkMessages", function()
    if !startedChalk then return end

    --local trace = LocalPlayer():GetEyeTrace()
    --local angle = trace.HitNormal:Angle()

    local text = ""
    for k, v in pairs(chalkMessages) do
        if !v.msg then text = v.num .. " dead"
        else text = v.msg end

        cam.Start3D2D(v.pos1, Angle(0, 0, 0), 1)
            surface.SetFont("nz.display.hud.main")
            surface.SetDrawColor(255, 255, 255)
            --surface.SetMaterial(chalkmaterial)
            surface.SetTextPos(30, 30)
            surface.DrawText(text)
        cam.End3D2D()
    end
end)

--Set up battery drawing on the screen here
hook.Add("HUDPaintBackground", "BatteryDisplay", function()
    --Do stuff
end)