
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
        if GetConVar("holylua_realistic_boot"):GetBool() then 
            surface.SetDrawColor( holylua.color[1] )
            surface.DrawRect( 0, 0, 388 * resolution, 320 * resolution )
            simpleline("TempleOS V"..TempleOS.Version.."0 "..os.date("%m/%d/%y %H:%M:%S "))
            simpleline("Enable IRQ's")
            simpleline("DskChg(':);")
            simpleline("")
            simpleline("Defined Drives:")
            simpleline("B REDSEA    RAM     0000 0000 00")
            simpleline_spaced("0000000000000058-0000000000020000")
            simpleline("C FAT32     ATA     01F0 03F4 00")
            simpleline_spaced("Model# :QEMU HARDDISK")
            simpleline_spaced("Serial#:QM00001")
            simpleline_spaced("000000000000003F-00000000040029D1")
            simpleline("D FAT32     ATA     01F0 03F4 00")
            simpleline_spaced("Model# :QEMU HARDDISK")
            simpleline_spaced("Serial#:QM00001")
            simpleline_spaced("00000000402A11F-0000000007FFD521")
            simpleline("T ISO9660     ATAPI  0170 0374 00")
            simpleline_spaced("0000000000000000-FFFFFFFFFFFFFFFF")
            simpleline("Home Dir: \"C:/HOME\"")
            simpleline("MultiCore Start")
            simpleline("")
            simpleline("Loading Compiler")
        else
            surface.SetMaterial(Material("TempleOS.png"))
            surface.SetDrawColor(holylua.color[16])
            surface.DrawTexturedRect( 0, 0, 388 * resolution, 320 * resolution )
        end
	cam.End3D2D()
end