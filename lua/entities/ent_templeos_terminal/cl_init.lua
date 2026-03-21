// Press Start 2P font by Codeman38. Found as TempleOS font alt. (TempleOS font doesn't work in gmod)
include("shared.lua")
surface.CreateFont("TempleOS", {
    font = "Press Start 2P",
    extended = false,
    size = 45,
    weight = 500,
    antialias = false,
})
net.Receive("TempleOS_Interact",function()
    local ent = net.ReadEntity()
    local line = net.ReadString()
    ent:AddTextLine(">   "..line)
    ent:AddEmptyLine()
end)
function ENT:Initialize()
    self.lines = {}
    self.blinkstatus = true
end
local z = 2000
function ENT:AddTextLine(msg)
    surface.SetFont("TempleOS")
    local words = string.Split(msg," ")
    local current_word = ""
    for _, word in ipairs(words) do 
        local test = current_word == "" and word or current_word .." ".. word
        if surface.GetTextSize(test) > z then 
            if current_word ~="" then table.insert(self.lines,current_word)
                current_word = word
            else
                for i = 1, #word do 
                    local ch = word:sub(i,i)
                    if surface.GetTextSize(current_word..ch) > z then 
                        table.insert(self.lines,current_word)
                        current_word = ch
                    else 
                        current_word = current_word .. ch
                    end
                end
            end
        else 
           current_word = test
        end
    end
    if current_word ~= "" then 
        table.insert(self.lines,current_word)
    end
    while #self.lines > 35 do 
        table.remove(self.lines,1)
    end
end
function ENT:AddEmptyLine()
    table.insert(self.lines," ")
end
function ENT:ClearText()
    self.lines = {}
end
function ENT:Draw( flags ) // https://wiki.facepunch.com/gmod/cam.Start3D2D
	self:DrawModel( flags )
    if !self:GetNWBool("On") then return end 
	local ang = self:GetAngles()
	ang:RotateAroundAxis( self:GetUp(), 90 )
	ang:RotateAroundAxis( self:GetRight(), -90 + 4.5 )
	ang:RotateAroundAxis( self:GetForward(), 0 )

	local pos = self:GetPos()
	pos = pos + self:GetForward() * 11.7
	pos = pos + self:GetRight() * 9.69
	pos = pos + self:GetUp() * 11.8
    //real memory
    local memory = collectgarbage("count") * 1024
    local memory_hexed = string.format("%08X",math.floor(memory))
	local resolution = 6
    local fps = math.ceil(1/FrameTime())
    if !self.cpu then self.cpu = 1 end
    if !self.blinktime then self.blinktime = CurTime() end 
	cam.Start3D2D( pos, ang, 0.05 / resolution )
        if self:GetNWBool("Boot") then 
        //bg
		surface.SetDrawColor(holylua.color[16])
		surface.DrawRect( 0, 0, 388 * resolution, 320 * resolution )
        //header
        surface.SetDrawColor(holylua.color[2])
		surface.DrawRect( 0, 0, 388 * resolution, 15 * resolution )
        //header text
		draw.SimpleText( os.date("%a %m/%d %H:%M:%S ").."FPS:"..fps..  " Mem:"..memory_hexed.." CPU: "..self.cpu, "TempleOS", 5, 20, holylua.color[16] )
		//draw.SimpleText( "123456789...", "TempleOS", 5, 100, holylua.color[2] ) //debug
        //Lines
        local y = 100
        for i, line in ipairs(self.lines) do 
         	draw.SimpleText(line, "TempleOS", 5, y, holylua.color[2] )
            y = y + 50 
        end
        local usey = #self.lines == 0 and y or y-40
        if self.blinktime < CurTime()  then 
            self.blinkstatus = !self.blinkstatus
            self.blinktime = CurTime() + .5
            self.cpu = (#self.lines + fps) % 9 + 1 //updating cpu display
            
        end
        if self.blinkstatus then 
        
        surface.DrawRect( 15, usey, 44, 44 ) // entry pointer
        end
        y = y + 50 
        else
            surface.SetMaterial(Material("TempleOS.png"))
            surface.SetDrawColor(holylua.color[16])
            surface.DrawTexturedRect( 0, 0, 388 * resolution, 320 * resolution )
        end
	cam.End3D2D()
end