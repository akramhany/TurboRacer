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
    MOV  AH, 2ch                   ;get sysytem time to get the dx mellisecond
    INT  21h
    MOV STARTTIME1,DH
    MOV COUNT1,5
    MOV ACTIVEUP_CAR1,1

P12:CMP SPEEDDOWN_CAR1,1
    JNZ P13

    CMP SPEED2,0
    JE CANCEL

    DEC SPEED2
    DEC SPEEDDOWN_CAR1
    MOV  AH, 2ch                   ;get sysytem time to get the dx mellisecond
    INT  21h
    MOV STARTTIME1,DH
    MOV COUNT1,5
    MOV ACTIVEDOWN_CAR1,1

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
    MOV AL, OBSTACLE_COLOR
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
    MOV AL, OBSTACLE_COLOR
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
    MOV AL, OBSTACLE_COLOR
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
    MOV AL, OBSTACLE_COLOR
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

PASS1:CMP PASS_CAR1,1
    JNE EXIT10
    MOV PASS_CAR1,0
    MOV CANPASS_CAR1,1


EXIT10:
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
    MOV  AH, 2ch                   ;get sysytem time to get the dx mellisecond
    INT  21h
    MOV STARTTIME2,DH
    MOV COUNT2,5
    MOV ACTIVEUP_CAR2,1


P22:CMP SPEEDDOWN_CAR2,1
    JNZ P23

    CMP SPEED1,0
    JE CANCEL2
    DEC SPEED1
    DEC SPEEDDOWN_CAR2
    MOV  AH, 2ch                   ;get sysytem time to get the dx mellisecond
    INT  21h
    MOV STARTTIME2,DH
    MOV COUNT2,5
    MOV ACTIVEDOWN_CAR2,1

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
    MOV AL, OBSTACLE_COLOR
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
    MOV AL, OBSTACLE_COLOR
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
    MOV AL, OBSTACLE_COLOR
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
    MOV AL, OBSTACLE_COLOR
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
    CMP PASS_CAR2,1
    JNZ EXIT11
    MOV PASS_CAR2,0 
    MOV CANPASS_CAR2,1
EXIT11:    
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_UP_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
    JE SPEED3
    DEC SI
    LOOP LOOP12

    JMP EXIT4

SPEED3:
    CMP SPEED2 , 0
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
    CMP AL,SPEED_DOWN_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
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
    CMP AL,SPEED_DOWN_COLOR
    JE SPEED6
    DEC SI
    LOOP LOOP16

    JMP EXIT5

SPEED6:
    CMP SPEED1,0
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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
    CMP AL,GENERATE_OBSTACLE_COLOR
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                  PASS OBSTACLE CAR1                                          ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PASSOBSTACLE_CAR1 PROC FAR
CMP STATE1 , 0      
    JNZ RIGHTPASSOBS

    MOV SI,TOP1
    MOV CX,WIDTH1
LOOP33:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS11
    INC SI
    LOOP LOOP33

    JMP EXIT8

PASSOBS11:
    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,0
    MOV PASS_CAR1 , 1

    JMP EXIT8

RIGHTPASSOBS:
    CMP STATE1 , 1
    JNZ LEFTPASSOBS

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP34:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS12
    ADD SI,320
    LOOP LOOP34
    JMP EXIT8
PASSOBS12:

    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,0
    MOV PASS_CAR1 , 1

    JMP EXIT8

LEFTPASSOBS:
    CMP STATE1,2
    JNZ DOWNPASSOBS

    MOV AX,TOP1
    MOV SI,AX
    MOV CX,WIDTH1

LOOP36:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS13
    SUB SI,320
    LOOP LOOP36
    JMP EXIT8

PASSOBS13:

    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,0
    MOV PASS_CAR1 , 1

    JMP EXIT8

DOWNPASSOBS:
    MOV SI,TOP1
    MOV CX,WIDTH1
LOOP37:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS14
    DEC SI
    LOOP LOOP37
    JMP EXIT8

PASSOBS14:
    MOV SPEEDUP_CAR1,0
    MOV SPEEDDOWN_CAR1,0
    MOV OBSTACLE_CAR1,0
    MOV PASS_CAR1 , 1

EXIT8:
    RET

PASSOBSTACLE_CAR1 ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                                              ;
;                                  PASS OBSTACLE CAR1                                          ;
;                                                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PASSOBSTACLE_CAR2 PROC FAR
    CMP STATE2 , 0      
    JNZ RIGHTPASSOBS2

    MOV SI,TOP2
    MOV CX,WIDTH2
