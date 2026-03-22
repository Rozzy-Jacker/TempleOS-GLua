function ENT:DrawScreen()
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
        local prompt = self:GetNWString("PromptLine") or ""
        local msg_prompt = "> " .. prompt
        local max_width = 388 * resolution - 50
        //much better prompt line
        if surface.GetTextSize(msg_prompt) > max_width then
            local available = max_width - surface.GetTextSize("...")
            local truncated = ""
            for i = 1, #msg_prompt do
                local test = truncated .. msg_prompt:sub(i, i)
                if surface.GetTextSize(test) <= available then
                    truncated = test
                else
                    break
                end
            end
            msg_prompt = truncated .. "..."
        end
        
        local prompt_xt = 5
        draw.SimpleText(msg_prompt, "TempleOS", prompt_xt, usey, holylua.color[2])
        
        if self.blinkstatus then
            local entry_x = math.min(5 + surface.GetTextSize("> " .. prompt), 388 * resolution - 50)
            surface.DrawRect(entry_x, usey, 44, 44)
        end
        //booting (TO DO make it more real)
	cam.End3D2D()
end