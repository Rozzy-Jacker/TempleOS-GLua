AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("templeos/cl_net.lua")
AddCSLuaFile("templeos/cl_screen.lua")
AddCSLuaFile("templeos/cl_boot.lua")
AddCSLuaFile("templeos/cl_text.lua")
include("shared.lua")
include("templeos/sv_cmd.lua")
include("templeos/sv_net.lua")
local realistic_boot = CreateConVar("holylua_realistic_boot", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
local bootconvar = CreateConVar("holylua_enable_boot", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})

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
end

function ENT:Use(ply)
    if !ply:IsPlayer() then return end
    
    if !self:GetNWBool("On") then 
        self:SetNWBool("On", true)
        
        if bootconvar:GetBool() then 
            if !realistic_boot:GetBool() then 
            self:EmitSound("TempleOS_Hymn.mp3")
            timer.Simple(12, function() 
                if IsValid(self) then 
                    self:SetNWBool("Boot", true)
                end
            end)
            else 
                timer.Simple(1, function() 
                    if IsValid(self) then 
                        self:SetNWBool("Boot", true)
                    end
                end)
            end
        else 
            self:SetNWBool("Boot", true)
        end
    else
        if !self:GetNWBool("Boot") then return end 
        TempleOS.Input(ply, self, true)
    end
end
