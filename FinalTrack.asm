.MODEL SMALL
.STACK 64

.DATA
    TrackWidth    equ 10      ;half track width
    GenTrack      db  31h     ;the key to generate another track
    EndKey        db  1bh     ;the key to end
    StatingPointX dw  12      ;starting point in x-axis
    StatingPointY dw  170     ;starting point in y-axis
    XAxis         dw  0       ;x-axis for the middel of road
    YAxis         dw  0       ;y-axis for the middel point of road
    RandomValue   db  0       ;to generate the track -> if the number >=2 go right  number >=5 go left number >=8 go up else go down
    StepValue     dw  30      ;step value after getting the direction( how many steps will draw every loop)
    WindowHight   dw  190     ;the max hight of window  ****-->>>>>>>>>>> NOTE THAT THERE IS A STAUTS BAR SHOULD BE SUBTRACTED FROM TEH MAXHIGHT!!
    WindowWidth   dw  310     ;the max hight ofwindow
    LastDirection db  1       ;indicat the last direction if 0->up 1->right  2->left  3->down
    Status        db  0       ; 0->inside window   1->out of the border of window
    Intersect     db  0       ;0->no intersection  1->intersected
    RoadNum       db  23      ;nubmer of blocks
    CurrentBlock  db  0       ; the counter when it equel to RoadNum stop generat another number
    seed          dw  1234    ;used in generating random nubmer
    BI            DB  0       ; flage to indicat if there is any intersection will happen before going to that dirction
    BO            DB  0       ; flage to indicat if it out of window before going to that direction
.CODE
MAIN PROC FAR
                        MOV  DX ,@data
                        MOV  DS ,DX
    CheckKey:           
                        mov  Status,0
                        mov  Intersect,0
                        MOV  AH ,01H
                        INT  16H
                        JZ   CheckKey
                        MOV  AH ,00h                       ;check which key is being pressed
                        INT  16h                           ;the pressed key in al
                        CMP  al,GenTrack                   ;if it enter so generate another track
                        JZ   TrackRandom
                        CMP  al ,EndKey                    ;check if it ESC to end the porgram
                        JZ   EndProgram                    ;go to hlt
                        JMP  CheckKey
    TrackRandom:        
                        CALL far ptr GenerateTrack         ;call to generate porcedure
                        CMP  Intersect ,1                  ;if if intersected go and generate another one
                        JZ   TrackRandom
                        CMP  Status ,1                     ;if if intersected go and generate another one
                        JZ   TrackRandom
    ;MOV  CL, RoadNum
    ;CMP  CurrentBlock,CL
                        CALL FAR PTR ENDTRACK
                        JZ   CheckKey
                        JMP  CheckKey                      ;return to check key pressed
    EndProgram:         
                        HLT
MAIN ENDP
    ;***********************************************************************
    ;generate random number
    ;***********************************************************************
GeneratRandomNumber proc near
                        mov  ax, seed
                        mov  bl,205
                        mov  bh ,RandomValue
                        mov  cx, 5245
                        imul bx
                        add  ax, cx
                        mov  seed,ax
    ; Generate random number in range 0 to 10
                        mov  dx, seed
                        xor  ah, ah                        ; Clear the upper byte of DX
                        mov  bx, 10                        ; Maximum value (exclusive)
                        xor  dx, dx                        ; Clear the upper word of DX
                        div  bx
                        mov  ax, dx                        ; Resulting random number is stored in AX
                        mov  RandomValue,al
                        ret
GeneratRandomNumber endp
    ;***********************************************************************
    ;generate a track go make 1-start vieo mode 2-random value then 3-go to one direction
    ;do it again untile the road number ==CurrentBlock
    ;Regester: AX
    ;***********************************************************************
