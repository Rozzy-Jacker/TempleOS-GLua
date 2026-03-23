function ENT:ApplyCommand(msg_raw)
 
    if self.editmode then
        if msg_raw == " " or msg_raw == "exit" then
            if self.editbuf and self.editbuf ~= "" then
                local filename = self.editfile:match("([^/\\]+)$") or self.editfile
                local valid, errMsg = self:fm_validate_name(filename)
                if not valid then
                    self:PrintInternal("Invalid filename: " .. (errMsg or "name is too big"), holylua.color[5])
                    self.editmode = false
                    self.editfile = nil
                    self.editbuf = nil
                    return
                end
                local suc, err = self:fm_write(nil, self.editfile, self.editbuf, false)
                if suc then
                    self:PrintInternal("File saved: " .. self.editfile, holylua.color[2])
                else
                    self:PrintInternal(err, holylua.color[5])
                end
            else
                self:PrintInternal("Empty file, nothing saved", holylua.color[3])
            end
            self.editmode = false
            self.editfile = nil
            self.editbuf = nil
            self:PrintInternal("Exited edit mode", holylua.color[2])
            return
        else
            self.editbuf = (self.editbuf or "") .. msg_raw .. "\n"
            self:PrintInternal("> " .. msg_raw, holylua.color[3])
            return
        end
    end
    local args = {}
    for arg in string.gmatch(msg_raw, "[^%s]+") do
        table.insert(args, arg)
    end
    local cmd = args[1] and string.lower(args[1]) or ""
    local arg = args[2] or ""
    local arg3 = args[3] or ""
    if cmd == "help" then
        if !self.help_page then self.help_page = 1 end
        local page = tonumber(arg)
        if page then
            self.help_page = page
        end
        local pages = {
            [1] = {
                title = "SYSTEM COMMANDS",
                cmds = {
                    {"help [page]", "Show this help"}, {"clear", "Clear the screen"}, {"shutdown", "Shutdown the system"},
                    {"reboot", "Reboot the system"}, {"version", "Show TempleOS version"}, {"pwd", "Show current path"}
                }
            },
            [2] = {
                title = "FILE MANAGER",
                cmds = {
                    {"dir [path]", "List directory contents"}, {"cd <path>", "Change directory"},{"cat <file>", "Display file content"},
                    {"edit <file>", "Create/edit file"},{"del <file>", "Delete file"},{"mkdir <dir>", "Create directory"},
                    {"rmdir <dir>", "Remove directory"}, {"drives", "List all drives"},{"tree [path] [depth]", "Show directory tree"},
                    //{"format <drv>", "Format drive"},
      
                }
            },
            [3] = {
                title = "DIVINE COMMANDS",
                cmds = {
                    {"god", "Random Bible verse"}, {"godspeak", "Divine speech"},
                    {"godbits", "Random divine number"}, {"randi32", "Random 32-bit integer"}
                }
            },
            [4] = {
                title = "SOUND & INFO",
                cmds = {
                    {"music", "Play TempleOS hymn"},{"beep", "System beep"},
                    {"snd <file>", "Play custom sound"},{"sndrst", "Stop all sounds"},
                    {"memrep", "Memory report"},{"date", "Current date"},
                    {"time", "Current time"},{"cpurep", "CPU report"}
                }
            }
        }
        local total_pages = table.Count(pages)
        if self.help_page < 1 then self.help_page = 1 end
        if self.help_page > total_pages then self.help_page = total_pages end
        
        local page_data = pages[self.help_page]
        self:PrintInternal("=== " .. page_data.title .. " (Page " .. self.help_page .. "/" .. total_pages .. ") ===", holylua.color[6])
        for _, cmd_item in ipairs(page_data.cmds) do
            self:PrintInternal(string.format("%-15s - %s", cmd_item[1], cmd_item[2]), holylua.color[1])
        end
        self:PrintInternal("", holylua.color[1])
        self:PrintInternal("Type 'help <page>' for other pages", holylua.color[3])
    
    elseif cmd == "godspeak" then 
        self:PrintInternal(">    "..holylua.God.Speech(), holylua.color[2])
    
    elseif cmd == "godbits" then 
        self:PrintInternal(holylua.random(100), holylua.color[2])
    
    elseif cmd == "god" then 
        self:PrintInternal(holylua.God.Verse(holylua.bible_verses), holylua.color[2]) 
    
    elseif cmd == "clear" then 
        self:ClearScreen()
    
    elseif cmd == "music" then 
        self:EmitSound("TempleOS_Hymn.mp3")
        table.insert(self.sounds, "TempleOS_Hymn.mp3")
    
    elseif cmd == "shutdown" then 
        self:ClearScreen()
        self:SetNWBool("Boot", false)
        self:SetNWBool("On", false)
    
    elseif cmd == "reboot" or cmd == "boot" then 
        self:ClearScreen()
        self:SetNWBool("On", false)
        self:SetNWBool("Boot", false)
        self:SetNWBool("On", true) 
        timer.Simple(math.random(0.5,1.5), function() 
            if IsValid(self) then 
                self:SetNWBool("Boot", true)
                self:EmitSound("ibm_beep.mp3")
            end
        end)
    
    elseif cmd == "memrep" or cmd == "date" or cmd == "time" or cmd == "cpurep" then 
        self:DoClientCommand(cmd)
    elseif cmd == "randi32" then 
        self:PrintInternal(holylua.random(2e31-1), holylua.color[2])
    elseif cmd == "version" then 
        self:PrintInternal("TempleOS V"..TempleOS.Version, holylua.color[6])
    
    elseif cmd == "beep" then 
        self:EmitSound("ibm_beep.mp3")
    elseif cmd == "snd" then
        if arg == "" then
            self:PrintInternal("Usage: snd <filename>", holylua.color[3])
            return
        end
        if file.Exists("sound/" .. arg, "GAME") then
            self:EmitSound(arg)
            table.insert(self.sounds, arg)
            self:PrintInternal("Playing: " .. arg, holylua.color[3])
        else
            self:PrintInternal("Sound file not found: " .. arg, holylua.color[5])
        end
    elseif cmd == "sndrst" then 
        for _, v in ipairs(self.sounds) do 
            self:StopSound(v)
        end
    elseif cmd == "dir" or cmd == "ls" then
        local path = arg or ""
        local items, err = self:fm_list(nil, path)
        if err then
            self:PrintInternal(err, holylua.color[5])
        else
            if #items == 0 then
                self:PrintInternal("Directory is empty", holylua.color[3])
            else
                self:PrintInternal("Directory listing:", holylua.color[6])
                for _, item in ipairs(items) do
                    local size_str = self:fm_format_size(item.size)
                    local type_char = item.dir and "[DIR]" or "     "
                    local color = item.dir and holylua.color[3] or holylua.color[1]
                    self:PrintInternal(string.format("%s %-20s %10s", type_char, item.name, size_str), color)
                end
            end
        end
    elseif cmd == "cd" then
        local path = arg or "/"
        if path:match("^[A-Za-z]$") then
            path = path .. ":\\"
        end
        local success, err = self:fm_cd(nil, path)
        if success then
            self:PrintInternal("Changed to " .. self:fm_get_prompt(), holylua.color[2])
            self:SyncPrompt()
        else
            self:PrintInternal(err, holylua.color[5])
        end
    elseif cmd == "cat" then
        if arg == "" then
            self:PrintInternal("Usage: cat <file>", holylua.color[5])
            return
        end
        local content, err = self:fm_read(nil, arg)
        if err then
            self:PrintInternal(err, holylua.color[5])
        else
            self:PrintInternal(content, holylua.color[1])
        end
    elseif cmd == "edit" or cmd == "ed" then
        if arg == "" then
            self:PrintInternal("Usage: edit <file>", holylua.color[5])
            return
        end
        local filename = arg:match("([^/\\]+)$") or arg
        local valid, errMsg = self:fm_validate_name(filename)
        if not valid then
            self:PrintInternal("Invalid name" .. (errMsg and (": "..errMsg) or ""), holylua.color[5])
            return
        end
        self.editfile = arg
        local existingContent, err = self:fm_read(nil, arg)
        if existingContent and existingContent ~= "" then
            self.editbuf = existingContent
            self:PrintInternal("Editing: " .. arg .. " (existing content shown below)", holylua.color[3])
            for line in string.gmatch(existingContent, "[^\n]+") do
                self:PrintInternal(line, holylua.color[1])
            end
            self:PrintInternal("Type additional content (end with empty line or exit cmd):", holylua.color[3])
        else
            self.editbuf = ""
            self:PrintInternal("Editing: " .. arg .. " (Type content, end with empty line or exit cmd)", holylua.color[3])
        end
        self.editmode = true
    elseif cmd == "delete" or cmd == "del" then
        if arg == "" then
            self:PrintInternal("Usage: del <file>", holylua.color[5])
            return
        end
        local success, err = self:fm_del(nil, arg)
        if success then
            self:PrintInternal("Deleted: " .. arg, holylua.color[2])
        else
            self:PrintInternal(err, holylua.color[5])
        end
    
    elseif cmd == "mkdir" then
        if arg == "" then
            self:PrintInternal("Usage: mkdir <directory>", holylua.color[5])
            return
        end
        local foldername = arg:match("([^/\\]+)$") or arg
        local valid, errMsg = self:fm_validate_name(foldername)
        if not valid then
            self:PrintInternal("Invalid name" .. (errMsg and (": "..errMsg) or ""), holylua.color[5])
            return
        end
        local success, err = self:fm_mkdir(nil, arg)
        if success then
            self:PrintInternal("Created: " .. arg, holylua.color[2])
        else
            self:PrintInternal(err, holylua.color[5])
        end
    elseif cmd == "rmdir" then
        if arg == "" then
            self:PrintInternal("Usage: rmdir <directory>", holylua.color[5])
            return
        end
        local success, err = self:fm_rmdir(nil, arg)
        if success then
            self:PrintInternal("Removed directory: " .. arg, holylua.color[2])
        else
            self:PrintInternal(err, holylua.color[5])
        end
    elseif cmd == "drives" or cmd == "drv" then
        local drives = self:fm_drives_list()
        self:PrintInternal("Available drives:", holylua.color[6])
        for _, d in ipairs(drives) do
            local size_str = self:fm_format_size(d.size)
            local free_str = self:fm_format_size(d.free)
            local used_str = self:fm_format_size(d.size - d.free)
            local marker = (d.letter == self.current_drive) and "*" or " "
            self:PrintInternal(string.format("%s%s: %-8s %-8s [%s/%s] %s/%s used", 
                marker, d.letter, d.name, d.type, d.status, d.readonly, size_str, used_str), holylua.color[1])
        end
    elseif cmd == "confirm" and self.pending_format then
        local success, msg = self:fm_format(self.pending_format)
        if success then
            self:PrintInternal(msg, holylua.color[2])
            self:SyncPrompt()
        else
            self:PrintInternal(msg, holylua.color[5])
        end
        self.pending_format = nil
    elseif cmd == "pwd" then
        self:PrintInternal(self:fm_get_prompt(), holylua.color[2])
    elseif cmd == "tree" then
        local path = arg or ""
        local maxdepth = tonumber(arg3) or 3
        if maxdepth < 1 then maxdepth = 1 end
        if maxdepth > 5 then maxdepth = 5 end
        local function print_tree(drive, curpath, prefix, maxdepth, curdepth)
            if curdepth > maxdepth then 
                self:PrintInternal(prefix .. "└── ...", holylua.color[3])
                return 
            end
            local items, err = self:fm_list(drive, curpath)
            if err then
                self:PrintInternal(prefix .. "└── [ERROR]", holylua.color[5])
                return
            end
            local dirs = {}
            local files = {}
            for _, item in ipairs(items) do
                if item.dir then
                    table.insert(dirs, item)
                else
                    table.insert(files, item)
                end
            end
            table.sort(dirs, function(a,b) return a.name < b.name end)
            table.sort(files, function(a,b) return a.name < b.name end)
            local all = {}
            for _, d in ipairs(dirs) do table.insert(all, d) end
            for _, f in ipairs(files) do table.insert(all, f) end
            for i, item in ipairs(all) do
                local is_last = (i == #all)
                local connector = is_last and "└── " or "├── "
                local new_prefix = prefix .. (is_last and "    " or "│   ")
                if item.dir then
                    self:PrintInternal(prefix .. connector .. "[" .. item.name .. "]/", holylua.color[3])
                    local newpath = curpath == "/" and "/" .. item.name or curpath .. "/" .. item.name
                    print_tree(drive, newpath, new_prefix, maxdepth, curdepth + 1)
                else
                    local size_str = self:fm_format_size(item.size)
                    if item.internal then 
                        self:PrintInternal(prefix .. connector .. item.name, holylua.color[1])
                    else
                    self:PrintInternal(prefix .. connector .. item.name .. " (" .. size_str .. ")", holylua.color[1])
                    end
                end
            end
        end
        local tdrive, tpath = self:fm_normalize(path, nil)
        local node, err = self:fm_node(tdrive, tpath)
        if err then
            self:PrintInternal(err, holylua.color[5])
        else
            local display_path = tdrive .. ":" .. tpath
            self:PrintInternal(display_path, holylua.color[6])
            print_tree(tdrive, tpath, "", maxdepth, 1)
        end
    elseif cmd == "exit" then
        if self.editmode then
            self.editmode = false
            self.editfile = nil
            self.editbuf = nil
            self:PrintInternal("Exited edit mode without saving", holylua.color[5])
        else
            self:PrintInternal("Not in edit mode", holylua.color[3])
        end
    else
        if msg_raw ~= "" then
            self:PrintInternal("Unknown command: " .. cmd .. " (type 'help')", holylua.color[5])
        end
    end
    self:SyncPrompt()
end