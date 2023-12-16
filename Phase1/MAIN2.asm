Delay MACRO 

MOV     CX, 00H
MOV     DX, 05240H
MOV     AH, 86H
INT     15H

ENDM

PUBLIC WIDTH1
PUBLIC WIDTH2
PUBLIC HEIGHT1
PUBLIC HEIGHT2
PUBLIC CENTER1
PUBLIC CENTER2
PUBLIC TOP1
PUBLIC TOP2
PUBLIC STATE1
PUBLIC STATE2
PUBLIC IMG1
PUBLIC IMG2
PUBLIC PIXELS1
PUBLIC PIXELS2

PUBLIC CANMOVE1
PUBLIC CANMOVE2
PUBLIC EXPECTEDSTATE1
PUBLIC EXPECTEDSTATE2

EXTRN CAR1:FAR
EXTRN CAR2:FAR
EXTRN RESETCAR1:FAR
EXTRN RESETCAR2:FAR
EXTRN ORIG1:FAR
EXTRN ORIG2:FAR
EXTRN CheckColisionCar1:FAR
EXTRN CheckColisionCar2:FAR

.MODEL SMALL
.STACK 64
.DATA
INCLUDE IMAGE1.INC
INCLUDE IMAGE2.INC
WIDTH1              DW 7                        ;WIDTH OF CAR1                  
HEIGHT1             DW 17                       ;HEIGHT OF CAR1   
WIDTH2              DW 7                        ;WIDTH OF CAR2
HEIGHT2             DW 15                       ;HEIGHT OF CAR2
CENTER1             DW 60000                    ;CENTER  OF CAR1
CENTER2             DW 38500                    ;CENTER OF CAR2
TOP1                DW ?                        ;INITIALIZED IN ORIGINAL PROCEDURE IN THE BEFINNING
TOP2                DW ?                        ;INITIALIZED IN ORIGINAL PROCEDURE IN THE BEGINNING
STATE1              DB 0                        ; 0 => UP    1 => RIGHT  2=> LEFT  3=>DOWN
STATE2              DB 0                        ; 0 => UP    1 => RIGHT  2=> LEFT  3=>DOWN
PIXELS1             DB 119 DUP (?)              ;ORIGINAL PIXELS IN THE PLACE OF CAR1
PIXELS2             DB 105 DUP(?)               ;ORIGINAL PIXELS IN THE PLACE OF CAR2
SPEED1              DW 1                        ;SPEED OF CAR1
SPEED2              DW 1                        ;CAR2 SPEED
OBSWIDTH            DW 5                        ;OBSTACLE WIDTH
OBSHEIGHT           DW 5                        ;OBSTACLE HEIGHT
POWCAR1             DB 0                        ;FLAG IF THE CAR1 HAS POWER UP
POWCAR2             DB 0                        ;FLAG IF THE CAR2 HAS POWER UP
SPEEDUP_CAR1        DB 0                        ;FLAG IF CAR1 HAS A SPEED UP POWER UP OR NOT
SPEEDUP_CAR2        DB 0                        ;FLAG IF CAR2 HAS A SPEED UP POWER UP OR NOT
SPEEDDOWN_CAR1      DB 0                        ;FLAG IF CAR1 HAS A SPEED DOWN POWER UP OR NOT
SPEEDDOWN_CAR2      DB 0                        ;FLAG IF CAR2 HAS A SPEED DOWN POWER UP OR NOT
OBSTACLE_CAR1       DB 0                        ;FLAG IF CAR1 HAS AN OBSTACLE POWER UP OR NOT
OBSTACLE_CAR2       DB 0                        ;FLAG IF CAR2 HAS AN OBSTACLE POWER UP OR NOT

EXPECTEDSTATE1      DB ?
EXPECTEDSTATE2      DB ?                        
CANMOVE1            DB ?
CANMOVE2            DB ?

;-------------------HANDELING TAKING MORE THAN ONE KEY INPUT AT THE SAME TIME---------------------------
origIntOffset       dw 0
origIntSegment      dw 0
shouldExit          db 0

moveDirectionRightC1 db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionUpC1   db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionLeftC1 db 0
moveDirectionDownC1 db 0


moveDirectionRightC2 db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionUpC2   db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionLeftC2 db 0
moveDirectionDownC2 db 0

.CODE


