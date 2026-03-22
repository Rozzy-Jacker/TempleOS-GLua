net.Receive("TempleOS_Print",function()
    local ent = net.ReadEntity()
    local msg = net.ReadString() or "invalid"
    local col = net.ReadColor() or holylua.color[2]
    local bool = net.ReadBool()
    if msg ~= "" then 
        ent:AddTextLine(msg,col, bool)
    else
        ent:AddEmptyLine()
    end
end)
net.Receive("TempleOS_Command",function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()
    ent:DoCommand(msg)
end)
net.Receive("TempleOS_Clear",function() 
    local ent = net.ReadEntity()
    ent.lines = {}
    ent:AddTextLine("TempleOS V"..TempleOS.Version, holylua.color[6], false)
    ent:AddTextLine("Type 'Help' for commands ", holylua.color[1], false)
    ent:AddEmptyLine()
    ent:SetNWString("PromptLine","")
end)