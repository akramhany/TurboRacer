PUBLIC DrawTrackHorizontal, GenerateTrack, DrawTrackVertical, FillScreen 
EXTRN upDist:WORD
EXTRN downDist:WORD
EXTRN leftDist:WORD
EXTRN rightDist:WORD

Include Macros.inc
Include Const.inc

.MODEL SMALL
.CODE


;; Description: Generates a Track from a given point and with a given instructions (start point is DI, while instructions is in stack)
;; Input:   DI, set of instructions that ends with 5
;; Registers:   DI, SI, BP
GenerateTrack PROC  FAR

    PUSH BP                         ;Store the value of BP
    MOV BP, SP                      ;Make BP point at the stack segment

    PUSH DI                         ;Store the value of DI
    PUSH SI                         ;Store the value of SI
    PUSH BX                         ;Store the value of BX

    MOV BX, BP                      ;Make BX point at stack
    ADD BX, 6                       ;Add (6) to reach the first instruction in stack

LOOP_ON_INSTRCTS:                   ;Loop over the instructions in the stack
    CMP BYTE PTR SS:[BX], UP
    JE MOVE_UP

    CMP BYTE PTR SS:[BX], LEFT
    JE MOVE_LEFT

    CMP BYTE PTR SS:[BX], RIGHT
    JE MOVE_RIGHT

    CMP BYTE PTR SS:[BX], DOWN
    JNE AUX_LABEL

    JMP MOVE_DOWN

AUX_LABEL:                          ;Fix an error bec je is out of range
    JMP EXIT                        ;If no instructions then EXIT

    MOVE_UP:
        ADD DI, upDist                          ;Changes DI to it's appropriate starting position
        CALL FAR PTR DrawTrackVertical   
        SUB DI, (TRACK_IMAGE_WIDTH) * 320       ;Advance DI to the beginnig of the last Drawen Row
        MOV rightDist, UP_RIGHT                 ;Set the rightDist to UP_RIGHT
        MOV leftDist, UP_LEFT                   ;Set the leftDist to UP_LEFT
        MOV upDist, 0                           ;Reset the value of upDist to default
        MOV downDist, TRACK_IMAGE_WIDTH         ;Reset the value of downDist to default

        JMP CONT

    MOVE_LEFT:
        ADD DI, leftDist                        ;Changes DI to it's appropriate starting position
        CALL FAR PTR DrawTrackHorizontal
        SUB DI, 0                               ;it doesn't do anything but it just makes sure the structure is const
        MOV upDist, LEFT_UP                     ;Set the upDist to LEFT_UP
        MOV downDist, LEFT_DOWN                 ;Set the downDist to LEFT_DOWN
        MOV leftDist, (-TRACK_IMAGE_WIDTH)      ;reset the value of leftDist to default
        MOV rightDist, 0                        ;reset the value of rightDist to default

        JMP CONT

    MOVE_RIGHT:
        ADD DI, rightDist                       ;Changes DI to it's appropriate starting position
        CALL FAR PTR DrawTrackHorizontal
        ADD DI, TRACK_IMAGE_WIDTH - 1           ;Advance DI to the beginning of the last Drawn Col
        MOV upDist, RIGHT_UP                    ;Set the upDist to RIGHT_UP 
        MOV downDist, RIGHT_DOWN                ;Set the downDist to RIGHT_DOWN
        MOV rightDist, 0                        ;Reset value of rightDist to default
        MOV leftDist, (-TRACK_IMAGE_WIDTH)      ;Reset value of leftDist to default

        JMP CONT

    MOVE_DOWN:
        ADD DI, downDist                        ;Changes DI to it's appropriate starting position
        CALL FAR PTR DrawTrackVertical
        ADD DI, 0                               ;it doesn't do anything but it just makes sure the structure is const
        MOV rightDist, DOWN_RIGHT               ;Set rightDist to DOWN_RIGHT
        MOV leftDist, DOWN_LEFT                 ;Set leftDist to DOWN_LEFT
        MOV downDist, (TRACK_IMAGE_WIDTH) * 320 ;Reset value of downDist to default
        MOV upDist, 0                           ;Resest value of upDist to default

        JMP CONT

    CONT:
        ADD BX, 2                               ;Increment BX to the next instruction
        JMP LOOP_ON_INSTRCTS

EXIT: 


    POP BX                              ;Retrive the original value of BX from memory
    POP SI                              ;Retrive the original value of SI from memory
    POP DI                              ;Retrive the original value of DI from memory
    POP BP                              ;Retrive the original value of BP from memory

    RET

GenerateTrack ENDP

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


    MOV DX, TRACK_IMAGE_WIDTH
    

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