;------------------------------THE PROC WHICH WILL OVER RIDE INT 9 TO ALLOW TAKING MORE THAN ONE INPUT---------------------
OverRideInt9 PROC FAR
    IN AL, 60H      ;READ SCAN CODE

    CMP AL, 48H        ;CHECK UP KEY
    JNE UP_NOT_PRESSED
    MOV moveDirectionUpC1, 1
    JMP CONT

UP_NOT_PRESSED:
    CMP AL, 48H + 80H
    JNE UP_NOT_RELEASED
    MOV moveDirectionUpC1, 0
    JMP CONT

UP_NOT_RELEASED:
    CMP AL, 4DH                 ;Check for right pressed
    JNE RIGHT_NOT_PRESSED
    MOV moveDirectionRightC1, 1
    JMP CONT
    

RIGHT_NOT_PRESSED:
    CMP AL, 4DH + 80H           ;Check for right released
    JNE RIGHT_NOT_RELEASED           
    MOV moveDirectionRightC1, 0
    JMP CONT

CONT_HELP:
    JMP CONT

HELPER_JUMP:
    JMP DOWN_NOT_RELEASED

RIGHT_NOT_RELEASED:
    CMP AL, 4BH                 ;Check for left pressed
    JNE LEFT_NOT_PRESSED
    MOV moveDirectionLeftC1, 1
    JMP CONT

LEFT_NOT_PRESSED:
    CMP AL, 4BH + 80H           ;Check for left released
    JNE LEFT_NOT_RELEASED
    MOV moveDirectionLeftC1, 0
    JMP CONT

LEFT_NOT_RELEASED:
    CMP AL, 50H                 ;Check for down pressed
    JNE DOWN_NOT_PRESSED
    MOV moveDirectionDownC1, 1
    JMP CONT

DOWN_NOT_PRESSED:
    CMP AL, 50H + 80H           ;Check for down released
    JNE DOWN_NOT_RELEASED
    MOV moveDirectionDownC1, 0
    JMP CONT

DOWN_NOT_RELEASED:
    CMP AL, 11H                 ;CHECK UP PRESSED FOR CAR 2
    JNE W_NOT_PRESSED
    MOV moveDirectionUpC2, 1
    JMP CONT

W_NOT_PRESSED:
    CMP AL, 11H + 80H           ;CHECK UP RELEASED FOR CAR 2
    JNE W_NOT_RELEASED
    MOV moveDirectionUpC2, 0
    JMP CONT

W_NOT_RELEASED:
    CMP AL, 20H                 ;CHECK RIGHT PRESSED FOR CAR 2
    JNE D_NOT_PRESSED
    MOV moveDirectionRightC2, 1
    JMP CONT

D_NOT_PRESSED:
    CMP AL, 20H + 80H           ;CHECK RIGHT RELEASED FOR CAR 2
    JNE D_NOT_RELEASED
    MOV moveDirectionRightC2, 0
    JMP CONT

D_NOT_RELEASED:
    CMP AL, 1EH                 ;CHECK LEFT PRESSED FOR CAR 2
    JNE A_NOT_PRESSED
    MOV moveDirectionLeftC2, 1
    JMP CONT

A_NOT_PRESSED:
    CMP AL, 1EH + 80H           ;CHECK LEFT RELEASED FOR CAR 2
    JNE A_NOT_RELEASED
    MOV moveDirectionLeftC2, 0
    JMP CONT

A_NOT_RELEASED:
    CMP AL, 1FH                 ;CHECK DOWN PRESSED FOR CAR 2
    JNE S_NOT_PRESSED
    MOV moveDirectionDownC2, 1
    JMP CONT

S_NOT_PRESSED:
    CMP AL, 1FH + 80H           ;CHECK DOWN RELEASED FOR CAR 2
    JNE S_NOT_RELEASED
    MOV moveDirectionDownC2, 0
    JMP CONT

S_NOT_RELEASED:
    CMP AL,32H
    JNE M_NOT_PRESSED
    MOV POWCAR1,1
    JMP CONT
    
M_NOT_PRESSED:
    CMP AL,32H+80H
    JNE M_NOT_RELEASED
    MOV POWCAR1,0
    JMP CONT

M_NOT_RELEASED:
    CMP AL,10H
    JNE Q_NOT_PRESSED
    MOV POWCAR2,1
    JMP CONT

Q_NOT_PRESSED:
    CMP AL,10H+80H
    JNE Q_NOT_RELEASED
    MOV POWCAR2,0
    JMP CONT

