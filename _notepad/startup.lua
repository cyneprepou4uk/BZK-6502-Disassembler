print("*** ca65 Notepad++ Lua script v1.1.1")
print("*** Read manual at https://iromhacker.ru/nes/en/bzk6502/1/index.html")
print("*** Forum topic at https://www.romhacking.net/forum/index.php?topic=31875.0")



SELECTION = ""

npp.AddEventHandler("OnUpdateUI", function()
    local function ShowMatches(str)
        npp.StatusBar[STATUSBAR_DOC_TYPE] = str
    end
    
    --print(editor.SelectionIsRectangle)
    selection, size = editor:GetSelText()
    if SELECTION ~= selection then
        SELECTION = selection
        local message = ""
        if size == 0 then
            message = "Select some text"
        else
            local overflow = false
            local ovf_counter = 0
            local matches = 0
            for m in editor:match(selection) do
                matches = matches + 1
                if size < 3 and matches > 1000 then
                    overflow = true
                    ovf_counter = 1000
                    break
                elseif matches > 10000 then
                    overflow = true
                    ovf_counter = 10000
                    break
                end
            end
            if overflow then message = "> "..ovf_counter.." matches"
            elseif matches == 1 then message = matches.." match"
            else message = matches.." matches" end
        end
        ShowMatches(message)
    end
end)





function BasicInfo()                    --получить информацию о строках курсора/выделения и позицию
    local l_min = npp.CurrentLine                   --получить номер текущей линии
    editor:SwapMainAnchorCaret()                    --свапнуть начало и конец выделения, так как линия вычисляется только по каретке
    local l_max = npp.CurrentLine
    if l_min > l_max then l_min, l_max = l_max, l_min end
    editor:SwapMainAnchorCaret()
    editor:GotoLine(l_min)                          --перейти на указанную линию
    local p = editor:PositionFromLine(l_min)        --получить позицию в начале линии
    return l_min, p, l_max                          --первые 2 параметра важные, третий необязательный
end

function CopyText(p1, p2)               --скопировать текст
    local t = editor:textrange(p1, p2)
    return t
end

function SelectLinesCompletely()        --выделяет выбранные линии от начала до конца
    local l_min, _, l_max = BasicInfo()
    local sel_pos_start = editor:PositionFromLine(l_min)
    local sel_pos_end = editor.LineEndPosition[l_max]
    editor.SelectionStart = sel_pos_start
    editor.SelectionEnd = sel_pos_end
    return sel_pos_start, sel_pos_end
end

function GetByteFromLine(line)          --прочитать байт из .byte $xx
    local l_pos_start = editor:PositionFromLine(line)
    local l_pos_end = editor.LineEndPosition[line]
    local f_pos = editor:findtext(".byte $", SCFIND_NONE, l_pos_start, l_pos_end)
    local byte = nil
    if f_pos ~= nil then byte = editor:textrange(f_pos + 7, f_pos + 9) end
    return byte, f_pos
end

function GetNesMemoryAddress(line)
    local l_pos_start = editor:PositionFromLine(line)
    local l_pos_end = editor.LineEndPosition[line]
    local f_pos = editor:findtext(":\\w\\w\\w\\w:", SCFIND_REGEXP, l_pos_start, l_pos_end)
    local addr = nil
    if f_pos ~= nil then addr = editor:textrange(f_pos + 1, f_pos + 5) end
    return addr, f_pos
end

function GetRomFileAddress(line)        --unused
    local l_pos_start = editor:PositionFromLine(line)
    local l_pos_end = editor.LineEndPosition[line]
    local f_pos = editor:findtext("0x\\w\\w\\w\\w\\w\\w", SCFIND_REGEXP, l_pos_start, l_pos_end)
    local addr = nil
    if f_pos ~= nil then addr = editor:textrange(f_pos, f_pos + 8) end
    return addr, f_pos
end

function IncreaseCounter()              --увеличить счетчик
    if COUNTER_mode ~= nil then
        COUNTER_value = (COUNTER_value + 1) & 0xFF
    end
end










npp.AddShortcut("---------- CONFIG ----------", "", function()
    print("[section info] This is a section for other scripts configuration")
end)



COUNTER_value = 0
COUNTER_mode = nil

npp.AddShortcut("Toggle counter mode to Disable | HEX | DEC", "", function()
    if     COUNTER_mode == nil then
        COUNTER_mode = "HEX"
        print("[config] Counter was set to <"..COUNTER_mode.."> mode, value = <"..string.upper(string.format("%02x", COUNTER_value))..">")
    elseif COUNTER_mode == "HEX" then
        COUNTER_mode = "DEC"
        print("[config] Counter was set to <"..COUNTER_mode.."> mode, value = <"..string.upper(string.format("%d", COUNTER_value))..">")
    elseif COUNTER_mode == "DEC" then
        COUNTER_mode = nil
        print("[config] Counter was disabled")
    end
end)



