;get the pixel color in AL, CX = COL, DX = ROW
GetPixelColor MACRO

    MOV AH, 0DH
    MOV BH, 0
    INT 10H

ENDM

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



    TrackWidth    equ 12           ;half track width
    GenTrack      db  31h          ;the key to generate another track
    EndKey        db  1bh          ;the key to end
    StatingPointX dw  12           ;starting point in x-axis
    StatingPointY dw  170          ;starting point in y-axis
    XAxis         dw  0            ;x-axis for the middel of road
    YAxis         dw  0            ;y-axis for the middel point of road
    RandomValue   db  0            ;to generate the track -> if the number >=2 go right  number >=5 go left number >=8 go up else go down
    StepValue     dw  15           ;step value after getting the direction( how many steps will draw every loop)
    WindowHight   dw  190          ;the max hight of window  ****-->>>>>>>>>>> NOTE THAT THERE IS A STAUTS BAR SHOULD BE SUBTRACTED FROM TEH MAXHIGHT!!
    WindowWidth   dw  310          ;the max hight ofwindow
    LastDirection db  1            ;indicat the last direction if 0->up 1->right  2->left  3->down
    Status        db  0            ; 0->inside window   1->out of the border of window
    Intersect     db  0            ;0->no intersection  1->intersected
    CurrentBlock  db  0            ; the counter when it equel to RoadNum stop generat another number
    seed          dw  12         ;used in generating random nubmer
    notvalid      DB  0            ; flage to indicat if there is any intersection will happen before going to that dirction or will go out of window
    ArrDir        db  16 dup(?)
    FUp           db  0
    FLeft         db  0
    FRgiht        db  0
    FDown         db  0
    FLAGE         DB  0
    HalfStep      equ 8
    divider       equ  7

    ;;;Obstacles Varaibles
    GenerateObstaclesKey equ 32H       ;NUMBER 2 IN KEYBOARD
    ObstaclePosX  DW  0
    ObstaclePosY  DW  0
    OB_RIGHT      equ 2
    OB_LEFT       equ 3
    OB_UP         equ 1
    OB_DOWN       equ 4
    OB_NO_DIRECTION     equ 0
    OB_Direction  DW  OB_RIGHT         ;1 -> UP, 2 -> RIGHT, 3 -> LEFT, 4 -> DOWN, 0 -> NO DIRECTION
    OB_StartX     DW 0
    OB_StartY     DW 0
    OB_EndX       DW 0
    OB_EndY       DW 0

;---------------------------------------CAR DATA---------------------------------------
    dw '0'
    dw 0
    dw 0
    dd 0
    dw '0'
    dw 0
    dw 0
    dd 0
    INCLUDE IMAGE1.INC
    db '0'
    
    dw '0'
    dw 0
    dw 0
    dd 0
    INCLUDE IMAGE2.INC
    db '1'

        dw '0'
    dw 0
    dw 0
    dd 0

    db ?
    WIDTH1              DW 5                        ;WIDTH OF CAR1                  
    HEIGHT1             DW 9                       ;HEIGHT OF CAR1   
    WIDTH2              DW 5                        ;WIDTH OF CAR2
    HEIGHT2             DW 9                       ;HEIGHT OF CAR2
    CENTER1             DW 50 * 320 + 1           ;CENTER  OF CAR1
    CENTER2             DW 165 * 320 + 20           ;CENTER OF CAR2
    TOP1                DW ?                        ;INITIALIZED IN ORIGINAL PROCEDURE IN THE BEFINNING
    TOP2                DW ?                        ;INITIALIZED IN ORIGINAL PROCEDURE IN THE BEGINNING
    STATE1              DB 1                        ; 0 => UP    1 => RIGHT  2=> LEFT  3=>DOWN
    STATE2              DB 1                        ; 0 => UP    1 => RIGHT  2=> LEFT  3=>DOWN
    PIXELS1             DB 45 DUP (?)              ;ORIGINAL PIXELS IN THE PLACE OF CAR1
    PIXELS2             DB 45 DUP(?)               ;ORIGINAL PIXELS IN THE PLACE OF CAR2
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
    MOV  DX ,@data
    MOV  DS ,DX

CheckKey:
    mov  Status,0
    mov  Intersect,0

    MOV  AH ,00h                   ;check which key is being pressed
    INT  16h                       ;the pressed key in al
    CMP  al,GenTrack               ;if it enter so generate another track
    JZ   TrackRandom
    CMP  al ,EndKey                ;check if it ESC to end the porgram
    JZ   EndProgram                ;go to hlt
    CMP  AL, GenerateObstaclesKey     ;check if the track is finished and we want to generate obstacles
    JZ   GenerateOb
    JMP  CheckKey
TrackRandom:
    CALL far ptr GenerateTrack     ;call to generate porcedure
    CMP  CurrentBlock,25
    JL   TrackRandom
    CMP  Intersect ,1              ;if if intersected go and generate another one
    JZ   TrackRandom
    CMP  Status ,1                 ;if if intersected go and generate another one
    JZ   TrackRandom
    ;MOV  CL, RoadNum
    ;CMP  CurrentBlock,CL
    CALL FAR PTR ENDTRACK
    JZ   CheckKey
    JMP  CheckKey                  ;return to check key pressed
EndProgram:

GenerateOb:
    CALL FAR PTR GenerateObstacles  ;Generate Random Obstacles



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

    CALL FAR PTR ORIG2
    CALL FAR PTR CAR2
    CALL FAR PTR ORIG1
    CALL FAR PTR CAR1

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AGAIN:
;CAR_CHECK: 

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
    JMP CAR_EXIT

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

CAR_EXIT:

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

                        MOV AH, 0
                        INT 16H
                        MOV AH, 04CH
                        INT 21H

MAIN ENDP
    ;***********************************************************************
    ;generate random number
    ;***********************************************************************
GeneratRandomNumber proc near
                        MOV  AH, 2ch                   ;get sysytem time to get the dx mellisecond
                        INT  21h
                        MOV  AX, DX
                        MOV  Cx ,seed
                        xor  dx,dx
                        IMUL CX
                        inc  cx
                        mov  seed ,cx

    ;mov to ax to be diveded by 10 to generate random number form (0->9)
                        MOV  CX, 10                    ;the inverval of the random number  from (0 to bx)
                        xor  dx,dx
                        DIV  CX                        ;dx have the random number

                        MOV  RandomValue,DL            ;keep the random number in the variable RandomValue

                        ret
