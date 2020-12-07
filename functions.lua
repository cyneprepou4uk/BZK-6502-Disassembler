function PrintFileError(e)
    print("\nERROR "..e)
    print("Until then the script won't work!")
    io.read()
end



function ReadAllBytesFrom(bin)
    --на вход подается .nes или .cdl, считывание всех байтов
    print("Reading bytes from <"..bin.."> file...")
    local file, err = io.open(INPUT_folder..bin, "rb")
    if err ~= nil then PrintFileError(err) end
    local result = {}
    local bytes = file:read("*all")
    for i = 1, string.len(bytes) do
        result[i] = string.sub(bytes, i, i)
    end
    return result
end



function CreateEmptyAsmFiles()
    --создание пустых .asm файлов
    print("Preparing empty assembly files...")
    local i = 0
    while true do
        if ASM_config_table[i * 5 + 1] == nil then break end
        
        local file, err = io.open(OUTPUT_folder..ASM_config_table[i * 5 + 1], "w+")
        if err ~= nil then PrintFileError(err) end
        io.close(file)
        i = i + 1
    end
end



function DumpHeader(bin)
    --дамп хедера
    if HEADER_file[3] == 0x0 then
        print("No header for this game, skipping...")
    else
        print("Dumping header into <"..HEADER_file[1].."> file...")
        local file, err = io.open(OUTPUT_folder..HEADER_file[1], "w+")
        if err ~= nil then PrintFileError(err) end
        io.close(file)
        file = io.open(OUTPUT_folder..HEADER_file[1], "ab")
        io.output(file)
        counter = HEADER_file[2] + 1
        size = HEADER_file[2] + HEADER_file[3]
        for i = counter, size do
            io.write(bin[i])
        end
        io.flush(file)
        io.close(file)
    end
end



function DumpChr(bin)
    --дамп chr если существует
    if CHR_file[3] == 0x0 then
        print("No CHR for this game, skipping...")
    else
        print("Dumping CHR into <"..CHR_file[1].."> file...")
        local file, err = io.open(OUTPUT_folder..CHR_file[1], "w+")
        if err ~= nil then PrintFileError(err) end
        io.close(file)
        file = io.open(OUTPUT_folder..CHR_file[1], "ab")
        io.output(file)
        counter = CHR_file[2] + 1
        size = CHR_file[2] + CHR_file[3]
        for i = counter, size do
            io.write(bin[i])
        end
        io.flush(file)
        io.close(file)
    end
end



function CreateRamUsageCounterTables()
    --подготовка счетчиков адресов, забитие таблицы нулями
    cpu_addr_usage = {}
    cpu_addr_zero_page_usage = {}
    cpu_addr_zero_page_X_usage = {}
    cpu_addr_zero_page_Y_usage = {}
    cpu_addr_absolute_usage = {}
    cpu_addr_absolute_X_usage = {}
    cpu_addr_absolute_Y_usage = {}
    cpu_addr_indirect_usage = {}
    cpu_addr_indirect_X_usage = {}
    cpu_addr_indirect_Y_usage = {}
    for i = 0, 0xFFFF do
        cpu_addr_usage[i + 1] = 0
        cpu_addr_zero_page_usage[i + 1] = 0
        cpu_addr_zero_page_X_usage[i + 1] = 0
        cpu_addr_zero_page_Y_usage[i + 1] = 0
        cpu_addr_absolute_usage[i + 1] = 0
        cpu_addr_absolute_X_usage[i + 1] = 0
        cpu_addr_absolute_Y_usage[i + 1] = 0
        cpu_addr_indirect_usage[i + 1] = 0
        cpu_addr_indirect_X_usage[i + 1] = 0
        cpu_addr_indirect_Y_usage[i + 1] = 0
    end
end



function PrepareOutputFile()
    --открыть файл, дописать сегмент, добавить .include, указать диапазон адресов
    print("<"..ASM_config_table[asm_files_counter * 5 + 1].."> file: "..
          "mapping code at $"..string.upper(string.format("%04x", ASM_config_table[asm_files_counter * 5 + 3]))..
          "-$"..string.upper(string.format("%04x", ASM_config_table[asm_files_counter * 5 + 3] + ASM_config_table[asm_files_counter * 5 + 4] - 1)).."...")
    
    local i = asm_files_counter * 5
    local file, err = io.open(OUTPUT_folder..ASM_config_table[i + 1], "a")
    if err ~= nil then PrintFileError(err) end
    io.output(file)
    io.write(".segment \"???\"\n")
    io.write(".include \""..RAM_file.."\"\n")
    io.write("; 0x"..string.upper(string.format("%06x", ASM_config_table[i + 2])))
    io.write("-0x"..string.upper(string.format("%06x", (ASM_config_table[i + 2] + ASM_config_table[i + 4] - 1))).."\n\n")
    io.flush(file)
    return file
