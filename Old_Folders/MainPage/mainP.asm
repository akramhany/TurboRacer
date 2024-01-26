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

.MODEL SMALL
STACK 64
.DATA 

widthToFill dw 00
heightToFill dw 00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
BUFFER_SIZE_LOGO equ 6400
LOGO_IMAGE_WIDTH equ 160
LOGO_IMAGE_HEIGHT equ 40
BUFFER_SIZE_CAR equ 4000
CAR_IMAGE_WIDTH equ 80
CAR_IMAGE_HEIGHT equ 50
OPEN_ATTRIBUTE equ 0    ;0 is read only
BACKGROUND_COLOR equ 201
INPUT_POS_ROW_1 equ 11
INPUT_POS_ROW_2 equ 12
INPUT_POS_COL_1 equ 18
INPUT_POS_COL_2 equ 18



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;IMAGES BUFFERS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
logoFileName db 'LogoN.bin'
logoBuffer db BUFFER_SIZE_LOGO dup(?)

TEMP  db ?

carFileName db 'carP.bin'
carBuffer db BUFFER_SIZE_CAR dup(?)

tt db ?


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;MESSAGES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
userName1M db 'User1 Name:$'
TEMP2 DB 00
userName2M db 'User2 Name:$'
hhhh DB 00
inputRules1 db 'Username must not exceed 15 chars$'
hhhhh DB 00 
inputRules2 db 'Username must start with a letter$'
asdf db 00
errorOne db 'Error:username must not exceed 15 chars$'
fsdal db 00
errorTwo db 'Error:username must start with a letter$'
errorOccured db 0 
aaalal db ?
msg1 db 'To start the game press F1$'
db ?
msg2 db 'To start chatting press F2$'
db ?
msg3 db 'To exit press F3$'
db ?

;The actual string is stored at user1Data or at userName1 + 2
userName1 LABEL BYTE
user1MaxLen DB 200
user1ActualLen DB ?
user1Data DB 200 DUP('$')

db ?
db ?
db ?

;;The actual string is stored at user2Data or at userName2 + 2
userName2 LABEL BYTE
user2MaxLen DB 200
user2ActualLen DB ?
user2Data DB 200 DUP('$')

db ?
db ?
db ?

.CODE


MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX

    CALL FAR PTR DisplayFirstPage

    CALL FAR PTR DisplayMainPage


    MOV AH, 0
    INT 16H

    MOV AH, 4CH
    INT 21H
MAIN ENDP

;; Description: fill the background (A000H MUST BE IN ES) with a given color in AL
;; Input:  
;; Registers:  DI, CX
FillBackground PROC FAR
    
    PUSH DI
    PUSH CX
    PUSH DX
    PUSH BX

    MOV DI, 0
    MOV CX, SCREEN_WIDTH
    MOV DX, SCREEN_HEIGHT
    MOV BX, 0

REPEAT:
    MOV CX, SCREEN_WIDTH

    FILL_LINE_OF_BACKGROUND:
        CMP ES:[BX], BYTE PTR 01H           ;If the pixel is black, fill it with the background color, if not do not fill it
        JL FILL
        JMP DONOT_FILL
        FILL:
            MOV ES:[BX], AL
        DONOT_FILL:
        INC BX
        DEC CX
        JNZ FILL_LINE_OF_BACKGROUND
    DEC DX
    JNZ REPEAT


    POP BX
    POP DX
    POP CX
    POP DI

    RET

FillBackground ENDP

;; Description: fill the SCREEN (A000H MUST BE IN ES) with a given color in AL, the starting point to fill from must be given in BP
;; fill a certain width and a certain height given in widthToFill, and heightToFill  
;; Registers:  DI, CX
FillScreen PROC FAR
    
    PUSH BP
    PUSH DI
    PUSH CX
    PUSH DX
    PUSH BX

    MOV DI, 0
    MOV CX, widthToFill
    MOV DX, heightToFill
    MOV BX, BP

REPEAT_S:
    MOV CX, widthToFill

    FILL_LINE_OF_SCREEN:
        MOV ES:[BX], AL
        INC BX
        DEC CX
        JNZ FILL_LINE_OF_SCREEN
    DEC DX
    JNZ REPEAT_S


    POP BX
    POP DX
    POP CX
    POP DI
    POP BP

    RET

FillScreen ENDP

DrawLogo PROC FAR

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

    LEA SI, logoBuffer


    MOV DX, LOGO_IMAGE_HEIGHT

REPEAT_H:
    MOV CX, LOGO_IMAGE_WIDTH
    
    DRAW_LINE_OF_IMG_H:         ;H stands for horizontal (horizontal component)
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        DEC CX
        JNZ DRAW_LINE_OF_IMG_H 
    
    ADD DI, SCREEN_WIDTH - LOGO_IMAGE_WIDTH  ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT_H


    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawLogo ENDP