GeneratRandomNumber endp
    ;***********************************************************************
    ;generate a track go make 1-start vieo mode 2-random value then 3-go to one direction
    ;do it again untile the road number ==CurrentBlock
    ;Regester: AX
    ;***********************************************************************
GenerateTrack proc far
                        MOV  AX,StatingPointX          ;put the value of x-axis with inintial point
                        MOV  XAxis,AX

                        MOV  AX,StatingPointY          ;put the value of y-axis with inintial point
                        MOV  YAxis,AX

                        MOV  AH ,00                    ;video mode
                        MOV  AL,13H
                        INT  10H

                        MOV  AH ,08H                   ;write in page0
                        MOV  BH ,00
                        INT  10H
                        MOV  FUp,0
                        MOV  FRgiht,0
                        MOV  FLeft,0
                        MOV  FDown,0
                        mov  Intersect,0
                        MOV  CurrentBlock,0
                        mov  LastDirection,1
                        MOV  BX ,OFFSET ArrDir
                        mov  Status,0
                        call far ptr RightDirection    ;at the begain of the track mov up
    Road:
                        MOV  AX,0
                        ADD  AL, FUp
                        ADD  AL, FLeft
                        ADD  AL, FRgiht
                        ADD  AL, FDown

                        CMP  AX,4
                        JZ   EEXIT
                        MOV  FUp,0
                        MOV  FRgiht,0
                        MOV  FLeft,0
                        MOV  FDown,0
                        CMP  Intersect,1               ;make sure that there is no intersection
                        JZ   EEXIT
    ;if there return
                        CMP  Status,1                  ;make sure that NOT OUT OF WINDOW
                        JZ   EEXIT
    ; MOV  CL ,RoadNum
    ; CMP  CurrentBlock,CL               ;CHECK IF THE NUMBER OF STEPS NEEDED IS DONE
    ; JZ   EEXIT
                        PUSH BX
                        call GeneratRandomNumber
                        POP  BX
                        CMP  RandomValue,3             ; if(num<=2) move to Right
                        JlE  RRight
                        CMP  RandomValue,5             ; if(num<=5) move to Left
                        JlE  up
                        CMP  RandomValue,7             ; if(num<=8) move to UP
                        JlE  Left
                        CMP  RandomValue,9
                        JlE  Down
                        jmp  Road
    RRight:
                        jmp  Right
    EEXIT:
                        ret                            ; if(num==9) move to Right
    UP:
                        MOV  CX,XAxis
                        MOV  DX,YAxis
                        SUB  DX,StepValue
                        SUB  DX, 2*TrackWidth+3
                        mov  ax, 0

                        CALL FAR PTR CheckBefore       ;make sure that you can go this direction
                        CMP  FUp,1                     ;make sure that NOT OUT OF WINDOW
                        JZ   Down
                        MOV  [BX], BYTE PTR 0
                        INC  BX
                        PUSH BX
                        call far ptr UpDirection       ; calling move up
                        POP  BX
                        jmp  Road                      ;return to creat randam number again
    Down:
                        MOV  CX,XAxis
                        MOV  DX, YAxis
                        ADD  DX,StepValue
                        ADD  DX, 2*TrackWidth+3
                        mov  ax, 3

                        CALL FAR PTR CheckBefore       ;make sure that you can go this direction
                        CMP  FDown,1                   ;make sure that NOT OUT OF WINDOW
                        JZ   Left
                        MOV  [BX],BYTE PTR 3
                        INC  BX
                        PUSH BX
                        call far ptr DownDirection     ; calling move down
                        POP  BX
                        jmp  Road                      ;return to creat randam number again
    Left:
                        MOV  CX,XAxis
                        SUB  CX,StepValue
                        SUB  CX,2*TrackWidth+3
                        MOV  DX, YAxis
                        mov  ax, 2

                        CALL FAR PTR CheckBefore       ;make sure that you can go this direction
                        CMP  FLeft,1                   ;make sure that NOT OUT OF WINDOW
                        JZ   Right
                        MOV  [BX], BYTE PTR 2
                        INC  BX
                        PUSH BX
                        call far ptr LeftDirection
                        POP  BX
                        jmp  Road                      ;return to creat randam number again
    FROAD:
                        JMP  FAR PTR Road
    Right:
                        MOV  CX,XAxis
                        ADD  CX,StepValue
                        ADD  CX ,2*TrackWidth+3
                        MOV  DX, YAxis
                        mov  ax, 1

                        CALL FAR PTR CheckBefore
                        CMP  FRgiht,1
                        JZ   FROAD                     ;make sure that there is no intersection
                        MOV  [BX], BYTE PTR 1H
                        INC  BX
                        PUSH BX
                        call far ptr RightDirection    ; calling move up
                        POP  BX
                        jmp  Road                      ;return to creat randam number again
    EXIT:
                        ret
GenerateTrack endp
    ;*************************************************************************
    ;CHECK IF THE COLOR OF THE NEXT PIXEL IS COLORED WITH THE ROAD COLOR
    ;*************************************************************************
Check proc far
                        MOV  AH ,0DH                   ;get the color of the pixel in al
                        INT  10H
                        CMP  AL, 8                     ;same as red check Gray
                        jz   NO1
                        CMP  AL, 0EH                   ;same as red check Gray
                        jz   NO1
                        CMP  AL, 0fh                   ;same as red check Gray
                        jz   NO1
                        CMP  DX,WindowHight
                        JGE  NO1
                        CMP  CX,WindowWidth
                        JGE  NO1
                        CMP  DX,10
                        JlE  NO1
                        CMP  CX,10
                        JlE  NO1
                        ret
    NO1:
                        MOV  FLAGE,1
                        RET
Check endp
    ;***********************************************************************
    ;MAKE CHECK BEFORE GOING TO ANY DIRECTION( I SET DX AND CX BEFORE CALLING PROC)
    ;Regester: AX
    ;***********************************************************************
