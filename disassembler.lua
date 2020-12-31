time = os.clock()

require("config")
require("functions")
require("opcodes")

ROM_binary = ReadAllBytesFrom(ROM_file)
CDL_binary = ReadAllBytesFrom(CDL_file)
DumpHeader(ROM_binary)
DumpChr(ROM_binary)
CreateEmptyAsmFiles()

CreateRamUsageCounterTables()
print()

asm_files_counter = 0
errors_counter = 0
errors_list = {}

while true do
    if ASM_config_table[asm_files_counter * 5 + 1] == nil then break end
    
    current_file = PrepareOutputFile()
    max_address = ASM_config_table[asm_files_counter * 5 + 4]
    
    ROM_bytes, CDL_bytes = ReadBytesForCurrentBank()
    TBL_encoding = ReadEncodingForCurrentBank()
    
    bytes_counter = 1
    incomplete_instr_err = false
    cpu_addr_overflow = false
    
    while true do
        if bytes_counter > max_address then break end
        
        flag_code, text_flags = ConvertCdlToFlags(CDL_bytes[bytes_counter])
        nes_address, rom_address, text_address = ConvertCounterToAddresses()
        opcode, operand_1, operand_2, instr_length, addr_mode, text_bytes = Get3BytesAndInfo()
        
        local text_final = ""
        if flag_code == false or incomplete_instr_err == true then
            text_final = GetByte()
            bytes_counter = bytes_counter + 1
        else
            text_final = GetInstruction()
            bytes_counter = bytes_counter + instr_length
        end
        
        io.write(text_flags..text_address..text_bytes..text_final.."\n")
    end
    
    io.write("\n\n\n")
    io.flush(current_file)
    io.close(current_file)
    asm_files_counter = asm_files_counter + 1
end

print()
CreateRamInclude()
CreateDebugFile()
PrintErrors()
PrintFinalMessage()

io.read()