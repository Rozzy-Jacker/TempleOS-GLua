AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("templeos/cl_net.lua")
AddCSLuaFile("templeos/cl_screen.lua")
AddCSLuaFile("templeos/cl_boot.lua")
AddCSLuaFile("templeos/cl_text.lua")
AddCSLuaFile("templeos/sh_fm.lua")
include("shared.lua")
include("templeos/sv_cmd.lua")
include("templeos/sv_net.lua")
include("templeos/sh_fm.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/monitor01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetNWBool("Boot", false)
    self:SetNWBool("On", false)
    self.sounds = {}
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:Wake()
    end
    self:fm_init()
    local fuckn = self:GetNWString("CurrentPrompt")
    if fuckn == "" or fuckn == nil then
        self:SetNWString("CurrentPrompt", "C:\\>")
    end
end

function ENT:Use(ply)
    if !ply:IsPlayer() then return end
    
    if !self:GetNWBool("On") then 
        self:SetNWBool("On", true)
        self:SyncPrompt()
        if !self.Killed then  
            timer.Simple(math.random(0.5,1.5), function() 
                if IsValid(self) then 
                    self:SetNWBool("Boot", true)
                    self:EmitSound("ibm_beep.mp3")
                end
            end)
        end
    elseif self:GetNWBool("On") and self:GetNWBool("Boot") then
        TempleOS.Input(ply, self, true)
    end
end