CheckBefore proc far
                        MOV  FLAGE,0
                        PUSH CX
                        PUSH DX
                        JMP  CON5
    LEFTFLAG3:
                        JMP  FAR PTR LEFTFLAG2
    RIGHTFLAGE3:
                        JMP  FAR PTR RIGHTFLAGE2
    CON5:
                        CMP  AX,0
                        JZ   UPFLAG2
                        CMP  AX,1
                        JZ   RIGHTFLAGE3
                        CMP  AX,2
                        JZ   LEFTFLAG3
                        JMP  DOWNFLAGE2

    UPFLAG2:            POP  DX
                        POP  CX
                        PUSH CX
                        PUSH DX
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   UPFLAG3
                        ADD  DX,HalfStep
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   UPFLAG3
                        SUB  DX, HalfStep
                        SUB  CX ,TrackWidth+3
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   UPFLAG3
                        ADD  CX ,2*TrackWidth+4
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   UPFLAG3
                        POP  DX
                        POP  CX
                        RET
    UPFLAG3:
                        JMP  FAR PTR UPFLAG
    DOWNFLAGE2:
                        POP  DX
                        POP  CX
                        PUSH CX
                        PUSH DX
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   DOWNFLAGE3
                        SUB  DX,HalfStep
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   DOWNFLAGE3
                        ADD  DX, HalfStep
                        SUB  CX ,TrackWidth+3
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   DOWNFLAGE3
                        ADD  CX ,2*TrackWidth+4
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   DOWNFLAGE3
                        POP  DX
                        POP  CX
                        RET
    DOWNFLAGE3:
                        JMP  FAR PTR DOWNFLAGE
    RIGHTFLAGE4:
                        JMP  FAR PTR RIGHTFLAGE
    RIGHTFLAGE2:
                        POP  DX
                        POP  CX
                        PUSH CX
                        PUSH DX
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   RIGHTFLAGE4
                        SUB  CX,HalfStep
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   RIGHTFLAGE
                        ADD  CX,HalfStep
                        SUB  DX ,TrackWidth+3
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   RIGHTFLAGE
                        ADD  DX ,2*TrackWidth+4
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   RIGHTFLAGE
                        POP  DX
                        POP  CX
                        RET
    LEFTFLAG2:
                        POP  DX
                        POP  CX
                        PUSH CX
                        PUSH DX
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   LEFTFLAG
                        ADD  CX,HalfStep
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   LEFTFLAG
                        SUB  CX,HalfStep
                        SUB  DX ,TrackWidth+3
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   LEFTFLAG
                        ADD  DX ,2*TrackWidth+4
                        CALL FAR PTR Check
                        CMP  FLAGE,1
                        JZ   LEFTFLAG
                        POP  DX
                        POP  CX
                        RET
    UPFLAG:
                        POP  DX
                        POP  CX
                        MOV  FUp,1                     ;move intersect to be 1 indicate thet there is intersection
                        ret
    RIGHTFLAGE:
                        POP  DX
                        POP  CX
                        MOV  FRgiht,1
                        ret
    LEFTFLAG:
                        POP  DX
                        POP  CX
                        MOV  FLeft,1
                        ret
    DOWNFLAGE:
                        POP  DX
                        POP  CX
                        MOV  FDown,1
                        ret
CheckBefore endp
    ;***********************************************************************
    ;GO RIGHT DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO RIGHT DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
RightDirection proc far
                        cmp  LastDirection,0           ;if the last direction is up it esay to go up
                        jz   GoUPRight

                        cmp  LastDirection,3           ;if the last direction is down we will  return
                        jz   farGoDownRight

                        cmp  LastDirection,1           ; if the last direction is right we will make Uturn
                        jz   farGoRight

                        cmp  LastDirection,2           ; if the last direction is left we will make Uturn
                        jz   FarExitRight
    FarExitRight:
                        ret
    farGoRight:
                        JMP  FAR PTR GoRight
    farGoDownRight:
                        jmp  far ptr GoDownRight
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUPRight:
                        CALL FAR PTR LDAndUR
    FixGoUPRight:
                        CALL FAR PTR FixURAndDR
                        jmp  GoRight                   ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDownRight:
                        CALL FAR PTR DRAndLU
                        JMP  FixGoDownRight
    fExitRight:
                        ret
    FixGoDownRight:
                        CALL FAR PTR FixURAndDR
                        jmp  GoRight                   ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRight:
                        MOV  CX,XAxis                  ;start from the middle
                        MOV  BX ,XAxis                 ;SAVE THE END POINT IN SI   X+STEPVALUE
                        ADD  BX,StepValue
    FirstLoopRight:
                        MOV  DX,YAxis                  ;start from the middle -width  going to ->middle +width
                        SUB  DX,TrackWidth
                        MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
    ;draw the wall left

                        CALL FAR PTR ColorWall         ; COLOR OF WALL IS RED
                        INC  DX
    SecondLoopRight:
                        JZ   fExitRight
                        CMP  SI ,TrackWidth-1
                        JNZ  M
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUE
    M:
                        CALL FAR PTR ColorRoad
    CONTINUE:
                        INC  DX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                        INC  SI                        ;INC counter
                        CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopRight
    ;draw the wall Right
                        CALL FAR PTR ColorWall         ; COLOR OF WALL IS RED
                        INC  CX                        ;GO UP BY dec the value of row
                        CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopRight
                        MOV  XAxis,BX                  ;set y-axis with the new value
                        JMP  ExitRight                 ;go to generte randam number agian
    ExitRight:
                        MOV  LastDirection ,1
                        INC  CurrentBlock              ;inc the counter of road blocks
                        ret
RightDirection endp
    ;***********************************************************************
    ;GO LEFT DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO LEFT DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