DrawCarImage PROC FAR

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

    LEA SI, carBuffer


    MOV DX, CAR_IMAGE_HEIGHT

REPEAT_CAR_IMAGE:
    MOV CX, CAR_IMAGE_WIDTH
    
    DRAW_LINE_OF_IMG_CAR:         ;H stands for horizontal (horizontal component)
        CMP DS:[SI], BYTE PTR 1FH
        JLE DONT_DRAW_CHECK
        JMP DRAW
        DONT_DRAW_CHECK:
            CMP DS:[SI], BYTE PTR 1dH
            JLE DRAW
            JMP DONT_DRAW
        DRAW:
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        JMP CONT
        DONT_DRAW:
            INC SI
            INC DI
        CONT:
        DEC CX
        JNZ DRAW_LINE_OF_IMG_CAR 
    
    ADD DI, SCREEN_WIDTH - CAR_IMAGE_WIDTH  ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT_CAR_IMAGE


    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawCarImage ENDP

;description
ValidateInput PROC FAR

    MOV AL, BACKGROUND_COLOR
    MOV BP, 60 * 320
    MOV widthToFill, 320
    MOV heightToFill, 20
    CALL FAR PTR FillScreen

    MOV errorOccured, 0

    CMP user1ActualLen, 15
    JG EXCEED_15
    CMP user2ActualLen, 15
    JG EXCEED_15

CONT_VALD:

    CMP user1Data, 'A'
    JL FIRST_CHAR_ERR
    CMP user1Data, 'Z'
    JG CHECK_LOWER_U1
    JMP CHECK_U2

CHECK_LOWER_U1:
    CMP user1Data, 'a'
    JL FIRST_CHAR_ERR
    CMP user1Data, 'z'
    JG FIRST_CHAR_ERR

CHECK_U2:

    CMP user2Data, 'A'
    JL FIRST_CHAR_ERR
    CMP user2Data, 'Z'
    JG CHECK_LOWER_U2
    JMP EXIT_V_I

CHECK_LOWER_U2:
    CMP user2Data, 'a'
    JL FIRST_CHAR_ERR
    CMP user2Data, 'z'
    JG FIRST_CHAR_ERR
    JMP EXIT_V_I


EXCEED_15:
    MOV errorOccured, 1
    SetCursor 8, 1
    DisplayString errorOne
    JMP CONT_VALD

FIRST_CHAR_ERR:
    MOV errorOccured, 1
    SetCursor 9, 1
    DisplayString errorTwo
    JMP EXIT_V_I

EXIT_V_I:

RET
    
ValidateInput ENDP 

;description
DisplayFirstPage PROC FAR

    OpenFile OPEN_ATTRIBUTE, logoFileName       ;open the logo image file
    ReadFile AX, BUFFER_SIZE_LOGO, logoBuffer   ;read all the bytes into the buffer
    CloseFile                                   ;close the file

    OpenFile OPEN_ATTRIBUTE, carFileName        ;open the logo image file
    ReadFile AX, BUFFER_SIZE_CAR, carBuffer     ;read all the bytes into the buffer
    CloseFile                                   ;close the file
    

;;;;;;;;;;;;;;;;;CHANGE TO VIDEO MODE 320 * 200;;;;;;;;;;;;;;;;;
    MOV AH, 0
    MOV AL, 13H
    INT 10H

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

;;Draw Logo
    MOV DI, 320 * 10 + 80
    CALL FAR PTR DrawLogo

;;Draw Car
    MOV DI, 320 * 140 + 120
    CALL FAR PTR DrawCarImage

;;Fill the background with a certain color
    MOV AL, BACKGROUND_COLOR
    CALL FAR PTR FillBackground

GET_NEW_INPUT:
;Fill Screen with a certain color
    MOV AL, BACKGROUND_COLOR
    MOV BP, 80 * 320
    MOV widthToFill, 320
    MOV heightToFill, 45
    CALL FAR PTR FillScreen

    DisplayPromptMessages

    SetCursor INPUT_POS_ROW_1, INPUT_POS_COL_1
    GetUserInput userName1
    SetCursor INPUT_POS_ROW_2, INPUT_POS_COL_2
    GetUserInput userName2

    CALL FAR PTR ValidateInput

    CMP errorOccured, 0
    JE CONT_EXEC
    JMP GET_NEW_INPUT

CONT_EXEC:
RET

DisplayFirstPage ENDP 

;description
DisplayMainPage PROC FAR

    MOV AL, BACKGROUND_COLOR
    MOV BP, 60 * 320
    MOV widthToFill, 320
    MOV heightToFill, 140
    CALL FAR PTR FillScreen

    SetCursor 12, 7
    DisplayString msg1
    SetCursor 14, 7
    DisplayString msg2
    SetCursor 16, 7
    DisplayString msg3

RET    
DisplayMainPage ENDP 

END MAIN