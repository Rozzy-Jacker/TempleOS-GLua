// fifo from TempleOS fucking hard 
//i'm fucking lost at this point. fifo based random seems don't work correct (the words just repeating or selecting close one)
// i should add more 'entropy' sources or use legacy random aggain [2] 
local fifo = _G.fifo
if !holylua.God then holylua.God = {} end  
holylua.fifo = holylua.fifo or fifo:new(512)
local bit_band,bit_rshift = bit.band,bit.rshift
holylua.GOD_BAD_BITS = 4 //TempleOS/Adam/God/GodExt.HC
holylua.GOD_GOOD_BITS = 24
//#define GOD_BAD_BITS	4 
//#define GOD_GOOD_BITS	24
function holylua.refill()
    local now = SysTime() * 1e9 
    local clock = os.clock() * 1e9
    local pseudorand = 1 // i'm not sure
    local entropy = now+clock+pseudorand

    for i = 0, holylua.GOD_GOOD_BITS - 1 do 
        local b = bit_band(bit_rshift(entropy, i + holylua.GOD_BAD_BITS), 1)
        holylua.fifo:PutByte(b)
    end
    // extra bits should make it better i hope
    for i = 0, 7 do 
        holylua.fifo:PutByte(bit_band(entropy,0xFF))
        entropy = bit_rshift(entropy,8)
    end
end
function holylua.random(max)
    if holylua.fifo:data() < holylua.GOD_GOOD_BITS then 
        holylua.refill()
    end
    local bits = 0 
    for i = 0, 23 do 
        if holylua.fifo:data() > 0 then
            bits = bits + (holylua.fifo:GetByte() * (2^i))
        end
    end    
    local greatestrandom = bits % 1e6
    local num = math.floor((greatestrandom / 1e6) * (max + 1))
    return num
end
function holylua.random_range(min, max)
    return holylua.random(max - min) + min
end
function holylua.God.word()
    if !holylua.vocab or #holylua.vocab == 0 then
        holylua.print("Vocab is empty.")
        return "No vocab"
    end
    return holylua.vocab[holylua.random(#holylua.vocab - 1) + 1]
end
function holylua.God.Speech(num)
    num = num or 32 
    local words = {}
    for i = 1, num do 
        words[i] = holylua.God.word()
    end
    return table.concat(words, " ")
end
function holylua.God.Verse(data)
    if !data or #data == 0 then 
        holylua.print("No verses loaded.")
        return nil
    end
    local verse = data[holylua.random(#data-1)+1]
    if verse and verse.ref and verse.text then 
        return verse.ref .." "..verse.text
    end
    return verse
end

concommand.Add("holylua_speech", function(ply) print(holylua.God.Speech()) end)
concommand.Add("holylua_verse", function(ply) print(holylua.God.Verse(holylua.bible_verses)) end)