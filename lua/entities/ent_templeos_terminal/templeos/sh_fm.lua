// file manager init
function ENT:fm_init()
    self.drives = { // got it from web emulator stats
        ["B"] ={ name = "REDSEA",type = "RAM",size = 32768,
        filesystem = {},readonly = false,mounted = true,cwd="/"},
        ["C"] ={ name = "FAT32",type = "ATA",size =  1048576,
        filesystem = {},readonly = false,mounted = true,cwd="/"},
        ["D"] ={ name = "FAT32",type = "ATA",size =  2097152,
        filesystem = {},readonly = false,mounted = true,cwd="/"},
        ["T"] ={ name = "ISO9660",type = "ATAPI",size =  524288,
        filesystem = {},readonly = true,mounted = true,cwd="/"},
    }
    self.current_drive = "C"
    self:fm_base_structure()
end

function ENT:fm_base_structure()
    self.drives["B"].filesystem = {
        ["Cache"] = {dir = true, child = {}}
    }
    self.drives["C"].filesystem = {
        ["Adam"] = {dir = true, internal = true, child = {
            ["God"] = {dir = true, internal = true, child = {
                ["GodBible.HC"] = {internal = true},
                ["GodDoodle.HC"] = {internal = true},
                ["GodExt.HC"] = {internal = true},
                ["GodSong.HC"] = {internal = true},
                ["HolySpirit.HC"] = {internal = true},
                ["MakeGod.HC"] = {internal = true},
                ["MakeGod.HC"] = {internal = true},
                ["HSNotes.DD"] = {internal = true},
                ["Vocab.DD"] = {internal = true},
            }},
            ["MakeAdam.HC"] = {internal = true},
            ["Win.HC"] = {internal = true},
            ["Menu.HC"] = {internal = true},
            ["Host.HC"] = {internal = true},
        }},
        ["Compiler"] ={dir= true, internal = true, child ={
            ["Asm.HC"] = {internal = true},
            ["Compiler.PRJ"] = {internal = true},
            ["Compiler.MAP"] = {internal = true},
            ["Compiler.BIN"] = {internal = true},
            ["CompilerA.HH"] = {internal = true},
            ["CompilerB.HH"] = {internal = true},
        }},
        ["Home"] = {dir = true, child = {
            ["Documents"] = {dir = true, child = {}},
        }},
        ["Temp"] = {dir = true, child = {}},
    }
    self.drives["D"].filesystem = {
        ["Users"] = {dir = true, child = {}},
    }
    self.drives["T"].filesystem = {
        ["Manual"] = {dir = true, child = {
            ["README.txt"] = {
                dir = false,
                modified = os.time(),
                content = "PlaceHOlder",
                size = 0
            }
        }}
    }
    
    self:fm_update_all_sizes()
end

function ENT:KillSystem()
    self.Killed = true 
    self:SetNWBool("Killed",true)
    self:SetNWBool("On",false)
    self:SetNWBool("Boot",false)
end

// other util funcs with some basic secuirty
function ENT:fm_normalize(path,drive)
    if !drive then drive = self.current_drive end 
    if !self.drives[drive] then return drive, "/" end 
    if !path or path == "" then 
        return drive, self.drives[drive].cwd or "/"
    end
    if string.match(path, "^[A-Za-z]$") then
        drive = string.upper(path)
        if !self.drives[drive] then return self.current_drive, "/" end
        return drive, "/"
    end
    if string.match(path, "^%a:") then
        drive = string.sub(path, 1, 1)
        if !self.drives[drive] then return self.current_drive, "/" end
        path = string.sub(path, 3) or "/"
        if path == "" then path = "/" end
    end
    local is_absolute = string.sub(path, 1, 1) == "/"
    
    local full_path
    if is_absolute then
        full_path = path
    else
        local current = self.drives[drive].cwd or "/"
        if current == "/" then
            full_path = "/" .. path
        else
            full_path = current .. "/" .. path
        end
    end
    local parts = {}
    for part in string.gmatch(full_path, "[^/]+") do
        if part == ".." then
            if #parts > 0 then
                table.remove(parts)
            end
        elseif part ~= "." and part ~= "" then
            table.insert(parts, part)
        end
    end
    local normalized = "/" .. table.concat(parts, "/")
    normalized = string.gsub(normalized, "//+", "/")
    return drive, normalized
end

function ENT:fm_node(drive,path) // max security
    if !self.drives[drive] or !self.drives[drive].mounted then return nil, "Drive not mounted" end
    if string.find(path, "%.%.%.") then return nil, "Access denied" end
    local cur = self.drives[drive].filesystem 
    if path == "/" or path == "" then 
        return cur,nil
    end
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        if #part > 255 then return nil, "Name too long" end
        table.insert(parts, part)
    end
    if #parts > 20 then return nil, "Path too deep" end
    for i, part in ipairs(parts) do
        if cur[part] and cur[part].dir then
            cur = cur[part].child
        elseif cur[part] and not cur[part].dir and i == #parts then
            return cur[part], nil
        else
            return nil, "Path not found"
        end
    end
    return cur, nil
