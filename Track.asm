Include Macros.asm 
.MODEL SMALL
.STACK 64

;-----------------------------------------

;*************************************
;   Data Section
;*************************************
.DATA

fileName db 'Track.bin'         ;image file name (image is in binary)
BUFFER_SIZE equ 2000            ;size of buffer that would contain the image (in bytes)
buffer db BUFFER_SIZE dup(?)    ;allocate 2000 byte

TRACK_IMAGE_HEIGHT equ 32
TRACK_IMAGE_WIDTH equ 60

SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
OPEN_ATTRIBUTE equ 0

;---------------------------------------------

;*************************************
;   Code Section
;*************************************

.CODE

START PROC FAR
    MOV AX, @DATA
    MOV DS, AX

    OpenFile OPEN_ATTRIBUTE     ;open the image file
    ReadFile AX                 ;read all the bytes into the buffer
    CloseFile                   ;close the file

    mov ah,0
    mov al,13h
    int 10h

    MOV DI,320/2 - TRACK_IMAGE_WIDTH/2 ;STARTING PIXEL
    CALL DrawImage


    HLT
START ENDP

;; Description: Draws an image from the buffer into the screen without using interrupts given the starting pixel in DI
;; Input:   
;; Registers:   AX, ES, SI, DX, CX, DI
DrawImage PROC

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

    MOV AL, 00H         ;set the color in al to black
    CALL FillScreen     ;fill the screen with black

    MOV SI, offset buffer       ;make si point to the beginning of the image buffer
    MOV DX, TRACK_IMAGE_HEIGHT

REPEAT:
    MOV CX, TRACK_IMAGE_WIDTH
    
    DRAW_LINE_OF_IMG:
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        DEC CX
        JNZ DRAW_LINE_OF_IMG
    
    ADD DI, SCREEN_WIDTH - TRACK_IMAGE_WIDTH   ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT

    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawImage ENDP

;; Description: fill the screen (A000H MUST BE IN ES) with a given color in AL
;; Input:
;; Registers:  DI, CX
FillScreen PROC
    
    PUSH DI
    PUSH CX

    MOV DI, 0
    MOV CX, SCREEN_WIDTH * SCREEN_HEIGHT

    REP STOSB   ;loop for CX and put AL into ES:[DI] and inc DI each time

    POP CX
    POP DI 

    RET

FillScreen ENDP

END START
