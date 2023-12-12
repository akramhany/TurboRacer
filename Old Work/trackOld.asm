



.MODEL SMALL
.STACK 64

.DATA

    TrackWidth    equ 8       ;half track width
    Red           db  4h      ;track wall
    White         db  0fh     ;track road
    GenTrack      db  31h     ;the key to generate another track
    EndKey        db  1bh     ;the key to end
    StatingPointX dw  160     ;starting point in x-axis
    StatingPointY dw  150     ;starting point in y-axis
    XAxis         dw  0       ;x-axis for the middel of road
    YAxis         dw  0       ;y-axis for the middel point of road
    RandomValue   db  0       ;to generate the track -> if the number >=2 go right  number >=5 go left number >=8 go up else go down
    StepValue     equ 20      ;step value after getting the direction( how many steps will draw every loop)
    WindowHight   dw  0c8h    ;the max hight of window  ****-->>>>>>>>>>> NOTE THAT THERE IS A STAUTS BAR SHOULD BE SUBTRACTED FROM TEH MAXHIGHT!!
    WindoWidth    dw  140h    ;the max hight ofwindow
    LastDirection db  0       ;indicat the last direction if 0->up 1->right  2->left  3->down
    Status        db  0       ; 0->inside window   1->out of the border of window
    Intersect     db  0       ;0->no intersection  1->intersected


.CODE
MAIN PROC FAR
                           MOV  DX ,@data
                           MOV  DS ,DX



    CheckKey:
                           MOV  AH ,01H
                           INT  16H
                           JZ   CheckKey


                           MOV  AH ,00h                   ;check which key is being pressed
                           INT  16h                       ;the pressed key in al
                           CMP  al,GenTrack               ;if it enter so generate another track
                           JZ   TrackRandom

                           CMP  al ,EndKey                ;check if it ESC to end the porgram
                           JZ   EndProgram                ;go to hlt
                           JMP  CheckKey

    TrackRandom:
                           CALL far ptr GenerateTrack     ;call to generate porcedure
                           CMP  Intersect ,1              ;if if intersected go and generate another one
                           JZ   TrackRandom
                           JMP  CheckKey                  ;return to check key pressed

    EndProgram:

                           HLT


MAIN ENDP

    ;;Description:
    ;Generat a Random number which help in generating a random track every time  (from 0-> 10 )
    ;if (num <=2)
    ;   go right <-
    ;else if(num>2&&num<=5)
    ;   go left ->
    ;esle if (num >5&&num <=8)
    ; go up  ^
    ;esle
    ;go down

    ;;Input

    ;;Registers:
    ; AX,CX,DX


GeneratRandomNumber proc near

                           MOV  AH, 2ch                   ;get sysytem time to get the dx mellisecond
                           INT  21h

                           MOV  AX,DX                     ;mov to ax to be diveded by 10 to generate random number form (0->9)
                           MOV  CX, 10                    ;the inverval of the random number  from (0 to bx)
                           DIV  CX                        ;dx have the random number

                           MOV  RandomValue,DL            ;keep the random number in the variable RandomValue

                           ret
GeneratRandomNumber endp

    ;;Description:
    ;generate a random track by getting random number to go to any direction of the three
    ;-------------------------------------
    ;  middl point (x,y)
    ;-------------------------------------
    ;go right by adding 1 to x-axis and draw form up to down
    ;go left by sub 1 from x-axis and draw form up to down
    ;go up by sub on form y-axis and draw form left to write
    ;go down by adding 1 to y-axis and draw it form left to write
    ;end point when the point to be draw is out of the range of window  (stop)
    ;road with white and its wall red





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
                           MOV  LastDirection ,0
                           call far ptr UpDirection       ;at the begain of the track mov up









    Road:
                           CMP  Intersect,1               ;make sure that there is no intersection
                           JZ   EXIT                      ;if there return
                           call GeneratRandomNumber
                           CMP  RandomValue,2             ; if(num<=2) move to Right
                           JLE  Right
                           CMP  RandomValue,5             ; if(num<=5) move to Left
                           JLE  Left
                           CMP  RandomValue,8             ; if(num<=8) move to UP
                           JLE  UP
                           JMP  Down                      ; if(num==9) move to Right



    UP:
                           call far ptr UpDirection       ; calling move up
                           jmp  Road                      ;return to creat randam number again
    Down:
                           call far ptr DownDirection     ; calling move down
                           jmp  Road                      ;return to creat randam number again
    Left:
                           call far ptr LeftDirection
                           jmp  Road                      ;return to creat randam number again
    Right:

                           call far ptr RightDirection    ; calling move up
                           jmp  Road                      ;return to creat randam number again
    EXIT:
                           ret
