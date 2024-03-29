;THE FUNCTIONALITY OF THIS CODE IS DRAWING THE CAR

collisionCOLOR1 EQU 14 ;FOR TRACK
collisionCOLOR2 EQU  4 ;FOR CAR1
collisionCOLOR3 EQU 65 ;FOR CAR2
ROAD_COLOR_BEGIN equ 6              ;brown
ROAD_COLOR_END  equ 1               ;blue
PUBLIC CheckColisionCar1
PUBLIC CheckColisionCar2
EXTRN HEIGHT1:WORD
EXTRN WIDTH1:WORD
EXTRN CENTER1:WORD
EXTRN STATE1:BYTE
EXTRN EXPECTEDSTATE1:BYTE
EXTRN CANMOVEOBSTACLE1:BYTE
EXTRN CANMOVETRACK1 :BYTE
EXTRN HEIGHT2:WORD
EXTRN WIDTH2:WORD
EXTRN CENTER2:WORD
EXTRN STATE2:BYTE
EXTRN EXPECTEDSTATE2:BYTE
EXTRN CANMOVEOBSTACLE2:BYTE
EXTRN CANMOVETRACK2 :BYTE
EXTRN CANPASS_CAR1:BYTE
EXTRN SPEED1:WORD
EXTRN SPEED2:WORD
EXTRN playerOneWin:BYTE
EXTRN playerTwoWin:BYTE
.MODEL SMALL
.STACK 64
.CODE