npp.AddShortcut("Set counter by selecting a 8-bit value", "", function()
    if COUNTER_mode == nil then
        npp.WriteError("Counter is currently disabled! First you need to set a counter mode")
    else
        local val = editor:GetSelText()
        if     COUNTER_mode == "HEX" then
            val = tonumber(val, 16)
            if val == nil then
                npp.WriteError("Select a proper hexadecimal value!")
            else
                COUNTER_value = val & 0xFF
                print("[config] HEX counter was set to <"..string.upper(string.format("%02x", COUNTER_value))..">")
            end
        elseif COUNTER_mode == "DEC" then
            val = tonumber(val)
            if val == nil then
                npp.WriteError("Select a proper decimal value!")
            else
                COUNTER_value = val & 0xFF
                print("[config] DEC counter was set to <"..string.upper(string.format("%d", COUNTER_value))..">")
            end
        end
    end
end)





CONVERSION_mode = ".word"
OFFSET_value = 0
LABEL_mode = "$"

npp.AddShortcut("Toggle bytes conversion mode to .word | .dbyt", "", function()
    if CONVERSION_mode == ".word" then
        CONVERSION_mode = ".dbyt"
    else 
        CONVERSION_mode = ".word"
    end
    print("[config] Bytes conversion mode was set to <"..CONVERSION_mode..">")
end)

npp.AddShortcut("Toggle labeling mode to $ | ofs_ | off_", "", function()
    if     LABEL_mode == "$" then
        LABEL_mode = "ofs_"
    elseif LABEL_mode == "ofs_" then
        LABEL_mode = "off_"
    elseif LABEL_mode == "off_" then
        LABEL_mode = "$"
    end
    print("[config] Labeling mode value was set to <"..LABEL_mode..">")
end)

npp.AddShortcut("Toggle offset value to 0 | 1", "", function()
    if OFFSET_value == 0 then
        OFFSET_value = 1
    else 
        OFFSET_value = 0
    end
    print("[config] Offset value was set to <"..OFFSET_value..">")
end)





LABEL_range = "(8|9)"

npp.AddShortcut("Toggle labeling range $8000 | $A000 | $C000 | $E000 | $6000", "", function()
    if     LABEL_range == "(6|7)" then
        LABEL_range = "(8|9)"
        print("[config] Labeling range was set to <$8000-$9FFF>")
    elseif LABEL_range == "(8|9)" then
        LABEL_range = "(A|B)"
        print("[config] Labeling range was set to <$A000-$BFFF>")
    elseif LABEL_range == "(A|B)" then
        LABEL_range = "(C|D)"
        print("[config] Labeling range was set to <$C000-$DFFF>")
    elseif LABEL_range == "(C|D)" then
        LABEL_range = "(E|F)"
        print("[config] Labeling range was set to <$E000-$FFFF>")
    elseif LABEL_range == "(E|F)" then
        LABEL_range = "(6|7)"
        print("[config] Labeling range was set to <$6000-$7FFF>")
    end
end)










npp.AddShortcut("---------- BYTES ----------", "", function()
    print("[section info] This is a section for working with <.byte $> strings")
end)



