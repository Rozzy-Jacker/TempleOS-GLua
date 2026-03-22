// should be pretty close to TempleOS FIFO i guess
local fifo = {}
fifo.__index = fifo 
local bit_band, bit_bor,bit_lshift  = bit.band, bit.bor,bit.lshift
local math_min,table_insert,table_remove = math.min,table.insert,table.remove

function fifo:new(size)
    size = size or 256
    size = 2 ^ math.ceil(math.log(size)/math.log(2))
    local buf = {}
    for i=0,size-1 do buf[i] = 0 end
    local obj = {
        buf = buf,
        pos = 0,
        tem = 0,
        size = size,
        count = 0,
        mask = size -1
    }
    setmetatable(obj,self)
    return obj
end

function fifo:PutByte(ch)
    if self.count >= self.size then return 0 end 
    self.buf[self.pos] = bit_band(ch,0xFF)
    self.pos = bit_band(self.pos + 1, self.mask)
    self.count = self.count +1 
    return ch 
end

function fifo:GetByte()
    if self.count <= 0 then return 0 end 
    local ch = self.buf[self.tem]
    self.buf[self.tem] = 0
    self.tem = bit_band(self.tem+1,self.mask)
    self.count = self.count -1 
    return ch
end

function fifo:PeekByte(offset)
    offset = offset or 0
    if offset >= self.count then return false,0 end 
    local idx = bit_band(self.tem + offset,self.mask)
    return true, self.buf[idx]
end

function fifo:put(src,len)
    local i = 0 
    local space = self.size - self.count 
    local actual = math_min(len,space)
    while i < actual do 
        self.buf[self.pos] = bit_band(src[i],0xFF)
        self.pos = bit_band(self.pos + 1,self.mask)
        i = i + 1
    end
    self.count = self.count + actual 
    return actual 
end

function fifo:get(dst,len)
    local i = 0 
    local actual = math_min(len,self.count)
    while i < actual do 
        dst[i] = self.buf[self.tem]
        self.buf[self.tem] = 0
        self.tem = bit_band(self.tem+1,self.mask)
        i = i + 1 
    end
    self.count = self.count - actual 
    return actual
end

function fifo:skip(len)
    local actual = math_min(len,self.count)
    self.tem = bit_band(self.tem + actual,self.mask)
    self.count = self.count - actual 
    return actual 
end

function fifo:flush()
    for i = 0,self.size -1 do 
        self.buf[i] = 0
    end
    self.pos = 0 
    self.tem = 0 
    self.count = 0
end

function fifo:space()
    return self.size - self.count 
end

function fifo:data()
    return self.count
end

function fifo:full()
    return self.count >= self.size
end

function fifo:empty()
    return self.count == 0 
end

function fifo:buf()
    return self.buf
end

function fifo:putbatch(len,data_func)
    local space = self.size - self.count 
    local actual = math_min(len,space)
    local start_pos = self.pos 
    for i = 0, actual-1 do 
        self.buf[bit_band(start_pos+i,self.mask)] = data_func(i)
    end
    self.pos = bit_band(self.pos + actual,self.mask)
    self.count = self.count + actual 
    return actual
end

function fifo:getbatch(len,data_func)
    local actual = math_min(len,self.count)
    local start_tem = self.tem 
    for i = 0, actual - 1 do 
        data_func(i,self.buf[bit_band(start_tem+i,self.mask)])
        self.buf[bit_band(start_tem+i,self.mask)] = 0
    end
    self.tem = bit_band(self.tem+actual,self.mask)
    self.count = self.count - actual 
    return actual
end
//TempleOS MemCpy 
function fifo:poke(offset,byte)
    if offset >= self.size then return false end 
    self.buf[bit_band(self.tem+offset,self.mask)] = bit_band(byte,0xFF)
    return true 
end

function fifo:peek(offset)
    if offset >= self.count then return 0 end 
    return self.buf[bit_band(self.tem+offset,self.mask)]
end
_G.fifo = fifo