LOOP38:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS21
    INC SI
    LOOP LOOP38

    JMP EXIT9

PASSOBS21:
    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,0
    MOV PASS_CAR2 , 1

    JMP EXIT9

RIGHTPASSOBS2:
    CMP STATE2 , 1
    JNZ LEFTPASSOBS2

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP39:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS22
    ADD SI,320
    LOOP LOOP39
    JMP EXIT9

PASSOBS22:
    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,0
    MOV PASS_CAR2 , 1

    JMP EXIT9

LEFTPASSOBS2:
    CMP STATE2,2
    JNZ DOWNPASSOBS2

    MOV AX,TOP2
    MOV SI,AX
    MOV CX,WIDTH2

LOOP40:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS23
    SUB SI,320
    LOOP LOOP40
    JMP EXIT9

PASSOBS23:

    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,0
    MOV PASS_CAR2 , 1

    JMP EXIT9

DOWNPASSOBS2:
    MOV SI,TOP2
    MOV CX,WIDTH2
LOOP41:
    MOV AL,ES:[SI]
    CMP AL,PASS_OBSTACLE_COLOR
    JE PASSOBS24
    DEC SI
    LOOP LOOP41
    JMP EXIT9

PASSOBS24:

    MOV SPEEDUP_CAR2,0
    MOV SPEEDDOWN_CAR2,0
    MOV OBSTACLE_CAR2,0
    MOV PASS_CAR2 , 1

EXIT9:
    RET

PASSOBSTACLE_CAR2 ENDP
    ;***********************************************************************************************
    ;KEEP POINT OF EACH BLOK IN ARRAY X  AND ARRAY Y
    ;***********************************************************************************************
;KeepTrackWithAxis proc far
;                            PUSH BX
;                            PUSH DI
;                                MOV           AL ,CurrentBlock
;                                MOV             AH, 0
;                                MOV           BX,OFFSET ArrX
;                                MOV           di,OFFSET ArrY
;;                                ADD BX, AX
;;                                ADD BX, AX
;                                ADD DI, AX
;                                ADD DI, AX
;    ;push_back:                  
;    ;                            inc           bx
;    ;                            inc           di
;    ;                            DEC           AL
;    ;                            CMP           AL ,0
;    ;                            JNZ           push_back
;                                MOV           AX,XAxis
;                                MOV           WORD PTR [bx],AX
;                                MOV           AX,YAxis
;                                MOV           WORD PTR [DI],AX
;;                                MOV AH, 0CH 
;;                                MOV AL, 05
;;                                MOV BH, 0
;;                                MOV CX, XAxis
;;                                MOV DX, YAxis
;;;                                INT 10H
;;                                POP DI
;;                                POP BX
;;                                ret
;;KeepTrackWithAxis endp
;
;;description
;GeneratePowerUps PROC FAR
;    PUSH AX
;    PUSH BX
;    PUSH CX
;    PUSH DX
;    PUSH DI
;    PUSH SI
;
;    LEA BX, ArrX2
;    LEA DI, ArrY2
;
;LOOP_OVER_POWERUPS:    
;    CALL GeneratRandomNumber
;
;    MOV AL, RandomValue
;    CMP AL, 3
;    JLE CONT_GPU
;
;    JMP END_OF_POWERUPS_LOOP
;
;CONT_GPU:
;    MOV SI, DS:[BX]
;    CMP SI, DS:[BX + 2]
;    JNE HORIZONTAL_COMP_GPU
;
;VERTICAL_COMP_GPU:
;    MOV CX, DS:[DI]
;    MOV DX, DS:[DI + 2]
;    PUSH BX
;    MOV BL, RandomValue
;    MOV BH, 0
;    CALL FAR PTR GenerateRandomNumBetTwoNums
;    POP BX
;    MOV powerUpPosX, AX
;
;    MOV CX, DS:[BX]
;    SUB CX, 7
;    MOV DX, DS:[BX + 2]
;    ADD DX, 7
;    PUSH BX
;    MOV BL, RandomValue
;    MOV BH, 0
;    CALL FAR PTR GenerateRandomNumBetTwoNums
;    POP BX
;    MOV powerUpPosY, AX
;
;    JMP CHECK_TYPE_POWERUP
;
;HORIZONTAL_COMP_GPU:
;
;    MOV CX, DS:[BX]
;    MOV DX, DS:[BX + 2]
;    PUSH BX
;    MOV BL, RandomValue
;    MOV BH, 0
;    CALL FAR PTR GenerateRandomNumBetTwoNums
;    POP BX
;    MOV powerUpPosX, AX
;
;    MOV CX, DS:[DI]
;    MOV DX, DS:[DI + 2]
;    SUB CX, 7
;    ADD DX, 7
;    PUSH BX
;    MOV BL, RandomValue
;    MOV BH, 0
;    CALL FAR PTR GenerateRandomNumBetTwoNums
;    POP BX
;    MOV powerUpPosY, AX
;
;
;CHECK_TYPE_POWERUP:
;    CMP RandomValue, 0
;    JE SPEED_UP_POWERUP
;    CMP RandomValue, 1
;    JE SPEED_DOWN_POWERUP
;    CMP RandomValue, 2
;    JE PASS_OBSTACLE_POWERUP
;    CMP RandomValue, 3
;    JE GENERATE_OBSTACLE_POWERUP
;
;SPEED_UP_POWERUP:
;    MOV powerUpColor, SPEED_UP_COLOR
;    CALL FAR PTR DrawPowerUP
;    JMP END_OF_POWERUPS_LOOP
;
;SPEED_DOWN_POWERUP:
;    MOV powerUpColor, SPEED_DOWN_COLOR
;    CALL FAR PTR DrawPowerUP
;    JMP END_OF_POWERUPS_LOOP
;
;PASS_OBSTACLE_POWERUP:
;    MOV powerUpColor, PASS_OBSTACLE_COLOR
;    CALL FAR PTR DrawPowerUP
;    JMP END_OF_POWERUPS_LOOP
;
;GENERATE_OBSTACLE_POWERUP:
;    MOV powerUpColor, GENERATE_OBSTACLE_COLOR
;    CALL FAR PTR DrawPowerUP
;    JMP END_OF_POWERUPS_LOOP
;
;END_OF_POWERUPS_LOOP:
;    ADD BX, 2
;    ADD DI, 2
;    CMP word ptr DS:[BX + 2], 0ffffh
;    JE EXIT_GPU
;    CMP word ptr DS:[DI + 2], 0ffffh
;    JE EXIT_GPU
;    JMP LOOP_OVER_POWERUPS
;
;
;EXIT_GPU:
;
;    POP SI
;    POP DI
;    POP DX
;    POP CX
;    POP BX
;    POP AX
;
;RET
;GeneratePowerUps ENDP

