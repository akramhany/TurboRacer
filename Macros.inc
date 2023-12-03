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
