.MODEL  SMALL                   

.stack  100H                    

.DATA                           ; test data area

    input   db  00100100B       ; input value - 24H
    sqroot  db  00000000B       ; storing the sqrt value

    ; keeping the bits 
    bit0  db  00000000B    
    bit1  db  00000000B 
    bit2  db  00000000B 
    bit3  db  00000000B
    bit4  db  00000000B 
    bit5  db  00000000B 
    bit6  db  00000000B
    bit7  db  00000000B 

.CODE                           ; code starts

MAIN:
    MOV AX,@DATA                ; setup 
    MOV DS,AX
    MOV ES,AX                   ; for correct STOSB usage

    XOR AH, AH
    MOV AL, input
    MOV BX, 1                  ; prepare BH
    MOV BL, 1
    loop1:
    SUB AX, BX
    CMP AX, 0                   ; compare it with 0
    JL sqrtend                  ; if less than 0 then stop    
    INC sqroot                  ; increment result (then the loop is over we will have our desired value)
    ADD BX, 2                   ; add 2 to BX
    JMP loop1                   ; loop until jumped to FINISH
    sqrtend:
    
    MOV AL, sqroot              ; move the value of computed srqt value to BL

    LEA DI, bit0
    MOV CX, 8
    loop2:
    STOSB
    SHR AL, 1                   ;most significant bits are important ones
    loop loop2

    ; gate 1
    MOV AL, bit0   
    MOV BL, bit1
    CALL NOR_F                  ; go to NOR_F
            
    ; gate 2
    MOV BL, bit2
    CALL NAND_F                 ; go to NAND_F  
    
    
    ; gate 3
    MOV BL, bit3
    NOT BL
    OR AL, BL

    PUSH AX                     ; back up current top-layer operand

    ; gate 4
    MOV AL, bit4   
    MOV BL, bit5
    XOR AL, BL
    
    ; gate 5
    POP BX                      
    CALL NAND_F                 
    
    PUSH AX                     
    
    ; gate 6
    MOV CL, bit6
    MOV DL, bit7
    AND CL, DL                  
    NOT CL              
    ; gate 4
    MOV AL, bit4
    MOV BL, bit5
    XOR AL, BL
    
    ; gate 7
    XOR AL, CL
    NOT AL
    
    
    ; gate 8
    POP BX
    CALL NAND_F
    
    
    AND AL, 00000001B           ; leave only most significant bit
    MOV DL, AL                  ; store result for printing
    ADD DL, 30H                 ; we need to add 30H so that it has its form in ASCII representation

    
    MOV AH,2                   
    INT 21H                     

    MOV AH,4CH                  ; setup to terminate program
    INT 21H                     
    

NAND_F:                         ; NAND AL and BL, store result in AL
    AND AL, BL                  
    NOT AL                      
    RET                         ; return to the part from where was called


NOR_F:                          ; NOR AL and BL, store result in AL
    OR AL, BL                   ; logical OR
    NOT AL                      ; logical NOT
    RET                     
    
END MAIN