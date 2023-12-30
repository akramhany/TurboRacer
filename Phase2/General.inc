    ;------------------------------THE PROC WHICH WILL OVER RIDE INT 9 TO ALLOW TAKING MORE THAN ONE INPUT---------------------
OverRideInt9 PROC FAR
                                IN            AL, 60H                                ;READ SCAN CODE

                                CMP           AL, 48H                                ;CHECK UP KEY
                                JNE           UP_NOT_PRESSED
                                MOV           moveDirectionUpC1, 1
                                JMP           CONT

    UP_NOT_PRESSED:             
                                CMP           AL, 48H + 80H
                                JNE           UP_NOT_RELEASED
                                MOV           moveDirectionUpC1, 0
                                JMP           CONT

    UP_NOT_RELEASED:            
                                CMP           AL, 4DH                                ;Check for right pressed
                                JNE           RIGHT_NOT_PRESSED
                                MOV           moveDirectionRightC1, 1
                                JMP           CONT


    RIGHT_NOT_PRESSED:          
                                CMP           AL, 4DH + 80H                          ;Check for right released
                                JNE           RIGHT_NOT_RELEASED
                                MOV           moveDirectionRightC1, 0
                                JMP           CONT

    CONT_HELP:                  
                                JMP           CONT

    HELPER_JUMP:                
                                JMP           DOWN_NOT_RELEASED

    RIGHT_NOT_RELEASED:         
                                CMP           AL, 4BH                                ;Check for left pressed
                                JNE           LEFT_NOT_PRESSED
                                MOV           moveDirectionLeftC1, 1
                                JMP           CONT

    LEFT_NOT_PRESSED:           
                                CMP           AL, 4BH + 80H                          ;Check for left released
                                JNE           LEFT_NOT_RELEASED
                                MOV           moveDirectionLeftC1, 0
                                JMP           CONT

    LEFT_NOT_RELEASED:          
                                CMP           AL, 50H                                ;Check for down pressed
                                JNE           DOWN_NOT_PRESSED
                                MOV           moveDirectionDownC1, 1
                                JMP           CONT

    DOWN_NOT_PRESSED:           
                                CMP           AL, 50H + 80H                          ;Check for down released
                                JNE           DOWN_NOT_RELEASED
                                MOV           moveDirectionDownC1, 0
                                JMP           CONT

    DOWN_NOT_RELEASED:          
                                CMP           AL, 11H                                ;CHECK UP PRESSED FOR CAR 2
                                JNE           W_NOT_PRESSED
                                MOV           moveDirectionUpC2, 1
                                JMP           CONT

    W_NOT_PRESSED:              
                                CMP           AL, 11H + 80H                          ;CHECK UP RELEASED FOR CAR 2
                                JNE           W_NOT_RELEASED
                                MOV           moveDirectionUpC2, 0
                                JMP           CONT

    W_NOT_RELEASED:             
                                CMP           AL, 20H                                ;CHECK RIGHT PRESSED FOR CAR 2
                                JNE           D_NOT_PRESSED
                                MOV           moveDirectionRightC2, 1
                                JMP           CONT

    D_NOT_PRESSED:              
                                CMP           AL, 20H + 80H                          ;CHECK RIGHT RELEASED FOR CAR 2
                                JNE           D_NOT_RELEASED
                                MOV           moveDirectionRightC2, 0
                                JMP           CONT

    D_NOT_RELEASED:             
                                CMP           AL, 1EH                                ;CHECK LEFT PRESSED FOR CAR 2
                                JNE           A_NOT_PRESSED
                                MOV           moveDirectionLeftC2, 1
                                JMP           CONT

    A_NOT_PRESSED:              
                                CMP           AL, 1EH + 80H                          ;CHECK LEFT RELEASED FOR CAR 2
                                JNE           A_NOT_RELEASED
                                MOV           moveDirectionLeftC2, 0
                                JMP           CONT

    A_NOT_RELEASED:             
                                CMP           AL, 1FH                                ;CHECK DOWN PRESSED FOR CAR 2
                                JNE           S_NOT_PRESSED
                                MOV           moveDirectionDownC2, 1
                                JMP           CONT

    S_NOT_PRESSED:              
                                CMP           AL, 1FH + 80H                          ;CHECK DOWN RELEASED FOR CAR 2
                                JNE           S_NOT_RELEASED
                                MOV           moveDirectionDownC2, 0
                                JMP           CONT

    S_NOT_RELEASED:             
                                CMP           AL,32H
                                JNE           M_NOT_PRESSED
                                MOV           POWCAR1,1
                                JMP           CONT

    M_NOT_PRESSED:              
                                CMP           AL,32H+80H
                                JNE           M_NOT_RELEASED
                                MOV           POWCAR1,0
                                JMP           CONT

    M_NOT_RELEASED:             
                                CMP           AL,10H
                                JNE           Q_NOT_PRESSED
                                MOV           POWCAR2,1
                                JMP           CONT

    Q_NOT_PRESSED:              
                                CMP           AL,10H+80H
                                JNE           Q_NOT_RELEASED
                                MOV           POWCAR2,0
                                JMP           CONT

    Q_NOT_RELEASED:             
                                CMP           AL, 1H                                 ;Check for escape pressed
                                JNE           CONT
                                MOV           shouldExit, 1

    CONT:                       
                                MOV           AL, 20H
                                OUT           20H, AL
                                IRET
