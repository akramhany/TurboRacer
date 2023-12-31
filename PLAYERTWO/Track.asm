include Macros.inc


.MODEL MEDIUM
.STACK 64

.DATA



    TrackWidth           equ     12                ;half track width
    GenTrack             db      31h               ;the key to generate another track
    EndKey               db      1bh               ;the key to end
    StatingPointX        dw      12                ;starting point in x-axis
    StatingPointY        dw      136               ;starting point in y-axis
    XAxis                dw      0                 ;x-axis for the middel of road
    YAxis                dw      0                 ;y-axis for the middel point of road
    RandomValue          db      0                 ;to generate the track -> if the number >=2 go right  number >=5 go left number >=8 go up else go down
    StepValue            dw      15                ;step value after getting the direction( how many steps will draw every loop)
    WindowHight          dw      150               ;the max hight of window  ****-->>>>>>>>>>> NOTE THAT THERE IS A STAUTS BAR SHOULD BE SUBTRACTED FROM TEH MAXHIGHT!!
    WindowWidth          dw      310               ;the max hight ofwindow
    LastDirection        db      1                 ;indicat the last direction if 0->up 1->right  2->left  3->down
    Status               db      0                 ; 0->inside window   1->out of the border of window
    Intersect            db      0                 ;0->no intersection  1->intersected
    CurrentBlock         db      0                 ; the counter when it equel to RoadNum stop generat another number
    seed                 dw      12                ;used in generating random nubmer
    notvalid             DB      0                 ; flage to indicat if there is any intersection will happen before going to that dirction or will go out of window
    IsStarte             db      0
    TIMER DW ?
    STARTINGTIME DB ?
    RACETIME EQU 40
    FUp                  db      0
    FLeft                db      0
    FRgiht               db      0
    FDown                db      0
    FLAGE                DB      0
    HalfStep             equ     8
    divider              equ     7
    db ?
                            db        ?
                            db        ?
    ArrX                    dW        2000 dup('#')                                 ;store x direction of track
     DW 2000 DUP('?')
    ArrY                    dW        2000 dup('#')                                 ;strore y axis of track
    DW 2000 DUP('?')
    ArrDirection            dB        1000 dup('#')
    COUNTERARR              DW        0                                             ;store direction for every point
                            db        ?
    db ?
    ArrX2                 dW      100 dup(0ffffh)
    ArrY2                 dW      100 dup(0ffffh)
    db ? 
    db ?
    ;;;Obstacles Varaibles

    GenerateObstaclesKey equ     32H               ;NUMBER 2 IN KEYBOARD
    ObstaclePosX         DW      0
    ObstaclePosY         DW      0
    OB_RIGHT             equ     2
    OB_LEFT              equ     3
    OB_UP                equ     1
    OB_DOWN              equ     4
    OB_NO_DIRECTION      equ     0
    OB_Direction         DW      OB_RIGHT          ;1 -> UP, 2 -> RIGHT, 3 -> LEFT, 4 -> DOWN, 0 -> NO DIRECTION
    OB_StartX            DW      0
    OB_StartY            DW      0
    OB_EndX              DW      0
    OB_EndY              DW      0
    COUNTER_CHECK       DB 0
    COUNTER_CHECK2      DB 0
    COUNTER_CHECK3      DW 0
    DrawPowerUpValidation DB 1


    ;---------------------------------------CAR DATA---------------------------------------
                         dw      '0'
                         dw      0
                         dw      0
                         dd      0
                         dw      '0'
                         dw      0
                         dw      0
                         dd      0
                         INCLUDE IMAGE1.INC
                         db      '0'

                         dw      '0'
                         dw      0
                         dw      0
                         dd      0
                         INCLUDE IMAGE2.INC
                         db      '1'

                         dw      '0'
                         dw      0
                         dw      0
                         dd      0
                         db      ?


    WIDTH1              DW 5                        ;WIDTH OF CAR1                  
    HEIGHT1             DW 9                       ;HEIGHT OF CAR1   
    WIDTH2              DW 5                        ;WIDTH OF CAR2
    HEIGHT2             DW 9                       ;HEIGHT OF CAR2
    CENTER1             DW 130 * 320 + 21           ;CENTER  OF CAR1
    CENTER2             DW 140 * 320 + 21           ;CENTER OF CAR2
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
    PASS_CAR1           DB 0
    PASS_CAR2           DB 0
    CANPASS_CAR1        DB 0
    CANPASS_CAR2        DB 0
    STARTTIME1          DB 0
    STARTTIME2          DB 0
    COUNT1              DB 0
    COUNT2              DB 0

    EXPECTEDSTATE1      DB ?
    EXPECTEDSTATE2      DB ?                        
    CANMOVEOBSTACLE1    DB ?
    CANMOVEOBSTACLE2    DB ?
    CANMOVETRACK1       DB ?
    CANMOVETRACK2       DB ?
    CHECKPASSEDOBSTACLE1 DB ?
    CHECKPASSEDOBSTACLE2 DB ?  
    ACTIVEUP_CAR1       DB 0
    ACTIVEUP_CAR2       DB 0
    ACTIVEDOWN_CAR1     DB 0
    ACTIVEDOWN_CAR2     DB 0
    powerUpPosX         DW 0
    powerUpPosY         DW 0
    powerUpColor        DB 0
    playerOneWin        DB 0
    playerTwoWin        DB 0
    counterForPU        DB 0
    currentSecond       DB 0

    ;-------------------HANDELING TAKING MORE THAN ONE KEY INPUT AT THE SAME TIME---------------------------
    DB ?
    origIntOffset        dw      0
    DB ?
    origIntSegment       dw      0
    DB ?
    shouldExit           db      0

    moveDirectionRightC1 db      0                 ;1 up, 2 right, 3 left, 4 down
    moveDirectionUpC1    db      0                 ;1 up, 2 right, 3 left, 4 down
    moveDirectionLeftC1  db      0
    moveDirectionDownC1  db      0


    moveDirectionRightC2 db      0                 ;1 up, 2 right, 3 left, 4 down
    moveDirectionUpC2    db      0                 ;1 up, 2 right, 3 left, 4 down
    moveDirectionLeftC2  db      0
    moveDirectionDownC2  db      0


