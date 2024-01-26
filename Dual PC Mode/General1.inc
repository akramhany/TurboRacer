OverRideInt9_p1 PROC FAR
                                IN            AL, 60H                                ;READ SCAN CODE

                                CMP           AL, 48H                                ;CHECK UP KEY
                                JNE           UP_NOT_PRESSED_p1
                                MOV           moveDirectionUpC1, 1
                                JMP           CONT_p1

    UP_NOT_PRESSED_p1:             
                                CMP           AL, 48H + 80H
                                JNE           UP_NOT_RELEASED_p1
                                MOV           moveDirectionUpC1, 0
                                JMP           CONT_p1

    UP_NOT_RELEASED_p1:            
                                CMP           AL, 4DH                                ;Check for right pressed
                                JNE           RIGHT_NOT_PRESSED_p1
                                MOV           moveDirectionRightC1, 1
                                JMP           CONT_p1


    RIGHT_NOT_PRESSED_p1:          
                                CMP           AL, 4DH + 80H                          ;Check for right released
                                JNE           RIGHT_NOT_RELEASED_p1
                                MOV           moveDirectionRightC1, 0
                                JMP           CONT_p1

    CONT_HELP_p1:                  
                                JMP           CONT_p1

    HELPER_JUMP_p1:                
                                JMP           DOWN_NOT_RELEASED_p1

    RIGHT_NOT_RELEASED_p1:         
                                CMP           AL, 4BH                                ;Check for left pressed
                                JNE           LEFT_NOT_PRESSED_p1
                                MOV           moveDirectionLeftC1, 1
                                JMP           CONT_p1

    LEFT_NOT_PRESSED_p1:           
                                CMP           AL, 4BH + 80H                          ;Check for left released
                                JNE           LEFT_NOT_RELEASED_p1
                                MOV           moveDirectionLeftC1, 0
                                JMP           CONT_p1

    LEFT_NOT_RELEASED_p1:          
                                CMP           AL, 50H                                ;Check for down pressed
                                JNE           DOWN_NOT_PRESSED_p1
                                MOV           moveDirectionDownC1, 1
                                JMP           CONT_p1

    DOWN_NOT_PRESSED_p1:           
                                CMP           AL, 50H + 80H                          ;Check for down released
                                JNE           DOWN_NOT_RELEASED_p1
                                MOV           moveDirectionDownC1, 0
                                JMP           CONT_p1

    DOWN_NOT_RELEASED_p1:
                                CMP           AL,32H
                                JNE           M_NOT_PRESSED_p1
                                MOV           POWCAR1,1
                                JMP           CONT_p1

    M_NOT_PRESSED_p1:              
                                CMP           AL,32H+80H
                                JNE           M_NOT_RELEASED_p1
                                MOV           POWCAR1,0
                                JMP           CONT_p1

    M_NOT_RELEASED_p1:
                                CMP           AL, 1H                                 ;Check for escape pressed
                                JNE           CONT_p1
                                MOV           shouldExit, 1

    CONT_p1:                       
                                MOV           AL, 20H
                                OUT           20H, AL
                                IRET
OverRideInt9_p1 ENDP
    
    
    
    ;------------------------------THE PROC WHICH WILL OVER RIDE INT 9 TO ALLOW TAKING MORE THAN ONE INPUT---------------------



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------




;; Description: fill the background (A000H MUST BE IN ES) with a given color in AL
;; Input:  
;; Registers:  DI, CX
FillBackground PROC FAR
    
    PUSH DI
    PUSH CX
    PUSH DX
    PUSH BX

    MOV DI, 0
    MOV CX, SCREEN_WIDTH
    MOV DX, SCREEN_HEIGHT
    MOV BX, 0

REPEAT:
    MOV CX, SCREEN_WIDTH

    FILL_LINE_OF_BACKGROUND:
        CMP ES:[BX], BYTE PTR 01H           ;If the pixel is black, fill it with the background color, if not do not fill it
        JL FILL
        JMP DONOT_FILL
        FILL:
            MOV ES:[BX], AL
        DONOT_FILL:
        INC BX
        DEC CX
        JNZ FILL_LINE_OF_BACKGROUND
    DEC DX
    JNZ REPEAT


    POP BX
    POP DX
    POP CX
    POP DI

    RET

