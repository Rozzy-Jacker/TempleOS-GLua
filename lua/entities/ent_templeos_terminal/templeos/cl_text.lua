// fully reworked
surface.CreateFont("TempleOS", { 
    font = "Press Start 2P",
    extended = false,
    size = 45,
    weight = 500,
    antialias = false,
})
local char_widths = {}
local function get_char_width(char)
    if char_widths[char] then
        return char_widths[char]
    end
    surface.SetFont("TempleOS")
    local width = surface.GetTextSize(char)
    if width == 0 then
        width = 45 
    end
    char_widths[char] = width
    return width
end

function ENT:AddTextLine(msg, col, user_input)
    if not msg or msg == "" then
        table.insert(self.lines, {msg = "", col = col, user_input = user_input})
        return
    end
    surface.SetFont("TempleOS")
    local max_width = 388 * 6 - 50
    local function split_by_width(text)
        local lines = {}
        local cur_line = ""
        local cur_width = 0
        for i = 1, #text do
            local char = text:sub(i, i)
            local char_width = get_char_width(char)
            if cur_width + char_width > max_width then
                if cur_line ~= "" then
                    table.insert(lines, cur_line)
                end
                cur_line = char
                cur_width = char_width
            else
                cur_line = cur_line .. char
                cur_width = cur_width + char_width
            end
        end
        if cur_line ~= "" then
            table.insert(lines, cur_line)
        end
        return lines
    end
    local function split_by_char_count(text)
        local avg_char_width = 45
        local max_chars = math.floor(max_width / avg_char_width)
        if max_chars < 10 then max_chars = 40 end
        
        local lines = {}
        for i = 1, #text, max_chars do
            local line = text:sub(i, math.min(i + max_chars - 1, #text))
            table.insert(lines, line)
        end
        return lines
    end
    local raw_lines = {}
    for line in string.gmatch(msg, "([^\n]*)\n?") do
        if line ~= "" or (msg:sub(-1) == "\n" and line == "") then
            table.insert(raw_lines, line)
        end
    end
    if #raw_lines == 0 and msg ~= "" then
        table.insert(raw_lines, msg)
    end
    for _, raw_line in ipairs(raw_lines) do
        if raw_line == "" then
            table.insert(self.lines, {msg = "", col = col, user_input = user_input})
        else
            local wrapped_lines = split_by_width(raw_line)
            if #wrapped_lines == 1 and #raw_line > 40 then
                wrapped_lines = split_by_char_count(raw_line)
            end
            for _, wrapped_line in ipairs(wrapped_lines) do
                table.insert(self.lines, {msg = wrapped_line, col = col, user_input = user_input})
            end
        end
    end
    while #self.lines > 35 do
        table.remove(self.lines, 1)
    end
end

function ENT:DoCommand(msg)
    if msg == "memrep" then 
        self:AddTextLine(string.format("%08X", math.floor(self.memory)), holylua.color[1], false)
    elseif msg == "cpurep" then 
        self:AddTextLine(tostring(self.cpu), holylua.color[1], false)
    elseif msg == "date" then 
        local toprint = os.date("%a %m/%d")
        self:AddTextLine(toprint, holylua.color[1], false)
    elseif msg == "time" then 
        local toprint = os.date("%H:%M:%S ")
        self:AddTextLine(toprint, holylua.color[1], false)
    end
end

function ENT:AddEmptyLine()
    table.insert(self.lines, {msg = "", user_input = false})
end

function ENT:ClearText()
    self.lines = {}
end