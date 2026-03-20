if !holylua then holylua = {} end 
if SERVER then 
    util.AddNetworkString("TempleOS_Interact")
end
//color (CGA 16-color palette)

local CGA_16Color = {  // https://en.wikipedia.org/wiki/Color_Graphics_Adapter#Color_palette
    [1] = Color(0, 0, 0),        // black
    [2] = Color(0, 0, 170),      // blue
    [3] = Color(0, 170, 0),      // green
    [4] = Color(0, 170, 170),    // cyan
    [5] = Color(170, 0, 0),      // red
    [6] = Color(170, 0, 170),    // magenta
    [7] = Color(170, 85, 0),     // brown
    [8] = Color(170, 170, 170),  // light gray
    [9] = Color(85, 85, 85),     // dark gray
    [10] = Color(85, 85, 255),   // light blue
    [11] = Color(85, 255, 85),   // light green
    [12] = Color(85, 255, 255),  // light cyan
    [13] = Color(255, 85, 85),   // light red
    [14] = Color(255, 85, 255),  // light magenta
    [15] = Color(255, 255, 85),  // yellow
    [16] = Color(255, 255, 255), // white
}
holylua.color = CGA_16Color
function holylua.print(a)
    if CLIENT then return end 
    MsgC(holylua.color[12],"[HolyLua] ", Color(255,255,255,255),a.."\n")
end
// simple loader that i made a long time ago (pasted and re-edited from gmodwiki) 
//  https://wiki.facepunch.com/gmod/Global.AddCSLuaFile
local function pr(string1)
    return string.sub(string.lower(string1), 1, 3)
end
function holylua.File_Add(dir,file)

    if string.StartsWith(file,"!") then return end  // skip
    if pr(file) == "cl_" then 
        if CLIENT then 
            include(dir..file)
        else
            AddCSLuaFile(dir..file)
        end
        holylua.print(dir..file.. " Loaded client file")
    elseif pr(file) == "sv_" then 
        if SERVER then 
            include(dir..file)
        end
        holylua.print(dir..file.. " Loaded server file")
        
    else // shared
        if SERVER then 
            AddCSLuaFile(dir..file)
        end
        include(dir..file)
        holylua.print(dir..file.. " Loaded shared file")
    end
end

function holylua.RecurseInclude(dir)
    dir = dir .. "/"
    local files,dirs = file.Find(dir .."*","LUA")
    for _, v in ipairs(files) do 
        if !string.EndsWith(v,".lua") then continue end
        holylua.File_Add(dir,v) 
    end
    for _, v in ipairs(dirs) do 
        holylua.RecurseInclude(dir .. v)
        
    end
end

holylua.RecurseInclude("templeos")