FillBackground ENDP



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



;; Description: fill the SCREEN (A000H MUST BE IN ES) with a given color in AL, the starting point to fill from must be given in BP
;; fill a certain width and a certain height given in widthToFill, and heightToFill  
;; Registers:  DI, CX
FillScreen PROC FAR
    
    PUSH BP
    PUSH DI
    PUSH CX
    PUSH DX
    PUSH BX



    MOV DI, 0
    MOV CX, widthToFill
    MOV DX, heightToFill
    MOV BX, BP

REPEAT_S:
    MOV CX, widthToFill

    FILL_LINE_OF_SCREEN:
        MOV ES:[BX], AL
        INC BX
        DEC CX
        JNZ FILL_LINE_OF_SCREEN
    DEC DX
    JNZ REPEAT_S


    POP BX
    POP DX
    POP CX
    POP DI
    POP BP

    RET

FillScreen ENDP



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



DrawLogo PROC FAR


    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

    LEA SI, logoBuffer


    MOV DX, LOGO_IMAGE_HEIGHT

REPEAT_H:
    MOV CX, LOGO_IMAGE_WIDTH
    
    DRAW_LINE_OF_IMG_H:         ;H stands for horizontal (horizontal component)
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        DEC CX
        JNZ DRAW_LINE_OF_IMG_H 
    
    ADD DI, SCREEN_WIDTH - LOGO_IMAGE_WIDTH  ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT_H


    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawLogo ENDP



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



DrawCarImage PROC FAR

    PUSH AX
    PUSH ES
    PUSH SI 
    PUSH DX
    PUSH CX
    PUSH DI

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

    LEA SI, carBuffer


    MOV DX, CAR_IMAGE_HEIGHT

REPEAT_CAR_IMAGE:
    MOV CX, CAR_IMAGE_WIDTH
    
    DRAW_LINE_OF_IMG_CAR:         ;H stands for horizontal (horizontal component)
        CMP DS:[SI], BYTE PTR 1FH
        JLE DONT_DRAW_CHECK
        JMP DRAW
        DONT_DRAW_CHECK:
            CMP DS:[SI], BYTE PTR 1dH
            JLE DRAW
            JMP DONT_DRAW
        DRAW:
        MOVSB                   ;move ds:[si] to es:[di] and inc both
        JMP CONT_DCI
        DONT_DRAW:
            INC SI
            INC DI
        CONT_DCI:
        DEC CX
        JNZ DRAW_LINE_OF_IMG_CAR 
    
    ADD DI, SCREEN_WIDTH - CAR_IMAGE_WIDTH  ;inc di to draw the second line of the image
    DEC DX
    JNZ REPEAT_CAR_IMAGE


    POP DI
    POP CX
    POP DX
    POP SI
    POP ES
    POP AX

    RET

DrawCarImage ENDP



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



;description
ValidateInputPlayerOne PROC FAR

    MOV AL, BACKGROUND_COLOR
    MOV BP, 60 * 320
    MOV widthToFill, 320
    MOV heightToFill, 20
    CALL FAR PTR FillScreen

    MOV errorOccured, 0

    CMP user1ActualLen, 15
    JG EXCEED_15_p1
;    CMP user2ActualLen, 15
;    JG EXCEED_15

CONT_VALD_p1:

    CMP user1Data, 'A'
    JL FIRST_CHAR_ERR_p1
    CMP user1Data, 'Z'
    JG CHECK_LOWER_U1_p1
    JMP EXIT_V_I_p1

CHECK_LOWER_U1_p1:
    CMP user1Data, 'a'
    JL FIRST_CHAR_ERR_p1
    CMP user1Data, 'z'
    JG FIRST_CHAR_ERR_p1
    JMP EXIT_V_I_p1

