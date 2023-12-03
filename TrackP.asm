PUBLIC DrawTrackHorizontal, DrawTrackVertical, FillScreen 

Include Const.inc

.MODEL SMALL
.CODE




;; Description: Draws Track Component Horizontally from the buffer into the screen without using interrupts given the starting pixel in DI
;; Input:   DI
;; Registers:   AX, ES, SI, DX, CX, DI
DrawTrackHorizontal PROC FAR

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen


    MOV DX, TRACK_IMAGE_HEIGHT

REPEAT_H:
    MOV CX, TRACK_IMAGE_WIDTH
    
    DRAW_LINE_OF_IMG_H:         ;H stands for horizontal (horizontal component)
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        DEC CX
        JNZ DRAW_LINE_OF_IMG_H 
    
    ADD DI, SCREEN_WIDTH - TRACK_IMAGE_WIDTH  ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT_H


    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawTrackHorizontal ENDP


;; Description: Draws Track Component Vertically from the buffer into the screen without using interrupts given the starting pixel in DI
;; Input:
;; Registers:   AX, ES, SI, DX, CX, DI
DrawTrackVertical PROC  FAR

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI
    PUSH BX

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen


    MOV DX, TRACK_IMAGE_WIDTH - 1
    

REPEAT_V:
    MOV CX, TRACK_IMAGE_HEIGHT
    MOV BX, SI
    DRAW_LINE_OF_IMG_V:         ;V stands for Vertical (Vertical component)
        MOV AX, DS:[SI]
        MOV ES:[DI], AX
        INC DI
        ADD SI, TRACK_IMAGE_WIDTH
        DEC CX
        JNZ DRAW_LINE_OF_IMG_V
    
    MOV SI, BX
    INC SI
    SUB DI, SCREEN_WIDTH + TRACK_IMAGE_HEIGHT  ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT_V

    POP BX
    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawTrackVertical ENDP

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