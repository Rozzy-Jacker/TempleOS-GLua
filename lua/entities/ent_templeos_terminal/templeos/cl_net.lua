net.Receive("TempleOS_Print",function() 
    local ent = net.ReadEntity()
    local msg = net.ReadString() or "invalid"
    local col = net.ReadColor() or holylua.color[2]
    local bool = net.ReadBool()
    if msg ~= "" then
        local prompt = ent:GetNWString("CurrentPrompt") or "C:\\>"
        if bool then
            ent:AddTextLine(prompt .. " " .. msg, col, bool)
        else
            ent:AddTextLine(msg, col, bool)
        end
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
net.Receive("TempleOS_SyncPrompt", function()
    local ent = net.ReadEntity()
    local prompt = net.ReadString()
    if IsValid(ent) then
        ent.full_prompt = prompt
    end
end)
net.Receive("TempleOS_SyncEditMode", function()
    local ent = net.ReadEntity()
    local mode = net.ReadBool()
    local file = net.ReadString()
    if IsValid(ent) then
        ent.editmode = mode
        ent.editfile = file
    end
end)