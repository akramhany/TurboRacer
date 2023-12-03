PUBLIC DrawTrack, FillScreen

Include Const.inc

.MODEL SMALL
.CODE

;; Description: Draws an image from the buffer into the screen without using interrupts given the starting pixel in DI
;; Input:   TRACK_IMAGE_HEIGHT, TRACK_IMAGE_WIDTH, SCREEN_WIDTH
;; Registers:   AX, ES, SI, DX, CX, DI
DrawTrack PROC FAR

    PUSH BP
    MOV BP, SP

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen


    MOV DX, [BP + 6]

REPEAT:
    MOV CX, [BP + 8]
    
    DRAW_LINE_OF_IMG:
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        DEC CX
        JNZ DRAW_LINE_OF_IMG
    
    MOV AX, [BP + 10]
    SUB AX, [BP + 8]
    ADD DI, AX   ;inc di to draw the second line of the image (AX = SCREEN_WIDTH - TRACK_IMAGE_WIDTH)
    DEC DX
    JNZ REPEAT


    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX
    POP BP

    RET

DrawTrack ENDP

;; Description: fill the screen (A000H MUST BE IN ES) with a given color in AL
;; Input:  
;; Registers:  DI, CX
FillScreen PROC
    
    PUSH BP
    MOV BP, SP

    PUSH DI
    PUSH CX

    MOV DI, 0
    MOV CX, SCREEN_HEIGHT * SCREEN_WIDTH

    REP STOSB   ;loop for CX and put AL into ES:[DI] and inc DI each time

    POP CX
    POP DI
    POP BP

    RET

FillScreen ENDP
END