LeftDirection proc far
                        cmp  LastDirection,0           ;if the last direction is up it esay to go up
                        jz   GoUPLeft
                        cmp  LastDirection,3           ;if the last direction is down we will  return
                        jz   farGoDownLeft
                        cmp  LastDirection,1           ; if the last direction is right we will make Uturn
                        jz   farExitLeft
                        cmp  LastDirection,2           ; if the last direction is left we will make Uturn
                        jz   farGoLeft
    farExitLeft:
                        ret
    farGoLeft:
                        JMP  FAR PTR GoLeft
    farGoDownLeft:
                        jmp  FAR PTR GoDownLeft
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUPLeft:
                        CALL FAR PTR RDAndUL
    FixGoUPLeft:
                        CALL FAR PTR FixULAndDL
                        jmp  GoLeft                    ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDownLeft:
                        CALL FAR PTR DLAndRU
                        JMP  FixGoDownLeft
    FExitLeft:
                        ret
    FixGoDownLeft:
                        CALL FAR PTR FixULAndDL
                        jmp  GoLeft                    ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeft:
                        MOV  CX,XAxis                  ;start from the middle
                        MOV  BX ,XAxis                 ;SAVE THE END POINT IN BX   X+STEPVALUE
                        SUB  BX,StepValue
    FirstLoopLeft:
                        MOV  DX,YAxis                  ;start from the middle -width  going to ->middle +width
                        SUB  DX,TrackWidth
                        MOV  SI,0                      ;start a counter
    ;draw the wall left
                        CALL FAR PTR ColorWall
                        INC  DX
    SecondLoopLeft:
                        CMP  SI ,TrackWidth-1
                        JNZ  LEF
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUELEFT
    LEF:
                        CALL FAR PTR ColorRoad
    CONTINUELEFT:
                        INC  DX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                        INC  SI                        ;INC counter
                        CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopLeft
    ;draw the wall Right
                        CALL FAR PTR ColorWall
                        DEC  CX                        ;GO UP BY dec the value of row
                        CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopLeft
                        MOV  XAxis,BX                  ;set y-axis with the new value
                        JMP  ExitLeft                  ;go to generte randam number agian
    ExitLeft:
                        MOV  LastDirection ,2
                        INC  CurrentBlock              ;inc the counter of road blocks
                        ret
LeftDirection endp
    ;***********************************************************************
    ;GO UP DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO UP DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
UpDirection proc far
                        cmp  LastDirection,0           ;if the lst direction is up it esay to go up
                        jz   GoUp
                        cmp  LastDirection,3           ;if the last direction is down we will not return
                        jz   farExitUP
                        cmp  LastDirection,1           ; if the last direction is right we will make Uturn
                        jz   GoRightUp
                        cmp  LastDirection,2           ; if the last direction is left we will make Uturn
                        jz   farGoLeftUp
    farExitUP:
                        ret
    farGoLeftUp:
                        jmp  far ptr GoLeftUp
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUp:
                        MOV  BX,YAxis                  ;END point of row
                        SUB  BX,StepValue
                        MOV  DX,YAxis                  ;put the valus of y-axis ->row
    FirstLoopUP:
                        MOV  CX,XAxis                  ;start from the middle -width  to ->middle +width
                        SUB  CX,TrackWidth
                        MOV  SI,0                      ;restart counter
                        CALL FAR PTR ColorWall
                        INC  CX                        ;move to the next right pixel
    SecondLoopUP:
                        CMP  SI ,TrackWidth-1
                        JNZ  U
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUEUP
    U:
                        CALL FAR PTR ColorRoad
    CONTINUEUP:
                        INC  CX
                        INC  SI                        ;INC counter
                        CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopUP
                        CALL FAR PTR ColorWall
                        DEC  DX                        ;GO UP BY dec the value of row
                        CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopUP
                        MOV  YAxis,BX                  ;set y-axis with the new value
                        JMP  ExitUP                    ;go to generte randam number agian
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRightUp:
                        CALL FAR PTR DLAndRU
    FixGoRightUp:
                        CALL FAR PTR FixLUAndRU
                        jmp  GoUp                      ;go up some pixels
    FExitup:
                        ret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeftUp:
                        CALL FAR PTR DRAndLU           ;if the end point =0 exit loop
    FixGoLeftUp:
                        cALL FAR PTR FixLUAndRU
                        jmp  GoUp                      ;go up some pixels
    ExitUP:
                        MOV  LastDirection ,0
                        INC  CurrentBlock              ;inc the counter of road blocks
                        ret
UpDirection endp
    ;***********************************************************************
    ;GO DOWN DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO DOWN DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
DownDirection proc far
                        cmp  LastDirection,0           ;if the lst direction is up it esay to go up
                        jz   farExiTDown
                        cmp  LastDirection,3           ;if the last direction is down we will not return
                        jz   GoDown
                        cmp  LastDirection,1           ; if the last direction is right we will make Uturn
                        jz   GoRightDown
                        cmp  LastDirection,2           ; if the last direction is left we will make Uturn
                        jz   farGoLeftDown
    farExitDown:
                        RET
    farGoLeftDown:
                        jmp  far ptr GoLeftDown
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDown:
                        MOV  BX,YAxis                  ;END point of row
                        add  BX,StepValue
                        MOV  DX,YAxis                  ;put the valus of y-axis ->row
    FirstLoopDown:
                        MOV  CX,XAxis                  ;start from the middle -width  to ->middle +width
                        SUB  CX,TrackWidth
                        MOV  SI,0                      ;restart counter
    ;draw the wall left
                        JZ   farExitDown
                        CALL FAR PTR ColorWall
                        INC  CX                        ;move to the next right pixel
    SecondLoopDown:
                        CMP  SI ,TrackWidth-1
                        JNZ  DO
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUEDOWN
    DO:
                        CALL FAR PTR ColorRoad
    CONTINUEDOWN:
                        INC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                        INC  SI                        ;INC counter
                        CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopDown
    ;draw the wall Right
                        CALL FAR PTR ColorWall
                        INC  DX                        ;GO UP BY dec the value of row
                        CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopDown
                        MOV  YAxis,BX                  ;set y-axis with the new value
                        JMP  ExiTDown                  ;go to generte randam number agian
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRightDown:
                        CALL FAR PTR RDAndUL
    FixGoRightDwon:
                        CALL FAR PTR FixLDAndRD
                        jmp  GoDown
    fExitDown:
                        ret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeftdown:
                        cALL FAR PTR LDAndUR
    FixGoLeftdown:
                        CALL FAR PTR FixLDAndRD
                        jmp  GoDown
    EXITDown:
                        MOV  LastDirection ,3
                        INC  CurrentBlock
                        ret
DownDirection endp
    ;***********************************************************************
    ;Drow a pixel with the road color (Gray) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoad PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,8                     ;gray
                        INT  10H
                        RET
ColorRoad ENDP
    ;***********************************************************************
    ;Drow a pixel with the wall color (Yellow) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorWall PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,0eh                   ;yellow
                        INT  10H
                        RET
ColorWall ENDP
    ;***********************************************************************
    ;Drow a pixel with the line color (White) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoadLanes PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,0fh                   ;white
                        INT  10H
                        RET