;-------------------------------------------Pages Data----------------------------------------------------


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    widthToFill dw 00
    heightToFill dw 00
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
    OBSTACLE_COLOR  equ 10              ;light Green
    SPEED_UP_COLOR  equ 5               ;purple
    SPEED_DOWN_COLOR equ 9              ;blue
    GENERATE_OBSTACLE_COLOR equ 3       ;cyan
    PASS_OBSTACLE_COLOR equ 13          ;pink 
    ROAD_COLOR_BEGIN equ 6              ;brown
    ROAD_COLOR_END  equ 1               ;blue

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
    msg4 db ' Won!$'
    db ?
    powerups1 DB 'PowerUps1:','$'
    powerups2 DB 'PowerUps2:','$'
    db ?
    msgUP db 'SPEEDUP$'
    msgDown db 'SPEEDDOWN$'
    msgOB db 'PASS OB$'
    msgGOB db 'GEN OB$'
    spaceMsg db '           $'

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

    org 900


.CODE

include ORIGINAL.inc
include RESET.inc
include DRAW.inc
include Colision.inc
include General.inc
include PowerUps.inc
include Obscs.inc
include Game.inc

MAIN PROC FAR
                                MOV           DX ,@data
                                MOV           DS ,DX

                                CALL FAR PTR DisplayFirstPage

    CHECK_MODE:                 
        MOV COUNTERARR, 0
                                CALL FAR PTR DisplayMainPage
                                MOV AH, 0
                                INT 16H
                                CMP AH, 3DH                                          ;CHECK IF THE PLAYER WANT TO EXIT
                                JNE CHECK_FOR_PLAY
                                JMP EXIT_PROGRAM
    CHECK_FOR_PLAY:             CMP AH, 3BH
                                JNE CHECK_MODE
                                JMP CheckKey

    CheckKey:                   
                                mov           Status,0
                                mov           Intersect,0

                                MOV           AH ,00h                                ;check which key is being pressed
                                INT           16h                                    ;the pressed key in al
                                CMP           al,GenTrack                            ;if it enter so generate another track
                                JZ            TrackRandom
                                CMP           al ,EndKey                             ;check if it ESC to end the porgram
                                JZ            EndProgram                             ;go to hlt
                                CMP           AL, GenerateObstaclesKey               ;check if the track is finished and we want to generate obstacles
                                JZ            GenerateOb
                                JMP           CheckKey
    TrackRandom:                
                                CALL          far ptr GenerateTrack                  ;call to generate porcedure
                                CMP           CurrentBlock,25
                                JL            TrackRandom
                                CMP           Intersect ,1                           ;if if intersected go and generate another one
                                JZ            TrackRandom
                                CMP           Status ,1                              ;if if intersected go and generate another one
                                JZ            TrackRandom
    ;MOV  CL, RoadNum
    ;CMP  CurrentBlock,CL
                                CALL          FAR PTR ENDTRACK
                                JZ            CheckKey
                                JMP           CheckKey                               ;return to check key pressed
    EndProgram:                 

    GenerateOb:                 

                                CALL          FAR PTR GenerateObstacles              ;Generate Random Obstacles
                                CALL FAR PTR GeneratePowerUps

    ;;Handle interrupt 9 procedure
                                CLI

                                MOV           AX, 3509h
                                INT           21H

                                MOV           origIntOffset, BX
                                MOV           origIntSegment, ES

                                PUSH          DS
                                MOV           AX, CS
                                MOV           DS, AX
                                MOV           AX, 2509h
                                LEA           DX, OverRideInt9
                                INT           21H
                                POP           DS

                                STI


                                MOV           AX,0A000H
                                MOV           ES,AX

                                CALL FAR PTR Play


    
   ;Return Interrupt 9
                                CLI
                                mov           ax, origIntSegment
                                mov           dx, origIntOffset

                                push          ds
                                mov           ds, ax

                                mov           ax, 2509h
                                int           21h
    ; Re-enable interrupts
                                pop           ds
                                STI
    
                                
                               JMP CHECK_MODE
    EXIT_PROGRAM:
                               MOV           AH, 0
                               INT           16H
                               MOV           AH, 04CH
                               INT           21H
MAIN ENDP

   ;***********************************************************************
   ;generate random number
   ;***********************************************************************
GeneratRandomNumber proc NEAR
                                MOV           AH, 2ch                                ;get sysytem time to get the dx mellisecond
                                INT           21h
                                MOV           AX, DX
                                MOV           Cx ,seed
                                xor           dx,dx
                                IMUL          CX
                                inc           cx
                                mov           seed ,cx

    ;mov to ax to be diveded by 10 to generate random number form (0->9)
                                MOV           CX, 10                                 ;the inverval of the random number  from (0 to bx)
                                xor           dx,dx
                                DIV           CX                                     ;dx have the random number

                                MOV           RandomValue,DL                         ;keep the random number in the variable RandomValue

                                ret
GeneratRandomNumber endp
    ;***********************************************************************
    ;generate a track go make 1-start vieo mode 2-random value then 3-go to one direction
    ;do it again untile the road number ==CurrentBlock
    ;Regester: AX
    ;***********************************************************************