end



function ReadBytesForCurrentBank()
    --чтение байтов исключительно для текущего .asm файла из кучи байтов
    local tbl_rom = {}
    local tbl_cdl = {}
    local counter = ASM_config_table[asm_files_counter * 5 + 2] + 1
    local size = ASM_config_table[asm_files_counter * 5 + 2] + ASM_config_table[asm_files_counter * 5 + 4]
    local j = 1
    for i = counter, size do
        local rom_byte = string.upper(string.format("%02x", string.byte(ROM_binary[i])))
        tbl_rom[j] = rom_byte
        local cdl_byte = string.upper(string.format("%02x", string.byte(CDL_binary[i - 0x10])))
        tbl_cdl[j] = cdl_byte
        j = j + 1
    end
    return tbl_rom, tbl_cdl
end



function ReadEncodingForCurrentBank()
    --чтение кодировки исключительно для текущего .asm файла из файла кодировки
    --если файл не указан, забить таблицу пустыми строками
    local encoding = {}
    if ASM_config_table[asm_files_counter * 5 + 5] == false then
        for i = 1, 256 do
            encoding[i] = ""
        end
    else
        local file, err = io.open(INPUT_folder..ASM_config_table[asm_files_counter * 5 + 5], "r")
        if err ~= nil then PrintFileError(err) end
        for i = 1, 256 do
            local str = file:read("*line")
            encoding[i] = string.sub(str, 4)
        end
        io.close(file)
    end
    return encoding
end



function ConvertCdlToFlags(cdl_byte)
    --расшифровать флаги
    local str = ""
    local byte = tonumber(cdl_byte, 16)
    local code_flag = false
    local data_flag = false
    if byte & 0xFF == 0x00 then str = "- - - - - - "
    else
        if byte & 0x01 == 0x01 then str = str.."C " code_flag = true else str = str.."- " end
        if byte & 0x02 == 0x02 then str = str.."D " data_flag = true else str = str.."- " end
        if data_flag == true then
            --fceux-master\src\debug.cpp, line 460
            --cdloggerdata[j+i] |= ((_PC & 0x8000) >> 8) ^ 0x80
            --19/07/14 used last reserved bit, if bit 7 is 1, then code is running from lowe area (6000)
            if     byte & 0x80 == 0x80 then str = str.."4 "
            elseif byte & 0x0C == 0x00 then str = str.."0 "
            elseif byte & 0x0C == 0x04 then str = str.."1 "
            elseif byte & 0x0C == 0x08 then str = str.."2 "
            elseif byte & 0x0C == 0x0C then str = str.."3 "
            end
        else str = str.."- " end
        if byte & 0x10 == 0x10 then str = str.."J " else str = str.."- " end
        if byte & 0x20 == 0x20 then str = str.."I " else str = str.."- " end
        if byte & 0x40 == 0x40 then str = str.."A " else str = str.."- " end
    end
    return code_flag, str
end



function ConvertCounterToAddresses()
    --оформить 2 адреса и номер банка после флагов
    local str = ""
    local rom_addr = string.upper(string.format("%06x", tonumber(tostring(ASM_config_table[asm_files_counter * 5 + 2] + bytes_counter - 1)), 16))
    local bank_num = (ASM_config_table[asm_files_counter * 5 + 2] + bytes_counter - 1 - 0x10) / 0x4000
    bank_num = bank_num - bank_num % 1
    bank_num = string.upper(string.format("%02x", tostring(bank_num)))
    local nes_addr = string.upper(string.format("%04x", tonumber(tostring((ASM_config_table[asm_files_counter * 5 + 3] + bytes_counter - 1) & 0xFFFF)), 16))
    str = str.."0x"..rom_addr.." "..bank_num..":"..nes_addr..": "
    return nes_addr, rom_addr, str
end



