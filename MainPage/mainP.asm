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


.MODEL SMALL
STACK 64
.DATA 

SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
BUFFER_SIZE_LOGO equ 6400
LOGO_IMAGE_WIDTH equ 160
LOGO_IMAGE_HEIGHT equ 40
BUFFER_SIZE_CAR equ 4000
CAR_IMAGE_WIDTH equ 80
CAR_IMAGE_HEIGHT equ 50
logoFileName db 'LogoN.bin'
OPEN_ATTRIBUTE equ 0    ;0 is read only

logoBuffer db BUFFER_SIZE_LOGO dup(?)
TEMP  db ?
strToDisp db 'Hi how are you ?$'
    db ?
TEMP2 DB 00

carFileName db 'carP.bin'
tt db ?
carBuffer db BUFFER_SIZE_CAR dup(?)
asdf db 00
dada db ?

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


    MOV DI, 320 * 10 + 80
    CALL FAR PTR DrawLogo

    MOV DI, 320 * 140 + 120
    CALL FAR PTR DrawCarImage

    MOV AL, 201
    CALL FillScreen
;
;    MOV DX, 0C0DH
;    MOV BH, 0
;    MOV AH, 02
;    INT 10H
;
;    MOV AH, 09
;    MOV DX, offset strToDisp
;    INT 21H


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
            CMP DS:[SI], BYTE PTR 1CH
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