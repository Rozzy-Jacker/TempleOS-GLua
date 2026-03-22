   
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
function ENT:ApplyCommand(msg_raw)

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
        if !GetConVar("holylua_realistic_boot"):GetBool() then 
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