OverRideInt9 ENDP



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
ValidateInput PROC FAR

    MOV AL, BACKGROUND_COLOR
    MOV BP, 60 * 320
    MOV widthToFill, 320
    MOV heightToFill, 20
    CALL FAR PTR FillScreen

    MOV errorOccured, 0

    CMP user1ActualLen, 15
    JG EXCEED_15
    CMP user2ActualLen, 15
    JG EXCEED_15

CONT_VALD:

    CMP user1Data, 'A'
    JL FIRST_CHAR_ERR
    CMP user1Data, 'Z'
    JG CHECK_LOWER_U1
    JMP CHECK_U2

CHECK_LOWER_U1:
    CMP user1Data, 'a'
    JL FIRST_CHAR_ERR
    CMP user1Data, 'z'
    JG FIRST_CHAR_ERR

CHECK_U2:

    CMP user2Data, 'A'
    JL FIRST_CHAR_ERR
    CMP user2Data, 'Z'
    JG CHECK_LOWER_U2
    JMP EXIT_V_I

CHECK_LOWER_U2:
    CMP user2Data, 'a'
    JL FIRST_CHAR_ERR
    CMP user2Data, 'z'
    JG FIRST_CHAR_ERR
    JMP EXIT_V_I


EXCEED_15:
    MOV errorOccured, 1
    SetCursor 8, 1
    DisplayString errorOne
    JMP CONT_VALD

FIRST_CHAR_ERR:
    MOV errorOccured, 1
    SetCursor 9, 1
    DisplayString errorTwo
    JMP EXIT_V_I

EXIT_V_I:

RET
    
ValidateInput ENDP 



;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------



;description
DisplayFirstPage PROC FAR

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


GET_NEW_INPUT:

    MOV CX, 200
    LEA BX, user1Data
 LOOP_U1:   
    MOV [BX], '$'
    INC BX
    LOOP LOOP_U1

    MOV CX, 200
    LEA BX, user2Data
 LOOP_U2:
    MOV [BX], '$'
    INC BX
    LOOP LOOP_U2

;Fill Screen with a certain color
    MOV AL, BACKGROUND_COLOR
    MOV BP, 80 * 320
    MOV widthToFill, 320
    MOV heightToFill, 45
    CALL FAR PTR FillScreen


    DisplayPromptMessages

    SetCursor INPUT_POS_ROW_1, INPUT_POS_COL_1
    GetUserInput userName1
    SetCursor INPUT_POS_ROW_2, INPUT_POS_COL_2
    GetUserInput userName2

    CALL FAR PTR ValidateInput


    CMP errorOccured, 0
    JE CONT_EXEC
    JMP GET_NEW_INPUT

CONT_EXEC:
RET

DisplayFirstPage ENDP 



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
