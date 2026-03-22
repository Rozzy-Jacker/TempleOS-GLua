if !holylua then holylua = {} end 
if SERVER then 
    local function TempleOS_AddNetworkString(string)
        util.AddNetworkString("TempleOS_"..string)
    end
    TempleOS_AddNetworkString("Interact")
    TempleOS_AddNetworkString("Command")
    TempleOS_AddNetworkString("Print")
    TempleOS_AddNetworkString("Input")
    TempleOS_AddNetworkString("StartInput")
    TempleOS_AddNetworkString("StopInput")
    TempleOS_AddNetworkString("Clear")
end
if !TempleOS then TempleOS = {} end 
TempleOS.Version = 5.03
TempleOS.Prefix = {"/", "!", "-", "\\"}
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
// simple loader  (re-edited from gmodwiki) 
//  https://wiki.facepunch.com/gmod/Global.AddCSLuaFile
holylua.Dir = holylua.Dir or {}
function holylua.Dir:Include(dir) // edited loader from AddCSLuaFile() gmod wiki
    dir = dir .. "/"
    local files,folders = file.Find (dir.."*","LUA")
    for i = 1, #files do 
        local file = files[i]
        if file:match("%.lua$") then 
            local prefix = file:sub(1,3):lower()
            local full_path = dir .. file 
            if string.find(dir,"vocab") then continue end
            if string.find(file,"bible") then continue end  
            if prefix == "sv_" then 
                if SERVER then include(full_path) end 
            elseif prefix == "cl_" then 
                if SERVER then 
                    AddCSLuaFile(full_path)
                else 
                    include(full_path)
                end
            else 
                if SERVER then AddCSLuaFile(full_path) end 
                include(full_path)
            end
        end
    end
    for i=1 , #folders do 
        self:Include(dir..folders[i])
    end
end

holylua.Dir:Include("templeos")