GenerateTrack proc far
                        MOV  AX,StatingPointX              ;put the value of x-axis with inintial point
                        MOV  XAxis,AX

                        MOV  AX,StatingPointY              ;put the value of y-axis with inintial point
                        MOV  YAxis,AX

                        MOV  AH ,00                        ;video mode
                        MOV  AL,13H
                        INT  10H

                        MOV  AH ,08H                       ;write in page0
                        MOV  BH ,00
                        INT  10H
                        mov  Intersect,0
                        MOV  CurrentBlock,0
                        mov  LastDirection,1
                        mov  Status,0
                        call far ptr RightDirection        ;at the begain of the track mov up

    Road:               
                        MOV  BI,0
                        MOV  BO,0
                        CMP  Intersect,1                   ;make sure that there is no intersection
                        JZ   EEXIT
    ;if there return
                        CMP  Status,1                      ;make sure that NOT OUT OF WINDOW
                        JZ   EEXIT

                        MOV  CL ,RoadNum
                        CMP  CurrentBlock,CL               ;CHECK IF THE NUMBER OF STEPS NEEDED IS DONE
                        JZ   EEXIT

                        call GeneratRandomNumber
                        CMP  RandomValue,3                 ; if(num<=2) move to Right
                        JlE  RRight
                        CMP  RandomValue,5                 ; if(num<=5) move to Left
                        JlE  up
                        CMP  RandomValue,7                 ; if(num<=8) move to UP
                        JlE  Left
                        CMP  RandomValue,9
                        JlE  Down
                        jmp  Road
    RRight:             
                        jmp  Right
    EEXIT:              
                        ret                                ; if(num==9) move to Right
    UP:                 
                        MOV  BI,0
                        MOV  BO,0
                        MOV  CX,XAxis
                        MOV  DX, YAxis
                        SUB  DX,StepValue
                        CALL FAR PTR CheckBefore           ;make sure that you can go this direction
                        CMP  BI,1                          ;make sure that there is no intersection
                        JZ   Down
                        CMP  BO,1                          ;make sure that NOT OUT OF WINDOW
                        JZ   Down
                        call far ptr UpDirection           ; calling move up
                        jmp  Road                          ;return to creat randam number again
    Down:               
                        MOV  BI,0
                        MOV  BO,0
                        MOV  CX,XAxis
                        MOV  DX, YAxis
                        ADD  DX,StepValue
                        CALL FAR PTR CheckBefore           ;make sure that you can go this direction
                        CMP  BI,1                          ;make sure that there is no intersection
                        JZ   Left
                        CMP  BO,1                          ;make sure that NOT OUT OF WINDOW
                        JZ   Left
                        call far ptr DownDirection         ; calling move down
                        jmp  Road                          ;return to creat randam number again
    Left:               
                        MOV  BI,0
                        MOV  BO,0
                        MOV  CX,XAxis
                        SUB  CX,StepValue
                        MOV  DX, YAxis
                        CALL FAR PTR CheckBefore           ;make sure that you can go this direction
                        CMP  BI,1                          ;make sure that there is no intersection
                        JZ   Right
                        CMP  BO,1                          ;make sure that NOT OUT OF WINDOW
                        JZ   Right
                        call far ptr LeftDirection
                        jmp  Road                          ;return to creat randam number again
    FROAD:              
                        JMP  FAR PTR Road
    Right:              
                        MOV  BI,0
                        MOV  BO,0
                        MOV  CX,XAxis
                        ADD  CX,StepValue
                        MOV  DX, YAxis
                        CALL FAR PTR CheckBefore
                        CMP  BI,1
                        JZ   FROAD                         ;make sure that there is no intersection
                        CMP  BO,1                          ;make sure that NOT OUT OF WINDOW
                        JZ   FROAD
                        call far ptr RightDirection        ; calling move up
                        jmp  Road                          ;return to creat randam number again
    EXIT:               
                        ret
GenerateTrack endp
    ;***********************************************************************
    ;MAKE CHECK BEFORE GOING TO ANY DIRECTION( I SET DX AND CX BEFORE CALLING PROC)
    ;Regester: AX
    ;***********************************************************************
CheckBefore proc far
                        MOV  AH ,0DH                       ;get the color of the pixel in al
                        INT  10H
                        CMP  AL, 8                         ;same as red check Gray
                        jz   BInersected
                        CMP  AL, 0fh                       ;same as red check Gray
                        jz   BInersected
                        CMP  DX,WindowHight
                        JGE  Bout
                        CMP  CX,WindowWidth
                        JGE  Bout
                        CMP  DX,10
                        JlE  Bout
                        CMP  CX,10
                        JlE  Bout
                        RET
    BInersected:        
                        MOV  BI,1                          ;move intersect to be 1 indicate thet there is intersection
                        ret
    Bout:               
                        MOV  BO,1                          ;move intersect to be 1 indicate thet there is intersection
                        ret
