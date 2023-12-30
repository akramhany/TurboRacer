;get the pixel color in AL, CX = COL, DX = ROW
GetPixelColor MACRO

                  MOV AH, 0DH
                  MOV BH, 0
                  INT 10H

ENDM

Delay MACRO

          MOV CX, 00H
          MOV DX, 04240H
          MOV AH, 86H
          INT 15H

ENDM

BigDelay MACRO

          MOV CX, 05AH
          MOV DX, 02240H
          MOV AH, 86H
          INT 15H

ENDM

OpenFile Macro openMode, filename

    mov ah, 03Dh
    mov al, openMode ; 0 - read-only, 1 - write-only, 2 -read&write
    mov dx, offset filename ; ASCII filename to open
    int 21h

ENDM


;fileHandle is the value stored in ax after opening the file
ReadFile Macro fileHandle, BUFFER_SIZE, buffer

    mov bx, fileHandle
    mov ah, 03Fh
    mov cx, BUFFER_SIZE     ; number of bytes to read
    mov dx, offset buffer   ; were to put read data
    int 21h

ENDM

CloseFile Macro

    MOV ah, 3Eh         ; DOS function: close file
    INT 21H

ENDM

SetCursor MACRO row, col

    MOV DH, row
    MOV DL, col
    MOV BH, 0
    MOV AH, 02
    INT 10H

ENDM

DisplayString MACRO strToDisp


    MOV AH, 09
    MOV DX, offset strToDisp
    INT 21H

ENDM

GetUserInput MACRO inputS
    
    MOV AH, 0AH
    MOV DX, offset inputS
    INT 21H

ENDM

DisplayPromptMessages MACRO
    
    SetCursor INPUT_POS_ROW_1, 7
    DisplayString userName1M
    SetCursor INPUT_POS_ROW_2, 7
    DisplayString userName2M
    SetCursor 14, 2
    DisplayString inputRules1
    SetCursor 15, 2
    DisplayString inputRules2


ENDM