npp.AddShortcut(".byte -> instruction", "F1", function()
    local function Calculate16BitAbsAddress()
        local a = tonumber(operand_2, 16) * 0x100 + tonumber(operand_1, 16)
        local s = ""
        if opcode == "20" or opcode == "4C" then
            if a < 0x0800 then
                s = " ram_"..operand_2..operand_1
            else
                s = " $"..operand_2..operand_1
            end
        elseif a < 0x0800 then
            if a < 0x0100 then
                s = " a: ram_"..operand_2..operand_1
            else
                s = " ram_"..operand_2..operand_1
            end
        else
            s = " $"..operand_2..operand_1
        end
        return s
    end
    
    local function Calculate16BitIndirectAddress()
        local a = tonumber(operand_2, 16) * 0x100 + tonumber(operand_1, 16)
        local s = ""
        if a < 0x0800 then
            s = " (ram_"..operand_2..operand_1..")"
        else
            s = " ($"..operand_2..operand_1..")"
        end
        return s
    end
    
    
    
    editor:BeginUndoAction()
    
    line = BasicInfo()
    --найти совпадение
    local opcode, f_pos = GetByteFromLine(line)
    if f_pos == nil then
        npp.WriteError("Line "..(line + 1)..": ".."unable to find any <.byte $> string to read an opcode")
    else
        --прочитать параметры инструкции из таблицы
        local length = opcodes_table[tonumber(opcode, 16) * 4 + 2]
        local instruction = opcodes_table[tonumber(opcode, 16) * 4 + 3]
        local addressing = opcodes_table[tonumber(opcode, 16) * 4 + 4]
        operand_1 = "  "
        operand_2 = "  "
        
        local err = false
        if length > 1 then
            --вычислить первый операнд
            operand_1, f_pos = GetByteFromLine(line + 1)
            if f_pos == nil then
                npp.WriteError("Line "..(line + 2)..": "..instruction.." <"..addressing..">: unable to find any <.byte $> string to read the 1st operand")
                err = true
            end
            if length == 3 and err == false then
                --вычислить второй операнд
                operand_2, f_pos = GetByteFromLine(line + 2)
                if f_pos == nil then
                    npp.WriteError("Line "..(line + 3)..": "..instruction.." <"..addressing..">: unable to find any <.byte $> string to read the 2nd operand")
                    err = true
                end
            end
        end
        
        if err == false then
            --оформить инструкцию
            local str = opcodes_table[tonumber(opcode, 16) * 4 + 3]
            if     addressing == "unknown" then
                --nothing
            elseif addressing == "implied" then
                --nothing
            elseif addressing == "accumulator" then
                --nothing
            elseif addressing == "#immediate" then
                str = str.." #$"..operand_1
            elseif addressing == "$zero page" then
                str = str.." ram_00"..operand_1
            elseif addressing == "$zero page,X" then
                str = str.." ram_00"..operand_1..",X"
            elseif addressing == "$zero page,Y" then
                str = str.." ram_00"..operand_1..",Y"
            elseif addressing == "$absolute" then
                str = str..Calculate16BitAbsAddress()
            elseif addressing == "$absolute,X" then
                str = str..Calculate16BitAbsAddress()..",X"
            elseif addressing == "$absolute,Y" then
                str = str..Calculate16BitAbsAddress()..",Y"
            elseif addressing == "($indirect)" then
                str = str..Calculate16BitIndirectAddress()
            elseif addressing == "($indirect,X)" then
                str = str.." (ram_00"..operand_1..",X)"
            elseif addressing == "($indirect),Y" then
                str = str.." (ram_00"..operand_1.."),Y"
            elseif addressing == "relative" then
                nes_address, f_pos = GetNesMemoryAddress(line)
                if f_pos == nil then
                    npp.WriteError("Line "..(line + 1)..": "..instruction.." <"..addressing..">: unable to calculate relative CPU address")
                    err = true
                else
                    local total = tonumber(nes_address, 16) + tonumber(operand_1, 16) + 0x02
                    if tonumber(operand_1, 16) & 0x80 == 0x80 then total = total - 0x100 end
                    str = str.." $"..string.upper(string.format("%04x", total & 0xFFFF))
                end
            end
            
            if err == false then
                --удалить лишний текст в конце строки
                l_pos_start = editor:PositionFromLine(line)
                l_pos_end = editor.LineEndPosition[line]
                editor:DeleteRange(l_pos_start + 30, l_pos_end - l_pos_start - 30)
                if addressing == "unknown" then
                    npp.WriteError("Line "..(line + 1)..": "..str)
                else
                    print("Line "..(line + 1)..": "..str)
                end
                
                --заменить на текст инструкции
                str = opcode.." "..operand_1.." "..operand_2.."  "..str
                editor:InsertText(l_pos_start + 30, str)
                
                --сместить курсор вниз
                editor:GotoLine(line + 1)
                
                --удалить нижние линии
                if length > 1 then
                    editor:LineDelete()
                    if length == 3 then
                        editor:LineDelete()
                    end
                end
            end
        end
    end
    
    editor:EndUndoAction()
end)