GenerateTrack endp




RightDirection proc far
                           cmp  LastDirection,0           ;if the last direction is up it esay to go up
                           jz   GoUPRight

                           cmp  LastDirection,3           ;if the last direction is down we will  return
                           jz   GoDownRight

                           cmp  LastDirection,1           ; if the last direction is right we will make Uturn
                           jz   farGoRight

                           cmp  LastDirection,2           ; if the last direction is left we will make Uturn
                           jz   FarExitRight
    FarExitRight:
                           jmp  ExitRight
    farGoRight:
                           JMP  FAR PTR GoRight
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    GoUPRight:
                           MOV  DX ,YAxis                 ;move the Y in cx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter
    FirstLooptUPRight:
                           MOV  CX,XAxis                  ;move row vlaue in dx
                           MOV  BH ,0                     ;COUNTER to compare with bl

    SecondLoopUPRihgt:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitRight
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  CX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopUPRihgt
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL
                           DEC  DX                        ;go right
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLooptUPRight

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoUPRight:

                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  CX,XAxis

                           MOV  BX,XAxis                  ;he end point in y-axis to reach
                           ADD  BX,TrackWidth
    FixFirstLoopUPRight:
                           MOV  DX,YAxis                  ;will be incremented by step size
                           MOV  SI ,0
    FixSecondLoopUPRight:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitRight
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  DX                        ;DEC ROW by one to draw VIRTICAL line the width is trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with TrackWidth
                           JNZ  FixSecondLoopUPRight
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           INC  CX                        ;GO RIGHT BY INC the value of row
                           CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopUPRight

                           MOV  XAxis,BX                  ;set y-axis with the new value
                           jmp  GoRight                   ;go up some pixels

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    GoDownRight:
                           MOV  CX ,XAxis                 ;move the Y in cx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter
    FirstLooptDownRight:
                           MOV  DX,YAxis                  ;move row vlaue in dx
                           MOV  BH ,0                     ;COUNTER to compare with bl

    SecondLoopDownRihgt:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitRight

                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopDownRihgt
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL
                           DEC  CX                        ;go right
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLooptDownRight

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoDownRight:

                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  CX,XAxis

                           MOV  BX,XAxis                  ;he end point in y-axis to reach
                           ADD  BX,TrackWidth
    FixFirstLoopDwonRight:
                           MOV  DX,YAxis                  ;will be incremented by step size
                           MOV  SI ,0
    FixSecondLoopDwonRight:

                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitRight

                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;DEC ROW by one to draw VIRTICAL line the width is trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with TrackWidth
                           JNZ  FixSecondLoopDwonRight
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           INC  CX                        ;GO RIGHT BY INC the value of row
                           CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopDwonRight

                           MOV  XAxis,BX                  ;set y-axis with the new value
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

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           INC  DX
    SecondLoopRight:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitRight

                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                           JNZ  SecondLoopRight
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           INC  CX                        ;GO UP BY dec the value of row

                           CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FirstLoopRight

                           MOV  XAxis,BX                  ;set y-axis with the new value
                           JMP  ExitRight                 ;go to generte randam number agian



    ExitRight:
                           MOV  LastDirection ,1
                           ret
RightDirection endp