GenerateTrack proc far
                                MOV                   AX,StatingPointX                         ;put the value of x-axis with inintial point
                                MOV                   XAxis,AX

                                MOV                   AX,StatingPointY                         ;put the value of y-axis with inintial point
                                MOV                   YAxis,AX

                                MOV                   AH ,00                                   ;video mode
                                MOV                   AL,13H
                                INT                   10H

                                MOV                   AH ,08H                                  ;write in page0
                                MOV                   BH ,00
                                INT                   10H

                                MOV                   IsStarte,0
                                MOV                   FUp,0
                                MOV                   FRgiht,0
                                MOV                   FLeft,0
                                MOV                   FDown,0
                                mov                   Intersect,0
                                MOV                   CurrentBlock,0
                                mov                   LastDirection,1
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ENDTRACK
                                MOV                   IsStarte,1

                                mov                   Status,0

                                call                  far ptr RightDirection                   ;at the begain of the track mov up


    Road:
                                MOV                   AX,0
                                ADD                   AL, FUp
                                ADD                   AL, FLeft
                                ADD                   AL, FRgiht
                                ADD                   AL, FDown

                                CMP                   AX,4
                                JZ                    EEXIT
                                MOV                   FUp,0
                                MOV                   FRgiht,0
                                MOV                   FLeft,0
                                MOV                   FDown,0
                                CMP                   Intersect,1                              ;make sure that there is no intersection
                                JZ                    EEXIT
    ;if there return
                                CMP                   Status,1                                 ;make sure that NOT OUT OF WINDOW
                                JZ                    EEXIT
    ; MOV  CL ,RoadNum
    ; CMP  CurrentBlock,CL               ;CHECK IF THE NUMBER OF STEPS NEEDED IS DONE
    ; JZ   EEXIT
                                PUSH                  BX
                                call                  GeneratRandomNumber
                                POP                   BX
                                CMP                   RandomValue,3                            ; if(num<=2) move to Right
                                JlE                   RRight
                                CMP                   RandomValue,5                            ; if(num<=5) move to Left
                                JlE                   up
                                CMP                   RandomValue,7                            ; if(num<=8) move to UP
                                JlE                   Left
                                CMP                   RandomValue,9
                                JlE                   Down
                                jmp                   Road
    RRight:
                                jmp                   Right
    EEXIT:
                                ret                                                            ; if(num==9) move to Right
    UP:
                                MOV                   CX,XAxis
                                MOV                   DX,YAxis
                                SUB                   DX,StepValue
                                SUB                   DX, 2*TrackWidth+3
                                mov                   ax, 0

                                CALL                  FAR PTR CheckBefore                      ;make sure that you can go this direction
                                CMP                   FUp,1                                    ;make sure that NOT OUT OF WINDOW
                                JZ                    Down
                                MOV                   [BX], BYTE PTR 0
                                INC                   BX
                                PUSH                  BX
                                call                  far ptr UpDirection                      ; calling move up
                                POP                   BX
                                jmp                   Road                                     ;return to creat randam number again
    Down:
                                MOV                   CX,XAxis
                                MOV                   DX, YAxis
                                ADD                   DX,StepValue
                                ADD                   DX, 2*TrackWidth+3
                                mov                   ax, 3

                                CALL                  FAR PTR CheckBefore                      ;make sure that you can go this direction
                                CMP                   FDown,1                                  ;make sure that NOT OUT OF WINDOW
                                JZ                    Left
                                MOV                   [BX],BYTE PTR 3
                                INC                   BX
                                PUSH                  BX
                                call                  far ptr DownDirection                    ; calling move down
                                POP                   BX
                                jmp                   Road                                     ;return to creat randam number again
    Left:
                                MOV                   CX,XAxis
                                SUB                   CX,StepValue
                                SUB                   CX,2*TrackWidth+3
                                MOV                   DX, YAxis
                                mov                   ax, 2

                                CALL                  FAR PTR CheckBefore                      ;make sure that you can go this direction
                                CMP                   FLeft,1                                  ;make sure that NOT OUT OF WINDOW
                                JZ                    Right
                                MOV                   [BX], BYTE PTR 2
                                INC                   BX
                                PUSH                  BX
                                call                  far ptr LeftDirection
                                POP                   BX
                                jmp                   Road                                     ;return to creat randam number again
    FROAD:
                                JMP                   FAR PTR Road
    Right:
                                MOV                   CX,XAxis
                                ADD                   CX,StepValue
                                ADD                   CX ,2*TrackWidth+3
                                MOV                   DX, YAxis
                                mov                   ax, 1

                                CALL                  FAR PTR CheckBefore
                                CMP                   FRgiht,1
                                JZ                    FROAD                                    ;make sure that there is no intersection
                                MOV                   [BX], BYTE PTR 1H
                                INC                   BX
                                PUSH                  BX
                                call                  far ptr RightDirection                   ; calling move up
                                POP                   BX
                                jmp                   Road                                     ;return to creat randam number again
    EXIT:
                                ret
GenerateTrack endp
    ;*************************************************************************
    ;CHECK IF THE COLOR OF THE NEXT PIXEL IS COLORED WITH THE ROAD COLOR
    ;*************************************************************************
Check proc far
                                MOV                   AH ,0DH                                  ;get the color of the pixel in al
                                INT                   10H
                                CMP                   AL, 8                                    ;same as red check Gray
                                jz                    NO1
                                CMP                   AL, 0EH                                  ;same as red check Gray
                                jz                    NO1
                                CMP                   AL, 0fh                                  ;same as red check Gray
                                jz                    NO1
                                CMP                   DX,WindowHight
                                JGE                   NO1
                                CMP                   CX,WindowWidth
                                JGE                   NO1
                                CMP                   DX,10
                                JlE                   NO1
                                CMP                   CX,10
                                JlE                   NO1
                                ret
    NO1:
                                MOV                   FLAGE,1
                                RET
Check endp
    ;***********************************************************************
    ;MAKE CHECK BEFORE GOING TO ANY DIRECTION( I SET DX AND CX BEFORE CALLING PROC)
    ;Regester: AX
    ;***********************************************************************