Q_NOT_RELEASED:
    CMP AL, 1H                  ;Check for escape pressed
    JNE CONT
    MOV shouldExit, 1

CONT:
    MOV AL, 20H
    OUT 20H, AL
    IRET
OverRideInt9 ENDP


MAIN PROC FAR
    MOV AX ,@DATA
    MOV DS,AX

    ;;Handle interrupt 9 procedure
    CLI

    MOV AX, 3509h
    INT 21H

    MOV origIntOffset, BX
    MOV origIntSegment, ES
        
    PUSH DS
    MOV AX, CS
    MOV DS, AX
    MOV AX, 2509h
    LEA DX, OverRideInt9
    INT 21H
    POP DS

    STI


    MOV AX,0A000H
    MOV ES,AX

    ;GRAPHICS MODE
    MOV AH,0H
    MOV AL,13H
    INT 10H

    CALL FAR PTR ORIG1
    CALL FAR PTR CAR1
    CALL FAR PTR ORIG2
    CALL FAR PTR CAR2

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;FOR TRIAL
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    MOV DI,20000
    MOV DX,5
MMMMM:
    MOV CX,5
    MOV AL,0EH
    REP STOSB
    DEC dx
    ADD DI,315
    CMP DX,0
    JNZ MMMMM

    MOV DI,10000
    MOV DX,5
NNN:
    MOV CX,5
    MOV AL,5
    REP STOSB
    DEC dx
    ADD DI,315
    CMP DX,0
    JNZ NNN

    MOV DI,40200
    MOV DX,5
LLL:
    MOV CX,5
    MOV AL,3
    REP STOSB
    DEC DX
    ADD DI,315
    CMP DX,0
    JNZ LLL

        ;draw obstacle to test check colision procedure
;{
    mov cx,120
    mov dx,80
    obstacle1:
    MOV AH,0CH
    MOV AL,10   ;COLOR OF THE PIXEL
    INT 10H     ;Draw PixeL
    INC CX      ;MOVE ON PIXEL ON X AXIS      ;MOVE TO THE NEXT PIXEL COLOR
    CMP CX,160  ;CHECK IF I REACH THE END OF IMAGE'S RANGE ON THE X AXIS
    JNZ obstacle1
    MOV CX,120   ;RETURN TO THE BEGINNING POSITION ON X AXIS
    INC DX
    CMP DX,120  ;CHECK IF I REACH THE END OF IMAGE'S RANGE ON THE Y AXIS
    JNZ obstacle1
;}


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AGAIN:
CHECK: 

    CMP shouldExit, 01H             ;;CHECK IF THE EXIT KEY IS PRESSED

    JE AA2

    CMP moveDirectionUpC1, 1          ;;CHECK IF THE UP ARROW KEY IS PRESSED
    JNZ RIGHT1
    MOV AL,0
    MOV EXPECTEDSTATE1,AL
    CALL FAR PTR CheckColisionCar1 
    CMP CANMOVE1,0
    JZ RIGHT1  

    CALL FAR PTR RESETCAR1
    MOV STATE1,0
    MOV AX,320
    MOV DX,SPEED1
    MUL DX
    SUB CENTER1,AX
    CALL FAR PTR ORIG1                  
    CALL FAR PTR SPEEDUP1
    CALL FAR PTR SPEEDDOWN1
    CALL FAR PTR OBSTACLECAR1
    CALL FAR PTR CAR1

    JMP RIGHT1

AA2:JMP AA

RIGHT1:
    CMP moveDirectionRightC1, 1       ;;CHECK IF THE RIGHT ARROW KEY IS PRESSED
    JNZ LEFT1
    MOV AL,1
    MOV EXPECTEDSTATE1,AL
    CALL FAR PTR CheckColisionCar1 
    CMP CANMOVE1,0
    JZ LEFT1 
    CALL FAR PTR RESETCAR1
    MOV STATE1 ,1
    MOV AX,SPEED1
    ADD CENTER1,AX
    CALL FAR PTR ORIG1
    CALL FAR PTR SPEEDUP1
    CALL FAR PTR SPEEDDOWN1
    CALL FAR PTR OBSTACLECAR1
    CALL FAR PTR CAR1

    JMP LEFT1
