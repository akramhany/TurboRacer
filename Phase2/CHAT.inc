SetCursor MACRO row, col

    MOV DH, ROW
    MOV DL, COL
    MOV BH, 0
    MOV AH, 02
    INT 10H

ENDM
DisplayString MACRO strToDisp
 

    MOV AH, 09
    MOV DX, offset strToDisp
    INT 21H

ENDM
DISPLAYCHAR MACRO CHARACTER
mov ah,2
MOV DL,CHARACTER
int 21h
ENDM

drawline MACRO ROWLINE
LOCAL LINE
    MOV CL,0
    LINE:
    SETCURSOR ROWLINE,CL
    MOV DL,HYPHEN
    DISPLAYCHAR DL
    INC CL
    CMP CL,80
    JNZ LINE
 
ENDM


.MODEL SMALL
.STACK 64
.DATA
  ;;;;;;;;;;;;;;;;;;;;;;;; CHATTING PROC
DataOut DB ?
    DataIn  DB '8'
    SRX     db 0
    SRY     db 13
    SSendX  db 0
    SSendY  db 1
    HYPHEN DB "-"
    MSG DB '-TO END CHATTING WITH $'
    PRESSMSG DB 'PRESS F3$'
    USER1 DB 'MOSTAFAAAAAAAAA $'
    USER2 DB 'BAKAR $'

;;;;;;;;;;;;;;;;;;
.CODE
CHATTING PROC FAR

            MOV  AX,@DATA
            MOV  DS,AX
            MOV SRX    , 8
            MOV SRY    ,  13
            MOV SSendX,   8
            MOV SSendY  , 1
            mov  ah,00H
            int  10h
; VIDEO MODE 
            mov  ah,0
            mov  al,3h
            int  10h
;DRAW THE SEPERATING LINE
            DRAWLINE 11
            DRAWLINE 22
            SETCURSOR 23,0
            DisplayString MSG
            DisplayString USER1
            DisplayString PRESSMSG
            SETCURSOR 0,0
            DisplayString USER1
            MOV DL,":"
            DISPLAYCHAR DL
            SETCURSOR 12,0
            DisplayString USER2
            MOV DL,":"
            DISPLAYCHAR DL

            


    AGAIN00000:
;MOVE CURSOR 
            SETCURSOR SRY,SRX
            mov  dl,SRX
            mov  dh,SRY
            mov  ah,2
            int  10h

;Check that Data Ready
            MOV  DX,3FDH
    LOP2:    IN   AL,DX
            AND  AL,1
            JZ   SENDLOP
;If Ready read the VALUE in Receive data register
            MOV  DX,03F8H
            IN   AL,DX
            MOV  DataOut,AL
            
;PRINT THE RECEIVING CHARACTER
            MOV  DL,DataOut
            cmp DL,3DH
            JZ EXITCHATING1
            MOV  AH,2
            INT  21H

;GET CURSOR POSITION FOR RECEIVING MODE
            MOV  AH,3
            INT  10h
            CMP DL,79
            JNZ CONT1111
            MOV  SRX,8
            INC DH
            MOV  SRY,DH
            JMP CONT22222
AGAIN1111:     JMP AGAIN00000
CONT1111:
            MOV SRX,DL
            MOV SRY,DH
CONT22222:
            CMP DataOut,0DH
            JNZ NEX
            INC SRY
            MOV SRX,8
            NEX:
;CHECK IF WE REACH LAST LINE IN THE RECEIVING MODE
            CMP SRY,22
            JNZ SKIP1
            mov ah,6       ; function 6
            mov al,1      ; scroll by 1 line
            mov bh,7       ; normal video attribute
            mov ch,13       ; upper left Y
            mov cl,0        ; upper left X
            mov dh,21     ; lower right Y
            mov dl,79      ; lower right X
            int 10h
            MOV SRY,21
            MOV SRX,8
            SETCURSOR 21,0

            SKIP1:
            JMP  AGAIN00000
EXITCHATING1: jmp EXITCHATING

    SENDLOP:
            SETCURSOR SSendY,SSendX
            mov  ah,2
            mov  dl,SSendX
            mov  dh,SSendY
            int  10h

            mov  ah,01h
            int  16h
            jz   AGAIN1111

            mov  ah,00H
            int  16h
            CMP AH,3DH
            JZ EXITCHATING1
            mov  bl,al
            push ax

            cmp ah,3DH
            JNE F3
            xchg al,ah
            f3:
           

            MOV  DX,3FDH
    LOP1:    IN   AL,DX
            AND  AL,00100000B
            JZ   LOP1

            MOV  DX,3F8H
            MOV  AL,bl
            OUT  DX,AL

            pop ax
            cmp ah,3DH
            jE EXITCHATING
            mov  dl,al
            mov  ah,2
            INT  21H

            MOV  AH,3
            INT  10h

            CMP DL,79
            JNZ CONT3333
            MOV  SSendX,8
            INC DH
            MOV  SSendY,DH
            JMP CONT4444
CONT3333:
            MOV SSendX,DL
            MOV SSendY,DH
CONT4444:

            CMP BL,0DH
            JNZ NEX1
            MOV SSENDX,8
            INC SSendY
            NEX1:

            CMP SSENDY,11
            JNZ SKIP
            mov ah,6       ; function 6
            mov al,1      ; scroll by 1 line
            mov bh,7       ; normal video attribute
            mov ch,1       ; upper left Y
            mov cl,0        ; upper left X
            mov dh,10     ; lower right Y
            mov dl,79      ; lower right X
            int 10h
            MOV SSENDY,10
            MOV SSendX,8
            SETCURSOR SSendY,SSENDX

            SKIP:
            JMP  SENDLOP
            EXITCHATING:
            MOV AX, 0600H
            MOV BH,7
            MOV CX ,0
            MOV DX,184FH
            INT 10H

            MOV AH,13H
            INT 10H
            RET

CHATTING ENDP