function Get3BytesAndInfo()
    --прочитать 3 байта для следующей инструкции
    local str = ""
    local b1 = ROM_bytes[bytes_counter]
    local b2 = ROM_bytes[bytes_counter + 1]
    local b3 = ROM_bytes[bytes_counter + 2]
    local length = opcodes_table[tonumber(b1, 16) * 4 + 2]
    local mode = opcodes_table[tonumber(b1, 16) * 4 + 4]
    
    if flag_code == true and bytes_counter + length > max_address + 1 and incomplete_instr_err == false then
        incomplete_instr_err = true
        errors_list[errors_counter + 1] = "Incomplete instruction at 0x"..rom_address.." in "..ASM_config_table[asm_files_counter * 5 + 1].." file!"
        errors_counter = errors_counter + 1
    end
    
    if cpu_addr_overflow == false then
        local addr = tonumber(tostring((ASM_config_table[asm_files_counter * 5 + 3] + bytes_counter - 1)))
        if addr > 0xFFFF then
            cpu_addr_overflow = true
            errors_list[errors_counter + 1] = "NES Memory overflow at 0x"..rom_address.." in "..ASM_config_table[asm_files_counter * 5 + 1].." file!"
            errors_counter = errors_counter + 1
        end
    end
    
    if flag_code == false or incomplete_instr_err == true then str = str..b1.."        "
    elseif length == 1 then str = str..b1.."        "
    elseif length == 2 then str = str..b1.." "..b2.."     "
    elseif length == 3 then str = str..b1.." "..b2.." "..b3.."  "
    end
    return b1, b2, b3, length, mode, str
end



function GetByte()
    --если это байт, оформить текст как байт
    local str = ".byte $"..opcode
    local i = tonumber(opcode, 16) + 1
    if TBL_encoding[i] ~= "" then
        str = str.."   ; <"..TBL_encoding[i]..">"
    end
    return str
end



function GetInstruction()
    --если это инструцкция, оформить текст как инструцкцию
    local function IncreaseRamAddressingModeUsage(i)
        if     addr_mode == "$zero page" then
            cpu_addr_zero_page_usage[i] = cpu_addr_zero_page_usage[i] + 1
        elseif addr_mode == "$zero page,X" then
            cpu_addr_zero_page_X_usage[i] = cpu_addr_zero_page_X_usage[i] + 1
        elseif addr_mode == "$zero page,Y" then
            cpu_addr_zero_page_Y_usage[i] = cpu_addr_zero_page_Y_usage[i] + 1
        elseif addr_mode == "$absolute" then
            cpu_addr_absolute_usage[i] = cpu_addr_absolute_usage[i] + 1
        elseif addr_mode == "$absolute,X" then
            cpu_addr_absolute_X_usage[i] = cpu_addr_absolute_X_usage[i] + 1
        elseif addr_mode == "$absolute,Y" then
            cpu_addr_absolute_Y_usage[i] = cpu_addr_absolute_Y_usage[i] + 1
        elseif addr_mode == "($indirect)" then
            cpu_addr_indirect_usage[i] = cpu_addr_indirect_usage[i] + 1
        elseif addr_mode == "($indirect,X)" then
            cpu_addr_indirect_X_usage[i] = cpu_addr_indirect_X_usage[i] + 1
        elseif addr_mode == "($indirect),Y" then
            cpu_addr_indirect_Y_usage[i] = cpu_addr_indirect_Y_usage[i] + 1
        end
    end
    
    local function IncreaseRamUsageZeroPage()
        local i = tonumber(operand_1, 16) + 1
        cpu_addr_usage[i] = cpu_addr_usage[i] + 1
        IncreaseRamAddressingModeUsage(i)
    end
    
    local function IncreaseRamUsageAbsolute()
        local i = tonumber(operand_2, 16) * 0x100 + tonumber(operand_1, 16) + 1
        cpu_addr_usage[i] = cpu_addr_usage[i] + 1
        IncreaseRamAddressingModeUsage(i)
    end
    
    local function Calculate16BitAbsoluteAddress()
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
    
    
    local index = tonumber(opcode, 16)
    local str = opcodes_table[index * 4 + 3]
    if     addr_mode == "unknown" then
        --nothing
        errors_list[errors_counter + 1] = "UNDEFINED instruction at 0x"..rom_address.." in "..ASM_config_table[asm_files_counter * 5 + 1].." file!"
        errors_counter = errors_counter + 1
    elseif addr_mode == "implied" then
        --nothing
    elseif addr_mode == "accumulator" then
        --nothing
    elseif addr_mode == "#immediate" then
        str = str.." #$"..operand_1
    elseif addr_mode == "$zero page" then
        str = str.." ram_00"..operand_1
        IncreaseRamUsageZeroPage()
    elseif addr_mode == "$zero page,X" then
        str = str.." ram_00"..operand_1..",X"
        IncreaseRamUsageZeroPage()
    elseif addr_mode == "$zero page,Y" then
        str = str.." ram_00"..operand_1..",Y"
        IncreaseRamUsageZeroPage()
    elseif addr_mode == "$absolute" then
        str = str..Calculate16BitAbsoluteAddress()
        IncreaseRamUsageAbsolute()
    elseif addr_mode == "$absolute,X" then
        str = str..Calculate16BitAbsoluteAddress()..",X"
        IncreaseRamUsageAbsolute()
    elseif addr_mode == "$absolute,Y" then
        str = str..Calculate16BitAbsoluteAddress()..",Y"
        IncreaseRamUsageAbsolute()
    elseif addr_mode == "($indirect)" then
        str = str..Calculate16BitIndirectAddress()
        IncreaseRamUsageAbsolute()
    elseif addr_mode == "($indirect,X)" then
        str = str.." (ram_00"..operand_1..",X)"
        IncreaseRamUsageZeroPage()
    elseif addr_mode == "($indirect),Y" then
        str = str.." (ram_00"..operand_1.."),Y"
        IncreaseRamUsageZeroPage()
    elseif addr_mode == "relative" then
        local total = tonumber(nes_address, 16) + tonumber(operand_1, 16) + 0x02
        if tonumber(operand_1, 16) & 0x80 == 0x80 then total = total - 0x100 end
        str = str.." $"..string.upper(string.format("%04x", total & 0xFFFF))
    end
    return str
