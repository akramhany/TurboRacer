GenerateObstacles PROC FAR

                                PUSH          AX
                                PUSH          ES
                                PUSH          BX
                                PUSH          DX
                                PUSH          CX
                                PUSH          BP

                                MOV           OB_Direction, OB_RIGHT                 ;INITIAL DIRECTION IS RIGHT

                                MOV           AX, StatingPointX                      ;Set the OB_StartX with the starting pointX
                                ADD           AX, 12                                 ;TO GIVE A SPACE FOR THE CARS TO RESPAWN
                                MOV           OB_StartX, AX

                                MOV           AX, StatingPointY                      ;Set the OB_StartY with the starting pointY
                                MOV           OB_StartY, AX

                                ;LEA           BX, ArrX2
                                ;LEA           BP, ArrY2


    ;;loop to get a component in the track then draw obstacles in it then get then next component and so on, until the end
    GENERATE_NEW_RANDOM_OB:     
                                ;MOV           AX, OB_StartX
                                ;MOV           DS:[BX], AX
                                ;MOV           AX, OB_StartY
                                ;MOV           DS:[BP], AX
                                ;ADD           BX, 2
                                ;ADD           BP, 2
                                CALL          FAR PTR GetEndOfCurrentTrackComp       ;GET END OF CURRENT TRACK COMP AND STORE IN OB_EndX, OB_EndY

                                CALL          GeneratRandomNumber                    ;generates a random variable between 0 - 9

                                CMP           RandomValue, 6                         ;CHECK IF THE RANDOM VALUE IS GREATER THAN 6 THEN DON'T DRAW AN OBSTACLE
                                JG            OB_CONT

                                
                                CALL          FAR PTR DrawRandomObstacle             ;Draw A random obstacle in this segment of the track

    OB_CONT:                    
                                CALL          FAR PTR GetNextDirection               ;Get the next direction on the track

                                MOV           AX, OB_EndX
                                MOV           OB_StartX, AX                          ;Update the start X of the current track comp

                                MOV           AX, OB_EndY
                                MOV           OB_StartY, AX                          ;Update the start Y of the current track comp

                                CMP           OB_Direction, OB_NO_DIRECTION          ;Check if there are no available directions (except the last direction I came from)
                                JNE           GENERATE_NEW_RANDOM_OB


    AGAIN_SENDER_CLOSING_BIT_OBS:  	            
                                mov dx , 3FDH
                                In al , dx 			;Read Line Status
                                AND al , 00100000B
                                JZ AGAIN_SENDER_CLOSING_BIT_OBS

                                mov dx , 3F8H		
                                MOV AL, '#'
                                out dx , al


                                POP           BP
                                POP           CX
                                POP           DX
                                POP           BX
                                POP           ES
                                POP           AX

                                RET
GenerateObstacles ENDP


    ;description: draw an obstacle on the current component of the track
    ;
    ;
DrawRandomObstacle PROC FAR

                                PUSH          AX
                                PUSH          BX
                                PUSH          CX
                                PUSH          DX

                                CMP           OB_Direction, OB_UP                    ;check if the direction is vertical or horizontal
                                JE            VERTICAL_DIR
                                CMP           OB_Direction, OB_DOWN
                                JE            VERTICAL_DIR


    HORIZONTAL_DIR:             

                                MOV           BL, RandomValue                        ;store the random variable
                                MOV           BH, 0
                                MOV           CX, OB_StartX                          ;store the start X into CX
                                MOV           DX, OB_EndX                            ;store the end X  into DX
                                CALL          FAR PTR GenerateRandomNumBetTwoNums    ;Generate a random number between start X and end X

                                MOV           ObstaclePosX, AX                       ;Store the generated random X coordinates into the obstacle pos X

                                MOV           BL, RandomValue                        ;store the random variable
                                MOV           BH, 0
                                MOV           CX, OB_StartY
                                SUB           CX, 8                                  ;Store the starting Y coordinates in CX
                                MOV           DX, OB_StartY
                                ADD           DX, 8                                  ;Store the ending Y coordinates in DX
                                CALL          FAR PTR GenerateRandomNumBetTwoNums    ;generates a random number between the starting and the ending Y coordinates

                                MOV           ObstaclePosY, AX                       ;Store the generated Y coordinates into the obstacle pos Y
                                JMP           DRAW_OBSTACLE                          ;Jmp to draw the obstacle

    VERTICAL_DIR:               

                                MOV           BL, RandomValue                        ;store the random variable
                                MOV           BH, 0
                                MOV           CX, OB_StartY                          ;store the start Y into CX
                                MOV           DX, OB_EndY                            ;store the end Y  into DX
                                CALL          FAR PTR GenerateRandomNumBetTwoNums    ;generates a random number between the starting and the ending Y coordinates

                                MOV           ObstaclePosY, AX                       ;Store the generated Y coordinates into the obstacle pos Y

                                MOV           BL, RandomValue                        ;store the random variable
                                MOV           BH, 0
                                MOV           CX, OB_StartX
                                SUB           CX, 8                                  ;Store the starting X coordinates in CX
                                MOV           DX, OB_StartX
                                ADD           DX, 8                                  ;Store the ending X coordinates in DX
                                CALL          FAR PTR GenerateRandomNumBetTwoNums    ;generates a random number between the starting and the ending X coordinates

                                MOV           ObstaclePosX, AX                       ;Store the generated X coordinates into the obstacle pos X
                                JMP           DRAW_OBSTACLE

    DRAW_OBSTACLE:              
                                CALL          FAR PTR SendObstaclesPosition
                                CALL          FAR PTR DrawObstacle                   ;Draw the obstacle using the generated random values in ObstaclePosX, and ObstaclePosY


                                POP           DX
                                POP           CX
                                POP           BX
                                POP           AX

                                RET