CheckBefore endp
    ;***********************************************************************
    ;GO RIGHT DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO RIGHT DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
RightDirection proc far
                        cmp  LastDirection,0               ;if the last direction is up it esay to go up
                        jz   GoUPRight

                        cmp  LastDirection,3               ;if the last direction is down we will  return
                        jz   farGoDownRight

                        cmp  LastDirection,1               ; if the last direction is right we will make Uturn
                        jz   farGoRight

                        cmp  LastDirection,2               ; if the last direction is left we will make Uturn
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
                        jmp  GoRight                       ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDownRight:        
                        CALL FAR PTR DRAndLU
                        JMP  FixGoDownRight
    fExitRight:         
                        ret
    FixGoDownRight:     
                        CALL FAR PTR FixURAndDR
                        jmp  GoRight                       ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRight:            
                        MOV  CX,XAxis                      ;start from the middle
                        MOV  BX ,XAxis                     ;SAVE THE END POINT IN SI   X+STEPVALUE
                        ADD  BX,StepValue
    FirstLoopRight:     
                        MOV  DX,YAxis                      ;start from the middle -width  going to ->middle +width
                        SUB  DX,TrackWidth
                        MOV  SI,0                          ;indicat how many pixel i draw right now to make red walls
    ;draw the wall left
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   fExitRight
                        cmp  Status,1
                        JZ   fExitRight
                        CALL FAR PTR ColorWall             ; COLOR OF WALL IS RED
                        INC  DX
    SecondLoopRight:    
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   fExitRight
                        cmp  Status,1
                        JZ   fExitRight

                        CMP  SI ,TrackWidth-1
                        JNZ  M
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUE
    M:                  
                        CALL FAR PTR ColorRoad
    CONTINUE:           
                        INC  DX                            ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                        INC  SI                            ;INC counter
                        CMP  SI,2*TrackWidth-1             ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopRight
    ;draw the wall Right
                        CALL FAR PTR ColorWall             ; COLOR OF WALL IS RED
                        INC  CX                            ;GO UP BY dec the value of row
                        CMP  CX,BX                         ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopRight
                        MOV  XAxis,BX                      ;set y-axis with the new value
                        JMP  ExitRight                     ;go to generte randam number agian
    ExitRight:          
                        MOV  LastDirection ,1
                        INC  CurrentBlock                  ;inc the counter of road blocks
                        ret
RightDirection endp
    ;***********************************************************************
    ;GO LEFT DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO LEFT DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
LeftDirection proc far
                        cmp  LastDirection,0               ;if the last direction is up it esay to go up
                        jz   GoUPLeft
                        cmp  LastDirection,3               ;if the last direction is down we will  return
                        jz   farGoDownLeft
                        cmp  LastDirection,1               ; if the last direction is right we will make Uturn
                        jz   farExitLeft
                        cmp  LastDirection,2               ; if the last direction is left we will make Uturn
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
                        jmp  GoLeft                        ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDownLeft:         
                        CALL FAR PTR DLAndRU
                        JMP  FixGoDownLeft
    FExitLeft:          
                        ret
    FixGoDownLeft:      
                        CALL FAR PTR FixULAndDL
                        jmp  GoLeft                        ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeft:             
                        MOV  CX,XAxis                      ;start from the middle
                        MOV  BX ,XAxis                     ;SAVE THE END POINT IN BX   X+STEPVALUE
                        SUB  BX,StepValue
    FirstLoopLeft:      
                        MOV  DX,YAxis                      ;start from the middle -width  going to ->middle +width
                        SUB  DX,TrackWidth
                        MOV  SI,0                          ;start a counter
    ;draw the wall left
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   FExitLeft
                        cmp  Status,1
                        JZ   FExitLeft
                        CALL FAR PTR ColorWall
                        INC  DX
    SecondLoopLeft:     
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   FExitLeft
                        cmp  Status,1
                        JZ   FExitLeft
                        CMP  SI ,TrackWidth-1
                        JNZ  LEF
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUELEFT
    LEF:                
                        CALL FAR PTR ColorRoad
    CONTINUELEFT:       
                        INC  DX                            ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                        INC  SI                            ;INC counter
                        CMP  SI,2*TrackWidth-1             ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopLeft
    ;draw the wall Right
                        CALL FAR PTR ColorWall
                        DEC  CX                            ;GO UP BY dec the value of row
                        CMP  CX,BX                         ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopLeft
                        MOV  XAxis,BX                      ;set y-axis with the new value
                        JMP  ExitLeft                      ;go to generte randam number agian
    ExitLeft:           
                        MOV  LastDirection ,2
                        INC  CurrentBlock                  ;inc the counter of road blocks
                        ret
