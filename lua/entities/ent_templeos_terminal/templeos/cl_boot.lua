function ENT:DrawBootScreen()
    local ang = self:GetAngles()
	ang:RotateAroundAxis( self:GetUp(), 90 )
	ang:RotateAroundAxis( self:GetRight(), -90 + 4.5 )
	ang:RotateAroundAxis( self:GetForward(), 0 )

	local pos = self:GetPos()
	pos = pos + self:GetForward() * 11.7
	pos = pos + self:GetRight() * 9.69
	pos = pos + self:GetUp() * 11.8
	local resolution = 5
    local y = 5
    local function simpleline(msg)
        draw.SimpleText( msg, "TempleOS", 5, y, holylua.color[16] )
        y = y + 50
    end
    local function simpleline_spaced(msg)
        draw.SimpleText( msg, "TempleOS", 150, y, holylua.color[16] )
        y = y + 50
    end
	cam.Start3D2D( pos, ang, 0.05 / resolution )

            surface.SetDrawColor( holylua.color[1] )
            surface.DrawRect( 0, 0, 388 * resolution, 320 * resolution )
            simpleline("TempleOS V"..TempleOS.Version.."0 "..os.date("%m/%d/%y %H:%M:%S "))
            simpleline("Enable IRQ's")
            simpleline("DskChg(':);")
            simpleline("")
            simpleline("Defined Drives:")
            for let,dat in pairs(self.drives) do 
                local line =  string.format("%s %-8s %-6s %-8s",let,string.sub(dat.name,1,8),dat.type,dat.readonly and "RO" or "RW")
                if dat.size then 
                    line = line .. string.format(" %04X %04X 00", 0, 0) 
                end
                simpleline(line)
                if dat.type == "RAM" then 
                    simpleline_spaced(string.format("%016X-%016X", 0, dat.size))
                elseif dat.type == "ATA" then 
                    simpleline_spaced("Model# :QEMU HARDDISK")
                    if !dat.serial then dat.serial = math.random(10000, 99999) end // FUCK
                    simpleline_spaced("Serial#:QM" .. string.format("%05d", dat.serial))
                    local st = 0x000000000000003F
                    local en = dat.size * 512 
                    simpleline_spaced(string.format("%016X-%016X", st, en))
                elseif dat.type == "ATAPI" then 
                    simpleline_spaced(string.format("%016X-%016X", 0, dat.size or 0xFFFFFFFFFFFFFFFF))
                end
            end
            simpleline("Home Dir: \"C:/HOME\"")
            simpleline("MultiCore Start")
            simpleline("")
            if !self:GetNWBool("Killed") then
                simpleline("Loading Compiler")
            else
                simpleline("Can't load Compiler")
                simpleline("KERNEL PANIC: /Adam directory damaged")
                simpleline("at kernel+0x7C84: fs_check_integrity+0x3A2")
                simpleline("at kernel+0x8F12: fs_validate_files+0x4F")
                simpleline("at boot+0x1A45: system_init+0xC8")
                simpleline("")
                simpleline("Code: 0f 0b 1b 03 50 d2 2b")
                simpleline("Kernel panic: Fatal exception")

            end
       
            --surface.SetMaterial(Material("TempleOS.png"))
            --surface.SetDrawColor(holylua.color[16])
            --surface.DrawTexturedRect( 0, 0, 388 * resolution, 320 * resolution )
        
	cam.End3D2D()
end