ColorRoadLanes ENDP
    ;***********************************************************************
    ;Drow a pixel with the wall color (red) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoadEnd PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,4h                    ;red
                        INT  10H
                        RET
ColorRoadEnd ENDP
    ;****************************************************************************
    ;TO DRAW TURN IN BOTH OF (LEFT AFTER DOWN  ) OR(UP AFTER RIGHT )
    ;Regester:DX,CX,BX
    ;****************************************************************************
DLAndRU PROC FAR
                        MOV  DX ,YAxis
                        MOV  BL,TrackWidth
                        MOV  BH ,0
    DLRU1:
                        MOV  CX,XAxis                  ;     **********
                        MOV  BH ,0                     ;     **********
    DLRU2:                                             ;     **********
                        CALL FAR PTR ColorRoad         ;***************    THIS LINE  MADE BY FIXDLAndRU
                        INC  CX                        ;***************    THIS LINE  MADE BY FIXDLAndRU
                        INC  BH                        ;*************   ---
                        CMP  BH, BL                    ;***********        | --> DLAndRU
                        JNZ  DLRU2                     ;********      -----
                        CALL FAR PTR ColorWall
                        DEC  BL
                        INC  DX
                        CMP  BL,0
                        JNZ  DLRU1
                        ret
DLAndRU ENDP
    ;****************************************************************************
    ;TO DRAW THE TURN IN BOTH OF (DOWN AFTER RIGHT  ) OR(LEFT AFTER UP )
    ;Regester:DX,CX,BX
    ;****************************************************************************
RDAndUL PROC FAR
                        MOV  DX ,YAxis
                        MOV  BL,TrackWidth
                        MOV  BH ,0
    RDUL1:
                        MOV  CX,XAxis
                        MOV  BH ,0
    RDUL2:
                        CALL FAR PTR ColorRoad
                        INC  CX
                        INC  BH
                        CMP  BH, BL
                        JNZ  RDUL2
                        CALL FAR PTR ColorWall
                        DEC  BL
                        DEC  DX
                        CMP  BL,0
                        JNZ  RDUL1
                        RET
RDAndUL ENDP
    ;****************************************************************************
    ;TO DRAW  TURN IN BOTH OF (RIGHT AFTER DOWN  ) OR(UP AFTER LEFT )
    ;Regester:DX,CX,BX
    ;****************************************************************************
DRAndLU PROC FAR
                        MOV  CX ,XAxis
                        MOV  BL,TrackWidth
                        MOV  BH ,0
    DRLU1:
                        MOV  DX,YAxis
                        MOV  BH ,0
    DRLU2:
                        CALL FAR PTR ColorRoad
                        INC  DX
                        INC  BH
                        CMP  BH, BL
                        JNZ  DRLU2
                        CALL FAR PTR ColorWall
                        DEC  BL
                        DEC  CX
                        CMP  BL,0
                        JNZ  DRLU1
                        RET
DRAndLU ENDP
    ;****************************************************************************
    ;TO DRAW THE ANGEL OF TURN IN BOTH OF (DOWN AFTER LEFT  ) OR(RIGHT AFTER UP )
    ;Regester:DX,CX,BX
    ;****************************************************************************
LDAndUR PROC FAR
                        MOV  CX,XAxis
                        MOV  BL,TrackWidth
                        MOV  BH ,0
    LDRU1:
                        MOV  DX , YAxis
                        MOV  BH ,0
    LDRU2:
                        CALL FAR PTR ColorRoad
                        DEC  DX
                        INC  BH
                        CMP  BH, BL
                        JNZ  LDRU2
                        CALL FAR PTR ColorWall
                        DEC  BL
                        DEC  CX
                        CMP  BL,0
                        JNZ  LDRU1
                        RET
LDAndUR ENDP
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (UP AFTER LEFT  ) OR(UP AFTER RIGHT )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixLUAndRU PROC FAR
                        MOV  SI,0
                        MOV  DX,YAxis
                        MOV  BX,YAxis
                        SUB  BX,TrackWidth
    LURU1:
                        MOV  CX,XAxis
                        CMP  LastDirection,1
                        JNZ  RU
                        ADD  CX,TrackWidth
    RU:
                        MOV  SI,0
    LURU2:
                        CMP  SI ,1
                        JGE  FLU
                        CMP  LastDirection,2
                        JZ   WALL
                        CALL FAR PTR ColorWall
                        JMP  ConLU
    WALL:
                        CALL FAR PTR ColorRoadLanes
                        JMP  ConLU
    FLU:
                        CALL FAR PTR ColorRoad
    ConLU:
                        DEC  CX
                        INC  SI
                        CMP  SI,TrackWidth
                        JNZ  LURU2
                        CMP  LastDirection,2
                        JZ   LINES
                        CALL FAR PTR ColorRoadLanes
                        JMP  CON
    LINES:
                        CALL FAR PTR ColorWall
    CON:
                        DEC  DX
                        CMP  DX,BX
                        JNZ  LURU1
                        MOV  YAxis,BX
                        RET
FixLUAndRU endp
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (DOWN AFTER LEFT  ) OR(DOWN AFTER RIGHT )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixLDAndRD PROC FAR
                        MOV  SI,0
                        MOV  DX,YAxis
                        MOV  BX,YAxis
                        ADD  BX,TrackWidth
    LDRD1:
                        MOV  CX,XAxis
                        CMP  LastDirection,2
                        JNZ  FixLD
                        SUB  CX,TrackWidth
    FixLD:
                        MOV  SI,0
    LDRD2:
                        CMP  SI ,1
                        JGE  FRD
                        CMP  LastDirection,1
                        JZ   WALL2
                        CALL FAR PTR ColorWall
                        JMP  ConLD
    WALL2:
                        CALL FAR PTR ColorRoadLanes
                        JMP  ConLD
    FRD:
                        CALL FAR PTR ColorRoad
    ConLD:
                        INC  CX
                        INC  SI
                        CMP  SI,TrackWidth
                        JNZ  LDRD2
                        CMP  LastDirection,1
                        JZ   LINES2
                        CALL FAR PTR ColorRoadLanes
                        JMP  CON2
    LINES2:
                        CALL FAR PTR ColorWall
    CON2:
                        INC  DX
                        CMP  DX,BX
                        JNZ  LDRD1
                        MOV  YAxis,BX
                        RET