npp.AddShortcut(".byte x2 -> [conversion] [label] [counter] [offset]", "", function()
    local function AddOffsetValue(hi, lo)
        local str = hi..lo
        local addr = tonumber(str, 16)
        addr = (addr + OFFSET_value) & 0xFFFF
        addr = string.upper(string.format("%04x", addr))
        hi = string.sub(addr, 1, 2)
        lo = string.sub(addr, 3, 4)
        return hi, lo
    end
    
    local function ReplaceText(line, text)
        local l_pos_start = editor:PositionFromLine(line)
        local l_pos_end = editor.LineEndPosition[line]
        
        editor:DeleteRange(l_pos_start + 30, l_pos_end - l_pos_start - 30)
        if OFFSET_value ~= 0 then
            text = text.." - "..OFFSET_value
        end
        
        editor:InsertText(l_pos_start + 30, text)
        editor:GotoLine(line + 1)
        editor:LineDelete()
        return text
    end
    
    
    
    editor:BeginUndoAction()
    
    local line, pos = BasicInfo()
    local byte_1, f_pos_1 = GetByteFromLine(line)
    local byte_2, f_pos_2 = GetByteFromLine(line + 1)
    
    local addr = ""
    local text = ""
    local search = ""
    
    if f_pos_1 == nil then
        npp.WriteError("Line "..(line + 1)..": unable to find 1st <.byte $> string to read a byte")
    elseif f_pos_2 == nil then
        npp.WriteError("Line "..(line + 2)..": unable to find 2nd <.byte $> string to read a byte")
    else
        if     CONVERSION_mode == ".word" then
            if OFFSET_value ~= 0 then
                byte_2, byte_1 = AddOffsetValue(byte_2, byte_1)
            end
            addr = byte_2..byte_1
            text = byte_1.." "..byte_2.."     "..".word "
        elseif CONVERSION_mode == ".dbyt" then
            if OFFSET_value ~= 0 then
                byte_1, byte_2 = AddOffsetValue(byte_1, byte_2)
            end
            addr = byte_1..byte_2
            text = byte_1.." "..byte_2.."     "..".dbyt "
        end
        
        if LABEL_mode == "$" then
            text = text.."$"..addr
        else
            search = LABEL_mode..addr
            if     COUNTER_mode == "HEX" then
                search = search.."_"..string.upper(string.format("%02x", COUNTER_value))
            elseif COUNTER_mode == "DEC" then
                search = search.."_"..string.upper(string.format("%d", COUNTER_value))
            end
            text = text..search
        end
        
        local text_offset = ""
        if OFFSET_value ~= 0 then text_offset = " - "..OFFSET_value end
        
        if LABEL_mode == "$" then
            print("Line "..(line + 1)..": converting <.byte $"..byte_1.."> and <.byte $"..byte_2.."> to <"..CONVERSION_mode.." $"..addr..text_offset..">")
            ReplaceText(line, text)
        else
            local f_pos = editor:findtext(search..":")
            if f_pos ~= nil then
                ReplaceText(line, text)
                local f_line = editor:LineFromPosition(f_pos)
                print("Line "..(line + 1)..": converting <.byte $"..byte_1.."> and <.byte $"..byte_2.."> to <"..CONVERSION_mode.." $"..addr..text_offset..">. "..
                      "Label <"..search.."> already exists at line "..(f_line + 1))
            else
                f_pos = editor:findtext(":"..addr..":")
                if f_pos == nil then
                    npp.WriteError("CPU address $"..addr.." was not found in current file")
                else
                    ReplaceText(line, text)
                    --повторный поиск позиции, так как она будет сдвинута после замены
                    f_pos = editor:findtext(":"..addr..":")
                    local f_line = editor:LineFromPosition(f_pos)
                    local f_pos_start = editor:PositionFromLine(f_line)
                    editor:InsertText(f_pos_start, search..":\n")
                    print("Line "..(line + 1)..": converting <.byte $"..byte_1.."> and <.byte $"..byte_2.."> to <"..CONVERSION_mode.." $"..addr..text_offset..">. "..
                          "New label <"..search.."> was added at line "..(f_line + 1))
                    IncreaseCounter()
                end
            end
        end
    end

    editor:EndUndoAction()
end)





npp.AddShortcut(".byte -> [counter] .byte", "", function()
    editor:BeginUndoAction()
    
    if COUNTER_mode == nil then
        npp.WriteError("Counter is currently disabled! First you need to set a counter mode")
    elseif COUNTER_value < 2 then
        npp.WriteError("Current counter value is "..COUNTER_value..", set a higher value!")
    else
        local sel_pos_start, sel_pos_end = SelectLinesCompletely()
        local line_min, _, line_max = BasicInfo()
        if (line_max - line_min + 1) % COUNTER_value ~= 0 then
            npp.WriteError("You have selected "..(line_max - line_min + 1).." line(s). "..
                           "Select an amount of lines that can be divided by "..COUNTER_value.."!")
        else
            local bytes = {}
            local err = false
            for i = 1, line_max - line_min + 1 do
                local search_line = line_min + i - 1
                local byte, f_pos = GetByteFromLine(search_line)
                if f_pos ~= nil then
                    bytes[i] = byte
                else
                    err = true
                    npp.WriteError("Line "..(search_line + 1)..": ".."unable to find any <.byte $> string!")
                    break
                end
            end
                
            if err == false then
                editor:DeleteRange(sel_pos_start, sel_pos_end - sel_pos_start)
                print("Converting "..(line_max - line_min + 1)..
                      " <.byte $xx> lines into "..string.format("%d", (line_max - line_min + 1) / COUNTER_value)..
                      " <.byte $xx> lines with "..COUNTER_value.." bytes each")
                local b_counter = 0
                local str = ""
                for i = 1, line_max - line_min + 1 do
                    if b_counter == 0 then str = "    .byte " end
                    str = str.."$"..bytes[i]
                    b_counter = b_counter + 1
                    if b_counter < COUNTER_value then
                        str = str..", "
                    else
                        str = str.."\n"
                        editor:AddText(str)
                        b_counter = 0
                    end
                end
            end
        end
    end
    
    editor:EndUndoAction()
end)





npp.AddShortcut(".byte $ -> .byte %", "", function()
    editor:BeginUndoAction()
    
    local line = BasicInfo()
    local byte, f_pos = GetByteFromLine(line)
    
    if f_pos == nil then
        npp.WriteError("Line "..(line + 1)..": ".."unable to find any <.byte $> string!")
    else
        local message = "Line "..(line + 1)..": converting <.byte $"..byte.."> to <.byte "
        byte = tonumber(byte, 16)
        
        local str = "%"
        if byte & 0x80 == 0x80 then str = str.."1" else str = str.."0" end
        if byte & 0x40 == 0x40 then str = str.."1" else str = str.."0" end
        if byte & 0x20 == 0x20 then str = str.."1" else str = str.."0" end
        if byte & 0x10 == 0x10 then str = str.."1" else str = str.."0" end
        if byte & 0x08 == 0x08 then str = str.."1" else str = str.."0" end
        if byte & 0x04 == 0x04 then str = str.."1" else str = str.."0" end
        if byte & 0x02 == 0x02 then str = str.."1" else str = str.."0" end
        if byte & 0x01 == 0x01 then str = str.."1" else str = str.."0" end
        
        print(message..str..">")
        editor:DeleteRange(f_pos + 6, 3)
        editor:InsertText(f_pos + 6, str)
        editor:GotoLine(line + 1)
    end
    editor:EndUndoAction()
end)