LeftDirection endp
    ;***********************************************************************
    ;GO UP DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO UP DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
UpDirection proc far
                        cmp  LastDirection,0               ;if the lst direction is up it esay to go up
                        jz   GoUp
                        cmp  LastDirection,3               ;if the last direction is down we will not return
                        jz   farExitUP
                        cmp  LastDirection,1               ; if the last direction is right we will make Uturn
                        jz   GoRightUp
                        cmp  LastDirection,2               ; if the last direction is left we will make Uturn
                        jz   farGoLeftUp
    farExitUP:          
                        ret
    farGoLeftUp:        
                        jmp  far ptr GoLeftUp
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoUp:               
                        MOV  BX,YAxis                      ;END point of row
                        SUB  BX,StepValue
                        MOV  DX,YAxis                      ;put the valus of y-axis ->row
    FirstLoopUP:        
                        MOV  CX,XAxis                      ;start from the middle -width  to ->middle +width
                        SUB  CX,TrackWidth
                        MOV  SI,0                          ;restart counter
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   farExitUP
                        cmp  Status,1
                        JZ   farExitUP
                        CALL FAR PTR ColorWall
                        INC  CX                            ;move to the next right pixel
    SecondLoopUP:       
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   farExitUP
                        cmp  Status,1
                        JZ   farExitUP
                        CMP  SI ,TrackWidth-1
                        JNZ  U
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUEUP
    U:                  
                        CALL FAR PTR ColorRoad
    CONTINUEUP:         
                        INC  CX
                        INC  SI                            ;INC counter
                        CMP  SI,2*TrackWidth-1             ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopUP
                        CALL FAR PTR ColorWall
                        DEC  DX                            ;GO UP BY dec the value of row
                        CMP  DX,BX                         ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopUP
                        MOV  YAxis,BX                      ;set y-axis with the new value
                        JMP  ExitUP                        ;go to generte randam number agian
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoRightUp:          
                        CALL FAR PTR DLAndRU
    FixGoRightUp:       
                        CALL FAR PTR FixLUAndRU
                        jmp  GoUp                          ;go up some pixels
    FExitup:            
                        ret
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoLeftUp:           
                        CALL FAR PTR DRAndLU               ;if the end point =0 exit loop
    FixGoLeftUp:        
                        cALL FAR PTR FixLUAndRU
                        jmp  GoUp                          ;go up some pixels
    ExitUP:             
                        MOV  LastDirection ,0
                        INC  CurrentBlock                  ;inc the counter of road blocks
                        ret
UpDirection endp
    ;***********************************************************************
    ;GO DOWN DIRECTION MAKE SOME CHECKS TO KNOW IF THERE ANY TURNS OR NOT
    ;IF THERE ANY TURNS MAKE TURN THEN TO DOWN DIRECTION
    ;Regester: SI ,DX ,CX,BX
    ;***********************************************************************
