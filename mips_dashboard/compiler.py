
registros = {"R0": "00000", "R1": "00001", "R2": "00010", "R3": "00011", "R4": "00100", "R5": "00101", "R6": "00110", "R7": "00111", 
"R8": "01000", "R9": "01001", "R10": "01010", "R11": "01011", "R12": "01100", "R13": "01101", "R14": "01110", "R15": "01111", 
"R16": "10000", "R17": "10001", "R18": "10010", "R19": "10011", "R20": "10100", "R21": "10101", "R22": "10110", "R23": "10111",
"R24": "11000", "R25": "11001", "R26": "11010", "R27": "11011", "R28": "11100", "R29": "11101", "R30": "11110", "R31": "11111"}

tipo_R = {"sll": "000000", "srl": "000010", "sra": "000011", "sllv": "000100", "srlv": "000110", 
"srav": "000111", "addu": "100001", "subu": "100011", "and": "100100", "or": "100101", 
"xor": "100110", "nor": "100111", "slt": "101010", "jr": "001000", "jalr": "001001"}

tipo_I =  {"lb": "100000", "lh": "100001", "lw": "100011", "lwu": "010011", "lbu": "100100",
"lhu": "100101", "sb": "101000", "sh": "101001", "sw": "101011", "addi": "001000", "andi": "001100",
"ori": "001101", "xori": "001110", "lui": "001111", "slti": "001010", "beq": "000100", "bne": "000101"}

tipo_J = { "j": "000010", "jal": "000011"}



def decimal_a_binario(decimal, bits=8):
    binario = bin(decimal)[2:]
    longitud_actual = len(binario)

    if longitud_actual < bits:
        binario = "0" * (bits - longitud_actual) + binario
    elif longitud_actual > bits:
        binario = binario[-bits:]
    return binario

def binario_a_hexadecimal(binario):
    hexadecimal = hex(int(binario,2))[2:]
    longitud_actual = len(hexadecimal)
    if longitud_actual < 8:
        hexadecimal = "0" * (8 - longitud_actual) + hexadecimal
    return hexadecimal

file   = open ('../mips_codes/code1.txt','r')
string = file.read()
file.close()
line = string.strip()


programa = line.split("\n")
print(line)

file = open ('codigo_maquina.txt', 'w')

for item in programa:

    instruction = item.split(" ")
    print(instruction)

    if (instruction[0] in tipo_R):
        function = tipo_R[instruction[0]]
        if (instruction[0] == "jalr"):
            rs = registros[instruction[2].replace(',','')]
            rd = registros[instruction[1].replace(',','')]
            instruction_ass = "000000" + str(rs) + "00000" + str(rd) + "00000" + str(function)		
        elif (instruction[0] == "jr"):
            rs = registros[instruction[1].replace(',','')]
            instruction_ass = "000000" + str(rs) + "00000" + "00000" + "00000" + str(function)	
        else:
            rs = registros[instruction[2].replace(',','')]
            rt = registros[instruction[3].replace(',','')]
            rd = registros[instruction[1].replace(',','')]
            instruction_ass = "000000" + str(rs) + str(rt) + str(rd) + "00000" + str(function)

    if (instruction[0] in tipo_I):
        op = tipo_I[instruction[0]]
        if (instruction[0] in ("lb","lh","lw","lwu","lbu","lhu","sb","sh","sw")):
            rt = registros[instruction[1].replace(',','')]			
            var1= instruction[2].split('(')		
            inm =  decimal_a_binario(int(var1[0]), 16)		
            var2 = var1[1].replace(')','')			
            rs = decimal_a_binario(int(var2),5)
        elif (instruction[0] == "lui"):			
            rt = registros[instruction[1].replace(',','')]
            rs = "00000"
            inm = decimal_a_binario(int(instruction[2]), 16)
        elif (instruction[0] == "beq" or instruction[0] == "bne"):
            rs = registros[instruction[1].replace(',','')]
            rt = registros[instruction[2].replace(',','')]			
            inm = decimal_a_binario(int(instruction[3]), 16)
        else:
            rs = registros[instruction[2].replace(',','')]			
            rt = registros[instruction[1].replace(',','')]		
            inm = decimal_a_binario(int(instruction[3]), 16)
        instruction_ass = str(op) + str(rs) + str(rt) + str(inm)

    if (instruction[0] in tipo_J):
        op  = tipo_J[instruction[0]]
        inm = decimal_a_binario(int(instruction[1]), 26)
        instruction_ass = str(op) + str(inm)

    file.write( binario_a_hexadecimal(instruction_ass) + "\n")


file.close()