npp.AddShortcut("List of bytes -> list of .byte", "Ctrl+N", function()
    editor:BeginUndoAction()
    
    local sel_pos_start, sel_pos_end = SelectLinesCompletely()
    local str = editor:GetSelText()
    str = string.gsub(str, " ", "")         --удалить пробелы
    str = string.gsub(str, "[\r\n]+","")    --удалить символы новой строки
    
    local length = string.len(str)
    if length % 2 == 1 then
        npp.WriteError("Seleced lines contain an odd number of HEX symbols!")
    else
        local bytes = {}
        local j = 1
        for i = 1, length, 2 do
           bytes[j] = string.sub(str, i, i + 1)
           j = j + 1
        end
        
        local err = false
        for i = 1, length / 2 do
            if (tonumber(bytes[i], 16)) == nil then err = true end
        end
        
        if err == true then
            npp.WriteError("One or more symbols are not HEX numbers!")
        else
            editor:DeleteRange(sel_pos_start, sel_pos_end - sel_pos_start)
            print("Converting bytes into "..string.format("%d", length / 2).." <.byte $xx> lines")
            for i = 1, length / 2 do
                editor:AddText("    .byte $"..bytes[i].."\n")
            end
        end
    end

    editor:EndUndoAction()
end)











npp.AddShortcut("---------- LABELS ----------", "", function()
    print("[section info] This is a section for auto adding labels to the current file")
end)



npp.AddShortcut("Label all branches", "", function()
    message = "\n*** Labeling branches ***\n"
    instruction = "(BEQ|BCC|BNE|BMI|BPL|BCS|BVS|BVC)"
    label = "bra_"
    range = "(6|7|8|9|A|B|C|D|E|F)"
    LabelInstrictions(message, instruction, label, _, _, range, _)
end)



npp.AddShortcut("Label tables [range]", "", function()
    message = "\n*** Labeling tables ***\n"
    instruction = "(LDA|LDX|LDY|STA|INC|DEC|CMP|ADC|SBC|ORA|AND|EOR|ASL|ROL|LSR|ROR)"
    label = "tbl_"
    range = LABEL_range
    addressing = "(,X|,Y)"
    LabelInstrictions(message, instruction, label, _, _, range, addressing)
end)



npp.AddShortcut("Label JMP/JSR [range]", "", function()
    message = "\n*** Labeling JMP/JSR ***\n"
    instruction = "(JMP|JSR)"
    jmp_label = "loc_"
    jsr_label = "sub_"
    range = LABEL_range
    LabelInstrictions(message, instruction, _, jmp_label, jsr_label, range, _)
end)



function LabelInstrictions(message, instruction, label, jmp_label, jsr_label, range, addressing)
    local function GetSearchPosition(str)
        pos = editor:SearchNext(SCFIND_REGEXP, str)
        return pos
    end

    time = os.clock()
    print(message)
    
    editor:BeginUndoAction()
    
    search = instruction.." \\$"..range.."..."
    if addressing ~= nil then search = search..addressing end
    next_search_line = 0
    instructions_renamed = 0
    labels_created = 0
    errors_counter = 0

    editor:GotoLine(0)        --начать поиск с начала документа
    editor:SearchAnchor()
    finish = false

    while not finish do
        pos = GetSearchPosition(search)
        if pos == -1 then
            finish = true
        else
            next_search_line = npp.CurrentLine + 1    --подготовить следующую строку для поиска инструкции
            editor:GotoPos(pos)                 --поставить курсор на позицию поиска
            
            local operand = CopyText(pos + 5, pos + 9)      --скопировать адрес из инструкции
            local label_str = ""
            if label ~= nil then
                label_str = label..operand
            elseif CopyText(pos, pos + 3) == "JMP" then
                label_str = jmp_label..operand
            elseif CopyText(pos, pos + 3) == "JSR" then
                label_str = jsr_label..operand
            end
            
            local label_pos = editor:findtext(":"..operand..":")        --найти адрес :xxxx: слева от инструкций
            if label_pos == nil then
                npp.WriteError(CopyText(pos - 28, pos - 20)..": can't find $"..operand.." address for creating a label")
                errors_counter = errors_counter + 1
            else
                editor:SetSel(pos + 4, pos + 9)     --выделить операнд вместе с $
                editor:ReplaceSel(label_str)        --поменять на лейбл + адрес
                instructions_renamed = instructions_renamed + 1
                editor:GotoLine(0)
                editor:SearchAnchor()               --начать поиск с начала документа
                if GetSearchPosition(label_str..":") == -1 then
                    editor:GotoPos(label_pos)
                    local label_line = npp.CurrentLine
                    editor:GotoLine(label_line)
                    editor:AddText(label_str..":\n")
                    labels_created = labels_created + 1
                    if next_search_line > label_line then
                        next_search_line = next_search_line + 1        --увеличить номер строки, если лейбл был добавлен вверху, что приводит к смещению
                    end
                end
            end
            
            if next_search_line <= editor.LineCount then
                editor:GotoLine(next_search_line)
                editor:SearchAnchor()
            else
                finish = true
            end
        end
    end
    
    editor:EndUndoAction()
    
    print("Instructions renamed   = "..instructions_renamed)
    print("New labels created     = "..labels_created)
    print("Errors occured         = "..errors_counter)
    print(string.format("Script finished in "..string.format("%.3f", os.clock() - time).." seconds"))