FixLDAndRD endp
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (RIGHT AFTER UP  ) OR(RIGHT AFTER DOWN )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixURAndDR PROC FAR
                        MOV  SI,0
                        MOV  CX,XAxis
                        MOV  BX,XAxis
                        ADD  BX,TrackWidth
    URDR1:
                        MOV  DX,YAxis
                        CMP  LastDirection,0
                        JNZ  FixUR
                        SUB  DX,TrackWidth
    FixUR:
                        MOV  SI,0
    URDR2:
                        CMP  SI ,1
                        JGE  FUR
                        CMP  LastDirection,3
                        JZ   WALL3
                        CALL FAR PTR ColorWall
                        JMP  ConUR
    WALL3:
                        CALL FAR PTR ColorRoadLanes
                        JMP  ConUR
    FUR:
                        CALL FAR PTR ColorRoad
    ConUR:
                        INC  DX
                        INC  SI
                        CMP  SI,TrackWidth
                        JNZ  URDR2
                        CMP  LastDirection,3
                        JZ   LINES3
                        CALL FAR PTR ColorRoadLanes
                        JMP  CON3
    LINES3:
                        CALL FAR PTR ColorWall
    CON3:
                        INC  CX
                        CMP  CX,BX
                        JNZ  URDR1
                        MOV  XAxis,BX
                        RET
FixURAndDR endp
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (RIGHT AFTER UP  ) OR(RIGHT AFTER DOWN )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixULAndDL PROC FAR
                        MOV  SI,0
                        MOV  CX,XAxis
                        MOV  BX,XAxis
                        SUB  BX,TrackWidth
    ULDL1:
                        MOV  DX,YAxis
                        CMP  LastDirection,0
                        JNZ  FixUL
                        SUB  DX,TrackWidth
    FixUL:
                        MOV  SI,0
    ULDL2:
                        CMP  SI ,1
                        JGE  FUL
                        CMP  LastDirection,3
                        JZ   WALL4
                        CALL FAR PTR ColorWall
                        JMP  ConUL
    WALL4:
                        CALL FAR PTR ColorRoadLanes
                        JMP  ConUL
    FUL:
                        CALL FAR PTR ColorRoad
    ConUL:
                        INC  DX
                        INC  SI
                        CMP  SI,TrackWidth
                        JNZ  ULDL2
                        CMP  LastDirection,3
                        JZ   LINES4
                        CALL FAR PTR ColorRoadLanes
                        JMP  CON4
    LINES4:
                        CALL FAR PTR ColorWall
    CON4:
                        DEC  CX
                        CMP  CX,BX
                        JNZ  ULDL1
                        MOV  XAxis,BX
                        RET
FixULAndDL endp
    ;****************************************************************************
    ;DRAW A RED LINES INDICATE THE END OF TRACK ACCORDING TO THA LAST DIRECTION
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
ENDTRACK PROC FAR
                        CMP  LastDirection,0
                        JZ   LUP
                        CMP  LastDirection,1
                        JZ   LRIGH
                        CMP  LastDirection,2
                        JZ   LLEFT
                        JMP  LDOWN
    LUP:
                        MOV  BX,YAxis
                        SUB  BX,1
                        MOV  DX,YAxis
    LastLoopUP:
                        MOV  CX,XAxis
                        SUB  CX,TrackWidth
                        MOV  SI,0
    LastSecondLoopUP:
                        CALL FAR PTR ColorRoadEnd
                        INC  CX
                        INC  SI
                        CMP  SI,2*TrackWidth+1
                        JNZ  LastSecondLoopUP
                        DEC  DX
                        CMP  DX,BX
                        JNZ  LastLoopUP
                        MOV  YAxis,BX
                        JMP  LastExit
    LRIGH:
                        MOV  CX,XAxis
                        MOV  BX ,XAxis
                        ADD  BX,1
    LastFirstLoopRight:
                        MOV  DX,YAxis
                        SUB  DX,TrackWidth
                        MOV  SI,0
    LastSecondLoopRight:
                        CALL FAR PTR ColorRoadEnd
                        INC  DX
                        INC  SI
                        CMP  SI,2*TrackWidth+1
                        JNZ  LastSecondLoopRight
                        INC  CX
                        CMP  CX,BX
                        JNZ  LastFirstLoopRight
                        MOV  XAxis,BX
                        JMP  LastExit
    LLEFT:
                        MOV  CX,XAxis
                        MOV  BX ,XAxis
                        SUB  BX,1
    LastFirstLoopLeft:
                        MOV  DX,YAxis
                        SUB  DX,TrackWidth
                        MOV  SI,0
    LastSecondLoopLeft:
                        CALL FAR PTR ColorRoadEnd
                        INC  DX
                        INC  SI
                        CMP  SI,2*TrackWidth+1
                        JNZ  LastSecondLoopLeft
                        DEC  CX
                        CMP  CX,BX
                        JNZ  LastFirstLoopLeft
                        MOV  XAxis,BX
                        JMP  ExitLeft
    LDOWN:
                        MOV  BX,YAxis
                        add  BX,1
                        MOV  DX,YAxis
    LastFirstLoopDown:
                        MOV  CX,XAxis
                        SUB  CX,TrackWidth
                        MOV  SI,0
    ;move to the next right pixel
    LastSecondLoopDown:
                        CALL FAR PTR ColorRoadEnd
                        INC  CX
                        INC  SI
                        CMP  SI,2*TrackWidth+1
                        JNZ  LastSecondLoopDown
                        INC  DX
                        CMP  DX,BX
                        JNZ  LastFirstLoopDown
                        MOV  YAxis,BX
                        JMP  ExiTDown
    LastExit:
                        RET
ENDTRACK ENDP

RandomObestical PROC FAR
                        MOV  BX ,offset ArrDir
                        RET
RandomObestical ENDP


virticalObstical PROC far

                        RET
virticalObstical ENDP

HorizontalObstical PROC far

                        RET
HorizontalObstical ENDP

;description: generate obstacles on the track by a certain percentage
;
GenerateObstacles PROC FAR

    PUSH AX
    PUSH ES
    PUSH BX
    PUSH DX
    PUSH CX

    MOV OB_Direction, OB_RIGHT          ;INITIAL DIRECTION IS RIGHT
    
    MOV AX, StatingPointX               ;Set the OB_StartX with the starting pointX
    MOV OB_StartX, AX                   

    MOV AX, StatingPointY               ;Set the OB_StartY with the starting pointY
    MOV OB_StartY, AX


