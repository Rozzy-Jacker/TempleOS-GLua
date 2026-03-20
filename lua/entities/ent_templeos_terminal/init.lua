AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
local bootconvar =  CreateConVar("holylua_enable_boot", 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED})
function ENT:Initialize()
    self:SetModel("models/props_lab/monitor01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetNWBool("Boot",false)
    self:SetNWBool("On",false)
    local physObj = self:GetPhysicsObject()
    if not physObj:IsValid() then return end
    physObj:Wake()
end

function ENT:Use(a, c)
    if !a:IsPlayer() then return end
    if !self:GetNWBool("On") then 
        self:SetNWBool("On",true)
        if bootconvar:GetBool() then 
            self:EmitSound("TempleOS_Hymn.mp3")
            timer.Simple(12,function() 
                if IsValid(self) then 
                    self:SetNWBool("Boot",true)
                end
            end)
        else 
            self:SetNWBool("Boot",true)
        end
    else
        if !self:GetNWBool("Boot") then return end 
        net.Start("TempleOS_Interact")
        net.WriteEntity(self)
        net.WriteString(holylua.God.Speech()) 
        net.Broadcast()
    end
end


