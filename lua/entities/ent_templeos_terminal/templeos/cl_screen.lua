// i hate comeback here
function ENT:DrawScreen()
    if !self:GetNWBool("On") then return end
    local show_tree = self.show_tree or false
    local tree_path = self.tree_path or "" 

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
        //text setup finally simplified 
        for i, line in ipairs(self.lines) do 
            local display_text = line.msg or ""
            
            if line.user_input and display_text ~= "" then
                if not string.find(display_text, "^>") then
                    display_text = "> " .. display_text
                end
            end
            
            draw.SimpleText(display_text, "TempleOS", 5, y, line.col or holylua.color[2])
            y = y + 50 
        end

        local usey = y 
        if self.blinktime < CurTime()  then 
            self.blinkstatus = !self.blinkstatus
            self.blinktime = CurTime() + .5
            self.cpu = (#self.lines + fps) % 9 + 1 //pseudocpu
            
        end
        local cprompt = self:GetNWString("CurrentPrompt") or "C:\\>"
        local userinput = self:GetNWString("PromptLine") or ""
        
        local fprompt= cprompt .. " " .. userinput
        local max_width = 388 * resolution - 50
        if surface.GetTextSize(fprompt) > max_width then
            local available = max_width - surface.GetTextSize("...")
            local truncated = ""
            for i = 1, #fprompt do
                local test = truncated .. fprompt:sub(i, i)
                if surface.GetTextSize(test) <= available then
                    truncated = test
                else
                    break
                end
            end
            fprompt = truncated .. "..."
        end
        draw.SimpleText(fprompt, "TempleOS", 5, usey, holylua.color[2])
        
        if self.blinkstatus then
            surface.SetFont("TempleOS")
            surface.SetDrawColor(holylua.color[2])
            surface.DrawRect( 5, usey + 60, 44, 44)
        end
	
        //booting (TO DO make it more real)
	cam.End3D2D()
end