;description
GeneratePowerUps PROC FAR

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI
    
    CALL GeneratRandomNumber

;;GENERATE A RANDOM NUMBER AND USE IT TO GET A BIG NUMBER IN AX
    MOV AL, RandomValue
    ADD AL, 1
    MOV AH, 0
    MOV DX, 0
    MOV BX, 777
    MUL BX
    ADD AX, COUNTER_CHECK3
    ADD COUNTER_CHECK3, 17

;;MOD BY THE COUNTERARR TO GET A NUMBER IN ITS RANGE (IN DX)
    MOV BX, COUNTERARR
    MOV DX, 0
    DIV BX

    CMP DX, 15
    JG CONT_GPU_CODE

    JMP EXIT_GPU

CONT_GPU_CODE:

;;REACH THE REQUIRED POINT INTO THE POSITION ARRAYS
    LEA BX, ArrX
    LEA SI, ArrY
    ADD BX, DX
    ADD BX, DX
    ADD SI, DX
    ADD SI, DX
    LEA DI, ArrDirection
    ADD DI, DX


    MOV DX, WORD PTR DS:[BX]
    MOV powerUpPosX, DX
    MOV DX, WORD PTR DS:[SI]
    MOV powerUpPosY, DX

    CALL FAR PTR ValidateThePowerUpPosition

    CMP DrawPowerUpValidation, 1
    JE DRAW_POWERUP_GPU
    JMP EXIT_GPU

DRAW_POWERUP_GPU:

    CMP DS:[DI], 0      ;UP
    JE VERTICAL_GPU
    CMP DS:[DI], 3
    JE VERTICAL_GPU

HORIZONTAL_GPU:
    CMP COUNTER_CHECK2, 0
    JNE SUB_OFFSET_H

ADD_OFFSET_H:
    MOV AL, RandomValue
    MOV AH, 0
    ADD powerUpPosY, AX
    SUB powerUpPosY, 3
    MOV COUNTER_CHECK2, 1

    JMP CONT_OFFSET_H