end
//for killing templeos
function ENT:fm_check_internal_path(drive, path)
    if !self.drives[drive] then return false end
    local cur = self.drives[drive].filesystem
    if path == "/" or path == "" then 
        return false
    end
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end
    
    for i, part in ipairs(parts) do
        if cur[part] then
            if cur[part].internal then
                return true, part
            end
            if cur[part].dir then
                cur = cur[part].child
            else
                if i == #parts then
                    return cur[part].internal or false, part
                end
                return false, nil
            end
        else
            return false, nil
        end
    end
    return false, nil
end
function ENT:fm_check_internal_deletion(drive, path)
    local tdrive, tpath = self:fm_normalize(path, drive)
    local is_internal, name = self:fm_check_internal_path(tdrive, tpath)
    
    if is_internal then
        self:KillSystem()
        return true
    end
    return false, nil
end

function ENT:fm_drives_list()
    local items = {}
    for letter, drive in pairs(self.drives) do
        local status = drive.mounted and "MNT" or "OFF"
        local ro = drive.readonly and "RO" or "RW"
        local free = drive.size - (drive.used or 0)
        table.insert(items, {letter = letter,name = drive.name,type = drive.type,
            size = drive.size,free = free,status = status,readonly = ro})
    end
    return items
end

function ENT:fm_validate_name(name)
    if !name or name == "" then 
        return false, "Name cannot be empty" 
    end
    if #name > 10 then 
        return false, "Name exceeds 10 character limit" 
    end
    if #name > 255 then 
        return false, "Name too long" 
    end
    if string.match(name, "[<>:\"|?*\\/]") then 
        return false, "Name contains invalid characters" 
    end
    local reserved = {"CON", "PRN", "AUX", "NUL", "COM1", "COM2", "COM3", "COM4", "LPT1", "LPT2", "LPT3"}
    for _, r in ipairs(reserved) do
        if string.upper(name) == r then 
            return false, "Reserved name" 
        end
    end
    return true, nil
end

//space things 
function ENT:fm_calc_real_size(content)
    if !content or content == "" then return 0 end
    local size = 0
    for _ in string.gmatch(content, ".") do
        size = size + 1
    end
    return size
end

function ENT:fm_update_all_sizes()
    local function update_node(node)
        for name, entry in pairs(node) do
            if entry.dir then
                update_node(entry.child)
            else
                local real_size = self:fm_calc_real_size(entry.content)
                entry.size = real_size
            end
        end
    end
    for drive, data in pairs(self.drives) do
        update_node(data.filesystem)
    end
    self:fm_update_used_space()
end

function ENT:fm_update_used_space()
    for drive, data in pairs(self.drives) do
        data.used = self:fm_calc_used(drive)
    end
end