;;loop to get a component in the track then draw obstacles in it then get then next component and so on, until the end
GENERATE_NEW_RANDOM_OB:
    CALL FAR PTR GetEndOfCurrentTrackComp           ;GET END OF CURRENT TRACK COMP AND STORE IN OB_EndX, OB_EndY
    
    CALL GeneratRandomNumber                        ;generates a random variable between 0 - 9

    CMP RandomValue, 7                              ;CHECK IF THE RANDOM VALUE IS GREATER THAN 6 THEN DON'T DRAW AN OBSTACLE
    JG OB_CONT
    
    CALL FAR PTR DrawRandomObstacle                 ;Draw A random obstacle in this segment of the track

    OB_CONT:
    CALL FAR PTR GetNextDirection                   ;Get the next direction on the track

    MOV AX, OB_EndX                                 
    MOV OB_StartX, AX                               ;Update the start X of the current track comp

    MOV AX, OB_EndY
    MOV OB_StartY, AX                               ;Update the start Y of the current track comp
                       
    CMP OB_Direction, OB_NO_DIRECTION               ;Check if there are no available directions (except the last direction I came from)
    JNE GENERATE_NEW_RANDOM_OB

    POP CX
    POP DX
    POP BX
    POP ES
    POP AX

    RET
GenerateObstacles ENDP


;description: draw an obstacle on the current component of the track
;
;
DrawRandomObstacle PROC FAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CMP OB_Direction, OB_UP                         ;check if the direction is vertical or horizontal
    JE VERTICAL_DIR
    CMP OB_Direction, OB_DOWN
    JE VERTICAL_DIR


    HORIZONTAL_DIR:

    MOV BL, RandomValue                             ;store the random variable
    MOV BH, 0
    MOV CX, OB_StartX                               ;store the start X into CX 
    MOV DX, OB_EndX                                 ;store the end X  into DX
    CALL FAR PTR GenerateRandomNumBetTwoNums        ;Generate a random number between start X and end X

    MOV ObstaclePosX, AX                            ;Store the generated random X coordinates into the obstacle pos X

    MOV BL, RandomValue                             ;store the random variable
    MOV BH, 0
    MOV CX, OB_StartY
    SUB CX, 9                                       ;Store the starting Y coordinates in CX
    MOV DX, OB_StartY
    ADD DX, 9                                       ;Store the ending Y coordinates in DX
    CALL FAR PTR GenerateRandomNumBetTwoNums        ;generates a random number between the starting and the ending Y coordinates

    MOV ObstaclePosY, AX                            ;Store the generated Y coordinates into the obstacle pos Y
    JMP DRAW_OBSTACLE                               ;Jmp to draw the obstacle

    VERTICAL_DIR:
    
    MOV BL, RandomValue                             ;store the random variable
    MOV BH, 0
    MOV CX, OB_StartY                               ;store the start Y into CX                                               
    MOV DX, OB_EndY                                 ;store the end Y  into DX
    CALL FAR PTR GenerateRandomNumBetTwoNums        ;generates a random number between the starting and the ending Y coordinates

    MOV ObstaclePosY, AX                            ;Store the generated Y coordinates into the obstacle pos Y

    MOV BL, RandomValue                             ;store the random variable
    MOV BH, 0
    MOV CX, OB_StartX                   
    SUB CX, 8                                       ;Store the starting X coordinates in CX
    MOV DX, OB_StartX
    ADD DX, 8                                       ;Store the ending X coordinates in DX
    CALL FAR PTR GenerateRandomNumBetTwoNums        ;generates a random number between the starting and the ending X coordinates

    MOV ObstaclePosX, AX                            ;Store the generated X coordinates into the obstacle pos X
    JMP DRAW_OBSTACLE

    DRAW_OBSTACLE:

    CALL FAR PTR DrawObstacle                       ;Draw the obstacle using the generated random values in ObstaclePosX, and ObstaclePosY


    POP DX
    POP CX
    POP BX
    POP AX

    RET

DrawRandomObstacle ENDP

;description: generates a random value between two random values in CX, DX given a third value IN BX
;the randomv value at the end would be in AX
;the equation is -> ((X - Y) / 7) * Z + Y, where X is the bigger value and Y is the lower value and Z is the random value
GenerateRandomNumBetTwoNums PROC FAR
    PUSH BX
    PUSH CX
    PUSH DX

    CMP CX, DX              ;Compare CX, DX to see which is bigger
    JL DX_BIGGER            ;if DX is bigger then go and swap them
    JMP CONT_GRNBTN         ;if CX is bigger then its okay

DX_BIGGER:
    XCHG DX, CX             ;Swap DX, CX

CONT_GRNBTN:
    ADD DX, 3
    SUB CX, 3

    SUB CX, DX              ;Subtract DX (smaller one) from CX
    MOV AX, CX              ;Move CX to AX
    MOV CX, 7               ;Set CX with 7 to divide by it
    PUSH DX                 ;Store the initial value of DX

    MOV DX, 0               ;Set DX with 0 to divide
    DIV CX                  ;Divide the difference between Start and End by 7 (stored in CX)

    ADD AH, 0
    MOV DX, 0               ;Set DX with 0 to multiply
    MUL BX                  ;Multiply the value in AX with the Random Value

    POP DX                  ;Restore DX
    ADD AX, DX              ;Add AX ,after performing the above instructions on it, to DX and store in AX


    POP DX
    POP CX
    POP BX

    RET
GenerateRandomNumBetTwoNums ENDP

;description
GetNextDirection PROC FAR
    
    PUSH CX
    PUSH DX
    PUSH AX

OB_CHECK_UP:
    CMP OB_Direction, OB_DOWN       ;CHECK TO AVOID THE DIRECTION WE CAME FROM
    JE OB_CHECK_RIGHT               ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
    MOV CX, OB_EndX                 ;MOVE TO CX THE X VALUE OF THE END PIXEL
    MOV DX, OB_EndY                 ;MOVE TO DX THE Y VALUE OF THE END PIXEL
    SUB DX, 4                       ;SUB 3 FROM Y TO CHECK THE PIXEL
    GetPixelColor                   ;GET THE PIXEL COLOR
    CMP AL, 0FH                     ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
    JNE OB_CHECK_RIGHT              ;IF NOT JMP TO NEXT CHECK
    MOV OB_Direction, OB_UP
    JMP OB_EXIT                     ;EXIT BEC WE FOUND THE DIRECTION


