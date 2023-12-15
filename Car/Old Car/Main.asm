Delay MACRO 

MOV     CX, 00H
MOV     DX, 02240H
MOV     AH, 86H
INT     15H

ENDM


EXTRN Car1:FAR
EXTRN Car1:FAR
EXTRN RESETCAR1:FAR
EXTRN UpToRight:FAR
EXTRN UpToLeft:FAR
EXTRN DownToRight:FAR
EXTRN DownToLeft:FAR  
EXTRN RightToUp:FAR
EXTRN RightToDown:FAR
EXTRN LeftToUp:FAR
EXTRN LeftToDown:FAR 
PUBLIC Car1Position
PUBLIC Car2Position
PUBLIC OrigPixel1
PUBLIC State1
PUBLIC State2 


.MODEL LARGE
.STACK 64
.DATA
CAR1Position DW 0032H,0041H,0041H,001DH     ; CAR1 POSITION (X1,X2,Y1,Y2) 
;X1=> FIRST POSITION OF CAR1 ON THE X AXIS
;X2=> LAST POSITION OF CAR1 ON THE X AXIS
;Y1=> FIRST POSITION OF CAR1 ON THE Y AXIS
;Y2=> LAST POSITION OF CAR1 ON THE Y AXIS

INCLUDE Image1.INC ;THE HEX COLORS OF CAR1 (Size=540)
OrigPixel1 DB 540 DUP (?)
State1 DB 1H ,0H     ;2 BYTES (00 -> LEFT, 01 -> RIGHT, 11 -> UP, 10 -> DOWN)

