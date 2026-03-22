AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

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
            self:EmitSound("TempleOS_Hymn.mp3")
            timer.Simple(12, function() 
                if IsValid(self) then 
                    self:SetNWBool("Boot", true)
                end
            end)
        else 
            self:SetNWBool("Boot", true)
        end
    else
        if !self:GetNWBool("Boot") then return end 
        TempleOS.Input(ply, self, true)
    end
end
function ENT:ClearScreen()
    print("Screen cleaned placeholder")
    net.Start("TempleOS_Clear")
    net.WriteEntity(self)
    net.Broadcast()
end
function ENT:DoClientCommand(msg)
    net.Start("TempleOS_Command")
    net.WriteEntity(self)
    net.WriteString(msg)
    net.Broadcast()
end
function ENT:Print(msg,col)
    net.Start("TempleOS_Print")
    net.WriteEntity(self)
    net.WriteString(msg)
    net.WriteColor(col or holylua.color[1])
    net.Broadcast()
end
function ENT:PrintInternal(msg,col)
    net.Start("TempleOS_Print")
    net.WriteEntity(self)
    net.WriteString(msg)
    net.WriteColor(col or holylua.color[1])
    net.WriteBool(false)
    net.Broadcast()
end
function ENT:ApplyCommand(msg_raw)
    
// MemRep, Date, Time, Version, CpuRep
// God - Random Verse
//Boot and Reboot to reboot system 
// Shutdown to shutdown
// music to play music templeos_hymn
// Beep - system beep
//Snd path to self:EmitSound
// SndRst to stop that sound 
// Randi32 - random integer
//GodBits() - divine random number
//GodSpeak() -  holylua.God.Speech()
//Clear screen
//Help - print all commands
    local msg = msg_raw:lower()
    if msg == "help" then 
        self:PrintInternal("[SYSTEM]", holylua.color[2])
        self:PrintInternal("help        - Show this help message", holylua.color[1])
        self:PrintInternal("clear       - Clear the screen", holylua.color[1])
        self:PrintInternal("shutdown    - Shutdown the system", holylua.color[1])
        self:PrintInternal("reboot      - Reboot the system", holylua.color[1])
        self:PrintInternal("version     - Show TempleOS version", holylua.color[1])
        self:PrintInternal("[DIVINE]", holylua.color[2])
        self:PrintInternal("god         - Random Bible verse", holylua.color[1])
        self:PrintInternal("godspeak    - Divine speech", holylua.color[1])
        self:PrintInternal("godbits     - Random divine number (1-100)", holylua.color[1])
        self:PrintInternal("randi32     - Random 32-bit integer", holylua.color[1])
        self:PrintInternal("[SOUND]", holylua.color[2])
        self:PrintInternal("music       - Play TempleOS hymn", holylua.color[1])
        self:PrintInternal("beep        - System beep", holylua.color[1])
        self:PrintInternal("snd <file>  - Play custom sound", holylua.color[1])
        self:PrintInternal("sndrst      - Stop all sounds", holylua.color[1])
        self:PrintInternal("[INFO]", holylua.color[2])
        self:PrintInternal("memrep      - Memory report", holylua.color[1])
        self:PrintInternal("date        - Current date", holylua.color[1])
        self:PrintInternal("time        - Current time", holylua.color[1])
        self:PrintInternal("cpurep      - CPU report", holylua.color[1])
    elseif msg == "godspeak" then 
        self:PrintInternal(">    "..holylua.God.Speech(),holylua.color[2])
    elseif msg == "godbits" then 
        self:PrintInternal(holylua.random(100),holylua.color[2])
    elseif msg == "god" then 
        self:PrintInternal(holylua.God.Verse(holylua.bible_verses),holylua.color[2]) 
    elseif msg == "clear" then 
        self:ClearScreen()
    elseif msg == "music" then 
        self:EmitSound("TempleOS_Hymn.mp3")
        table.insert(self.sounds,"TempleOS_Hymn.mp3")
    elseif msg == "shutdown" then 
        self:ClearScreen()
        if bootconvar:GetBool() then 
            self:SetNWBool("Boot",false)
        end
        self:SetNWBool("On",false)
    elseif msg == "reboot" or msg == "boot" then 
        self:ClearScreen()
        self:SetNWBool("On",false)
        self:SetNWBool("Boot", false)
        self:SetNWBool("On", true) 
        self:EmitSound("TempleOS_Hymn.mp3")
        timer.Simple(12, function() 
           if IsValid(self) then 
                self:SetNWBool("Boot", true)
            end
        end)
    elseif msg == "memrep" or msg == "date" or msg =="time" or msg =="cpurep" then 
        self:DoClientCommand(msg)
    elseif msg == "randi32" then 
        self:PrintInternal(holylua.random(2e31-1),holylua.color[2])
    elseif msg == "version" then 
        self:PrintInternal("TempleOS V"..TempleOS.Version, holylua.color[6])
    elseif msg == "beep" then 
        self:EmitSound("ibm_beep.mp3")
    elseif string.find(msg, "^snd ") then
        local snd = string.sub(msg, 5) 
        snd = string.Trim(snd)
        if snd == "" then
            self:PrintInternal("Usage: snd <filename>", holylua.color[3])
            return
        end
        if file.Exists("sound/" .. snd, "GAME") then
            self:EmitSound(snd)
            table.insert(self.sounds, snd)
            self:PrintInternal("Playing: " .. snd, holylua.color[3])
        else
            self:PrintInternal("Sound file not found: " .. snd, holylua.color[5])
        end
    elseif msg == "sndrst" then 
        for _, v in ipairs(self.sounds) do 
            self:StopSound(v)
        end
    end
end
net.Receive("TempleOS_Input", function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()
    net.Start("TempleOS_Print")
    net.WriteEntity(ent)
    net.WriteString(msg)
    net.WriteColor(holylua.color[2])
    net.Broadcast()
    ent:ApplyCommand(msg)
end)