
include("shared.lua")
include("templeos/cl_net.lua")
include("templeos/cl_screen.lua")
include("templeos/cl_text.lua")
function ENT:Initialize()
    self.lines = {}
    self.blinkstatus = true
    self:AddTextLine("TempleOS V"..TempleOS.Version, holylua.color[6], false)
    self:AddTextLine("Type 'Help' for commands ", holylua.color[1], false)
    self:AddEmptyLine()
    self:SetNWString("PromptLine","")
end

function ENT:Draw( flags ) 
	self:DrawModel( flags )
    self:DrawScreen()
end