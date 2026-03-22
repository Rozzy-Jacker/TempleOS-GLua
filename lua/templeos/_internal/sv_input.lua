function TempleOS.Input(ply,ent,bool)
    if bool == true then 
        ply.tos_input = true 
        ply:SetNWBool("TOS_Input",true)
        ply.tos_ent = ent 
        net.Start("TempleOS_StartInput")
        net.WriteEntity(ply.tos_ent)
        net.Send(ply)
        ply:DrawViewModel(false)
    elseif bool == false then 
        ply.tos_input = false
        ply:SetNWBool("TOS_Input",false)
        ply.tos_ent = nil 
        ply:DrawViewModel(true)
    end
end
hook.Add("PlayerDeath","TOS_DisableInput",function(ply)
    TempleOS.Input(ply,ply.tos_ent,false)
end)
hook.Add("PlayerSpawn","TOS_DisableInput",function(ply)
    TempleOS.Input(ply,ply.tos_ent,false)
end)
net.Receive("TempleOS_StopInput",function()
    local ply = net.ReadEntity()
    TempleOS.Input(ply,ply.tos_ent,false)
end)
/*hook.Add("StartCommand", "TOS_BlockInput", function(ply, cmd)
    if ply:GetNWBool("TOS_Input") then
        cmd:ClearButtons()
        return true  
    end
end)
hook.Add("KeyPress","TOS_Input",function(ply,key)
    if ply.tos_input then 
        if key == KEY_ESCAPE or IN_ATTACK2 then 
            TempleOS.Input(ply,ply.tos_ent,false)
        end
    end
end) */ // doesn't work properly
// add disconnect disabling later