Car2Position DW 0064H,0073H,0064H,0043H ; CAR2 POSITION (X1,X2,Y1,Y2)
;X1=> FIRST POSITION OF CAR2 ON THE X AXIS
;X2=> LAST POSITION OF CAR2 ON THE X AXIS
;Y1=> FIRST POSITION OF CAR2 ON THE Y AXIS
;Y2=> LAST POSITION OF CAR2 ON THE Y AXIS
HEIGHT EQU 36
Include Image2.inc ;THE HEX COLORS OF CAR2  (


State2 DB 0 , 0    ;(1 => vertical , 0 => horizontal) && SECOND BYTE (1=> FRONT TO THE RIGHT , 0=> FRONT TO THE LEFT)

origIntOffset dw 0
origIntSegment dw 0
shouldExit db 0
moveDirectionRight db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionUp db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionLeft db 0
moveDirectionDown db 0
numOfKeysPressed db 0

.CODE

OverRideInt9 PROC FAR
    IN AL, 60H      ;READ SCAN CODE

    CMP AL, 48H        ;CHECK UP KEY
    JNE UP_NOT_PRESSED
    MOV moveDirectionUp, 1
    JMP CONT

UP_NOT_PRESSED:
    CMP AL, 48H + 80H
    JNE UP_NOT_RELEASED
    MOV moveDirectionUp, 0
    JMP CONT

UP_NOT_RELEASED:
    CMP AL, 4DH                 ;Check for right pressed
    JNE RIGHT_NOT_PRESSED
    MOV moveDirectionRight, 1
    JMP CONT
    

RIGHT_NOT_PRESSED:
    CMP AL, 4DH + 80H           ;Check for right released
    JNE RIGHT_NOT_RELEASED           
    MOV moveDirectionRight, 0
    JMP CONT

CONT_HELP:
JMP CONT

HELPER_JUMP:
JMP DOWN_NOT_RELEASED

RIGHT_NOT_RELEASED:
    CMP AL, 4BH                 ;Check for left pressed
    JNE LEFT_NOT_PRESSED
    MOV moveDirectionLeft, 1
    JMP CONT

LEFT_NOT_PRESSED:
    CMP AL, 4BH + 80H           ;Check for left released
    JNE LEFT_NOT_RELEASED
    MOV moveDirectionLeft, 0
    JMP CONT

LEFT_NOT_RELEASED:
    CMP AL, 50H                 ;Check for down pressed
    JNE DOWN_NOT_PRESSED
    MOV moveDirectionDown, 1
    JMP CONT

DOWN_NOT_PRESSED:
    CMP AL, 50H + 80H           ;Check for down released
    JNE DOWN_NOT_RELEASED
    MOV moveDirectionDown, 0
    JMP CONT

DOWN_NOT_RELEASED:
    CMP AL, 1H                  ;Check for escape pressed
    JNE CONT
    MOV shouldExit, 1

CONT:
    MOV AL, 20H
    OUT 20H, AL
    IRET
OverRideInt9 ENDP



MAIN PROC FAR
MOV AX,@DATA
MOV DS,AX





;{
    ;CHANGE VIDEO MODE
    MOV AL,13H
    MOV AH,0
    INT 10H
    
;}

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CALL Far ptr Car1   ;DRAW CAR1
CHECK:
;CALL Car2   ;DRAW CAR2
;{
    ;THIS BLOCK IS RESPONSIBLE FOR MOVING CAR

    ;Get key pressed (do not wait for a key-AH:scancode,AL:ASCII) 

    ;COMPARE IF THE CHARACTER ENTERED IS ESCAPE CHARACTER
    CMP shouldExit, 01H   
    jz EXITP10 
    CMP moveDirectionUp, 1                  ;check if up arrow is pressed
    JNZ BACK1                   ;if not go check for down
    CALL FAR PTR RESETCAR1      ;if up is pressed delete the car, 
    MOV AX,WORD PTR State1      
    CMP AX,0100H
    JNE CheckLeft1
    Call FAR PTR RightToUp
    CheckLeft1:
    CMP AX,0H
    JNE ConinueAbove
    Call FAR PTR LeftToUp
    ConinueAbove:
    LEA DI,CAR1Position
    MOV AX,[DI+4]
    DEC AX
    MOV [DI+4],AX
    SUB AX,36
    MOV [DI+6],AX
    LEA SI,State1
    mov BL,01H
    mov BH,01H
    mov [SI],BL
    mov [SI+1],BH
    CALL Far ptr Car1   ;DRAW CAR1
    JMP BACK1
    CHECK1:JMP CHECK

    ;;;;;;;;;;;;;
    EXITP10: jmp EXITP11
    ;;;;;;;;;;;;

    BACK1: CMP moveDirectionDown, 1           ;check if down arrow is pressed
    JNZ RIGHT1
    CALL FAR PTR RESETCAR1
    MOV AX,WORD PTR State1
    CMP AX,0100H
    JNE CheckLeft2
    Call FAR PTR RightToDown
    CheckLeft2:
    CMP AX,0H
    JNE ConinueBelow
    Call FAR PTR LeftToDown
    ConinueBelow:
    LEA DI,CAR1Position
    MOV AX,[DI+4]
    INC AX
    MOV [DI+4],AX
    SUB AX,36
    MOV [DI+6],AX
    LEA SI,State1
    mov BL,01H
    mov BH,00H
    mov [SI],BL
    mov [SI+1],BH
    CALL Far ptr Car1   ;DRAW CAR1
    JMP RIGHT1

    EXITP11:JMP EXITP12

;;;;;;;;;this dosn't work
    RIGHT1: CMP moveDirectionRight, 1
    JNZ LEFT1
    CALL FAR PTR RESETCAR1
    MOV AX,WORD PTR State1
    CMP AX,0101H
    JNE CheckBelow1
    Call FAR PTR UpToRight
    CheckBelow1:
    CMP AX,0001H
    JNE ConinueRight
    Call FAR PTR DownToRight
    ConinueRight:
    LEA DI,CAR1Position
    MOV AX,[DI+4]
    inc AX
    MOV [DI+4],AX
    SUB AX,36d
    MOV [DI+6],AX
    LEA SI,State1
    mov BX,0100H
    mov [SI],BX
    CALL Far ptr Car1   ;DRAW CAR1
    JMP LEFT1
    EXITP12:JMP EXITP13
    ;THIS PART NEED TO MODIFY THIS IS FOR TRIAL
    ;IN THIS PART I CHANGE THE POSITION OF THE CAR AND THEN 
    ;ASSIGN THE NEW VALUES OF BEGINNING AND ENDING POSITION OF THE CAR IN THE MEMORY
    ;THEN REDRAW THE CAR WITH NEW POSITIOINS  
    LEFT1:
    CMP moveDirectionLeft, 1
    JNZ CheckP11
    CALL FAR PTR RESETCAR1
    MOV AX,WORD PTR State1
    CMP AX,0101H
    JNE CheckBelow2
    Call FAR PTR UpToLeft
    CheckBelow2:
    CMP AX,0001H
    JNE ConinueLeft
    Call FAR PTR DownToLeft
    ConinueLeft:
    LEA DI,CAR1Position
    MOV AX,[DI+4]
    DEC AX
    MOV [DI+4],AX
    SUB AX,36d
    MOV [DI+6],AX
    LEA SI,State1
    mov BX,0H
    mov [SI],BX
    CALL Far ptr Car1   ;DRAW CAR1
    CheckP11:
    Delay
    JMP CHECK1

;}


EXITP13:
    CALL FAR PTR RESETCAR1


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

    mov ah, 4CH
    int 21H

MAIN ENDP
;;;;;;;;;;;


;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;




END MAIN