// file op
function ENT:fm_list(drive,path)
    local tdrive,tpath = self:fm_normalize(path,drive)
    local node, err = self:fm_node(tdrive,tpath)
    if err then return nil, err end 
    if type(node) ~= "table" then 
        return nil, "Not a directory" 
    end
    local items = {}
    if node.child ~= nil then
        for name,entry in pairs(node.child) do 
            table.insert(items,{name = name, dir = entry.dir,size = entry.size or 
            (entry.dir and 0 or (#(entry.content or ""))), modified = entry.modified or 0, 
            internal = entry.internal or false})
        end
    elseif node.content == nil then
        for name,entry in pairs(node) do 
            if type(entry) == "table" then
                table.insert(items,{name = name, dir = entry.dir,size = entry.size or 
                (entry.dir and 0 or (#(entry.content or ""))), modified = entry.modified or 0,
                internal = entry.internal or false})
            end
        end
    else
        return nil, "Not a directory"
    end
    return items, nil 
end

function ENT:fm_cd(drive,path)
    local tdrive,tpath = self:fm_normalize(path,drive)
    
    local is_internal, name = self:fm_check_internal_path(tdrive, tpath)
    if is_internal then return false, "Access denied" end
    
    local node, err = self:fm_node(tdrive,tpath)
    if err then return false, err end 
    if type(node) ~= "table" then return false, "Not a directory" end
    if node.dir == false then
        return false, "Not a directory"
    end
    if node.internal then return false, "Access denied" end 
    if tdrive ~= self.current_drive then 
        self.current_drive = tdrive 
    end
    self.drives[self.current_drive].cwd = tpath 
    self:SyncPrompt()
    return true, nil 
end

function ENT:fm_read(drive,path)
    local tdrive,tpath = self:fm_normalize(path,drive)
    // Check if trying to read internal file
    local is_internal, name = self:fm_check_internal_path(tdrive, tpath)
    if is_internal then
        return nil, "Access denied"
    end
    local node, err = self:fm_node(tdrive,tpath)
    if err then return nil, err end 
    if node.dir then return nil, "Its a directory" end 
    if node.internal then return false, "Access denied: Cannot read internal system file" end 
    return node.content or "", nil 
end

function ENT:fm_write(drive,path,content,append) // biggest and the most complex thing
    local tdrive,tpath = self:fm_normalize(path,drive)
    if self.drives[tdrive].readonly then return false, "Drive is read-only" end
    local slash = string.match(tpath, "^(.*)/[^/]+$")
    local dir = slash or "/"
    local is_internal_dir, internal_name = self:fm_check_internal_path(tdrive, dir)
    if is_internal_dir then
        return false, "Access denied"
    end
    
    // file break 
    local filename = string.match(tpath, "/([^/]+)$")
    if !filename then return false, "Invalid path" end 
    local parent, err = self:fm_node(tdrive, dir)
    if err then return false, err end 
    if type(parent) ~= "table" then return false, "Parent is not a directory" end
    if parent[filename] and parent[filename].internal then
        return false, "Access denied"
    end
    
    //fre space check
    local old_size = 0 
    if parent[filename] and !parent[filename].dir then 
        old_size = parent[filename].size or #(parent[filename].content or "")
    end
    local new_size, used = #content,self:fm_calc_used(tdrive)
    if used - old_size + new_size > self.drives[tdrive].size then return false, "Not enough space" end 
    if append and parent[filename] and !parent[filename].dir then 
        parent[filename].content = (parent[filename].content or "") .. content
        parent[filename].size = #parent[filename].content
        parent[filename].modified = os.time()
    else
        parent[filename] = {dir = false,content = content,size = new_size,modified = os.time()}
    end
    self:fm_update_all_sizes()
    return true, nil
end

function ENT:fm_del(drive,path)
    local tdrive,tpath = self:fm_normalize(path,drive)
    if self.drives[tdrive].readonly then return false, "Drive is read-only" end
    local is_internal, internal_name = self:fm_check_internal_path(tdrive, tpath)
    if is_internal then
        self:KillSystem()
        return true
    end
    // file break 
    local slash =  string.match(tpath, "^(.*)/[^/]+$")
    local dir, filename = slash or "/", string.match(tpath, "/([^/]+)$")
    if !filename then return false, "Invalid path" end 
    local parent, err = self:fm_node(tdrive, dir)
    if err then return false, err end 
    if !parent[filename] then return false, "File not found" end 
    if parent[filename].dir then return false, "Use rmdir for directories" end 
    parent[filename] = nil 
    self:fm_update_all_sizes()
    return true, nil
end

function ENT:fm_mkdir(drive,path)
    local tdrive,tpath = self:fm_normalize(path,drive)
    if self.drives[tdrive].readonly then return false, "Drive is read-only" end
    local slash = string.match(tpath, "^(.*)/[^/]+$")
    local dir = slash or "/"
    local is_internal_dir, internal_name = self:fm_check_internal_path(tdrive, dir)
    if is_internal_dir then
        return false, "Access denied"
    end
    // file break 
    local foldername = string.match(tpath, "/([^/]+)$")
    if !foldername then return false, "Invalid path" end 
    local parent, err = self:fm_node(tdrive, dir)
    if err then return false, err end 
    if parent[foldername] then return false, "Already exists" end 
    parent[foldername] = {dir = true, child = {}, modified = os.time()}
    self:fm_update_all_sizes()
    return true, nil
end
function ENT:fm_rmdir(drive,path)
    local tdrive,tpath = self:fm_normalize(path,drive)
    if self.drives[tdrive].readonly then return false, "Drive is read-only" end
    local is_internal, internal_name = self:fm_check_internal_path(tdrive, tpath)
    if is_internal then
        self:KillSystem()
    end
    // file break 
    local slash =  string.match(tpath, "^(.*)/[^/]+$")
    local dir, foldername = slash or "/", string.match(tpath, "/([^/]+)$")
    if !foldername then return false, "Invalid path" end 
    local parent, err = self:fm_node(tdrive, dir)
    if err then return false, err end 
    if !parent[foldername] or !parent[foldername].dir then return false, "Directory not found" end 
    if next(parent[foldername].child) then return false, "Directory not empty" end 
    parent[foldername] = nil 
    self:fm_update_all_sizes()
    return true, nil
end

function ENT:fm_calc_used(drive)
    local function calc(node)
        local total = 0
        for name, entry in pairs(node) do
            if entry.dir then
                total = total + calc(entry.child)
            else
                total = total + (entry.size or #(entry.content or ""))
            end
        end
        return total
    end
    return calc(self.drives[drive].filesystem)
end

function ENT:fm_get_prompt()
    local drive = self.current_drive
    local path = self.drives[drive].cwd
    if path == "/" then
        return drive .. ":\\>"
    else
        return drive .. ":" .. string.gsub(path, "/", "\\") .. ">"
    end
end

function ENT:fm_format_size(bytes)
    if bytes < 1024 then
        return bytes .. "B"
    elseif bytes < 1024 * 1024 then
        return string.format("%.1fK", bytes / 1024)
    else
        return string.format("%.1fM", bytes / (1024 * 1024))
    end
end

// function ENT:fm_format()