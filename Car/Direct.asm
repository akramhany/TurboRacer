EXTRN Car1Position:BYTE
EXTRN Car2Position:BYTE
PUBLIC UpToRight 
PUBLIC UpToLeft
PUBLIC DownToRight
PUBLIC DownToLeft  
PUBLIC RightToUp
PUBLIC RightToDown
PUBLIC LeftToUp
PUBLIC LeftToDown    
.MODEL SMALL
.CODE
UpToRight PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI]
MOV [DI+6],cx
Add Cx,36
mov [DI+4],cx
mov [DI+2],AX
sub AX,15
mov [DI],AX
RET
UpToRight ENDP
;;;;;;;;;;;;;;;;;;
DownToRight PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI]
MOV [DI+6],cx
Add Cx,36
mov [DI+4],cx
mov [DI],BX
add BX,15
mov [DI+2],BX
RET
DownToRight ENDP
;;;;;;;;;;;;;;;;;;
UpToLeft PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI+2]
MOV [DI+4],cx
sub Cx,36
mov [DI+6],cx
mov [DI+2],AX
sub AX,15
mov [DI],AX
RET
UpToLeft ENDP
;;;;;;;;;;;;;;;;;;
DownToLeft PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI+2]
MOV [DI+4],cx
sub Cx,36
mov [DI+6],cx
mov [DI],BX
add BX,15
mov [DI+2],BX
RET
DownToLeft ENDP
;;;;;;;;;;;;;;;;;;
RightToUp PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]       ;Y1
Mov BX,[DI+6]       ;Y2
Mov CX,[DI+2]       ;X2
Mov DX,[DI]         ;X1
MOV [DI+4],cx       ;MAKE Y1 = X2
sub Cx,36           ;SUB FROM X2 THE HEIGHT OF THE CAR
mov [DI+6],cx       ;MAKE Y2 = X2
mov [DI],BX         ;MAKE X1 = BX
add BX,15           ;ADD TO BX THE WIDTH OF THE CAR
mov [DI+2],BX       ;X2 = BX
RET
RightToUp ENDP
;;;;;;;;;;;;;;;;;;
RightToDown PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI+2]
Mov DX,[DI]
MOV [DI+6],DX
add DX,36
mov [DI+4],DX
mov [DI],BX
add BX,15
mov [DI+2],BX
RET
RightToDown ENDP
;;;;;;;;;;;;;;;;;;
LeftToUp PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI+2]
Mov DX,[DI]
MOV [DI+4],cx
sub Cx,36
mov [DI+6],cx
mov [DI+2],AX
SUB AX,15
mov [DI],AX
RET
LeftToUp ENDP
;;;;;;;;;;;;;;;;;;
LeftToDown PROC FAR
LEA DI,Car1Position
Mov AX,[DI+4]
Mov BX,[DI+6]
Mov CX,[DI+2]
Mov DX,[DI]
MOV [DI+6],DX
add DX,36
mov [DI+4],DX
mov [DI+2],AX
SUB AX,15
mov [DI],AX
RET
LeftToDown ENDP
;;;;;;;;;;;;;;;;;;
END UpToRight