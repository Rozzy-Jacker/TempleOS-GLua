// it's was pretty fun to make pseudorandom instead of math.Rand.
// fifo from TempleOS fucking hard (but i'm recreated it on GLua and deleted it)
if !holylua.God then holylua.God = {} end  
holylua.rand = math.floor(SysTime() * 1e6) % 4294967295
function holylua.random(max) // C
    holylua.rand = (holylua.rand * 1103515245 + 12345) % 4294967295 
    local greatestrandom = holylua.rand % 1000000
    local number = math.floor((greatestrandom / 1000000) * (max + 1))
    return number
end
function holylua.random_range(min,max)
    return holylua.random(max-min)+min
end
function holylua.God.word()
    if !holylua.vocab or #holylua.vocab == 0 then
        holylua.print("Vocab is empty.")
        return "No vocab"
    end
    return holylua.vocab[holylua.random(table.Count(holylua.vocab))]
end
function holylua.God.Speech(num)
    num = num or 32 
    local words = {}
    for i = 1, num do 
        words[i] = holylua.God.word()
    end
    return table.concat(words," ")
end
concommand.Add("holylua_speech",function(ply) print(holylua.God.Speech())end)