CheckBefore proc far
                                MOV                   FLAGE,0
                                PUSH                  CX
                                PUSH                  DX
                                JMP                   CON5
    LEFTFLAG3:
                                JMP                   FAR PTR LEFTFLAG2
    RIGHTFLAGE3:
                                JMP                   FAR PTR RIGHTFLAGE2
    CON5:
                                CMP                   AX,0
                                JZ                    UPFLAG2
                                CMP                   AX,1
                                JZ                    RIGHTFLAGE3
                                CMP                   AX,2
                                JZ                    LEFTFLAG3
                                JMP                   DOWNFLAGE2

    UPFLAG2:                    POP                   DX
                                POP                   CX
                                PUSH                  CX
                                PUSH                  DX
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    UPFLAG3
                                ADD                   DX,HalfStep
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    UPFLAG3
                                SUB                   DX, HalfStep
                                SUB                   CX ,TrackWidth+3
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    UPFLAG3
                                ADD                   CX ,2*TrackWidth+4
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    UPFLAG3
                                POP                   DX
                                POP                   CX
                                RET
    UPFLAG3:
                                JMP                   FAR PTR UPFLAG
    DOWNFLAGE2:
                                POP                   DX
                                POP                   CX
                                PUSH                  CX
                                PUSH                  DX
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    DOWNFLAGE3
                                SUB                   DX,HalfStep
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    DOWNFLAGE3
                                ADD                   DX, HalfStep
                                SUB                   CX ,TrackWidth+3
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    DOWNFLAGE3
                                ADD                   CX ,2*TrackWidth+4
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    DOWNFLAGE3
                                POP                   DX
                                POP                   CX
                                RET
    DOWNFLAGE3:
                                JMP                   FAR PTR DOWNFLAGE
    RIGHTFLAGE4:
                                JMP                   FAR PTR RIGHTFLAGE
    RIGHTFLAGE2:
                                POP                   DX
                                POP                   CX
                                PUSH                  CX
                                PUSH                  DX
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    RIGHTFLAGE4
                                SUB                   CX,HalfStep
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    RIGHTFLAGE
                                ADD                   CX,HalfStep
                                SUB                   DX ,TrackWidth+3
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    RIGHTFLAGE
                                ADD                   DX ,2*TrackWidth+4
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    RIGHTFLAGE
                                POP                   DX
                                POP                   CX
                                RET
    LEFTFLAG2:
                                POP                   DX
                                POP                   CX
                                PUSH                  CX
                                PUSH                  DX
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    LEFTFLAG
                                ADD                   CX,HalfStep
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    LEFTFLAG
                                SUB                   CX,HalfStep
                                SUB                   DX ,TrackWidth+3
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    LEFTFLAG
                                ADD                   DX ,2*TrackWidth+4
                                CALL                  FAR PTR Check
                                CMP                   FLAGE,1
                                JZ                    LEFTFLAG
                                POP                   DX
                                POP                   CX
                                RET
    UPFLAG:
                                POP                   DX
                                POP                   CX
                                MOV                   FUp,1                                    ;move intersect to be 1 indicate thet there is intersection
                                ret
    RIGHTFLAGE:
                                POP                   DX
                                POP                   CX
                                MOV                   FRgiht,1
                                ret
    LEFTFLAG:
                                POP                   DX
                                POP                   CX
                                MOV                   FLeft,1
                                ret
    DOWNFLAGE:
                                POP                   DX
                                POP                   CX
                                MOV                   FDown,1
                                ret
CheckBefore endp


    ; CHECKDIRECTION PROC FAR

    ;                                 mov                   ah, 00h                                  ; Function 00h - Read character from standard input, wait if necessary
    ;                                 int                   16h                                      ; BIOS interrupt 16h



    ;                                 MOV                   AH ,00                                   ;video mode
    ;                                 MOV                   AL,13H
    ;                                 INT                   10H

    ;                                 MOV                   AH ,08H                                  ;write in page0
    ;                                 MOV                   BH ,00
    ;                                 INT                   10H

    ;                                 MOV                   CX,StatingPointX
    ;                                 MOV                   DX , StatingPointY
    ;                                 MOV                   SI ,0
    ;                                 MOV                   DI, OFFSET ArrDirection

    ;     LOOP111:
    ;                                 mov                   al, 0
    ;                                 CMP                   AL,[DI]
    ;                                 JNZ                   CHECK1
    ;                                 DEC                   DX
    ;                                 call                  far ptr ColorRoadLanes
    ;                                 jmp                   e
    ;     Check1:
    ;                                 mov                   al ,1
    ;                                 cmp                   AL,[DI]
    ;                                 JNZ                   CHECK2
    ;                                 INC                   CX
    ;                                 call                  far ptr ColorRoadLanes
    ;                                 JMP                   e
    ;     Check2:
    ;                                 mov                   al ,2
    ;                                 cmp                   AL,[DI]
    ;                                 jnz                   Check3
    ;                                 dec                   cx
    ;                                 call                  far ptr ColorRoadLanes
    ;                                 jmp                   e
    ;     Check3:


    ;                                 inc                   dx
    ;                                 call                  far ptr ColorRoadLanes
    ;     e:
    ;                                 inc                   si
    ;                                 inc                   DI
    ;                                 cmp                   si ,COUNTERARR
    ;                                 jnz                   loop111                                  ;
    ;                                 ret

    ; CHECKDIRECTION ENDP








    ;***********************************************************************
    ;GO RIGHT DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO RIGHT DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
RightDirection proc far
                                cmp                   LastDirection,0                          ;if the last direction is up it esay to go up
                                jz                    GoUPRight

                                cmp                   LastDirection,3                          ;if the last direction is down we will  return
                                jz                    farGoDownRight

                                cmp                   LastDirection,1                          ; if the last direction is right we will make Uturn
                                jz                    farGoRight

                                cmp                   LastDirection,2                          ; if the last direction is left we will make Uturn
                                jz                    FarExitRight
    FarExitRight:
                                ret
    farGoRight:
                                JMP                   FAR PTR GoRight
    farGoDownRight:
                                jmp                   far ptr GoDownRight
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUPRight:
                                CALL                  FAR PTR LDAndUR
    FixGoUPRight:
                                CALL                  FAR PTR FixURAndDR
                                jmp                   GoRight                                  ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDownRight:
                                CALL                  FAR PTR DRAndLU
                                JMP                   FixGoDownRight
    fExitRight:
                                ret
    FixGoDownRight:
                                CALL                  FAR PTR FixURAndDR
                                jmp                   GoRight                                  ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRight:
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                MOV                   CX,XAxis                                 ;start from the middle
                                MOV                   BX ,XAxis                                ;SAVE THE END POINT IN SI   X+STEPVALUE
                                ADD                   BX,StepValue
    FirstLoopRight:
                                MOV                   DX,YAxis                                 ;start from the middle -width  going to ->middle +width
                                SUB                   DX,TrackWidth
                                MOV                   SI,0                                     ;indicat how many pixel i draw right now to make red walls
    ;draw the wall left

                                CALL                  FAR PTR ColorWall                        ; COLOR OF WALL IS RED
                                INC                   DX
    SecondLoopRight:
                                JZ                    fExitRight
                                CMP                   SI ,TrackWidth-1
                                JNZ                   M
                                CALL                  FAR PTR ColorRoadLanes
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,1
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                JMP                   CONTINUE
    M:
                                CALL                  FAR PTR ColorRoad
    CONTINUE:
                                INC                   DX                                       ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                                INC                   SI                                       ;INC counter
                                CMP                   SI,2*TrackWidth-1                        ;compare the to current width with 2*TrackWidth
                                JNZ                   SecondLoopRight
    ;draw the wall Right
                                CALL                  FAR PTR ColorWall                        ; COLOR OF WALL IS RED
                                INC                   CX                                       ;GO UP BY dec the value of row
                                CMP                   CX,BX                                    ;see if the value movment in row equal to stepvlaue
                                JNZ                   FirstLoopRight
                                MOV                   XAxis,BX                                 ;set y-axis with the new value

                                JMP                   ExitRight                                ;go to generte randam number agian
    ExitRight:
                                MOV                   LastDirection ,1
                                INC                   CurrentBlock                             ;inc the counter of road blocks
                                ret