AA: JMP EXIT1
    LEFT1: 
    CMP moveDirectionLeftC1, 1
    JNZ DOWN1

    MOV AL,2
    MOV EXPECTEDSTATE1,AL
    CALL FAR PTR CheckColisionCar1 
    CMP CANMOVE1,0
    JZ DOWN1

    CALL FAR PTR RESETCAR1
    MOV STATE1,2
    MOV AX,SPEED1
    SUB CENTER1,AX
    CALL FAR PTR ORIG1
    CALL FAR PTR SPEEDUP1
    CALL FAR PTR SPEEDDOWN1
    CALL FAR PTR OBSTACLECAR1
    CALL FAR PTR CAR1

    JMP DOWN1

EXIT1:
    JMP EXIT

DOWN1:
    CMP moveDirectionDownC1, 1
    JNZ UP2

    MOV AL,3
    MOV EXPECTEDSTATE1,AL
    CALL FAR PTR CheckColisionCar1 
    CMP CANMOVE1,0
    JZ UP2

    CALL FAR PTR RESETCAR1
    MOV STATE1,3
    MOV AX,320
    MOV DX,SPEED1
    MUL DX
    ADD CENTER1,AX
    CALL FAR PTR ORIG1
    CALL FAR PTR SPEEDUP1
    CALL FAR PTR SPEEDDOWN1
    CALL FAR PTR OBSTACLECAR1
    CALL FAR PTR CAR1

    JMP UP2



UP2:
    CMP moveDirectionUpC2, 1
    JNZ RIGHT2

    MOV AL,0
    MOV EXPECTEDSTATE2,AL
    CALL FAR PTR CheckColisionCar2 
    CMP CANMOVE2,0
    JZ RIGHT2 

    CALL FAR PTR RESETCAR2
    MOV STATE2,0
    MOV AX,320
    MOV DX,SPEED2
    MUL DX
    SUB CENTER2,AX
    CALL FAR PTR ORIG2
    CALL FAR PTR SPEEDUP2
    CALL FAR PTR SPEEDDOWN2
    CALL FAR PTR OBSTACLECAR2
    CALL FAR PTR CAR2
    JMP RIGHT2



RIGHT2:
    CMP moveDirectionRightC2, 1
    JNZ LEFT2

    MOV AL,1
    MOV EXPECTEDSTATE2,AL
    CALL FAR PTR CheckColisionCar2 
    CMP CANMOVE2,0
    JZ LEFT2

    CALL FAR PTR RESETCAR2
    MOV STATE2 ,1
    MOV AX,SPEED2
    ADD CENTER2,AX
    CALL FAR PTR ORIG2
    CALL FAR PTR SPEEDUP2
    CALL FAR PTR SPEEDDOWN2
    CALL FAR PTR OBSTACLECAR2
    CALL FAR PTR CAR2
    JMP LEFT2

AGAIN2:
    CMP POWCAR1,1
    JNE BBB
    CALL FAR PTR ACTIVATE_POWER_UP_CAR1
BBB:CMP POWCAR2,1
    JNE ASD
    CALL FAR PTR ACTIVATE_POWER_UP_CAR2
ASD:
    Delay
    JMP AGAIN

LEFT2:
    CMP moveDirectionLeftC2, 1
    JNZ DOWN2

    MOV AL,2
    MOV EXPECTEDSTATE2,AL
    CALL FAR PTR CheckColisionCar2 
    CMP CANMOVE2,0
    JZ DOWN2

    CALL FAR PTR RESETCAR2
    MOV STATE2,2
    MOV AX,SPEED2
    SUB CENTER2,AX
    CALL FAR PTR ORIG2
    CALL FAR PTR SPEEDUP2
    CALL FAR PTR SPEEDDOWN2
    CALL FAR PTR OBSTACLECAR2
    CALL FAR PTR CAR2
    JMP DOWN2

DOWN2:
    CMP moveDirectionDownC2, 1
    JNZ AGAIN2

    MOV AL,3
    MOV EXPECTEDSTATE2,AL
    CALL FAR PTR CheckColisionCar2 
    CMP CANMOVE2,0
    JZ DOWN2_5312

    CALL FAR PTR RESETCAR2
    MOV STATE2,3
    MOV AX,320
    MOV DX,SPEED2
    MUL DX
    ADD CENTER2,AX
    CALL FAR PTR ORIG2
    CALL FAR PTR SPEEDUP2
    CALL FAR PTR SPEEDDOWN2
    CALL FAR PTR OBSTACLECAR2
    CALL FAR PTR CAR2

DOWN2_5312:

    JMP AGAIN2

