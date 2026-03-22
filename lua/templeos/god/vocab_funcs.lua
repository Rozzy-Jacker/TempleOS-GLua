// vocab.lua — i found it on TempleOS github [https://github.com/cia-foundation/TempleOS/tree/archive/Adam/God]
holylua.default_vocab = "vocab"
holylua.vocab_to_use = holylua.default_vocab or "vocab"
holylua.bible_verses = ""
function holylua.ReadVocab(name)
    local path = "templeos/vocab/"..name..".lua"
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
//bible code
function holylua.LoadBible()
    local content = file.Read("templeos/bible.lua","LUA")
    if !content then 
        holylua.print("Empty Holy Bible file. How despair")
        return {}
    end
    local verses = {}
    local current_verse = ""
    local current_ref = ""
    for line in string.gmatch(content, "[^\r\n]+") do 
        line = string.Trim(line)
        if line ~= "" then 
            local book, chapter, verse = string.match(line, "^(%d+):(%d+)%s+(.*)$")
            if book and chapter and verse then 
                if current_ref ~= "" and current_verse ~= "" then 
                    table.insert(verses, {ref = current_ref, text = string.Trim(current_verse)})
                end
                current_ref = book .. ":" .. chapter
                current_verse = verse
            else
                if current_ref ~= "" then 
                    if current_verse ~= "" then 
                        current_verse = current_verse .. " " .. line
                    else
                        current_verse = line
                    end
                end
            end
        end
    end
    if current_ref ~= "" and current_verse ~= "" then 
        table.insert(verses, {ref = current_ref, text = string.Trim(current_verse)})
    end
    holylua.print("Loaded " .. #verses .. " verses")

    return verses
end
holylua.bible_verses = holylua.LoadBible()