DrawRandomObstacle ENDP

    ;description: generates a random value between two random values in CX, DX given a third value IN BX
    ;the randomv value at the end would be in AX
    ;the equation is -> ((X - Y) / 7) * Z + Y, where X is the bigger value and Y is the lower value and Z is the random value
GenerateRandomNumBetTwoNums PROC FAR
                                PUSH          BX
                                PUSH          CX
                                PUSH          DX

                                CMP           CX, DX                                 ;Compare CX, DX to see which is bigger
                                JL            DX_BIGGER                              ;if DX is bigger then go and swap them
                                JMP           CONT_GRNBTN                            ;if CX is bigger then its okay

    DX_BIGGER:                  
                                XCHG          DX, CX                                 ;Swap DX, CX

    CONT_GRNBTN:                
                                ADD           DX, 3
                                SUB           CX, 3

                                SUB           CX, DX                                 ;Subtract DX (smaller one) from CX
                                MOV           AX, CX                                 ;Move CX to AX
                                MOV           CX, 7                                  ;Set CX with 7 to divide by it
                                PUSH          DX                                     ;Store the initial value of DX

                                MOV           DX, 0                                  ;Set DX with 0 to divide
                                DIV           CX                                     ;Divide the difference between Start and End by 7 (stored in CX)

                                ADD           AH, 0
                                MOV           DX, 0                                  ;Set DX with 0 to multiply
                                MUL           BX                                     ;Multiply the value in AX with the Random Value

                                POP           DX                                     ;Restore DX
                                ADD           AX, DX                                 ;Add AX ,after performing the above instructions on it, to DX and store in AX


                                POP           DX
                                POP           CX
                                POP           BX

                                RET
GenerateRandomNumBetTwoNums ENDP

    ;description