;CHECK_U2:
;
;    CMP user2Data, 'A'
;    JL FIRST_CHAR_ERR
;    CMP user2Data, 'Z'
;    JG CHECK_LOWER_U2
;    JMP EXIT_V_I
;
;CHECK_LOWER_U2:
;    CMP user2Data, 'a'
;    JL FIRST_CHAR_ERR
;    CMP user2Data, 'z'
;    JG FIRST_CHAR_ERR
;    JMP EXIT_V_I


EXCEED_15_p1:
    MOV errorOccured, 1
    SetCursor 8, 1
    DisplayString errorOne
    JMP EXIT_V_I_p1

FIRST_CHAR_ERR_p1:
    MOV errorOccured, 1
    SetCursor 9, 1
    DisplayString errorTwo
    JMP EXIT_V_I_p1

EXIT_V_I_p1:

RET
    
ValidateInputPlayerOne ENDP 

;description
ValidateInputPlayerTwo PROC FAR

    MOV AL, BACKGROUND_COLOR
    MOV BP, 60 * 320
    MOV widthToFill, 320
    MOV heightToFill, 20
    CALL FAR PTR FillScreen

    MOV errorOccured, 0

;    CMP user1ActualLen, 15
;    JG EXCEED_15
    CMP user2ActualLen, 15
    JG EXCEED_15_p2

;CONT_VALD:
;
;    CMP user1Data, 'A'
;    JL FIRST_CHAR_ERR
;    CMP user1Data, 'Z'
;    JG CHECK_LOWER_U1
;    JMP EXIT_V_I
;
;CHECK_LOWER_U1:
;    CMP user1Data, 'a'
;    JL FIRST_CHAR_ERR
;    CMP user1Data, 'z'
;    JG FIRST_CHAR_ERR
;    JMP EXIT_V_I

CHECK_U2_p2:

    CMP user2Data, 'A'
    JL FIRST_CHAR_ERR_p2
    CMP user2Data, 'Z'
    JG CHECK_LOWER_U2_p2
    JMP EXIT_V_I_p2

CHECK_LOWER_U2_p2:
    CMP user2Data, 'a'
    JL FIRST_CHAR_ERR_p2
    CMP user2Data, 'z'
    JG FIRST_CHAR_ERR_p2
    JMP EXIT_V_I_p2


EXCEED_15_p2:
    MOV errorOccured, 1
    SetCursor 8, 1
    DisplayString errorOne
    JMP EXIT_V_I_p2

FIRST_CHAR_ERR_p2:
    MOV errorOccured, 1
    SetCursor 9, 1
    DisplayString errorTwo
    JMP EXIT_V_I_p2

EXIT_V_I_p2:

RET
    
ValidateInputPlayerTwo ENDP 


;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



;description
DisplayFirstPagePlayerOne PROC FAR

    OpenFile OPEN_ATTRIBUTE, logoFileName       ;open the logo image file
    ReadFile AX, BUFFER_SIZE_LOGO, logoBuffer   ;read all the bytes into the buffer
    CloseFile                                   ;close the file

    OpenFile OPEN_ATTRIBUTE, carFileName        ;open the logo image file
    ReadFile AX, BUFFER_SIZE_CAR, carBuffer     ;read all the bytes into the buffer
    CloseFile                                   ;close the file
    

;;;;;;;;;;;;;;;;;CHANGE TO VIDEO MODE 320 * 200;;;;;;;;;;;;;;;;;
    MOV AH, 0
    MOV AL, 13H
    INT 10H


    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

;;Draw Logo
    MOV DI, 320 * 10 + 80
    CALL FAR PTR DrawLogo


;;Draw Car
    MOV DI, 320 * 140 + 120
    CALL FAR PTR DrawCarImage


;;Fill the background with a certain color
    MOV AL, BACKGROUND_COLOR
    CALL FAR PTR FillBackground


