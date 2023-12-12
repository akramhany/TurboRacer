OpenFile Macro openMode

    mov ah, 03Dh
    mov al, openMode ; 0 - read-only, 1 - write-only, 2 -read&write
    mov dx, offset filename ; ASCII filename to open
    int 21h

ENDM


;fileHandle is the value stored in ax after opening the file
ReadFile Macro fileHandle

    mov bx, fileHandle
    mov ah, 03Fh
    mov cx, buffer_size     ; number of bytes to read
    mov dx, offset buffer   ; were to put read data
    int 21h

ENDM

CloseFile Macro

    MOV ah, 3Eh         ; DOS function: close file
    INT 21H

ENDM

ChangeVideoMode Macro videoMode

    MOV AH, 0
    MOV AL, videoMode
    INT 10H

ENDM

; Description: Handle DI & directions depending on the values of each direction and diChange
HandleDI Macro direction1, direction2, direction3, direction4, directionChange1, directionChange2, directionChange3, directionChange4, diChange

    SUB DI, diChange                        ;Change the value of DI with a certain value (it maybe 0)
    MOV direction3, directionChange3        ;Set each direction with its new value
    MOV direction4, directionChange4        ;Set each direction with its new value
    MOV direction1, directionChange1        ;Set each direction with its new value
    MOV direction2, directionChange2        ;Set each direction with its new value 

ENDM