GetNextDirection PROC FAR

                                PUSH          CX
                                PUSH          DX
                                PUSH          AX

    OB_CHECK_UP:                
                                CMP           OB_Direction, OB_DOWN                  ;CHECK TO AVOID THE DIRECTION WE CAME FROM
                                JE            OB_CHECK_RIGHT                         ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
                                MOV           CX, OB_EndX                            ;MOVE TO CX THE X VALUE OF THE END PIXEL
                                MOV           DX, OB_EndY                            ;MOVE TO DX THE Y VALUE OF THE END PIXEL
                                SUB           DX, 4                                  ;SUB 3 FROM Y TO CHECK THE PIXEL
                                GetPixelColor                                        ;GET THE PIXEL COLOR
                                CMP           AL, 0FH                                ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
                                JNE           OB_CHECK_RIGHT                         ;IF NOT JMP TO NEXT CHECK
                                MOV           OB_Direction, OB_UP
                                JMP           OB_EXIT                                ;EXIT BEC WE FOUND THE DIRECTION


    OB_CHECK_RIGHT:             
                                CMP           OB_Direction, OB_LEFT                  ;CHECK TO AVOID THE DIRECTION WE CAME FROM
                                JE            OB_CHECK_LEFT                          ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
                                MOV           CX, OB_EndX                            ;MOVE TO CX THE X VALUE OF THE END PIXEL
                                MOV           DX, OB_EndY                            ;MOVE TO DX THE Y VALUE OF THE END PIXEL
                                ADD           CX, 4                                  ;ADD 3 TO Y TO CHECK THE PIXEL
                                GetPixelColor                                        ;GET THE PIXEL COLOR
                                CMP           AL, 0FH                                ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
                                JNE           OB_CHECK_LEFT                          ;IF NOT JMP TO NEXT CHECK
                                MOV           OB_Direction, OB_RIGHT
                                JMP           OB_EXIT                                ;EXIT BEC WE FOUND THE DIRECTION

    OB_CHECK_LEFT:              
                                CMP           OB_Direction, OB_RIGHT                 ;CHECK TO AVOID THE DIRECTION WE CAME FROM
                                JE            OB_CHECK_DOWN                          ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
                                MOV           CX, OB_EndX                            ;MOVE TO CX THE X VALUE OF THE END PIXEL
                                MOV           DX, OB_EndY                            ;MOVE TO DX THE Y VALUE OF THE END PIXEL
                                SUB           CX, 4                                  ;SUB 3 FROM X TO CHECK THE PIXEL
                                GetPixelColor                                        ;GET THE PIXEL COLOR
                                CMP           AL, 0FH                                ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
                                JNE           OB_CHECK_DOWN                          ;IF NOT JMP TO NEXT CHECK
                                MOV           OB_Direction, OB_LEFT
                                JMP           OB_EXIT                                ;EXIT BEC WE FOUND THE DIRECTION

    OB_CHECK_DOWN:              
                                CMP           OB_Direction, OB_UP                    ;CHECK TO AVOID THE DIRECTION WE CAME FROM
                                JE            OB_CHECK_END                           ;JMP TO THE NEXT CHECK IF THIS IS THE DIRECTION WE CAME FROM
                                MOV           CX, OB_EndX                            ;MOVE TO CX THE X VALUE OF THE END PIXEL
                                MOV           DX, OB_EndY                            ;MOVE TO DX THE Y VALUE OF THE END PIXEL
                                ADD           DX, 4                                  ;ADD 3 TO Y TO CHECK THE PIXEL
                                GetPixelColor                                        ;GET THE PIXEL COLOR
                                CMP           AL, 0FH                                ;IF THE PIXEL IS WHITE THEN THIS IS THE DIRECTION WE WANT TO CONTINUE AT
                                JNE           OB_CHECK_END                           ;IF NOT JMP TO NEXT CHECK
                                MOV           OB_Direction, OB_DOWN
                                JMP           OB_EXIT                                ;EXIT BEC WE FOUND THE DIRECTION

    OB_CHECK_END:               
                                MOV           OB_Direction, OB_NO_DIRECTION
                                JMP           OB_EXIT

    OB_EXIT:                    

                                POP           AX
                                POP           DX
                                POP           CX

                                RET

GetNextDirection ENDP

    ;description: start from OB_Start then go along the white line to the next component
    ;