LeftDirection proc far
                           cmp  LastDirection,0           ;if the last direction is up it esay to go up
                           jz   GoUPLeft

                           cmp  LastDirection,3           ;if the last direction is down we will  return
                           jz   GoDownLeft

                           cmp  LastDirection,1           ; if the last direction is right we will make Uturn
                           jz   farExitLeft

                           cmp  LastDirection,2           ; if the last direction is left we will make Uturn
                           jz   FarGoLeft
    FarExitLeft:
                           jmp  far ptr ExitLeft
    farGoLeft:
                           JMP  FAR PTR GoLeft
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    GoUPLeft:
                           MOV  DX ,YAxis                 ;move the Y in cx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter
    FirstLooptUPLeft:
                           MOV  CX,XAxis                  ;move row vlaue in dx
                           MOV  BH ,0                     ;COUNTER to compare with bl

    SecondLoopUPLeft:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitLeft

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  CX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopUPLeft
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL
                           DEC  DX                        ;go right
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLooptUPLeft

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoUPLeft:

                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  CX,XAxis

                           MOV  BX,XAxis                  ;he end point in y-axis to reach
                           SUB  BX,TrackWidth
    FixFirstLoopUPLeft:
                           MOV  DX,YAxis                  ;will be incremented by step size
                           MOV  SI ,0
    FixSecondLoopUPLeft:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitLeft

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  DX                        ;DEC ROW by one to draw VIRTICAL line the width is trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with TrackWidth
                           JNZ  FixSecondLoopUPLeft
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           DEC  CX                        ;GO RIGHT BY INC the value of row
                           CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopUPLeft

                           MOV  XAxis,BX                  ;set y-axis with the new value
                           jmp  GoLeft                    ;go up some pixels

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    GoDownLeft:
                           MOV  DX ,YAxis                 ;move the Y in cx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter
    FirstLooptDownLeft:
                           MOV  CX,XAxis                  ;move row vlaue in dx
                           MOV  BH ,0                     ;COUNTER to compare with bl

    SecondLoopDownleft:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitLeft

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  CX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopDownleft
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL
                           INC  DX                        ;go right
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLooptDownLeft

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoDownLeft:

                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  CX,XAxis

                           MOV  BX,XAxis                  ;he end point in y-axis to reach
                           SUB  BX,TrackWidth
    FixFirstLoopDwonLeft:
                           MOV  DX,YAxis                  ;will be incremented by step size
                           MOV  SI ,0
    FixSecondLoopDwonLeft:

                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitLeft

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;DEC ROW by one to draw VIRTICAL line the width is trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with TrackWidth
                           JNZ  FixSecondLoopDwonLeft
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           DEC  CX                        ;GO RIGHT BY INC the value of row
                           CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopDwonLeft

                           MOV  XAxis,BX                  ;set y-axis with the new value
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

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           INC  DX
    SecondLoopLeft:
                           CALL FAR CheckIfIntersected    ;CHECK IF THER IS ANY ENTERSECTIONS
                           CMP  Intersect,1
                           JZ   ExitLeft

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                           JNZ  SecondLoopLeft
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  CX                        ;GO UP BY dec the value of row

                           CMP  CX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FirstLoopLeft

                           MOV  XAxis,BX                  ;set y-axis with the new value
                           JMP  ExitLeft                  ;go to generte randam number agian



    ExitLeft:
                           MOV  LastDirection ,2
                           ret
LeftDirection endp



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
                           jmp  far ptr ExitUP
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
    ;draw the wall left
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           INC  CX                        ;move to the next right pixel
    SecondLoopUP:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                           JNZ  SecondLoopUP
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           DEC  DX                        ;GO UP BY dec the value of row

                           CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FirstLoopUP

                           MOV  YAxis,BX                  ;set y-axis with the new value
                           JMP  ExitUP                    ;go to generte randam number agian

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    GoRightUp:
                           MOV  CX , XAxis                ;move the Y in cx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter
    FirstLoopRightUP:
                           MOV  DX,YAxis                  ;move row vlaue in dx
                           MOV  BH ,0                     ;COUNTER to compare with bl
    SecondLoopRihgtUP:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopRihgtUP
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL
                           INC  CX                        ;go right
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLoopRightUP


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoRightUp:
                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  DX,YAxis
                           MOV  BX,YAxis                  ;he end point in y-axis to reach
                           SUB  BX,TrackWidth
    FixFirstLoopRightUP:
                           MOV  CX,XAxis                  ;will be incremented by step size
                           MOV  SI ,0
    FixSecondLoopRightUP:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with TrackWidth
                           JNZ  FixSecondLoopRightUP
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  DX                        ;GO UP BY dec the value of row

                           CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopRightUP

                           MOV  YAxis,BX                  ;set y-axis with the new value
                           jmp  GoUp                      ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    GoLeftUp:
                           MOV  CX,XAxis                  ;move the column in dx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter

    FirstLoopLeftUP:
                           MOV  DX , YAxis                ;move the row in cx which will be incremented by si
                           MOV  BH ,0                     ;COUNTER to compare with bl

    SecondLoopLeftUP:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  DX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopLeftUP
    ;draw the wall LEFT
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL                        ;dec end piont
                           DEC  CX                        ;go left
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLoopLeftUP

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoLeftUp:

                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  DX,YAxis                  ;will be incremented by step size
                           MOV  BX,YAxis                  ;he end point in y-axis to reach
                           SUB  BX,TrackWidth
    FixFirstLoopLeftUP:
                           MOV  CX,XAxis
                           MOV  SI,0
    FixSecondLoopLeftUP:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExitUP

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with 2*TrackWidth
                           JNZ  FixSecondLoopLeftUP
    ;draw the wall LEFT
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  DX                        ;GO UP BY dec the value of row

                           CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopLeftUP

                           MOV  YAxis,BX                  ;set y-axis with the new value
                           jmp  GoUp                      ;go up some pixels


    ExitUP:
                           MOV  LastDirection ,0
                           ret
