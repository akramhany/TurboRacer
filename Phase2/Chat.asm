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
    DataOut DB ?
    DataIn  DB '8'
    SRX     db 0
    SRY     db 12
    SSendX  db 0
    SSendY  db 0
    HYPHEN DB "-"
    MSG DB '-TO END CHATTING WITH $'
    PRESSMSG DB 'PRESS F3$'
    USER1 DB 'MOSTAFAAAAAAAAA $'
    USER2 DB 'BAKAR $'
.CODE

CHATTING PROC FAR

    MOV  AX,@DATA
             MOV  DS,AX

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
;Set Divisor Latch Access Bit
             MOV  DX,3FBH
             MOV  AL,10000000B
             OUT  DX,AL
;Set LSB byte of the Baud Rate Divisor Latch register
             MOV  DX,3F8H
             MOV  AL,0CH
             OUT  DX,AL
;Set MSB byte of the Baud Rate Divisor Latch register
             MOV  DX,3F9H
             MOV  AL,00H
             OUT  DX,AL
;Set port configuration
             MOV  DX,3FBH
             MOV  AL,00011011B
             OUT  DX,AL

    AGAIN:
;MOVE CURSOR 
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
             MOV  AH,2
             INT  21H


;GET CURSOR POSITION FOR RECEIVING MODE
             MOV  AH,3
             INT  10h
             CMP DL,79
             JNZ CONT1
             MOV  SRX,0
             INC DH
             MOV  SRY,DH
             JMP CONT2
AGAIN1:     JMP AGAIN
CONT1:
             MOV SRX,DL
             MOV SRY,DH
CONT2:
            CMP DataOut,0DH
            JNZ NEX
            INC SRY
            NEX:
;CHECK IF WE REACH LAST LINE IN THE RECEIVING MODE
            CMP SRY,22
            JNZ SKIP1
            mov ah,6       ; function 6
            mov al,1      ; scroll by 1 line
            mov bh,7       ; normal video attribute
            mov ch,12       ; upper left Y
            mov cl,0        ; upper left X
            mov dh,21     ; lower right Y
            mov dl,79      ; lower right X
            int 10h
            MOV SRY,21
            MOV SRX,0
            SETCURSOR 21,0

            SKIP1:
            JMP  AGAIN

    SENDLOP:
            SETCURSOR SSendY,SSendX
             mov  ah,2
             mov  dl,SSendX
             mov  dh,SSendY
             int  10h

             mov  ah,01h
             int  16h
             jz   AGAIN1

             mov  ah,00H
             int  16h
             CMP AH,3CH
             JE EXIT
             mov  bl,al

             mov  dl,bl
             mov  ah,2
             INT  21H

             MOV  DX,3FDH
    LOP1:    IN   AL,DX
             AND  AL,00100000B
             JZ   LOP1

             MOV  DX,3F8H
             MOV  AL,bl
             OUT  DX,AL

             MOV  AH,3
             INT  10h

             CMP DL,79
             JNZ CONT3
             MOV  SSendX,0
             INC DH
             MOV  SSendY,DH
             JMP CONT4
CONT3:
             MOV SSendX,DL
             MOV SSendY,DH
CONT4:

            CMP BL,0DH
            JNZ NEX1
            MOV SSENDX,0
            INC SSendY
            NEX1:

            CMP SSENDY,11
            JNZ SKIP
            mov ah,6       ; function 6
            mov al,1      ; scroll by 1 line
            mov bh,7       ; normal video attribute
            mov ch,0       ; upper left Y
            mov cl,0        ; upper left X
            mov dh,10     ; lower right Y
            mov dl,79      ; lower right X
            int 10h
            MOV SSENDY,10
            MOV SSendX,0

            SKIP:
             JMP  SENDLOP
EXIT:
mov ax,0600h
mov bh,07
mov cx,0
mov dx,184FH
int 10h
HLT
             RET

CHATTING ENDP



END CHATTING