RightDirection endp
    ;***********************************************************************
    ;GO LEFT DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO LEFT DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
LeftDirection proc far
                                cmp                   LastDirection,0                          ;if the last direction is up it esay to go up
                                jz                    GoUPLeft
                                cmp                   LastDirection,3                          ;if the last direction is down we will  return
                                jz                    farGoDownLeft
                                cmp                   LastDirection,1                          ; if the last direction is right we will make Uturn
                                jz                    farExitLeft
                                cmp                   LastDirection,2                          ; if the last direction is left we will make Uturn
                                jz                    farGoLeft
    farExitLeft:
                                ret
    farGoLeft:
                                JMP                   FAR PTR GoLeft
    farGoDownLeft:
                                jmp                   FAR PTR GoDownLeft
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUPLeft:
                                CALL                  FAR PTR RDAndUL
    FixGoUPLeft:
                                CALL                  FAR PTR FixULAndDL
                                jmp                   GoLeft                                   ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDownLeft:
                                CALL                  FAR PTR DLAndRU
                                JMP                   FixGoDownLeft
    FExitLeft:
                                ret
    FixGoDownLeft:
                                CALL                  FAR PTR FixULAndDL
                                jmp                   GoLeft                                   ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeft:
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                MOV                   CX,XAxis                                 ;start from the middle
                                MOV                   BX ,XAxis                                ;SAVE THE END POINT IN BX   X+STEPVALUE
                                SUB                   BX,StepValue
    FirstLoopLeft:
                                MOV                   DX,YAxis                                 ;start from the middle -width  going to ->middle +width
                                SUB                   DX,TrackWidth
                                MOV                   SI,0                                     ;start a counter
    ;draw the wall left
                                CALL                  FAR PTR ColorWall
                                INC                   DX
    SecondLoopLeft:
                                CMP                   SI ,TrackWidth-1
                                JNZ                   LEF

                                CALL                  FAR PTR ColorRoadLanes
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,2
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                JMP                   CONTINUELEFT
    LEF:
                                CALL                  FAR PTR ColorRoad
    CONTINUELEFT:
                                INC                   DX                                       ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                                INC                   SI                                       ;INC counter
                                CMP                   SI,2*TrackWidth-1                        ;compare the to current width with 2*TrackWidth
                                JNZ                   SecondLoopLeft
    ;draw the wall Right
                                CALL                  FAR PTR ColorWall
                                DEC                   CX                                       ;GO UP BY dec the value of row
                                CMP                   CX,BX                                    ;see if the value movment in row equal to stepvlaue
                                JNZ                   FirstLoopLeft
                                MOV                   XAxis,BX                                 ;set y-axis with the new value

                                JMP                   ExitLeft                                 ;go to generte randam number agian
    ExitLeft:
                                MOV                   LastDirection ,2
                                INC                   CurrentBlock                             ;inc the counter of road blocks
                                ret
LeftDirection endp
    ;***********************************************************************
    ;GO UP DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO UP DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
UpDirection proc far
                                cmp                   LastDirection,0                          ;if the lst direction is up it esay to go up
                                jz                    GoUp
                                cmp                   LastDirection,3                          ;if the last direction is down we will not return
                                jz                    farExitUP
                                cmp                   LastDirection,1                          ; if the last direction is right we will make Uturn
                                jz                    GoRightUp
                                cmp                   LastDirection,2                          ; if the last direction is left we will make Uturn
                                jz                    farGoLeftUp
    farExitUP:
                                ret
    farGoLeftUp:
                                jmp                   far ptr GoLeftUp
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUp:
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                MOV                   BX,YAxis                                 ;END point of row
                                SUB                   BX,StepValue
                                MOV                   DX,YAxis                                 ;put the valus of y-axis ->row
    FirstLoopUP:
                                MOV                   CX,XAxis                                 ;start from the middle -width  to ->middle +width
                                SUB                   CX,TrackWidth
                                MOV                   SI,0                                     ;restart counter
                                CALL                  FAR PTR ColorWall
                                INC                   CX                                       ;move to the next right pixel
    SecondLoopUP:
                                CMP                   SI ,TrackWidth-1
                                JNZ                   U
                                CALL                  FAR PTR ColorRoadLanes
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,0
                                MOV                   [DI],AL
                                POP                   DI

                                CALL                  FAR PTR KeepTrackWithAxis
                                JMP                   CONTINUEUP
    U:
                                CALL                  FAR PTR ColorRoad
    CONTINUEUP:
                                INC                   CX
                                INC                   SI                                       ;INC counter
                                CMP                   SI,2*TrackWidth-1                        ;compare the to current width with 2*TrackWidth
                                JNZ                   SecondLoopUP
                                CALL                  FAR PTR ColorWall
                                DEC                   DX                                       ;GO UP BY dec the value of row
                                CMP                   DX,BX                                    ;see if the value movment in row equal to stepvlaue
                                JNZ                   FirstLoopUP
                                MOV                   YAxis,BX                                 ;set y-axis with the new value
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                JMP                   ExitUP                                   ;go to generte randam number agian
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRightUp:
                                CALL                  FAR PTR DLAndRU
    FixGoRightUp:
                                CALL                  FAR PTR FixLUAndRU
                                jmp                   GoUp                                     ;go up some pixels
    FExitup:
                                ret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeftUp:
                                CALL                  FAR PTR DRAndLU                          ;if the end point =0 exit loop
    FixGoLeftUp:
                                cALL                  FAR PTR FixLUAndRU
                                jmp                   GoUp                                     ;go up some pixels
    ExitUP:
                                MOV                   LastDirection ,0
                                INC                   CurrentBlock                             ;inc the counter of road blocks
                                ret