OB_CHECK_RIGHT:
    CMP OB_Direction, OB_LEFT      ;CHECK TO AVOID THE DIRECTION WE CAME FROM
    JE OB_CHECK_LEFT                ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
    MOV CX, OB_EndX                 ;MOVE TO CX THE X VALUE OF THE END PIXEL
    MOV DX, OB_EndY                 ;MOVE TO DX THE Y VALUE OF THE END PIXEL
    ADD CX, 4                       ;ADD 3 TO Y TO CHECK THE PIXEL
    GetPixelColor                   ;GET THE PIXEL COLOR
    CMP AL, 0FH                     ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
    JNE OB_CHECK_LEFT               ;IF NOT JMP TO NEXT CHECK
    MOV OB_Direction, OB_RIGHT
    JMP OB_EXIT                     ;EXIT BEC WE FOUND THE DIRECTION

OB_CHECK_LEFT:
    CMP OB_Direction, OB_RIGHT       ;CHECK TO AVOID THE DIRECTION WE CAME FROM
    JE OB_CHECK_DOWN                ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
    MOV CX, OB_EndX                 ;MOVE TO CX THE X VALUE OF THE END PIXEL
    MOV DX, OB_EndY                 ;MOVE TO DX THE Y VALUE OF THE END PIXEL
    SUB CX, 4                       ;SUB 3 FROM X TO CHECK THE PIXEL
    GetPixelColor                   ;GET THE PIXEL COLOR
    CMP AL, 0FH                     ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
    JNE OB_CHECK_DOWN               ;IF NOT JMP TO NEXT CHECK
    MOV OB_Direction, OB_LEFT
    JMP OB_EXIT                     ;EXIT BEC WE FOUND THE DIRECTION

OB_CHECK_DOWN:
    CMP OB_Direction, OB_UP       ;CHECK TO AVOID THE DIRECTION WE CAME FROM
    JE OB_CHECK_END                 ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
    MOV CX, OB_EndX                 ;MOVE TO CX THE X VALUE OF THE END PIXEL
    MOV DX, OB_EndY                 ;MOVE TO DX THE Y VALUE OF THE END PIXEL
    ADD DX, 4                       ;ADD 3 TO Y TO CHECK THE PIXEL
    GetPixelColor                   ;GET THE PIXEL COLOR
    CMP AL, 0FH                     ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
    JNE OB_CHECK_END                ;IF NOT JMP TO NEXT CHECK
    MOV OB_Direction, OB_DOWN
    JMP OB_EXIT                     ;EXIT BEC WE FOUND THE DIRECTION

OB_CHECK_END:
    MOV OB_Direction, OB_NO_DIRECTION
    JMP OB_EXIT

OB_EXIT:

    POP AX
    POP DX
    POP CX

    RET

GetNextDirection ENDP

;description: start from OB_Start then go along the white line to the next component
;
GetEndOfCurrentTrackComp PROC FAR

    PUSH DX
    PUSH CX
    PUSH BX
    PUSH AX

    MOV CX, OB_StartX               ;move the start X value to CX
    MOV DX, OB_StartY               ;move the start Y vallue to DX

;Ckeck what is the direction to go along
    CMP OB_Direction, OB_RIGHT
    JE  GET_END_RIGHT
    CMP OB_Direction, OB_UP
    JE GET_END_UP
    CMP OB_Direction, OB_DOWN
    JE GET_END_DOWN
    CMP OB_Direction, OB_LEFT
    JE GET_END_LEFT

;Go along the Up direction and loop over the white line until 
;there are no more white pixels so we know we reached the end of this component
GET_END_UP:
    DEC DX              ;go up one pixel
    GetPixelColor       ;get the pixel color
    CMP AL, 0FH         ;check if it is white
    JE GET_END_UP       ;if it is white loop again
    INC DX              ;if it is not white then return to the last white pixel and exit
    JMP T_CONT  

GET_END_RIGHT:
    INC CX              ;go right one pixel
    GetPixelColor       ;get the pixel color
    CMP AL, 0FH         ;check if it is white
    JE GET_END_RIGHT    ;if it is white loop again
    DEC CX              ;if it is not white then return to the last white pixel and exit
    JMP T_CONT

GET_END_LEFT:
    DEC CX              ;go left one pixel
    GetPixelColor       ;get the pixel color
    CMP AL, 0FH         ;check if it is white
    JE GET_END_LEFT     ;if it is white loop again
    INC CX              ;if it is not white then return to the last white pixel and exit
    JMP T_CONT

GET_END_DOWN:
    INC DX              ;go down one pixel
    GetPixelColor       ;get the pixel color
    CMP AL, 0FH         ;check if it is white
    JE GET_END_DOWN     ;if it is white loop again
    DEC DX              ;if it is not white then return to the last white pixel and exit
    JMP T_CONT

T_CONT:
    MOV OB_EndX, CX     ;Move the last pixel we are at to the OB_End
    MOV OB_EndY, DX     ;Move the last pixel we are at to the OB_End

    POP AX
    POP BX
    POP CX
    POP DX

    RET
GetEndOfCurrentTrackComp ENDP


;description: take a point in ObstaclePosX, ObstaclePosY
;then Draw a 5 * 5 pixles Obstacle in red
DrawObstacle PROC FAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH ObstaclePosX
    PUSH ObstaclePosY
    PUSH DI

    MOV BL, 5
    MOV DI, 5
    Sub ObstaclePosX, 1
    Sub ObstaclePosY, 1

OB_OUTER_LOOP:
    MOV BL, 5

    OB_INNER_LOOP:
        MOV AH, 0CH
        MOV AL, 0EH
        MOV BH, 0
        MOV CX, ObstaclePosX
        MOV DX, ObstaclePosY
        INT 10H

        INC ObstaclePosX
        DEC BL
        JNZ OB_INNER_LOOP
    INC ObstaclePosY
    SUB ObstaclePosX, 5
    DEC DI
    JNZ OB_OUTER_LOOP

    POP DI
    POP ObstaclePosY
    POP ObstaclePosX
    POP DX
    POP CX
    POP BX
    POP AX

    RET
DrawObstacle ENDP

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

end main



