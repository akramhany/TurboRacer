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

.MODEL SMALL
STACK 64
.DATA 

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

asdf db 00
dada db ?

;;The actual string is stored at user1Data or at userName1 + 2
userName1 LABEL BYTE
user1MaxLen DB 30
user1ActualLen DB ?
user1Data DB 30 DUP('$')

 db ?

;;The actual string is stored at user2Data or at userName2 + 2
userName2 LABEL BYTE
user2MaxLen DB 30
user2ActualLen DB ?
user2Data DB 30 DUP('$')

.CODE


MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

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

;;Fill Screen with a certain color
    MOV AL, 201
    CALL FillScreen

;;Display the first message to get username of player 1
    SetCursor 12, 10
    DisplayString userName1M

;;Get user 1 name
    MOV AH, 0AH
    MOV DX, offset userName1
    INT 21H

;;Display the second message to get username of player 2
    SetCursor 13, 10
    DisplayString userName2M

;;Get user 2 name
    MOV AH, 0AH
    MOV DX, offset userName2
    INT 21H

;;make the program wait to not end
    MOV AH, 0
    INT 16H

    MOV AH, 4CH
    INT 21H
MAIN ENDP

;; Description: fill the screen (A000H MUST BE IN ES) with a given color in AL
;; Input:  
;; Registers:  DI, CX
FillScreen PROC
    
    PUSH BP
    MOV BP, SP

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

    FILL_LINE_OF_SCREEN:
        CMP ES:[BX], BYTE PTR 01H
        JL FILL
        JMP DONOT_FILL
        FILL:
            MOV ES:[BX], AL
        DONOT_FILL:
        INC BX
        DEC CX
        JNZ FILL_LINE_OF_SCREEN
    DEC DX
    JNZ REPEAT


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

END MAIN