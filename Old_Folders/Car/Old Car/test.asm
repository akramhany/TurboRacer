DeleteBox MACRO

    MOV DL, 00H
    MOV BX, boxPosition
    SUB BX, 2 * 320
    SUB BX, 5
    MOV CL, 30

    CALL FAR PTR DrawBox

ENDM

Delay MACRO 

MOV     CX, 01H
MOV     DX, 3240H
MOV     AH, 86H
INT     15H

ENDM

MOVE_UP MACRO

    MOV DX, 0
    MOV CX, 0

    MOV BX, boxPosition
    SUB BX, 2 * 320
    MOV boxPosition, BX
    MOV DL, 05H
    MOV CL, 20
    CALL FAR PTR DrawBox

ENDM

MOVE_RIGHT MACRO

    MOV DX, 0
    MOV CX, 0

    MOV BX, boxPosition
    ADD BX, 2
    MOV boxPosition, BX
    MOV DL, 05H
    MOV CL, 20
    CALL FAR PTR DrawBox ;MOVE RIGHT

ENDM

.286
.MODEL SMALL
.STACK 100H
.DATA 

origIntOffset dw 0
db ?
origIntSegment dw 0
db ?
boxPosition dw 100 * 320 + 150
db ?
blabla    db 'hi$'
db ?
shouldExit db 0
 db ?

width equ 20
Color equ 05H

moveDirectionRight db 0      ;1 up, 2 right, 3 left, 4 down
moveDirectionUp db 0      ;1 up, 2 right, 3 left, 4 down

.CODE 


OverRideInt9 PROC FAR
    IN AL, 60H      ;READ SCAN CODE

    CMP AL, 48H        ;CHECK UP KEY
    JNE NOT_PRESSED
    MOV moveDirectionUp, 1

    JMP CONT

NOT_PRESSED:
    CMP AL, 48H + 80H
    JNE NOT_RELEASED
    MOV moveDirectionUp, 0
    JMP CONT

NOT_RELEASED:
    CMP AL, 4DH
    JNE NOT_PRESSED2

    MOV moveDirectionRight, 1
    JMP CONT
    

NOT_PRESSED2:
    CMP AL, 4DH + 80H
    JNE NOT_RELEASED2
    MOV moveDirectionRight, 0
    JMP CONT


NOT_RELEASED2:
    CMP AL, 1H
    JNE CONT
    MOV shouldExit, 1

CONT:
    MOV AL, 20H
    OUT 20H, AL
    IRET
OverRideInt9 ENDP


;;MAIN
MAIN PROC FAR
    MOV AX, @DATA   
    MOV DS, AX 

    
    CLI
    MOV AX, 3509h
    INT 21H

    MOV origIntOffset, BX
    MOV origIntSegment, ES
    

    PUSH DS

    MOV AX, CS
    MOV DS, AX
    MOV AX, 2509h
    LEA DX, OverRideInt9
    INT 21H
    POP DS
    STI


    MOV AH, 0
    MOV AL, 13h
    INT 10H

    MOV BX, boxPosition
    MOV CL, 20
    MOV DL, 05H
    CALL FAR PTR DrawBox 

LOOPY:
    CMP shouldExit, 1
    JE KILLINT
    CMP moveDirectionUp, 1
    JNE TEMP1
    DeleteBox
    MOVE_UP
    
TEMP1:
    CMP moveDirectionRight, 1
    JNE TEMP2
    DeleteBox
    MOVE_RIGHT


TEMP2:
    Delay
    JMP LOOPY

KILLINT:
    ;CLEAR SCREEN
    mov ax ,0600h
  	mov bh,0h
  	mov cx,0h
  	mov dx , 184fh
  	int 10h


    ;Return Interrupt 9
    CLI
    mov ax, origIntOffset
    mov dx, origIntSegment
    
    push ds
    mov ds, ax

    mov ax, 2509h
    int 21h
    ; Re-enable interrupts
    pop ds
    STI

    mov ah, 4CH
    int 21H

MAIN ENDP



;TAKE THE BOX DIMENSIONAS IN CL, COORDINATES IN BX, COLOR IN DL
DrawBox PROC FAR
    PUSH AX
    PUSH ES
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, 0A000H
    MOV ES, AX

    MOV CH, CL
    MOV AL, CL
    MOV AH, 0

LOOP1:
    MOV CL, AL

    LOOP2:
        MOV ES:[BX], DL
        INC BX
        DEC CL
        CMP CL, 0
        JNE LOOP2
    
    ADD BX, 320
    SUB BX, AX
    DEC CH
    CMP CH, 0
    JNE LOOP1

    POP DX
    POP CX
    POP BX
    POP ES
    POP AX

    RET
DrawBox ENDP

showmes macro str
    mov ah,09h
    lea dx,str
    int 21h  
endm   

moveCursor macro x, y
    mov dl, x
    mov dh, y
    mov ah, 2H
    int 10h  
endm

ClearScreen PROC FAR
    PUSH AX
    PUSH CX
    PUSH DX

    MOV AX, 0A000H
    MOV ES, AX

    XOR DI, DI
    MOV CX, 320 * 200 / 2   ; Assuming mode 13h (320x200), 2 bytes per pixel

    MOV AX, 0000H           ; Clear with color 0
    REP STOSW

    POP DX
    POP CX
    POP AX

    RET
ClearScreen ENDP

END MAIN