EXIT:

    ;Return Interrupt 9
    CLI
    mov ax, origIntOffset
    mov dx, origIntSegment
        
    push ds
    mov ds, ax

    mov ax, 2509h
    int 21h

    ; Re-enable interrupts
    pop ds
    STI


    ;MOV AH,0
    ;INT 16H
    MOV AH,4CH
    INT 21H
MAIN ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                ACTIVATE POWER UP FOR CAR1                                    ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ACTIVATE_POWER_UP_CAR1 PROC FAR
    CMP SPEEDUP_CAR1 , 1
    JNZ P12
    INC SPEED1
    DEC SPEEDUP_CAR1

P12:CMP SPEEDDOWN_CAR1,1
    JNZ P13

    CMP SPEED2,1
    JE CANCEL

    DEC SPEED2
    DEC SPEEDDOWN_CAR1
P13:CMP OBSTACLE_CAR1,1
    JNZ PASS1_1
    MOV OBSTACLE_CAR1,0

    CMP STATE1,0
    JNZ RIGHTOBS3

    MOV AX,320
    MOV CX,HEIGHT1
    MUL CX
    ADD AX,TOP1
    PUSH AX

    MOV DX,OBSHEIGHT
ROWOBSUP:
    MOV DI,AX
    MOV CX,OBSWIDTH
LOOP18:
    MOV AL,2
    STOSB
    LOOP LOOP18
    POP AX
    MOV BX,320
    ADD AX,BX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ ROWOBSUP
    POP AX

CANCEL:PASS1_1:JMP PASS1_2

RIGHTOBS3:
    CMP STATE1,1
    JNZ LEFTOBS3

    MOV CX,HEIGHT1
    MOV AX,TOP1
    SUB AX,CX
    PUSH AX

    MOV DX,OBSWIDTH
    MOV BX,320
COLOBSRIGHT:
    MOV DI,AX
    MOV CX,OBSHEIGHT
LOOP20:
    MOV AL,2
    PUSH DI
    STOSB
    POP DI
    ADD DI,BX
    LOOP LOOP20
    POP AX
    DEC AX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ COLOBSRIGHT
    POP AX

PASS1_2:JMP PASS1_3

LEFTOBS3: 
    CMP STATE1,2
    JNZ DOWNOBS3
    MOV CX,HEIGHT1
    MOV AX,TOP1
    ADD AX,CX
    PUSH AX

    MOV DX,OBSWIDTH
    MOV BX,320
COLOBSLEFT:
    MOV DI,AX
    MOV CX,OBSHEIGHT
LOOP22:
    MOV AL,2
    PUSH DI
    STOSB
    POP DI
    SUB DI,BX
    LOOP LOOP22
    POP AX
    INC AX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ COLOBSLEFT
    POP AX

PASS1_3:JMP PASS1

DOWNOBS3:
    CMP STATE1,3
    JNZ PASS1
    MOV AX,320
    MOV CX,HEIGHT2
    MUL CX
    MOV BX,TOP1
    SUB BX,AX
    PUSH BX
    MOV AX,BX

    MOV DX,OBSHEIGHT
    MOV BX,320
ROWOBSDOWN2:
    MOV DI,AX
    MOV CX,OBSWIDTH
LOOP32:
    MOV AL,2
    STOSB
    SUB DI,2
    LOOP LOOP32
    POP AX
    SUB AX,BX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ ROWOBSDOWN2
    POP AX

PASS1:
    RET
    ACTIVATE_POWER_UP_CAR1 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                ACTIVATE POWER UP FOR CAR2                                    ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ACTIVATE_POWER_UP_CAR2 PROC FAR

    CMP SPEEDUP_CAR2 , 1
    JNZ P22
    INC SPEED2
    DEC SPEEDUP_CAR2

P22:CMP SPEEDDOWN_CAR2,1
    JNZ P23

    CMP SPEED1,1
    JE CANCEL2
    DEC SPEED1
    DEC SPEEDDOWN_CAR2

P23:CMP OBSTACLE_CAR2,1
    JNZ PASS2_1
    MOV OBSTACLE_CAR2,0
    CMP STATE2,0
    JNZ RIGHTOBS4

    MOV AX,320
    MOV CX,HEIGHT2
    MUL CX
    ADD AX,TOP2
    PUSH AX

    MOV DX,OBSHEIGHT
ROWOBSUP2:
    MOV DI,AX
    MOV CX,OBSWIDTH