GET_NEW_INPUT_p1:

    MOV CX, 200
    LEA BX, user1Data
 LOOP_U1_p1:   
    MOV [BX], '$'
    INC BX
    LOOP LOOP_U1_p1

    MOV CX, 200
    LEA BX, user2Data
 LOOP_U2_p1:
    MOV [BX], '$'
    INC BX
    LOOP LOOP_U2_p1

;Fill Screen with a certain color
    MOV AL, BACKGROUND_COLOR
    MOV BP, 80 * 320
    MOV widthToFill, 320
    MOV heightToFill, 45
    CALL FAR PTR FillScreen


    DisplayPromptMessagesPlayerOne

    SetCursor INPUT_POS_ROW_1, INPUT_POS_COL_1
    GetUserInput userName1


    CALL FAR PTR ValidateInputPlayerOne


    CMP errorOccured, 0
    JE CONT_EXEC_p1
    JMP GET_NEW_INPUT_p1

CONT_EXEC_p1:
RET

DisplayFirstPagePlayerOne ENDP 


;description
DisplayFirstPagePlayerTwo PROC FAR

    OpenFile OPEN_ATTRIBUTE, logoFileName       ;open the logo image file
    ReadFile AX, BUFFER_SIZE_LOGO, logoBuffer   ;read all the bytes into the buffer
    CloseFile                                   ;close the file

    OpenFile OPEN_ATTRIBUTE, carFileName        ;open the logo image file
    ReadFile AX, BUFFER_SIZE_CAR, carBuffer     ;read all the bytes into the buffer
    CloseFile                                   ;close the file
    

;;;;;;;;;;;;;;;;;CHANGE TO VIDEO MODE 320 * 200;;;;;;;;;;;;;;;;;
    MOV AH, 0
    MOV AL, 13H
    INT 10H


    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen

;;Draw Logo
    MOV DI, 320 * 10 + 80
    CALL FAR PTR DrawLogo


;;Draw Car
    MOV DI, 320 * 140 + 120
    CALL FAR PTR DrawCarImage


;;Fill the background with a certain color
    MOV AL, BACKGROUND_COLOR
    CALL FAR PTR FillBackground


GET_NEW_INPUT_p2:

    MOV CX, 200
    LEA BX, user1Data
 LOOP_U1_p2:   
    MOV [BX], '$'
    INC BX
    LOOP LOOP_U1_p2

    MOV CX, 200
    LEA BX, user2Data
 LOOP_U2_p2:
    MOV [BX], '$'
    INC BX
    LOOP LOOP_U2_p2

;Fill Screen with a certain color
    MOV AL, BACKGROUND_COLOR
    MOV BP, 80 * 320
    MOV widthToFill, 320
    MOV heightToFill, 45
    CALL FAR PTR FillScreen


    DisplayPromptMessagesPlayerTwo

    SetCursor INPUT_POS_ROW_2, INPUT_POS_COL_2
    GetUserInput userName2


    CALL FAR PTR ValidateInputPlayerTwo


    CMP errorOccured, 0
    JE CONT_EXEC_p2
    JMP GET_NEW_INPUT_p2

CONT_EXEC_p2:
RET

DisplayFirstPagePlayerTwo ENDP 



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



;description
DisplayMainPage PROC FAR

    MOV AL, BACKGROUND_COLOR
    MOV BP, 0
    MOV widthToFill, 320
    MOV heightToFill, 200
    CALL FAR PTR FillScreen

    MOV DI, 320 * 10 + 80
    CALL FAR PTR DrawLogo

    ;;Fill the background with a certain color
    MOV AL, BACKGROUND_COLOR
    CALL FAR PTR FillBackground


    SetCursor 12, 7
    DisplayString msg1
    SetCursor 14, 7
    DisplayString msg2
    SetCursor 16, 7
    DisplayString msg3

RET    
DisplayMainPage ENDP 


;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



;description
FillArrDirectionSmall PROC FAR

    LEA SI, ArrDirectionSmall
    MOV CX, 200
FADS_LOOP:
    MOV AL, '#'
    MOV DS:[SI], AL
    INC SI
    DEC CX
    JNZ FADS_LOOP


    RET
FillArrDirectionSmall ENDP