DownDirection proc far
                        cmp  LastDirection,0               ;if the lst direction is up it esay to go up
                        jz   farExiTDown
                        cmp  LastDirection,3               ;if the last direction is down we will not return
                        jz   GoDown
                        cmp  LastDirection,1               ; if the last direction is right we will make Uturn
                        jz   GoRightDown
                        cmp  LastDirection,2               ; if the last direction is left we will make Uturn
                        jz   farGoLeftDown
    farExitDown:        
                        RET
    farGoLeftDown:      
                        jmp  far ptr GoLeftDown
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    GoDown:             
                        MOV  BX,YAxis                      ;END point of row
                        add  BX,StepValue
                        MOV  DX,YAxis                      ;put the valus of y-axis ->row
    FirstLoopDown:      
                        MOV  CX,XAxis                      ;start from the middle -width  to ->middle +width
                        SUB  CX,TrackWidth
                        MOV  SI,0                          ;restart counter
    ;draw the wall left
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   farExitDown
                        cmp  Status,1
                        JZ   farExitDown
                        CALL FAR PTR ColorWall
                        INC  CX                            ;move to the next right pixel
    SecondLoopDown:     
                        CALL FAR PTR CheckIfIntersected
                        CMP  Intersect ,1
                        JZ   farExitDown
                        cmp  Status,1
                        JZ   farExitDown
                        CMP  SI ,TrackWidth-1
                        JNZ  DO
                        CALL FAR PTR ColorRoadLanes
                        JMP  CONTINUEDOWN
    DO:                 
                        CALL FAR PTR ColorRoad
    CONTINUEDOWN:       
                        INC  CX                            ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                        INC  SI                            ;INC counter
                        CMP  SI,2*TrackWidth-1             ;compare the to current width with 2*TrackWidth
                        JNZ  SecondLoopDown
    ;draw the wall Right
                        CALL FAR PTR ColorWall
                        INC  DX                            ;GO UP BY dec the value of row
                        CMP  DX,BX                         ;see if the value movment in row equal to stepvlaue
                        JNZ  FirstLoopDown
                        MOV  YAxis,BX                      ;set y-axis with the new value
                        JMP  ExiTDown                      ;go to generte randam number agian
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
    ;chech if there is any intersection and if it out of the window borders
    ;Regester: only AX ( i oresdy setted the values of cx and dx befor calling)
    ;***********************************************************************
CheckIfIntersected proc far
                        MOV  AH ,0DH                       ;get the color of the pixel in al
                        INT  10H
                        CMP  AL, 8                         ;same as ROAD COLOR
                        jz   Inersected
                        CMP  AL, 0fh                       ;same as LINE OF ROAD
                        jz   Inersected
                        CMP  DX,WindowHight
                        JGE  outof
                        CMP  CX,WindowWidth
                        JGE  outof
                        CMP  DX,10
                        JlE  outof
                        CMP  CX,10
                        JlE  outof
                        RET
    Inersected:         
                        MOV  Intersect,1                   ;move intersect to be 1 indicate thet there is intersection
                        ret
    outof:              
                        MOV  Status,1                      ;move intersect to be 1 indicate that it out of the window
                        ret
CheckIfIntersected endp
    ;***********************************************************************
    ;Drow a pixel with the road color (Gray) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoad PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,8                         ;gray
                        INT  10H
                        RET
ColorRoad ENDP
    ;***********************************************************************
    ;Drow a pixel with the wall color (Yellow) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorWall PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,0eh                       ;yellow
                        INT  10H
                        RET
ColorWall ENDP
    ;***********************************************************************
    ;Drow a pixel with the line color (White) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoadLanes PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,0fh                       ;white
                        INT  10H
                        RET
ColorRoadLanes ENDP
    ;***********************************************************************
    ;Drow a pixel with the wall color (red) dx and cx setted before calling
    ;Regester: only AX
    ;***********************************************************************
ColorRoadEnd PROC FAR
                        MOV  AH ,0CH
                        MOV  AL ,4h                        ;red
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
                        MOV  CX,XAxis                      ;     **********
                        MOV  BH ,0                         ;     **********
    DLRU2:                                                 ;     **********
                        CALL FAR PTR ColorRoad             ;***************    THIS LINE  MADE BY FIXDLAndRU
                        INC  CX                            ;***************    THIS LINE  MADE BY FIXDLAndRU
                        INC  BH                            ;*************   ---
                        CMP  BH, BL                        ;***********        | --> DLAndRU
                        JNZ  DLRU2                         ;********      -----
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

end main