end



function CreateRamInclude()
    --чтение таблиц счетчиков адресов и запись в include файл
    local function WriteAddresses(counter, size)
        for i = counter + 1, size + 1 do
            local str = "ram_"
            local convert = "%04x"      --для адреса после =
            if i < 0x0100 then convert = "%02x" end
            local addr = string.upper(string.format("%04x", i - 1))
            str = str..addr.."                        = $"..string.upper(string.format(convert, i - 1)).." ; "
            
            if RAM_usage_output[1] == true then
                if RAM_usage_output[2] == true then
                    if cpu_addr_usage[i] == 0 then
                        str = str.."N/A"
                    else
                        str = str..cpu_addr_usage[i].."   "
                    end
                end
                
                if cpu_addr_usage[i] ~= 0 then
                    if RAM_usage_output[3] == true then
                        if cpu_addr_zero_page_usage[i] ~= 0 then
                            str = str.."$zero page <"..cpu_addr_zero_page_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[4] == true then
                        if cpu_addr_zero_page_X_usage[i] ~= 0 then
                            str = str.."$zero page,X <"..cpu_addr_zero_page_X_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[5] == true then
                        if cpu_addr_zero_page_Y_usage[i] ~= 0 then
                            str = str.."$zero page,Y <"..cpu_addr_zero_page_Y_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[6] == true then
                        if cpu_addr_absolute_usage[i] ~= 0 then
                            str = str.."$absolute <"..cpu_addr_absolute_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[7] == true then
                        if cpu_addr_absolute_X_usage[i] ~= 0 then
                            str = str.."$absolute,X <"..cpu_addr_absolute_X_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[8] == true then
                        if cpu_addr_absolute_Y_usage[i] ~= 0 then
                            str = str.."$absolute,Y <"..cpu_addr_absolute_Y_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[9] == true then
                        if cpu_addr_indirect_usage[i] ~= 0 then
                            str = str.."($indirect) <"..cpu_addr_indirect_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[10] == true then
                        if cpu_addr_indirect_X_usage[i] ~= 0 then
                            str = str.."($indirect,X) <"..cpu_addr_indirect_X_usage[i]..">   "
                        end
                    end
                    
                    if RAM_usage_output[11] == true then
                        if cpu_addr_indirect_Y_usage[i] ~= 0 then
                            str = str.."($indirect),Y <"..cpu_addr_indirect_Y_usage[i]..">   "
                        end
                    end
                end
            end
            
            io.write(str.."\n")
        end
    end
    
    
    print("Working on <"..RAM_file.."> file...")
    local file, err = io.open(OUTPUT_folder..RAM_file, "w+")
    if err ~= nil then PrintFileError(err) end
    io.output(file)
    
    io.write("; RAM\n")
    if RAM_usage_output[1] == true then
        if RAM_usage_output[3] == true then  io.write("; $zero page <?>\n") end
        if RAM_usage_output[4] == true then  io.write("; $zero page,X <?>\n") end
        if RAM_usage_output[5] == true then  io.write("; $zero page,Y <?>\n") end
        if RAM_usage_output[6] == true then  io.write("; $absolute <?>\n") end
        if RAM_usage_output[7] == true then  io.write("; $absolute,X <?>\n") end
        if RAM_usage_output[8] == true then  io.write("; $absolute,Y <?>\n") end
        if RAM_usage_output[9] == true then  io.write("; ($indirect) <?>\n") end
        if RAM_usage_output[10] == true then io.write("; ($indirect,X) <?>\n") end
        if RAM_usage_output[11] == true then io.write("; ($indirect),Y <?>\n") end
    end
    
    WriteAddresses(0x0000, 0x07FF)
    
    local sram_addr_usage_counter = 0
    for i = 0x6000, 0x7FFF do
        if cpu_addr_usage[i + 1] ~= 0 then
            sram_addr_usage_counter = sram_addr_usage_counter + 1
        end
    end
    
    if sram_addr_usage_counter ~= 0 then
        io.write("\n\n\n; SRAM (battery)\n")
        io.write("    ; It appears that some code in your game uses at least "..sram_addr_usage_counter.." address(es) of $6000-$7FFF range.\n")
        io.write("    ; These ram_xxxx names are not actually used in your output asm files right now.\n")
        io.write("    ; Before you can safely use them, first you need to prepare SRAM location\n")
        io.write("    ; by converting bytes to instructions and labeling branches, tables and jumps\n")
        io.write("    ; using my Notepad++ scripts. When you are done with that, manually replace names\n")
        io.write("    ; via <Replace> function in Notepad++. Here is how you can do that:\n")
        io.write("\n")
        io.write("    ; 1 - open all assembly files at once (except this one)\n")
        io.write("    ; 2 - open search window with Ctrl + F and then go to <Replace> tab\n")
        io.write("    ; 3 - select <Regular expression> option down below\n")
        io.write("    ; 4 - replace this\n")
        io.write("        ; \\$(6|7)(0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F)(0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F)(0|1|2|3|4|5|6|7|8|9|A|B|C|D|E|F)\n")
        io.write("    ; with this\n")
        io.write("        ; ram_$1$2$3$4\n")
        io.write("    ; using <Replace All in All Opened Documents> button\n")
        io.write("\n")
        WriteAddresses(0x6000, 0x7FFF)
    end
    
    io.flush(file)
    io.close(file)
