surface.CreateFont("TempleOS", { // Press Start 2P font by Codeman38. Found as TempleOS font alt. (TempleOS font doesn't work in gmod)
    font = "Press Start 2P",
    extended = false,
    size = 45,
    weight = 500,
    antialias = false,
})

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