UpDirection endp
    ;***********************************************************************
    ;GO DOWN DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO DOWN DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
DownDirection proc far
                                cmp                   LastDirection,0                          ;if the lst direction is up it esay to go up
                                jz                    farExiTDown
                                cmp                   LastDirection,3                          ;if the last direction is down we will not return
                                jz                    GoDown
                                cmp                   LastDirection,1                          ; if the last direction is right we will make Uturn
                                jz                    GoRightDown
                                cmp                   LastDirection,2                          ; if the last direction is left we will make Uturn
                                jz                    farGoLeftDown
    farExitDown:
                                RET
    farGoLeftDown:
                                jmp                   far ptr GoLeftDown
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDown:
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                MOV                   BX,YAxis                                 ;END point of row
                                add                   BX,StepValue
                                MOV                   DX,YAxis                                 ;put the valus of y-axis ->row
    FirstLoopDown:
                                MOV                   CX,XAxis                                 ;start from the middle -width  to ->middle +width
                                SUB                   CX,TrackWidth
                                MOV                   SI,0                                     ;restart counter
    ;draw the wall left
                                JZ                    farExitDown
                                CALL                  FAR PTR ColorWall
                                INC                   CX                                       ;move to the next right pixel
    SecondLoopDown:
                                CMP                   SI ,TrackWidth-1
                                JNZ                   DO
                                CALL                  FAR PTR ColorRoadLanes
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,3
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                JMP                   CONTINUEDOWN
    DO:
                                CALL                  FAR PTR ColorRoad
    CONTINUEDOWN:
                                INC                   CX                                       ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                                INC                   SI                                       ;INC counter
                                CMP                   SI,2*TrackWidth-1                        ;compare the to current width with 2*TrackWidth
                                JNZ                   SecondLoopDown
    ;draw the wall Right
                                CALL                  FAR PTR ColorWall
                                INC                   DX                                       ;GO UP BY dec the value of row
                                CMP                   DX,BX                                    ;see if the value movment in row equal to stepvlaue
                                JNZ                   FirstLoopDown

                                MOV                   YAxis,BX                                 ;set y-axis with the new value
    ;                                CALL          FAR PTR KeepTrackWithAxis
                                JMP                   ExiTDown                                 ;go to generte randam number agian
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRightDown:
                                CALL                  FAR PTR RDAndUL
    FixGoRightDwon:
                                CALL                  FAR PTR FixLDAndRD

                                jmp                   GoDown
    fExitDown:
                                ret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeftdown:
                                cALL                  FAR PTR LDAndUR
    FixGoLeftdown:
                                CALL                  FAR PTR FixLDAndRD
                                jmp                   GoDown
    EXITDown:
                                MOV                   LastDirection ,3
                                INC                   CurrentBlock
                                ret
DownDirection endp
    ;***********************************************************************
    ;Drow a pixel with the road color (Gray) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoad PROC FAR
                                MOV                   AH ,0CH
                                MOV                   AL ,8                                    ;gray
                                INT                   10H
                                RET
ColorRoad ENDP
    ;***********************************************************************
    ;Drow a pixel with the wall color (Yellow) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorWall PROC FAR
                                MOV                   AH ,0CH
                                MOV                   AL ,0eh                                  ;yellow
                                INT                   10H
                                RET
ColorWall ENDP
    ;***********************************************************************
    ;Drow a pixel with the line color (White) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoadLanes PROC FAR
                                MOV                   AH ,0CH
                                MOV                   AL ,0fh                                  ;white
                                INT                   10H
                                RET
ColorRoadLanes ENDP
    ;***********************************************************************
    ;Drow a pixel with the wall color (blue) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoadEnd PROC FAR
                                MOV                   AH ,0CH
                                CMP                   IsStarte,0
                                JNZ                   End_track
                                MOV                   AL , ROAD_COLOR_BEGIN
                                JMP                   CON10
    End_track:
                                MOV                   AL ,ROAD_COLOR_END                       ;blue
    con10:
                                INT                   10H
                                RET
ColorRoadEnd ENDP

    ;****************************************************************************
    ;TO DRAW TURN IN BOTH OF (LEFT AFTER DOWN  ) OR(UP AFTER RIGHT )
    ;Regester:DX,CX,BX
    ;****************************************************************************
DLAndRU PROC FAR
                                MOV                   DX ,YAxis
                                MOV                   BL,TrackWidth+1
                                MOV                   BH ,0
    DLRU1:
                                MOV                   CX,XAxis                                 ;     **********
                                MOV                   BH ,0                                    ;     **********
    DLRU2:                                                                                     ;     **********

                                CMP                   BL, 1
                                JNZ                   NOTWALL
                                CALL                  FAR PTR ColorWall
                                JMP                   con6

    NOTWALL:
                                CALL                  FAR PTR ColorRoad                        ;***************    THIS LINE  MADE BY FIXDLAndRU
    con6:
                                INC                   CX                                       ;***************    THIS LINE  MADE BY FIXDLAndRU
                                INC                   BH                                       ;*************   ---
                                CMP                   BH, TrackWidth                           ;***********        | --> DLAndRU
                                JNZ                   DLRU2                                    ;********      -----
                                CALL                  FAR PTR ColorWall
                                DEC                   BL
                                INC                   DX
                                CMP                   BL,0
                                JNZ                   DLRU1

                                ret
DLAndRU ENDP
    ;****************************************************************************
    ;TO DRAW THE TURN IN BOTH OF (DOWN AFTER RIGHT  ) OR(LEFT AFTER UP )
    ;Regester:DX,CX,BX
    ;****************************************************************************
RDAndUL PROC FAR
                                MOV                   DX ,YAxis
                                MOV                   BL,TrackWidth+1
                                MOV                   BH ,0
    RDUL1:
                                MOV                   CX,XAxis
                                MOV                   BH ,0
    RDUL2:


                                CMP                   BL, 1
                                JNZ                   NOTWALL2
                                CALL                  FAR PTR ColorWall
                                JMP                   con7

    NOTWALL2:
                                CALL                  FAR PTR ColorRoad
    con7:
                                INC                   CX
                                INC                   BH
                                CMP                   BH, TrackWidth
                                JNZ                   RDUL2
                                CALL                  FAR PTR ColorWall
                                DEC                   BL
                                DEC                   DX
                                CMP                   BL,0
                                JNZ                   RDUL1
                                RET
