local ib, terminal = nil,nil 
local camera_on = false 
CreateClientConVar("holylua_terminal_view","0",true,false,"Enable direct view pos on terminal screen")
net.Receive("TempleOS_StartInput",function()
    local ply = LocalPlayer()
    local ent = net.ReadEntity()
    if !IsValid(ply) then return end 
    terminal = ent 
    if IsValid(terminal) then terminal:SetNWString("PromptLine","") end
    gui.EnableScreenClicker(true)
    ib = vgui.Create("DTextEntry") // input box
    ib:SetSize(0,0) ib:SetPos(0,0)
    ib:MakePopup() ib:RequestFocus()
    function ib:AllowedText(text)
        return text:match("^[a-zA-Z0-9 %p]*$") ~= nil //font
    end
    ib.OnTextChanged = function(box)
        local msg_raw = box:GetValue()
        if !box:AllowedText(msg_raw) then 
            local msg = msg_raw:gsub("[^a-zA-Z0-9 %p]", "")
            box:SetValue(msg)
            if IsValid(terminal) then terminal:SetNWString("PromptLine",msg) end
        else
            if IsValid(terminal) then terminal:SetNWString("PromptLine",msg_raw) end
        end
    end
    ib.OnKeyCode = function(box,key) // escaping
        if key == KEY_ESCAPE then
            CloseInput()
        end
    end
    ib.OnEnter = function(box) // sending
        local cmd = box:GetValue()
        cmd = cmd:gsub("[^a-zA-Z0-9 %p]", "")
        if cmd != "" then
            net.Start("TempleOS_Input")
            net.WriteEntity(terminal)
            net.WriteString(cmd)
            net.WriteEntity(LocalPlayer())
            net.SendToServer()
        end
        //reset
        box:SetText("")
        if IsValid(terminal) then terminal:SetNWString("PromptLine","") end
        box:SetValue("")
        box:RequestFocus()
    end
end)
hook.Add("OnPauseMenuShow", "TOS_DisableMenu", function() // fix main menu opening after close
    if IsValid(ib) then 
        return false 
    end 
end)

function CloseInput()
    if IsValid(terminal) then terminal:SetNWString("PromptLine","") end
    if ib and ib:IsValid() then
        ib:SetValue("")
        ib:Remove()
        ib = nil 
    end
    net.Start("TempleOS_StopInput")
    net.WriteEntity(LocalPlayer())
    net.SendToServer()
    gui.EnableScreenClicker(false)
    camera_on = false 
    terminal = nil
end
hook.Add("CalcView","TOS_TerminalCamera",function(ply, origin, angles, fov, znear, zfar)
    if GetConVarNumber("holylua_terminal_view") == 0 then return end
    if IsValid(terminal) and LocalPlayer():GetNWBool("TOS_Input") then 
        local tpos,tang = terminal:GetPos(),terminal:GetAngles()
        local f,r,u = tang:Forward(),tang:Right(),tang:Up()
        local cam_pos = tpos + f * 40 + u * 5 
        local cam_ang = (tpos-cam_pos):Angle()
        local view = {}
        view.origin = cam_pos
        view.angles = cam_ang
        view.fov = 75
        view.drawviewer = false
        return view
    end
end)
