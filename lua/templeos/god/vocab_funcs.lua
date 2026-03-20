// vocab.json — i found it on TempleOS github [https://github.com/cia-foundation/TempleOS/tree/archive/Adam/God]
holylua.default_vocab = "vocab"
holylua.vocab_to_use = holylua.default_vocab or "vocab"
function holylua.ReadVocab(name)
    local path = "templeos/vocab/"..name..".json"
    local content =  file.Read(path,"LUA")
    if !content then 
        holylua.print("Empty Vocab")
        return {}
    end
    local words = {}
    for lin in string.gmatch(content, "[^\r\n]+") do
        lin = string.Trim(lin)
        if lin ~= "" then table.insert(words,lin) end
    end
    holylua.print("Vocab ["..name.."] Loaded. Total word count: "..table.Count(words))
    return words
end
holylua.vocab = holylua.ReadVocab(holylua.vocab_to_use)
function holylua.UpdateVocab()
    holylua.vocab = holylua.vocab_to_use 
end
function holylua.SetNewVocab(name)
    holylua.vocab_to_use = name 
    holylua.UpdateVocab()
end