RDAndUL ENDP
    ;****************************************************************************
    ;TO DRAW  TURN IN BOTH OF (RIGHT AFTER DOWN  ) OR(UP AFTER LEFT )
    ;Regester:DX,CX,BX
    ;****************************************************************************
DRAndLU PROC FAR
                                MOV                   CX ,XAxis
                                MOV                   BL,TrackWidth+1
                                MOV                   BH ,0
    DRLU1:
                                MOV                   DX,YAxis
                                MOV                   BH ,0
    DRLU2:
                                CMP                   BL, 1
                                JNZ                   NOTWALL3
                                CALL                  FAR PTR ColorWall
                                JMP                   con8

    NOTWALL3:
                                CALL                  FAR PTR ColorRoad                        ;***************    THIS LINE  MADE BY FIXDLAndRU
    con8:
                                INC                   DX
                                INC                   BH
                                CMP                   BH, TrackWidth
                                JNZ                   DRLU2
                                CALL                  FAR PTR ColorWall
                                DEC                   BL
                                DEC                   CX
                                CMP                   BL,0
                                JNZ                   DRLU1
                                RET
DRAndLU ENDP
    ;****************************************************************************
    ;TO DRAW THE ANGEL OF TURN IN BOTH OF (DOWN AFTER LEFT  ) OR(RIGHT AFTER UP )
    ;Regester:DX,CX,BX
    ;****************************************************************************
LDAndUR PROC FAR
                                MOV                   CX,XAxis
                                MOV                   BL,TrackWidth+1
                                MOV                   BH ,0
    LDRU1:
                                MOV                   DX , YAxis
                                MOV                   BH ,0
    LDRU2:
                                CMP                   BL, 1
                                JNZ                   NOTWALL4
                                CALL                  FAR PTR ColorWall
                                JMP                   con9

    NOTWALL4:
                                CALL                  FAR PTR ColorRoad                        ;***************    THIS LINE  MADE BY FIXDLAndRU
    con9:
                                DEC                   DX
                                INC                   BH
                                CMP                   BH, TrackWidth
                                JNZ                   LDRU2
                                CALL                  FAR PTR ColorWall
                                DEC                   BL
                                DEC                   CX
                                CMP                   BL,0
                                JNZ                   LDRU1
                                RET
LDAndUR ENDP
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (UP AFTER LEFT  ) OR(UP AFTER RIGHT )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixLUAndRU PROC FAR
                                MOV                   SI,0
                                MOV                   DX,YAxis
                                MOV                   BX,YAxis
                                SUB                   BX,TrackWidth
    LURU1:
                                MOV                   CX,XAxis
                                CMP                   LastDirection,1
                                JNZ                   RU
                                ADD                   CX,TrackWidth
    RU:
                                MOV                   SI,0
    LURU2:
                                CMP                   SI ,1
                                JGE                   FLU
                                CMP                   LastDirection,2
                                JZ                    WALL
                                CALL                  FAR PTR ColorWall
                                JMP                   ConLU
    WALL:
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,0
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis

                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   ConLU
    FLU:
                                CALL                  FAR PTR ColorRoad
    ConLU:
                                DEC                   CX
                                INC                   SI
                                CMP                   SI,TrackWidth
                                JNZ                   LURU2
                                CMP                   LastDirection,2
                                JZ                    LINES
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,0
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   CON
    LINES:
                                CALL                  FAR PTR ColorWall
    CON:
                                DEC                   DX
                                CMP                   DX,BX
                                JNZ                   LURU1
                                MOV                   YAxis,BX
                                RET
FixLUAndRU endp
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (DOWN AFTER LEFT  ) OR(DOWN AFTER RIGHT )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixLDAndRD PROC FAR
                                MOV                   SI,0
                                MOV                   DX,YAxis
                                MOV                   BX,YAxis
                                ADD                   BX,TrackWidth
    LDRD1:
                                MOV                   CX,XAxis
                                CMP                   LastDirection,2
                                JNZ                   FixLD
                                SUB                   CX,TrackWidth
    FixLD:
                                MOV                   SI,0
    LDRD2:
                                CMP                   SI ,1
                                JGE                   FRD
                                CMP                   LastDirection,1
                                JZ                    WALL2
                                CALL                  FAR PTR ColorWall
                                JMP                   ConLD

    WALL2:
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,3
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   ConLD
    FRD:
                                CALL                  FAR PTR ColorRoad
    ConLD:
                                INC                   CX
                                INC                   SI
                                CMP                   SI,TrackWidth
                                JNZ                   LDRD2
                                CMP                   LastDirection,1
                                JZ                    LINES2
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,3
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   CON2
    LINES2:
                                CALL                  FAR PTR ColorWall
    CON2:
                                INC                   DX
                                CMP                   DX,BX
                                JNZ                   LDRD1
                                MOV                   YAxis,BX
                                RET
FixLDAndRD endp
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (RIGHT AFTER UP  ) OR(RIGHT AFTER DOWN )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixURAndDR PROC FAR
                                MOV                   SI,0
                                MOV                   CX,XAxis
                                MOV                   BX,XAxis
                                ADD                   BX,TrackWidth
    URDR1:
                                MOV                   DX,YAxis
                                CMP                   LastDirection,0
                                JNZ                   FixUR
                                SUB                   DX,TrackWidth
    FixUR:
                                MOV                   SI,0
    URDR2:
                                CMP                   SI ,1
                                JGE                   FUR
                                CMP                   LastDirection,3
                                JZ                    WALL3
                                CALL                  FAR PTR ColorWall
                                JMP                   ConUR
    WALL3:
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,1
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   ConUR
    FUR:
                                CALL                  FAR PTR ColorRoad
    ConUR:
                                INC                   DX
                                INC                   SI
                                CMP                   SI,TrackWidth
                                JNZ                   URDR2
                                CMP                   LastDirection,3
                                JZ                    LINES3
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,1
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   CON3
    LINES3:
                                CALL                  FAR PTR ColorWall
    CON3:
                                INC                   CX
                                CMP                   CX,BX
                                JNZ                   URDR1
                                MOV                   XAxis,BX
                                RET