SUB_OFFSET_H:
    MOV AL, RandomValue
    MOV AH, 0
    SUB powerUpPosY, AX
    ADD powerUpPosY, 3
    MOV COUNTER_CHECK2, 0

CONT_OFFSET_H:



VERTICAL_GPU:
    CMP COUNTER_CHECK2, 0
    JNE SUB_OFFSET_V

ADD_OFFSET_V:
    MOV AL, RandomValue
    MOV AH, 0
    ADD powerUpPosX, AX
    SUB powerUpPosX, 3
    MOV COUNTER_CHECK2, 1

    JMP CONT_OFFSET_V
SUB_OFFSET_V:
    MOV AL, RandomValue
    MOV AH, 0
    SUB powerUpPosX, AX
    ADD powerUpPosX, 3
    MOV COUNTER_CHECK2, 0

CONT_OFFSET_V:


;;HANDLE COLORS
    CMP COUNTER_CHECK, 0
    JE DRAW_SLOW_DOWN

    CMP COUNTER_CHECK, 1
    JE PASS_OBSTACLE_POWERUP

    CMP COUNTER_CHECK, 2
    JE GENERATE_OBSTACLE_POWERUP

    MOV powerUpColor, SPEED_UP_COLOR
    MOV COUNTER_CHECK, 0
    JMP CONT_CHECKER_POWERUP

DRAW_SLOW_DOWN:
    MOV powerUpColor, SPEED_DOWN_COLOR
    ADD COUNTER_CHECK, 1
    JMP CONT_CHECKER_POWERUP
PASS_OBSTACLE_POWERUP:
    MOV powerUpColor, PASS_OBSTACLE_COLOR
    ADD COUNTER_CHECK, 1
    JMP CONT_CHECKER_POWERUP

GENERATE_OBSTACLE_POWERUP:
    MOV powerUpColor, GENERATE_OBSTACLE_COLOR
    ADD COUNTER_CHECK, 1
    JMP CONT_CHECKER_POWERUP

CONT_CHECKER_POWERUP:
    
    CALL FAR PTR DrawPowerUP

EXIT_GPU:

    POP SI
    POP DI
    POP DX
    POP CX
    POP BX
    POP AX

    RET

GeneratePowerUps ENDP 

;description
DrawPowerUP PROC  FAR    
                                PUSH          AX
                                PUSH          BX
                                PUSH          CX
                                PUSH          DX
                                PUSH          powerUpPosX
                                PUSH          powerUpPosY
                                PUSH          DI

                                MOV           BL, 4
                                MOV           DI, 4
                                Sub           powerUpPosX, 2
                                Sub           powerUpPosY, 2

    POWERUP_OUTER_LOOP:              
                                MOV           BL, 4

    POWERUP_INNER_LOOP:              
                                MOV           AH, 0CH
                                MOV           AL, powerUpColor
                                MOV           BH, 0
                                MOV           CX, powerUpPosX
                                MOV           DX, powerUpPosY
                                INT           10H

                                INC           powerUpPosX
                                DEC           BL
                                JNZ           POWERUP_INNER_LOOP
                                INC           powerUpPosY
                                SUB           powerUpPosX, 4
                                DEC           DI
                                JNZ           POWERUP_OUTER_LOOP

                                POP           DI
                                POP           powerUpPosY
                                POP           powerUpPosX
                                POP           DX
                                POP           CX
                                POP           BX
                                POP           AX

RET

DrawPowerUP ENDP

;description
ValidateThePowerUpPosition PROC

    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI

    MOV CX, powerUpPosX
    MOV DX, powerUpPosY
    SUB CX, 2
    SUB DX, 2

    MOV BH, 0
    MOV AH, 0DH

    MOV BL, 4
    MOV DI, 4

VTPUP_OUTER_LOOP:
    MOV BL, 4
    MOV CX, powerUpPosX
    VTPUP_INNER_LOOP:
        INT 10H
        CMP AL, 8
        JE CONT_VTPUP_CHECK
        CMP AL, 0FH
        JE CONT_VTPUP_CHECK
        MOV DrawPowerUpValidation, 0
        JMP EXIT_VTPUP

        CONT_VTPUP_CHECK:
        INC CX
        DEC BL
        JNZ VTPUP_INNER_LOOP
    
    INC DX
    DEC DI
    JNZ VTPUP_OUTER_LOOP

    MOV DrawPowerUpValidation, 1

EXIT_VTPUP:

    POP DI
    POP DX
    POP CX
    POP BX
    POP AX

    RET
ValidateThePowerUpPosition ENDP