CheckColisionCar1 PROC FAR
    CMP EXPECTEDSTATE1 , 0      
    JNZ KOBRY11
    ;PERFORM EQUATION CENTER-(WIDTH/2)-(320*HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (TOP LEFT IN THE SCREEN)
    ;CALCULATE (320*HEIGHT/2) TERM
    MOV BX,320          
    MOV AX,HEIGHT1
    shr AX,1
    ADD AX,SPEED1
    MUL BX
    PUSH AX

    ;CALCULATE WIDTH/2 TERM
    MOV AX , WIDTH1
    shr AX,1

    ;GET THE REQUIRED POINT
    MOV BX , CENTER1
    SUB BX ,AX
    POP AX
    SUB BX,AX
    MOV AX,BX

    PUSH BX
    MOV DX,HEIGHT1  
UPROW1:
    MOV SI,AX
    MOV CX,WIDTH1
    JMP LOOP11

KOBRY11:
JMP RIGHT1

LOOP11:
    MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN11
    JMP NOT_WIN11
WIN11:
    MOV playerOneWin, 1
NOT_WIN11:

    CMP AL, ROAD_COLOR_BEGIN
    JZ CANTMOVETRACKUP1
    CMP AL, collisionCOLOR1
    JZ CANTMOVETRACKUP1   ; ->THIS PIXEL HAS COLOUR OF THE OBSTACLE SO CAR CAN'T MOVE
    CMP AL, collisionCOLOR3
    JZ CANTMOVETRACKUP1   ; ->THIS PIXEL HAS COLOUR OF THE CAR2 SO CAR CAN'T MOVE
    CMP AL, 10d
    JZ CANTMOVEOBSTACKUP1   ; ->THIS PIXEL HAS COLOUR OF THE CAR2 SO CAR CAN'T MOVE
    INC SI
    LOOP LOOP11
    POP AX
    ADD AX,320      ; MOVE TO THE NEXT ROW
    PUSH AX
    DEC DX          
    CMP DX , 0
    JNZ UPROW1
    POP AX
    MOV AL,1
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1

CANTMOVETRACKUP1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1

CANTMOVEOBSTACKUP1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    INC AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1


RIGHT1:
    CMP EXPECTEDSTATE1 , 1
    JNZ KOBRY12
    ;PERFORM EQUATION CENTER-(WIDTH*320/2)+(HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (TOP RIGHT IN THE SCREEN)
    ;CALCULATE (HEIGHT/2) TERM
    MOV AX , HEIGHT1
    shr AX,1
    ADD AX,SPEED1
    PUSH AX

    ;CALCULATE WIDTH*320/2 TERM
    MOV BX,320
    MOV AX,WIDTH1
    shr AX,1
    MUL BX

    ;GET THE REQUIRED POINT
    MOV BX , CENTER1
    SUB BX ,AX
    POP AX
    ADD BX,AX
    MOV AX,BX
    PUSH BX
    MOV DX,HEIGHT1
RIGHTCOLUMN1:
    MOV SI,AX
    MOV CX,WIDTH1
    JMP LOOP12

KOBRY12:
JMP LEFT1

LOOP12:
    MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN12
    JMP NOT_WIN12
WIN12:
    MOV playerOneWin, 1
NOT_WIN12:

    CMP AL, ROAD_COLOR_BEGIN
    JZ CANTMOVETRACKRIGHT1
    CMP AL, collisionCOLOR1
    JZ CANTMOVETRACKRIGHT1
    CMP AL, collisionCOLOR3
    JZ CANTMOVETRACKRIGHT1
    CMP AL, 10d
    JZ CANTMOVEOBSTACLERIGHT1 
    ADD SI,320
    LOOP LOOP12
    POP AX
    SUB AX,1
    PUSH AX
    DEC DX
    CMP DX , 0
    JNZ RIGHTCOLUMN1
    POP AX
    MOV AL,1
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1

CANTMOVETRACKRIGHT1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1
CANTMOVEOBSTACLERIGHT1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    INC AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1



LEFT1:
    CMP EXPECTEDSTATE1,2
    JNZ KOBRY13

    ;PERFORM EQUATION CENTER+(WIDTH*320/2)-(HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (BOTTOM LEFT IN THE SCREEN)
    ;CALCULATE (HEIGHT/2) TERM
    MOV AX , HEIGHT1
    shr AX,1
    ADD AX,SPEED1
    PUSH AX

    ;CALCULATE WIDTH*320/2 TERM
    MOV BX,320
    MOV AX,WIDTH1
    shr AX,1
    MUL BX

    ;GET THE REQUIRED POINT
    MOV BX , CENTER1
    ADD BX ,AX
    POP AX
    SUB BX,AX


    MOV AX,BX
    PUSH BX
    MOV DX,HEIGHT1

LEFTCOLUMN1:
    MOV SI,AX
    MOV CX,WIDTH1
    JMP LOOP13

KOBRY13:
JMP DOWN1

LOOP13: 
    MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN13
    JMP NOT_WIN13
WIN13:
    MOV playerOneWin, 1
NOT_WIN13:
    CMP AL, ROAD_COLOR_BEGIN
    JZ CANTMOVETRACKLEFT1
    CMP AL, collisionCOLOR1
    JZ CANTMOVETRACKLEFT1
    CMP AL, collisionCOLOR3
    JZ CANTMOVETRACKLEFT1
    CMP AL, 10d
    JZ CANTMOVEOBSTACLELEFT1
    SUB SI,320
    LOOP LOOP13
    POP AX
    ADD AX,1
    PUSH AX
    DEC DX
    CMP DX , 0
    JNZ LEFTCOLUMN1
    POP AX
    MOV AL,1
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1

CANTMOVETRACKLEFT1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1
CANTMOVEOBSTACLELEFT1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    INC AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1

DOWN1:
;PERFORM EQUATION CENTER+(WIDTH/2)+(320*HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (TOP LEFT IN THE SCREEN)
;CALCULATE (320*HEIGHT/2) TERM
MOV BX,320
MOV AX,HEIGHT1
shr AX,1
ADD AX,SPEED1
MUL BX
PUSH AX

;CALCULATE WIDTH/2 TERM
MOV AX , WIDTH1
shr AX,1

;GET THE REQUIRED POINT
MOV BX , CENTER1
ADD BX ,AX
POP AX
ADD BX,AX


MOV AX,BX
PUSH BX
MOV DX,HEIGHT1

DOWNROW1:
MOV SI,AX
MOV CX,WIDTH1

LOOP14:
MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN14
    JMP NOT_WIN14
WIN14:
    MOV playerOneWin, 1
NOT_WIN14:
CMP AL, ROAD_COLOR_BEGIN
JZ CANTMOVETRACKDOWN1
CMP AL, collisionCOLOR1
JZ CANTMOVETRACKDOWN1
CMP AL, collisionCOLOR3
JZ CANTMOVETRACKDOWN1
CMP AL, 10d
JZ CANTMOVEOBSTACLEDOWN1
DEC SI
LOOP LOOP14
POP AX
SUB AX,320
PUSH AX
DEC DX
CMP DX , 0
JNZ DOWNROW1
POP AX
MOV AL,1
MOV CANMOVEOBSTACLE1,AL
MOV CANMOVETRACK1,AL
JMP EXIT1

CANTMOVETRACKDOWN1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1
CANTMOVEOBSTACLEDOWN1:
    POP AX
    MOV AL,0
    MOV CANMOVEOBSTACLE1,AL
    INC AL
    MOV CANMOVETRACK1,AL
    JMP EXIT1 
EXIT1:
RET
CheckColisionCar1 ENDP
;;;;;;;;;;;;;;;;;;;;;;
;////////////////////;
;;;;;;;;;;;;;;;;;;;;;;
CheckColisionCar2 PROC FAR
CMP EXPECTEDSTATE2 , 0      
JNZ RIGHT2
;PERFORM EQUATION CENTER-(WIDTH/2)-(320*HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (TOP LEFT IN THE SCREEN)
;CALCULATE (320*HEIGHT/2) TERM
MOV BX,320          
MOV AX,HEIGHT2
shr AX,1
ADD AX,SPEED2
MUL BX
PUSH AX

;CALCULATE WIDTH/2 TERM
MOV AX , WIDTH2
shr AX,1

;GET THE REQUIRED POINT
MOV BX , CENTER2
SUB BX ,AX
POP AX
SUB BX,AX

MOV AX,BX
PUSH BX
MOV DX,HEIGHT2 
UPROW2:
MOV SI,AX
MOV CX,WIDTH2


LOOP21:
MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN21
    JMP NOT_WIN21
WIN21:
    MOV playerTwoWin, 1
NOT_WIN21:
CMP AL, ROAD_COLOR_BEGIN
JZ CANTMOVETRACKUP2
CMP AL, collisionCOLOR1
JZ CANTMOVETRACKUP2   ; ->THIS PIXEL HAS COLOUR OF THE OBSTACLE SO CAR CAN'T MOVE
CMP AL, collisionCOLOR2
JZ CANTMOVETRACKUP2   ; ->THIS PIXEL HAS COLOUR OF THE CAR1 SO CAR CAN'T MOVE
CMP AL, 10d
JZ CANTMOVEOBSTACLEUP2   ; ->THIS PIXEL HAS COLOUR OF THE obstacle SO CAR CAN'T MOVE
INC SI
LOOP LOOP21
POP AX
ADD AX,320      ; MOVE TO THE NEXT ROW
PUSH AX
DEC DX          
CMP DX , 0
JNZ UPROW2
POP AX
MOV AL,1
MOV CANMOVEOBSTACLE2,AL
MOV CANMOVETRACK2,AL
JMP EXIT2

CANTMOVETRACKUP2:
POP AX
MOV AL,0
MOV CANMOVETRACK2,AL
JMP EXIT2
CANTMOVEOBSTACLEUP2:
POP AX
MOV AL,0
MOV CANMOVEOBSTACLE2,AL
INC AL
MOV CANMOVETRACK2,AL
JMP EXIT2


RIGHT2:
CMP EXPECTEDSTATE2 , 1
JNZ KOBRY22
;PERFORM EQUATION CENTER-(WIDTH*320/2)+(HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (TOP RIGHT IN THE SCREEN)
;CALCULATE (HEIGHT/2) TERM
MOV AX , HEIGHT2
shr AX,1
ADD AX,SPEED2
PUSH AX

;CALCULATE WIDTH*320/2 TERM
MOV BX,320
MOV AX,WIDTH2
shr AX,1
MUL BX

;GET THE REQUIRED POINT
MOV BX , CENTER2
SUB BX ,AX
POP AX
ADD BX,AX
PUSH BX
MOV AX,BX
MOV DX,HEIGHT2
RIGHTCOLUMN2:
MOV SI,AX
MOV CX,WIDTH2
JMP LOOP22

KOBRY22:
JMP LEFT2

LOOP22:
MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN22
    JMP NOT_WIN22
WIN22:
    MOV playerTwoWin, 1
NOT_WIN22:
CMP AL, ROAD_COLOR_BEGIN
JZ CANTMOVETRACKRIGHT2
CMP AL, collisionCOLOR1
JZ CANTMOVETRACKRIGHT2
CMP AL, collisionCOLOR2
JZ CANTMOVETRACKRIGHT2
CMP AL, 10d
JZ CANTMOVEOBSTACLERIGHT2
ADD SI,320
LOOP LOOP22
POP AX
SUB AX,1
PUSH AX
DEC DX
CMP DX , 0
JNZ RIGHTCOLUMN2
POP AX
MOV AL,1
MOV CANMOVEOBSTACLE2,AL
MOV CANMOVETRACK2,AL
JMP EXIT2

CANTMOVETRACKRIGHT2:
POP AX
MOV AL,0
MOV CANMOVETRACK2,AL
JMP EXIT2
CANTMOVEOBSTACLERIGHT2:
POP AX
MOV AL,0
MOV CANMOVEOBSTACLE2,AL
INC AL
MOV CANMOVETRACK2,AL
JMP EXIT2



LEFT2:
CMP EXPECTEDSTATE2,2
JNZ KOBRY23

;PERFORM EQUATION CENTER+(WIDTH*320/2)-(HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (BOTTOM LEFT IN THE SCREEN)
;CALCULATE (HEIGHT/2) TERM
MOV AX , HEIGHT2
shr AX,1
ADD AX,SPEED2
PUSH AX

;CALCULATE WIDTH*320/2 TERM
MOV BX,320
MOV AX,WIDTH2
shr AX,1
MUL BX

;GET THE REQUIRED POINT
MOV BX , CENTER2
ADD BX ,AX
POP AX
SUB BX,AX

PUSH BX
MOV AX,BX
MOV DX,HEIGHT2

LEFTCOLUMN2:
MOV SI,AX
MOV CX,WIDTH2
JMP LOOP23

KOBRY23:
JMP DOWN2

LOOP23: 
MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN23
    JMP NOT_WIN23
WIN23:
    MOV playerTwoWin, 1
NOT_WIN23:
CMP AL, ROAD_COLOR_BEGIN
JZ CANTMOVETRACKLEFT2
CMP AL, collisionCOLOR1
JZ CANTMOVETRACKLEFT2
CMP AL, collisionCOLOR2
JZ CANTMOVETRACKLEFT2
CMP AL, 10d
JZ CANTMOVEOBSTACLELEFT2
SUB SI,320
LOOP LOOP23
POP AX
ADD AX,1
PUSH AX
DEC DX
CMP DX , 0
JNZ LEFTCOLUMN2
POP AX
MOV AL,1
MOV CANMOVEOBSTACLE2,AL
MOV CANMOVETRACK2,AL
JMP EXIT2

CANTMOVETRACKLEFT2:
POP AX
MOV AL,0
MOV CANMOVETRACK2,AL
JMP EXIT2

CANTMOVEOBSTACLELEFT2:
POP AX
MOV AL,0
MOV CANMOVEOBSTACLE2,AL
INC AL
MOV CANMOVETRACK2,AL
JMP EXIT2

DOWN2:
;PERFORM EQUATION CENTER+(WIDTH/2)+(320*HEIGHT/2) TO GET TOP LEFT POINT OF THE CAR (TOP LEFT IN THE SCREEN)
;CALCULATE (320*HEIGHT/2) TERM
MOV BX,320
MOV AX,HEIGHT2
shr AX,1
ADD AX,SPEED2
MUL BX
PUSH AX

;CALCULATE WIDTH/2 TERM
MOV AX , WIDTH2
shr AX,1

;GET THE REQUIRED POINT
MOV BX , CENTER2
ADD BX ,AX
POP AX
ADD BX,AX

PUSH BX
MOV AX,BX
MOV DX,HEIGHT2

DOWNROW2:
MOV SI,AX
MOV CX,WIDTH2

LOOP24:
MOV AL, ES:[SI]
    CMP AL, ROAD_COLOR_END
    JZ WIN24
    JMP NOT_WIN24
WIN24:
    MOV playerTwoWin, 1
NOT_WIN24:
CMP AL, ROAD_COLOR_BEGIN
JZ CANTMOVETRACKDOWN2
CMP AL, collisionCOLOR1
JZ CANTMOVETRACKDOWN2
CMP AL, collisionCOLOR2
JZ CANTMOVETRACKDOWN2
CMP AL, 10d
JZ CANTMOVEOBSTACLEDOWN2
DEC SI
LOOP LOOP24
POP AX
SUB AX,320
PUSH AX
DEC DX
CMP DX , 0
JNZ DOWNROW2
POP AX
MOV AL,1
MOV CANMOVEOBSTACLE2,AL
MOV CANMOVETRACK2,AL
JMP EXIT2

CANTMOVETRACKDOWN2:
POP AX
MOV AL,0
MOV CANMOVETRACK2,AL
JMP EXIT2

CANTMOVEOBSTACLEDOWN2:
POP AX
MOV AL,0
MOV CANMOVEOBSTACLE2,AL
INC AL
MOV CANMOVETRACK2,AL
JMP EXIT2
EXIT2:
RET
CheckColisionCar2 ENDP
END 