LOOP26:
    MOV AL,2
    STOSB
    LOOP LOOP26
    POP AX
    MOV BX,320
    ADD AX,BX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ ROWOBSUP2
    POP AX

CANCEL2:PASS2_1:JMP PASS2_2

RIGHTOBS4:
    CMP STATE2,1
    JNZ LEFTOBS4

    MOV CX,HEIGHT2
    MOV AX,TOP2
    SUB AX,CX
    PUSH AX

    MOV DX,OBSWIDTH
    MOV BX,320
COLOBSRIGHT2:
    MOV DI,AX
    MOV CX,OBSHEIGHT
LOOP28:
    MOV AL,2
    PUSH DI
    STOSB
    POP DI
    ADD DI,BX
    LOOP LOOP28
    POP AX
    DEC AX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ COLOBSRIGHT2
    POP AX

PASS2_2:JMP PASS2_3

LEFTOBS4: 
    CMP STATE2,2
    JNZ DOWNOBS4
    MOV CX,HEIGHT2
    MOV AX,TOP2
    ADD AX,CX
    PUSH AX

    MOV DX,OBSWIDTH
    MOV BX,320
COLOBSLEFT2:
    MOV DI,AX
    MOV CX,OBSHEIGHT
LOOP30:
    MOV AL,2
    PUSH DI
    STOSB
    POP DI
    SUB DI,BX
    LOOP LOOP30
    POP AX
    INC AX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ COLOBSLEFT2
    POP AX

PASS2_3:JMP PASS2

DOWNOBS4:
    CMP STATE2,3
    JNZ PASS2
    MOV AX,320
    MOV CX,HEIGHT1
    MUL CX
    MOV BX,TOP2
    SUB BX,AX
    PUSH BX
    MOV AX,BX

    MOV DX,OBSHEIGHT
    MOV BX,320
ROWOBSDOWN:
    MOV DI,AX
    MOV CX,OBSWIDTH
LOOP24:
    MOV AL,2
    STOSB
    SUB DI,2
    LOOP LOOP24
    POP AX
    SUB AX,BX
    PUSH AX
    DEC DX
    CMP DX,0
    JNZ ROWOBSDOWN
    POP AX

PASS2:
    RET

ACTIVATE_POWER_UP_CAR2 ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                        POWER UPS                                             ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                       SPEED UP CAR1                                          ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SPEEDUP1 PROC FAR

    CMP STATE1 , 0      
    JNZ RIGHT5

    MOV SI,TOP1
    MOV CX,WIDTH1
LOOP1:
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED
    INC SI
    LOOP LOOP1
    JMP EXIT2

RIGHT5:
    CMP STATE1 , 1
    JNZ LEFT5

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP2:
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED
    ADD SI,320
    LOOP LOOP2

    JMP EXIT2

LEFT5:
    CMP STATE1,2
    JNZ DOWN5

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP3: 
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED
    SUB SI,320
    LOOP LOOP3

    JMP EXIT2

DOWN5:
    CMP STATE1 , 3
    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP4:
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED
    DEC SI
    LOOP LOOP4

    JMP EXIT2

SPEED:
    MOV SPEEDUP_CAR1,1
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,0

EXIT2:
    RET
SPEEDUP1 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                      SPEED UP CAR2                                           ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SPEEDUP2 PROC FAR

    CMP STATE2 , 0      
    JNZ RIGHT51

    MOV SI,TOP2
    MOV CX,WIDTH2
LOOP5:
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED5
    INC SI
    LOOP LOOP5
    JMP EXIT3

RIGHT51:
    CMP STATE2 , 1
    JNZ LEFT51

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP6:
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED5
    ADD SI,320
    LOOP LOOP6

    JMP EXIT3

LEFT51:
    CMP STATE2,2
    JNZ DOWN51

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP7: 
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED5
    SUB SI,320
    LOOP LOOP7

    JMP EXIT3

DOWN51:
    CMP STATE2 , 3
    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP8:
    MOV AL,ES:[SI]
    CMP AL,0EH
    JE SPEED5
    DEC SI
    LOOP LOOP8

    JMP EXIT3

SPEED5:
    MOV SPEEDUP_CAR2,1
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,0
EXIT3:
    RET
SPEEDUP2 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                      SPEED DOWN CAR1                                         ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPEEDDOWN1 PROC FAR
    CMP STATE1 , 0      
    JNZ RIGHTDOWN1

    MOV SI,TOP1
    MOV CX,WIDTH1