FixURAndDR endp
    ;****************************************************************************
    ;TO DRAW THE BOX OF TURN IN BOTH OF (LEFT AFTER UP  ) OR(LEFT AFTER DOWN )
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
FixULAndDL PROC FAR
                                MOV                   SI,0
                                MOV                   CX,XAxis
                                MOV                   BX,XAxis
                                SUB                   BX,TrackWidth
    ULDL1:
                                MOV                   DX,YAxis
                                CMP                   LastDirection,0
                                JNZ                   FixUL
                                SUB                   DX,TrackWidth
    FixUL:
                                MOV                   SI,0
    ULDL2:
                                CMP                   SI ,1
                                JGE                   FUL
                                CMP                   LastDirection,3
                                JZ                    WALL4
                                CALL                  FAR PTR ColorWall
                                JMP                   ConUL

    WALL4:
                                PUSH                  DI
                                MOV                   DI , OFFSET ArrDirection
                                ADD                   DI,COUNTERARR
                                MOV                   AL ,2
                                MOV                   [DI],AL
                                POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   ConUL
    FUL:
                                CALL                  FAR PTR ColorRoad
    ConUL:
                                INC                   DX
                                INC                   SI
                                CMP                   SI,TrackWidth
                                JNZ                   ULDL2
                                CMP                   LastDirection,3
                                JZ                    LINES4
    PUSH                  DI
    MOV                   DI , OFFSET ArrDirection
    ADD                   DI,COUNTERARR
    MOV                   AL ,2
    MOV                   [DI],AL
    POP                   DI
                                CALL                  FAR PTR KeepTrackWithAxis
                                CALL                  FAR PTR ColorRoadLanes
                                JMP                   CON4
    LINES4:
                                CALL                  FAR PTR ColorWall
    CON4:
                                DEC                   CX
                                CMP                   CX,BX
                                JNZ                   ULDL1
                                MOV                   XAxis,BX
                                RET
FixULAndDL endp
    ;****************************************************************************
    ;DRAW A RED LINES INDICATE THE END OF TRACK ACCORDING TO THA LAST DIRECTION
    ;Regester:DX,CX,BX,SI
    ;****************************************************************************
ENDTRACK PROC FAR
                                CMP                   LastDirection,0
                                JZ                    LUP
                                CMP                   LastDirection,1
                                JZ                    LRIGH
                                CMP                   LastDirection,2
                                JZ                    LLEFT
                                JMP                   LDOWN
    LUP:
                                MOV                   BX,YAxis
                                SUB                   BX,1
                                MOV                   DX,YAxis
    LastLoopUP:
                                MOV                   CX,XAxis
                                SUB                   CX,TrackWidth
                                MOV                   SI,0
    LastSecondLoopUP:
                                CALL                  FAR PTR ColorRoadEnd
                                INC                   CX
                                INC                   SI
                                CMP                   SI,2*TrackWidth+1
                                JNZ                   LastSecondLoopUP
                                DEC                   DX
                                CMP                   DX,BX
                                JNZ                   LastLoopUP
                                MOV                   YAxis,BX
                                JMP                   LastExit
    LRIGH:
                                MOV                   CX,XAxis
                                MOV                   BX ,XAxis
                                ADD                   BX,1
    LastFirstLoopRight:
                                MOV                   DX,YAxis
                                SUB                   DX,TrackWidth
                                MOV                   SI,0
    LastSecondLoopRight:
                                CALL                  FAR PTR ColorRoadEnd
                                INC                   DX
                                INC                   SI
                                CMP                   SI,2*TrackWidth+1
                                JNZ                   LastSecondLoopRight
                                INC                   CX
                                CMP                   CX,BX
                                JNZ                   LastFirstLoopRight
                                MOV                   XAxis,BX
                                JMP                   LastExit
    LLEFT:
                                MOV                   CX,XAxis
                                MOV                   BX ,XAxis
                                SUB                   BX,1
    LastFirstLoopLeft:
                                MOV                   DX,YAxis
                                SUB                   DX,TrackWidth
                                MOV                   SI,0
    LastSecondLoopLeft:
                                CALL                  FAR PTR ColorRoadEnd
                                INC                   DX
                                INC                   SI
                                CMP                   SI,2*TrackWidth+1
                                JNZ                   LastSecondLoopLeft
                                DEC                   CX
                                CMP                   CX,BX
                                JNZ                   LastFirstLoopLeft
                                MOV                   XAxis,BX
                                JMP                   ExitLeft
    LDOWN:
                                MOV                   BX,YAxis
                                add                   BX,1
                                MOV                   DX,YAxis
    LastFirstLoopDown:
                                MOV                   CX,XAxis
                                SUB                   CX,TrackWidth
                                MOV                   SI,0
    ;move to the next right pixel
    LastSecondLoopDown:
                                CALL                  FAR PTR ColorRoadEnd
                                INC                   CX
                                INC                   SI
                                CMP                   SI,2*TrackWidth+1
                                JNZ                   LastSecondLoopDown
                                INC                   DX
                                CMP                   DX,BX
                                JNZ                   LastFirstLoopDown
                                MOV                   YAxis,BX
                                JMP                   ExiTDown
    LastExit:
                                RET
ENDTRACK ENDP

KeepTrackWithAxis proc far

                                PUSH                  SI
                                PUSH                  DI
    ;PUSH                  BP
                                PUSH                  DX
                                PUSH                  CX
                                PUSH                  BX
    ;PUSH                  AX

                                MOV                   AX, COUNTERARR
                                MOV                   SI,OFFSET ArrX
                                MOV                   DI,OFFSET ArrY
    ;MOV                   BP ,OFFSET ArrDirection
                                ADD                   SI, AX
                                ADD                   SI, AX
                                ADD                   DI, AX
                                ADD                   DI, AX
    ;ADD                   BP,AX
    ;POP                   AX
    ;MOV                   [BP],AL
                                MOV                   [SI],CX
                                MOV                   [DI],DX

                                inc                   COUNTERARR
                                POP                   BX
                                POP                   CX
                                POP                   DX
    ;POP                   BP
                                POP                   DI
                                POP                   SI
                                ret
KeepTrackWithAxis endp

end main