end



function CreateDebugFile()
    --аналогично предыдущему, но читает весь nes диапазон адресов и пишет в отдельный файл
    if DEBUG_file[2] == true then
        print("Additionally creating <"..DEBUG_file[1].."> file...")
        local file, err = io.open(OUTPUT_folder..DEBUG_file[1], "w+")
        if err ~= nil then PrintFileError(err) end
        io.output(file)
        
        for i = 0 + 1, 0xFFFF + 1 do
            local str = "$"..string.upper(string.format("%04x", i - 1))..": "
            
            if cpu_addr_usage[i] == 0 then
                str = str.."N/A"
            else
                str = str..cpu_addr_usage[i].."   "
            end
            
            if cpu_addr_usage[i] ~= 0 then
                str = str.."$zero page <"..cpu_addr_zero_page_usage[i]..">   "
                str = str.."$zero page,X <"..cpu_addr_zero_page_X_usage[i]..">   "
                str = str.."$zero page,Y <"..cpu_addr_zero_page_Y_usage[i]..">   "
                str = str.."$absolute <"..cpu_addr_absolute_usage[i]..">   "
                str = str.."$absolute,X <"..cpu_addr_absolute_X_usage[i]..">   "
                str = str.."$absolute,Y <"..cpu_addr_absolute_Y_usage[i]..">   "
                str = str.."($indirect) <"..cpu_addr_indirect_usage[i]..">   "
                str = str.."($indirect,X) <"..cpu_addr_indirect_X_usage[i]..">   "
                str = str.."($indirect),Y <"..cpu_addr_indirect_Y_usage[i]..">   "
            end
            
            io.write(str.."\n")
        end
        
        io.flush(file)
        io.close(file)
    end
end



function PrintErrors()
    print("\n\n\nErrors occured = "..errors_counter)
    if errors_counter ~= 0 then
        for i = 1, errors_counter do
            print("> "..errors_list[i])
        end
    end
end



function PrintFinalMessage()
    print("\n\n")
    print("***       Everything is ready to go        ***")
    print("***                                        ***")
    print("***          Thank you for using           ***")
    print("***      BZK 6502 Disassembler v1.3.0      ***")
    print("***                                        ***")
    print("***     You can close this window now      ***")
    print(string.format("\n\n\nFinished in "..string.format("%.3f", os.clock() - time).." seconds"))
end