UpDirection endp

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
                           jmp  far ptr ExiTDown
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
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           INC  CX                        ;move to the next right pixel
    SecondLoopDown:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExiTDown

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,2*TrackWidth-1         ;compare the to current width with 2*TrackWidth
                           JNZ  SecondLoopDown
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ;COLOR OF WALL IS RED
                           INT  10H
                           INC  DX                        ;GO UP BY dec the value of row

                           CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FirstLoopDown

                           MOV  YAxis,BX                  ;set y-axis with the new value
                           JMP  ExiTDown                  ;go to generte randam number agian

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    GoRightDown:
                           MOV  CX , XAxis                ;move the Y in cx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter
    FirstLoopRighDown:
                           MOV  DX,YAxis                  ;move row vlaue in dx
                           MOV  BH ,0                     ;COUNTER to compare with bl
    SecondLoopRihgtDown:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExiTDown

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  DX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopRihgtDown
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL
                           INC  CX                        ;go right
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLoopRighDown


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoRightDwon:
                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  DX,YAxis
                           MOV  BX,YAxis                  ;he end point in y-axis to reach
                           add  BX,TrackWidth
    FixFirstLoopRightDown:
                           MOV  CX,XAxis                  ;will be incremented by step size
                           MOV  SI ,0
    FixSecondLoopRightDown:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExiTDown

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           INC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with TrackWidth
                           JNZ  FixSecondLoopRightDown
    ;draw the wall Right
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           INC  DX                        ;GO UP BY dec the value of row

                           CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopRightDown

                           MOV  YAxis,BX                  ;set y-axis with the new value
                           jmp  GoDown                    ;go up some pixels
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    GoLeftdown:
                           MOV  CX,XAxis                  ;move the column in dx
                           MOV  BL,TrackWidth             ;the end of the intier loop
                           MOV  BH ,0                     ;initioalize a counter

    FirstLoopLeftdown:
                           MOV  DX , YAxis                ;move the row in cx which will be incremented by si
                           MOV  BH ,0                     ;COUNTER to compare with bl

    SecondLoopLeftdwon:
                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExiTDown

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  DX                        ;go down
                           INC  BH                        ;inc counter
                           CMP  BH, BL                    ;compare teh counter with end point
                           JNZ  SecondLoopLeftdwon
    ;draw the wall LEFT
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           DEC  BL                        ;dec end piont
                           DEC  CX                        ;go left
                           CMP  BL,0                      ;if the end point =0 exit loop
                           JNZ  FirstLoopLeftdown

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FixGoLeftdown:

                           MOV  SI,0                      ;indicat how many pixel i draw right now to make red walls
                           MOV  DX,YAxis                  ;will be incremented by step size
                           MOV  BX,YAxis                  ;he end point in y-axis to reach
                           ADD  BX,TrackWidth
    FixFirstLoopLeftdown:
                           MOV  CX,XAxis
                           MOV  SI,0
    FixSecondLoopLeftdown:

                           CALL FAR CheckIfIntersected
                           CMP  Intersect,1
                           JZ   ExiTDown

                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,White
                           INT  10H
                           DEC  CX                        ;inc column by one to draw horizontal line the width is 2*trackwidth without wall
                           INC  SI                        ;INC counter
                           CMP  SI,TrackWidth             ;compare the to current width with 2*TrackWidth
                           JNZ  FixSecondLoopLeftdown
    ;draw the wall LEFT
                           MOV  AH ,0CH                   ;draw a pixcel
                           MOV  AL ,red                   ; COLOR OF WALL IS RED
                           INT  10H
                           INC  DX                        ;GO UP BY dec the value of row

                           CMP  DX,BX                     ;see if the value movment in row equal to stepvlaue
                           JNZ  FixFirstLoopLeftdown

                           MOV  YAxis,BX                  ;set y-axis with the new value
                           jmp  GoDown                    ;go up some pixels


    EXITDown:
                           MOV  LastDirection ,3
                           ret
DownDirection endp


CheckIfIntersected proc far

                           MOV  AH ,0DH                   ;get the color of the pixel in al
                           INT  10H
                           CMP  AL,Red                    ;check if the pixel color is red
                           jnz  Inersected                ;if it not colored by the road color exit
                           CMP  AL, White                 ;same as red check white
                           jnz  Inersected
                           MOV  Intersect,1               ;move intersect to be 1 indicate thet there is intersection
    Inersected:
                           ret
CheckIfIntersected endp

end main



