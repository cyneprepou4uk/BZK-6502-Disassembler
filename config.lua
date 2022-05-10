--[[ Read manual at https://cyneprepou4uk.github.io/iromhacker/nes/en/bzk6502/1/index.html ]]--

--Put ROM_file, CDL_file and table files inside INPUT_folder
--OUTPUT_folder will store all files produced by the script
INPUT_folder = "C:/BZK 6502/input/"
OUTPUT_folder = "C:/BZK 6502/output/"

--name of the main game file, containing bytes for header, banks and CHR
ROM_file = "game.nes"

--this file contains different flags for bytes like code/data, can be produced using Code/Data Logger tool in FCEUX emulator
    --by looking at this file, the script will separate code from data, so the more bytes you have logged, the better
CDL_file = "game.cdl"

--file name, base ROM file address, size (set size to 0x0 if there is no header in your ROM file)
HEADER_file = { "header.bin", 0x000000, 0x10 }

--file name, base ROM file address, size (set size to 0x0 if there is no CHR in your ROM file)
CHR_file = { "CHR_ROM.chr", 0x008010, 0x8000 }

--RAM_file will contain labels for all RAM addresses, it will be included in all ASM banks
RAM_file = "bank_ram.inc"

--additional information for RAM_file
RAM_usage_output = {
                     true,      --1  global variable, set to false in order to set options 2-11 to false as well
                     true,      --2  RAM/SRAM           address usage counter
                     false,     --3  $zero page         addressing mode usage counter
                     false,     --4  $zero page,X       addressing mode usage counter
                     false,     --5  $zero page,Y       addressing mode usage counter
                     false,     --6  $absolute          addressing mode usage counter
                     false,     --7  $absolute,X        addressing mode usage counter
                     false,     --8  $absolute,Y        addressing mode usage counter
                     true,      --9  ($indirect)        addressing mode usage counter
                     true,      --10 ($indirect,X)      addressing mode usage counter
                     true,      --11 ($indirect),Y      addressing mode usage counter
}
                
--file name, flag (set to false if you don't want the script to produce a debug file)
DEBUG_file = { "debug.txt", true }

--if true, prints ";" near a byte even if it doesn't have a match from a table file
FORCE_byte_comments = true

--add/delete configuration lines depending on your game and write correct settings for each bank
    --1 <ASM file name>, name can be reused, assembly text will be appended to the file, not overwritten
    --2 <base ROM File address>
    --3 <base NES Memory address>
    --4 <size>, for example <base NES address> 0x8000 + <size> 0x2000 = $8000-$9FFF range
    --5 <table file name>, set to false if you don't want to use it for this particular bank
ASM_config_table = 
    {--       1            2        3       4        5
        "bank_00.asm", 0x000010, 0x8000, 0x2000, "game.tbl",
        "bank_01.asm", 0x002010, 0xA000, 0x2000, "game.tbl",
        "bank_02.asm", 0x004010, 0xC000, 0x2000, "game.tbl",
        "bank_03.asm", 0x006010, 0xE000, 0x2000, false,
    }