GetEndOfCurrentTrackComp PROC FAR

                                PUSH          DX
                                PUSH          CX
                                PUSH          BX
                                PUSH          AX

                                MOV           CX, OB_StartX                          ;move the start X value to CX
                                MOV           DX, OB_StartY                          ;move the start Y vallue to DX

    ;Ckeck what is the direction to go along
                                CMP           OB_Direction, OB_RIGHT
                                JE            GET_END_RIGHT
                                CMP           OB_Direction, OB_UP
                                JE            GET_END_UP
                                CMP           OB_Direction, OB_DOWN
                                JE            GET_END_DOWN
                                CMP           OB_Direction, OB_LEFT
                                JE            GET_END_LEFT

    ;Go along the Up direction and loop over the white line until
    ;there are no more white pixels so we know we reached the end of this component
    GET_END_UP:                 
                                DEC           DX                                     ;go up one pixel
                                GetPixelColor                                        ;get the pixel color
                                CMP           AL, 0FH                                ;check if it is white
                                JE            GET_END_UP                             ;if it is white loop again
                                INC           DX                                     ;if it is not white then return to the last white pixel and exit
                                JMP           T_CONT

    GET_END_RIGHT:              
                                INC           CX                                     ;go right one pixel
                                GetPixelColor                                        ;get the pixel color
                                CMP           AL, 0FH                                ;check if it is white
                                JE            GET_END_RIGHT                          ;if it is white loop again
                                DEC           CX                                     ;if it is not white then return to the last white pixel and exit
                                JMP           T_CONT

    GET_END_LEFT:               
                                DEC           CX                                     ;go left one pixel
                                GetPixelColor                                        ;get the pixel color
                                CMP           AL, 0FH                                ;check if it is white
                                JE            GET_END_LEFT                           ;if it is white loop again
                                INC           CX                                     ;if it is not white then return to the last white pixel and exit
                                JMP           T_CONT

    GET_END_DOWN:               
                                INC           DX                                     ;go down one pixel
                                GetPixelColor                                        ;get the pixel color
                                CMP           AL, 0FH                                ;check if it is white
                                JE            GET_END_DOWN                           ;if it is white loop again
                                DEC           DX                                     ;if it is not white then return to the last white pixel and exit
                                JMP           T_CONT

    T_CONT:                     
                                MOV           OB_EndX, CX                            ;Move the last pixel we are at to the OB_End
                                MOV           OB_EndY, DX                            ;Move the last pixel we are at to the OB_End

                                POP           AX
                                POP           BX
                                POP           CX
                                POP           DX

                                RET
GetEndOfCurrentTrackComp ENDP


    ;description: take a point in ObstaclePosX, ObstaclePosY
    ;then Draw a 5 * 5 pixles Obstacle in red
DrawObstacle PROC FAR

                                PUSH          AX
                                PUSH          BX
                                PUSH          CX
                                PUSH          DX
                                PUSH          ObstaclePosX
                                PUSH          ObstaclePosY
                                PUSH          DI

                                MOV           BL, 5
                                MOV           DI, 5
                                Sub           ObstaclePosX, 2
                                Sub           ObstaclePosY, 2

    OB_OUTER_LOOP:              
                                MOV           BL, 5

    OB_INNER_LOOP:              
                                MOV           AH, 0CH
                                MOV           AL, OBSTACLE_COLOR
                                MOV           BH, 0
                                MOV           CX, ObstaclePosX
                                MOV           DX, ObstaclePosY
                                INT           10H

                                INC           ObstaclePosX
                                DEC           BL
                                JNZ           OB_INNER_LOOP
                                INC           ObstaclePosY
                                SUB           ObstaclePosX, 5
                                DEC           DI
                                JNZ           OB_OUTER_LOOP

                                POP           DI
                                POP           ObstaclePosY
                                POP           ObstaclePosX
                                POP           DX
                                POP           CX
                                POP           BX
                                POP           AX

                                RET
DrawObstacle ENDP

;description
SendObstaclesPosition PROC FAR
    PUSH          AX
    PUSH          BX
    PUSH          CX
    PUSH          DX
    PUSH          ObstaclePosX
    PUSH          ObstaclePosY
    PUSH          DI

    MOV CX, ObstaclePosX

AGAIN_SENDER_OBS_X1:  	            
    mov dx , 3FDH
    In al , dx 			;Read Line Status
    AND al , 00100000B
    JZ AGAIN_SENDER_OBS_X1

    mov dx , 3F8H		
    MOV AL, CL
    out dx , al


AGAIN_SENDER_OBS_X2:  	            
    mov dx , 3FDH
    In al , dx 			;Read Line Status
    AND al , 00100000B
    JZ AGAIN_SENDER_OBS_X2

    mov dx , 3F8H		
    MOV AL, CH
    out dx , al
    MOV CX, ObstaclePosY

AGAIN_SENDER_OBS_Y1:  	            
    mov dx , 3FDH
    In al , dx 			;Read Line Status
    AND al , 00100000B
    JZ AGAIN_SENDER_OBS_Y1

    mov dx , 3F8H		
    MOV AL, CL
    out dx , al

AGAIN_SENDER_OBS_Y2:  	            
    mov dx , 3FDH
    In al , dx 			;Read Line Status
    AND al , 00100000B
    JZ AGAIN_SENDER_OBS_Y2

    mov dx , 3F8H		
    MOV AL, CH
    out dx , al

    POP           DI
    POP           ObstaclePosY
    POP           ObstaclePosX
    POP           DX
    POP           CX
    POP           BX
    POP           AX
    RET
SendObstaclesPosition ENDP