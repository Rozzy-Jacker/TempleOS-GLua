// Press Start 2P font by Codeman38. Found as TempleOS font alt. (TempleOS font doesn't work in gmod)
include("shared.lua")
surface.CreateFont("TempleOS", {
    font = "Press Start 2P",
    extended = false,
    size = 45,
    weight = 500,
    antialias = false,
})

net.Receive("TempleOS_Print",function()
    local ent = net.ReadEntity()
    local msg = net.ReadString() or "invalid"
    local col = net.ReadColor() or holylua.color[2]
    local bool = net.ReadBool()
    if msg ~= "" then 
        ent:AddTextLine(msg,col, bool)
    else
        ent:AddEmptyLine()
    end
end)
net.Receive("TempleOS_Command",function()
    local ent = net.ReadEntity()
    local msg = net.ReadString()
    ent:DoCommand(msg)
end)
net.Receive("TempleOS_Clear",function() 
    local ent = net.ReadEntity()
    ent.lines = {}
    ent:AddTextLine("TempleOS V"..TempleOS.Version, holylua.color[6], false)
    ent:AddTextLine("Type 'Help' for commands ", holylua.color[1], false)
    ent:AddEmptyLine()
    ent:SetNWString("PromptLine","")
end)
function ENT:Initialize()
    self.lines = {}
    self.blinkstatus = true
    self:AddTextLine("TempleOS V"..TempleOS.Version, holylua.color[6], false)
    self:AddTextLine("Type 'Help' for commands ", holylua.color[1], false)
    self:AddEmptyLine()
    self:SetNWString("PromptLine","")

   // print(#self.lines)
end

local z = 2000

function ENT:AddTextLine(msg,col, user_input)
    surface.SetFont("TempleOS")
    local words = string.Split(msg," ")
    local current_word = ""
    for _, word in ipairs(words) do 
        local test = current_word == "" and word or current_word .." ".. word
        if surface.GetTextSize(test) > z then 
            if current_word ~="" then 
                table.insert(self.lines,{msg = current_word, col = col, user_input = user_input})
                current_word = word
            else
                for i = 1, #word do 
                    local ch = word:sub(i,i)
                    if surface.GetTextSize(current_word..ch) > z then 
                        table.insert(self.lines,{msg = current_word, col = col, user_input = user_input})
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
        table.insert(self.lines,{msg = current_word, col = col, user_input = user_input})
    end
    while #self.lines > 35 do 
        table.remove(self.lines,1)
    end
end
function ENT:DoCommand(msg)
    if msg == "memrep" then 
        self:AddTextLine( string.format("%08X",math.floor(self.memory)),holylua.color[1],false)
    elseif msg == "cpurep" then 
        self:AddTextLine(self.cpu,holylua.color[1],false)
    elseif msg == "date" then 
        local toprint = os.date("%a %m/%d")
        self:AddTextLine(toprint,holylua.color[1],false)
    elseif msg == "time" then 
        local toprint = os.date("%H:%M:%S ")
        self:AddTextLine(toprint,holylua.color[1],false)
    end
end
function ENT:AddEmptyLine()
    table.insert(self.lines,{msg = "", user_input = false})
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
    if !self.memory then 
        self.memory = collectgarbage("count") * 1024
      
    end

    local memory_hexed = string.format("%08X",math.floor(self.memory))
 
	local resolution = 6
    local fps = math.ceil(1/FrameTime())
    if !self.cpu then self.cpu = 1 end
    if !self.blinktime then self.blinktime = CurTime() end 
    if !self.memorytime then self.memorytime = CurTime() end 
    if self.memorytime < CurTime() then 
        self.memorytime = CurTime() + 1 
        self.memory = collectgarbage("count") * 1024
    end
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
        //text setup and > formating
        for i, line in ipairs(self.lines) do 
            local display_text = line.msg or ""
            local x_offset = 5
            
            if line.user_input and display_text ~= "" then
                if display_text:sub(1, 2) ~= "> " then
                    display_text = "> " .. display_text
                end
            end
            local space = 0
            for j = 1, #display_text do
                if display_text:sub(j, j) == " " then
                    space = space + 1
                else
                    break
                end
            end
            if space > 0 then
                local space_width = surface.GetTextSize(" ")
                x_offset = x_offset + (space * space_width)
                display_text = display_text:sub(space + 1)
            end
            
         	draw.SimpleText(display_text, "TempleOS", x_offset, y, self.lines[i].col or holylua.color[2] )
            y = y + 50 
        end

        local usey = y
        if self.blinktime < CurTime()  then 
            self.blinkstatus = !self.blinkstatus
            self.blinktime = CurTime() + .5
            self.cpu = (#self.lines + fps) % 9 + 1 //pseudocpu
            
        end
        local prompt = self:GetNWString("PromptLine") or "" //prompt display
        local msg_prompt = "> " .. prompt
        local prompt_space = 0
        for j = 1, #msg_prompt do
            if msg_prompt:sub(j, j) == " " then
                prompt_space = prompt_space + 1
            else
                break
            end
        end
        local prompt_xt = 5
        if prompt_space > 0 then
            local space_width = surface.GetTextSize(" ")
            prompt_xt = prompt_xt + (prompt_space * space_width)
            msg_prompt = msg_prompt:sub(prompt_space + 1)
        end
        //prompt
        draw.SimpleText(msg_prompt, "TempleOS", prompt_xt, usey, holylua.color[2] )
        if self.blinkstatus then 
            local full_text = "> " .. prompt
            local entry_x = 5 + surface.GetTextSize(full_text)
            local entry_space = 0
            for j = 1, #full_text do
                if full_text:sub(j, j) == " " then
                    entry_space = entry_space + 1
                else
                    break
                end
            end
            if entry_space > 0 then
                local space_width = surface.GetTextSize(" ")
                entry_x = entry_x - (entry_space * space_width)
            end
            surface.DrawRect( entry_x, usey, 44, 44 ) // entry pointer
        end
        //booting (TO DO make it more real)
        else
            surface.SetMaterial(Material("TempleOS.png"))
            surface.SetDrawColor(holylua.color[16])
            surface.DrawTexturedRect( 0, 0, 388 * resolution, 320 * resolution )
        end
	cam.End3D2D()
end