LOOP9:
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED3
    INC SI
    LOOP LOOP9
    JMP EXIT4

RIGHTDOWN1:
    CMP STATE1 , 1
    JNZ LEFTDOWN1

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP10:
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED3
    ADD SI,320
    LOOP LOOP10

    JMP EXIT4

LEFTDOWN1:
    CMP STATE1,2
    JNZ DOWNDOWN1

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP11: 
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED3
    SUB SI,320
    LOOP LOOP11

    JMP EXIT4

DOWNDOWN1:
    CMP STATE1 , 3
    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP12:
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED3
    DEC SI
    LOOP LOOP12

    JMP EXIT4

SPEED3:
    CMP SPEED2 , 1
    JE EXIT4
    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,1
    MOV OBSTACLE_CAR1,0
EXIT4:
    RET
SPEEDDOWN1 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                      SPEED DOWN CAR2                                         ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPEEDDOWN2 PROC FAR
    CMP STATE2 , 0      
    JNZ RIGHT55

    MOV SI,TOP2
    MOV CX,WIDTH2
LOOP13:
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED6
    INC SI
    LOOP LOOP13
    JMP EXIT5

RIGHT55:
    CMP STATE2 , 1
    JNZ LEFT55

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP14:
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED6
    ADD SI,320
    LOOP LOOP14

    JMP EXIT5

LEFT55:
    CMP STATE2,2
    JNZ DOWN55

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP15: 
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED6
    SUB SI,320
    LOOP LOOP15

    JMP EXIT5

DOWN55:
    CMP STATE2 , 3
    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP16:
    MOV AL,ES:[SI]
    CMP AL,5
    JE SPEED6
    DEC SI
    LOOP LOOP16

    JMP EXIT5

SPEED6:
    CMP SPEED1,1
    JE EXIT5
    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,1
    MOV OBSTACLE_CAR2,0
EXIT5:
    RET

SPEEDDOWN2 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                  GENERATE OBSTACLE CAR1                                      ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

OBSTACLECAR1 PROC FAR
    CMP STATE1 , 0      
    JNZ RIGHTOBS

    MOV SI,TOP1
    MOV CX,WIDTH1
LOOP17:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS11
    INC SI
    LOOP LOOP17

    JMP EXIT6

OBS11:
    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,1

    JMP EXIT6

RIGHTOBS:
    CMP STATE1 , 1
    JNZ LEFTOBS

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP19:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS12
    ADD SI,320
    LOOP LOOP19
    JMP EXIT6
OBS12:

    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,1

    JMP EXIT6

LEFTOBS:
    CMP STATE1,2
    JNZ DOWNOBS

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP21:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS13
    SUB SI,320
    LOOP LOOP21
    JMP EXIT6

OBS13:

    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,1

    JMP EXIT6

DOWNOBS:
    MOV SI,TOP1
    MOV CX,WIDTH1
LOOP23:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS14
    DEC SI
    LOOP LOOP23
    JMP EXIT6

OBS14:
    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,1

EXIT6:
    RET

OBSTACLECAR1 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                  GENERATE OBSTACLE CAR2                                      ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OBSTACLECAR2 PROC FAR
    CMP STATE2 , 0      
    JNZ RIGHTOBS2

    MOV SI,TOP2
    MOV CX,WIDTH2
LOOP25:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS21
    INC SI
    LOOP LOOP25

    JMP EXIT7

OBS21:
    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,1

    JMP EXIT7

RIGHTOBS2:
    CMP STATE2 , 1
    JNZ LEFTOBS2

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP27:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS22
    ADD SI,320
    LOOP LOOP27
    JMP EXIT7

OBS22:
    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,1

    JMP EXIT7

LEFTOBS2:
    CMP STATE2,2
    JNZ DOWNOBS2

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP29:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS23
    SUB SI,320
    LOOP LOOP29
    JMP EXIT7

OBS23:

    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,1

    JMP EXIT7

DOWNOBS2:
    MOV SI,TOP2
    MOV CX,WIDTH2
LOOP31:
    MOV AL,ES:[SI]
    CMP AL,3
    JE OBS24
    DEC SI
    LOOP LOOP31
    JMP EXIT7

OBS24:

    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,1

EXIT7:
    RET

OBSTACLECAR2 ENDP
END MAIN