end









npp.AddShortcut("----------- OTHER -----------", "", function()
    print("[section info] This is a section for other scripts")
end)

npp.AddShortcut("Clear console", "", function()
    npp.ClearConsole()
end)

npp.AddShortcut("Paste counter and increase it", "", function()
    if COUNTER_mode == nil then
        npp.WriteError("Counter is currently disabled! First you need to set a counter mode")
    else
        editor:BeginUndoAction()
        if     COUNTER_mode == "HEX" then
            local val = string.upper(string.format("%02x", COUNTER_value))
            print("Printing HEX value <"..val..">")
            editor:AddText(val)
        elseif COUNTER_mode == "DEC" then
            local val = string.upper(string.format("%d", COUNTER_value))
            print("Printing DEC value <"..val..">")
            editor:AddText(val)
        end
        IncreaseCounter()
        
        editor:EndUndoAction()
    end
end)










opcodes_table = {
-- "unknown"
-- "implied"
-- "accumulator"
-- "#immediate"
-- "$zero page"
-- "$zero page,X"
-- "$zero page,Y"
-- "$absolute"
-- "$absolute,X"
-- "$absolute,Y"
-- "($indirect)"
-- "($indirect,X)"
-- "($indirect),Y"
-- "relative"

--byte (unused), instruction length, instruction name, addressing mode
    "00",        1,        "BRK",              "implied",            -- BRK
    "01",        2,        "ORA",              "($indirect,X)",      -- ORA ($00,X)
    "02",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED 
    "03",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED  
    "04",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED 
    "05",        2,        "ORA",              "$zero page",         -- ORA $00
    "06",        2,        "ASL",              "$zero page",         -- ASL $00
    "07",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "08",        1,        "PHP",              "implied",            -- PHP
    "09",        2,        "ORA",              "#immediate",         -- ORA #$00
    "0A",        1,        "ASL",              "accumulator",        -- ASL
    "0B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "0C",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "0D",        3,        "ORA",              "$absolute",          -- ORA $0000
    "0E",        3,        "ASL",              "$absolute",          -- ASL $0000
    "0F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "10",        2,        "BPL",              "relative",           -- BPL $0000
    "11",        2,        "ORA",              "($indirect),Y",      -- ORA ($00),Y
    "12",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "13",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "14",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "15",        2,        "ORA",              "$zero page,X",       -- ORA $00,X
    "16",        2,        "ASL",              "$zero page,X",       -- ASL $00,X
    "17",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "18",        1,        "CLC",              "implied",            -- CLC
    "19",        3,        "ORA",              "$absolute,Y",        -- ORA $0000,Y
    "1A",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "1B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "1C",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "1D",        3,        "ORA",              "$absolute,X",        -- ORA $0000,X
    "1E",        3,        "ASL",              "$absolute,X",        -- ASL $0000,X
    "1F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "20",        3,        "JSR",              "$absolute",          -- JSR $0000
    "21",        2,        "AND",              "($indirect,X)",      -- AND ($00,X)
    "22",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "23",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "24",        2,        "BIT",              "$zero page",         -- BIT $00
    "25",        2,        "AND",              "$zero page",         -- AND $00
    "26",        2,        "ROL",              "$zero page",         -- ROL $00
    "27",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "28",        1,        "PLP",              "implied",            -- PLP
    "29",        2,        "AND",              "#immediate",         -- AND #$00 
    "2A",        1,        "ROL",              "accumulator",        -- ROL
    "2B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "2C",        3,        "BIT",              "$absolute",          -- BIT $0000
    "2D",        3,        "AND",              "$absolute",          -- AND $0000
    "2E",        3,        "ROL",              "$absolute",          -- ROL $0000
    "2F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "30",        2,        "BMI",              "relative",           -- BMI $0000
    "31",        2,        "AND",              "($indirect),Y",      -- AND ($00),Y
    "32",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "33",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "34",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "35",        2,        "AND",              "$zero page,X",       -- AND $00,X
    "36",        2,        "ROL",              "$zero page,X",       -- ROL $00,X
    "37",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "38",        1,        "SEC",              "implied",            -- SEC
    "39",        3,        "AND",              "$absolute,Y",        -- AND $0000,Y
    "3A",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "3B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "3C",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "3D",        3,        "AND",              "$absolute,X",        -- AND $0000,X
    "3E",        3,        "ROL",              "$absolute,X",        -- ROL $0000,X
    "3F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "40",        1,        "RTI",              "implied",            -- RTI
    "41",        2,        "EOR",              "($indirect,X)",      -- EOR ($00,X)
    "42",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "43",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "44",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "45",        2,        "EOR",              "$zero page",         -- EOR $00  
    "46",        2,        "LSR",              "$zero page",         -- LSR $00  
    "47",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "48",        1,        "PHA",              "implied",            -- PHA
    "49",        2,        "EOR",              "#immediate",         -- EOR #$00 
    "4A",        1,        "LSR",              "accumulator",        -- LSR
    "4B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "4C",        3,        "JMP",              "$absolute",          -- JMP $0000
    "4D",        3,        "EOR",              "$absolute",          -- EOR $0000
    "4E",        3,        "LSR",              "$absolute",          -- LSR $0000
    "4F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "50",        2,        "BVC",              "relative",           -- BVC $0000
    "51",        2,        "EOR",              "($indirect),Y",      -- EOR ($00),Y
    "52",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "53",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "54",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "55",        2,        "EOR",              "$zero page,X",       -- EOR $00,X
    "56",        2,        "LSR",              "$zero page,X",       -- LSR $00,X
    "57",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "58",        1,        "CLI",              "implied",            -- CLI
    "59",        3,        "EOR",              "$absolute,Y",        -- EOR $0000,Y
    "5A",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "5B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "5C",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "5D",        3,        "EOR",              "$absolute,X",        -- EOR $0000,X
    "5E",        3,        "LSR",              "$absolute,X",        -- LSR $0000,X
    "5F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "60",        1,        "RTS",              "implied",            -- RTS
    "61",        2,        "ADC",              "($indirect,X)",      -- ADC ($00,X)
    "62",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "63",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "64",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "65",        2,        "ADC",              "$zero page",         -- ADC $00  
    "66",        2,        "ROR",              "$zero page",         -- ROR $00  
    "67",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "68",        1,        "PLA",              "implied",            -- PLA
    "69",        2,        "ADC",              "#immediate",         -- ADC #$00 
    "6A",        1,        "ROR",              "accumulator",        -- ROR
    "6B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "6C",        3,        "JMP",              "($indirect)",        -- JMP ($0000)
    "6D",        3,        "ADC",              "$absolute",          -- ADC $0000
    "6E",        3,        "ROR",              "$absolute",          -- ROR $0000
    "6F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "70",        2,        "BVS",              "relative",           -- BVS $0000
    "71",        2,        "ADC",              "($indirect),Y",      -- ADC ($00),Y
    "72",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "73",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "74",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "75",        2,        "ADC",              "$zero page,X",       -- ADC $00,X
    "76",        2,        "ROR",              "$zero page,X",       -- ROR $00,X
    "77",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "78",        1,        "SEI",              "implied",            -- SEI
    "79",        3,        "ADC",              "$absolute,Y",        -- ADC $0000,Y
    "7A",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "7B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "7C",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "7D",        3,        "ADC",              "$absolute,X",        -- ADC $0000,X
    "7E",        3,        "ROR",              "$absolute,X",        -- ROR $0000,X
    "7F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "80",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "81",        2,        "STA",              "($indirect,X)",      -- STA ($00,X)
    "82",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "83",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "84",        2,        "STY",              "$zero page",         -- STY $00
    "85",        2,        "STA",              "$zero page",         -- STA $00
    "86",        2,        "STX",              "$zero page",         -- STX $00
    "87",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "88",        1,        "DEY",              "implied",            -- DEY
    "89",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "8A",        1,        "TXA",              "implied",            -- TXA
    "8B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "8C",        3,        "STY",              "$absolute",          -- STY $0000
    "8D",        3,        "STA",              "$absolute",          -- STA $0000
    "8E",        3,        "STX",              "$absolute",          -- STX $0000
    "8F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "90",        2,        "BCC",              "relative",           -- BCC $0000
    "91",        2,        "STA",              "($indirect),Y",      -- STA ($00),Y
    "92",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "93",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "94",        2,        "STY",              "$zero page,X",       -- STY $00,X
    "95",        2,        "STA",              "$zero page,X",       -- STA $00,X
    "96",        2,        "STX",              "$zero page,Y",       -- STX $00,Y
    "97",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "98",        1,        "TYA",              "implied",            -- TYA
    "99",        3,        "STA",              "$absolute,Y",        -- STA $0000,Y
    "9A",        1,        "TXS",              "implied",            -- TXS
    "9B",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "9C",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "9D",        3,        "STA",              "$absolute,X",        -- STA $0000,X
    "9E",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "9F",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "A0",        2,        "LDY",              "#immediate",         -- LDY #$00
    "A1",        2,        "LDA",              "($indirect,X)",      -- LDA ($00,X)
    "A2",        2,        "LDX",              "#immediate",         -- LDX #$00
    "A3",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "A4",        2,        "LDY",              "$zero page",         -- LDY $00
    "A5",        2,        "LDA",              "$zero page",         -- LDA $00
    "A6",        2,        "LDX",              "$zero page",         -- LDX $00
    "A7",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "A8",        1,        "TAY",              "implied",            -- TAY      
    "A9",        2,        "LDA",              "#immediate",         -- LDA #$00 
    "AA",        1,        "TAX",              "implied",            -- TAX      
    "AB",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "AC",        3,        "LDY",              "$absolute",          -- LDY $0000
    "AD",        3,        "LDA",              "$absolute",          -- LDA $0000
    "AE",        3,        "LDX",              "$absolute",          -- LDX $0000
    "AF",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "B0",        2,        "BCS",              "relative",           -- BCS $0000
    "B1",        2,        "LDA",              "($indirect),Y",      -- LDA ($00),Y
    "B2",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "B3",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "B4",        2,        "LDY",              "$zero page,X",       -- LDY $00,X
    "B5",        2,        "LDA",              "$zero page,X",       -- LDA $00,X
    "B6",        2,        "LDX",              "$zero page,Y",       -- LDX $00,Y
    "B7",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "B8",        1,        "CLV",              "implied",            -- CLV      
    "B9",        3,        "LDA",              "$absolute,Y",        -- LDA $0000,Y
    "BA",        1,        "TSX",              "implied",            -- TSX      
    "BB",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "BC",        3,        "LDY",              "$absolute,X",        -- LDY $0000,X
    "BD",        3,        "LDA",              "$absolute,X",        -- LDA $0000,X
    "BE",        3,        "LDX",              "$absolute,Y",        -- LDX $0000,Y
    "BF",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "C0",        2,        "CPY",              "#immediate",         -- CPY #$00 
    "C1",        2,        "CMP",              "($indirect,X)",      -- CMP ($00,X)
    "C2",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "C3",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "C4",        2,        "CPY",              "$zero page",         -- CPY $00  
    "C5",        2,        "CMP",              "$zero page",         -- CMP $00  
    "C6",        2,        "DEC",              "$zero page",         -- DEC $00  
    "C7",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "C8",        1,        "INY",              "implied",            -- INY      
    "C9",        2,        "CMP",              "#immediate",         -- CMP #$00 
    "CA",        1,        "DEX",              "implied",            -- DEX      
    "CB",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "CC",        3,        "CPY",              "$absolute",          -- CPY $0000
    "CD",        3,        "CMP",              "$absolute",          -- CMP $0000
    "CE",        3,        "DEC",              "$absolute",          -- DEC $0000
    "CF",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "D0",        2,        "BNE",              "relative",           -- BNE $0000
    "D1",        2,        "CMP",              "($indirect),Y",      -- CMP ($00),Y
    "D2",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "D3",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "D4",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "D5",        2,        "CMP",              "$zero page,X",       -- CMP $00,X
    "D6",        2,        "DEC",              "$zero page,X",       -- DEC $00,X
    "D7",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "D8",        1,        "CLD",              "implied",            -- CLD      
    "D9",        3,        "CMP",              "$absolute,Y",        -- CMP $0000,Y
    "DA",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "DB",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "DC",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "DD",        3,        "CMP",              "$absolute,X",        -- CMP $0000,X
    "DE",        3,        "DEC",              "$absolute,X",        -- DEC $0000,X
    "DF",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "E0",        2,        "CPX",              "#immediate",         -- CPX #$00 
    "E1",        2,        "SBC",              "($indirect,X)",      -- SBC ($00,X)
    "E2",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "E3",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "E4",        2,        "CPX",              "$zero page",         -- CPX $00  
    "E5",        2,        "SBC",              "$zero page",         -- SBC $00  
    "E6",        2,        "INC",              "$zero page",         -- INC $00  
    "E7",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "E8",        1,        "INX",              "implied",            -- INX      
    "E9",        2,        "SBC",              "#immediate",         -- SBC #$00 
    "EA",        1,        "NOP",              "implied",            -- NOP      
    "EB",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "EC",        3,        "CPX",              "$absolute",          -- CPX $0000
    "ED",        3,        "SBC",              "$absolute",          -- SBC $0000
    "EE",        3,        "INC",              "$absolute",          -- INC $0000
    "EF",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "F0",        2,        "BEQ",              "relative",           -- BEQ $0000
    "F1",        2,        "SBC",              "($indirect),Y",      -- SBC ($00),Y
    "F2",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "F3",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "F4",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "F5",        2,        "SBC",              "$zero page,X",       -- SBC $00,X
    "F6",        2,        "INC",              "$zero page,X",       -- INC $00,X
    "F7",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "F8",        1,        "SED",              "implied",            -- SED
    "F9",        3,        "SBC",              "$absolute,Y",        -- SBC $0000,Y
    "FA",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "FB",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "FC",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
    "FD",        3,        "SBC",              "$absolute,X",        -- SBC $0000,X
    "FE",        3,        "INC",              "$absolute,X",        -- INC $0000,X
    "FF",        1,        "UNDEFINED",        "unknown",            -- UNDEFINED
}