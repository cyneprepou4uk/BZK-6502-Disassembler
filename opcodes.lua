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