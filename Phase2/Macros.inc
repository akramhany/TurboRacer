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

DISPLAYCHAR MACRO CHARACTER
mov ah,2
MOV DL,CHARACTER
int 21h
ENDM  

DISPLAYTIMER MACRO ROW,COL,TIMER 

SetCursor ROW,COL
    MOV AX,TIMER
    MOV DL,100
    DIV DL
    PUSH AX
    ADD AL,30H
    MOV DL,AL
    DISPLAYCHAR DL
    MOV DL,10
    POP AX
    MOV AL,AH
    MOV AH,0
    DIV DL
    PUSH AX
    ADD AL,30H
    MOV DL,AL
    DISPLAYCHAR DL
    POP AX
    MOV DL,AH
    ADD DL,30H
    DISPLAYCHAR DL

ENDM

ResetVariables MACRO

    MOV playerOneWin, 0
    MOV playerTwoWin, 0
    MOV CENTER1, 130 * 320 + 21
    MOV CENTER2, 140 * 320 + 21
    MOV STATE1, 1
    MOV STATE1, 2
    MOV SPEED1, 1
    MOV SPEED2, 1
    MOV POWCAR1, 0
    MOV POWCAR2, 0
    MOV POWCAR1, 0
    MOV POWCAR2, 0
    MOV SPEEDUP_CAR1, 0
    MOV SPEEDUP_CAR2, 0 
    MOV SPEEDDOWN_CAR1, 0
    MOV SPEEDDOWN_CAR2, 0
    MOV OBSTACLE_CAR1, 0 
    MOV OBSTACLE_CAR2, 0
    MOV PASS_CAR1, 0
    MOV PASS_CAR2, 0
    MOV CANPASS_CAR1, 0
    MOV CANPASS_CAR2, 0
    MOV STARTTIME1, 0
    MOV STARTTIME2, 0
    MOV COUNT1, 0
    MOV COUNT2, 0
    MOV ACTIVEUP_CAR1, 0
    MOV ACTIVEUP_CAR2, 0
    MOV ACTIVEDOWN_CAR1, 0
    MOV ACTIVEDOWN_CAR2, 0
    MOV powerUpPosX, 0
    MOV powerUpPosY, 0
    MOV powerUpColor, 0
    MOV playerOneWin, 0
    MOV playerTwoWin, 0
    MOV counterForPU, 0
    MOV currentSecond, 0
    MOV shouldExit, 0
    MOV moveDirectionRightC1, 0
    MOV moveDirectionUpC1, 0
    MOV moveDirectionLeftC1, 0
    MOV moveDirectionDownC1, 0
    MOV moveDirectionRightC2, 0 
    MOV moveDirectionUpC2, 0 
    MOV moveDirectionLeftC2, 0
    MOV moveDirectionDownC2, 0

ENDM