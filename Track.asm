EXTRN DrawTrack:FAR
EXTRN FillScreen:FAR
PUBLIC TRACK_IMAGE_HEIGHT, TRACK_IMAGE_WIDTH, buffer, SCREEN_HEIGHT, SCREEN_WIDTH

Include Macros.inc
Include Const.inc

.MODEL SMALL
.STACK 64

;-----------------------------------------

;*************************************
;   Data Section
;*************************************
.DATA

fileName db 'Track.bin'         ;image file name (image is in binary)

buffer db BUFFER_SIZE dup(?)    ;allocate 2000 byte

emptyByte db 0



;---------------------------------------------

;*************************************
;   Code Section
;*************************************
.CODE

START PROC FAR
    MOV AX, @DATA
    MOV DS, AX


;********************************************
;   Load an image from a file to a buffer
;********************************************
    OpenFile OPEN_ATTRIBUTE     ;open the image file
    ReadFile AX                 ;read all the bytes into the buffer
    CloseFile                   ;close the file


;********************************************
;   Draw an Image from the buffer
;********************************************
    ChangeVideoMode 13H

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen
    MOV AL, 00H         ;set the color in al to black
    CALL FillScreen     ;fill the screen with black

    push SCREEN_WIDTH
    push TRACK_IMAGE_WIDTH
    push TRACK_IMAGE_HEIGHT
    MOV SI, OFFSET buffer
    MOV DI, 3200 + 320/2 - TRACK_IMAGE_WIDTH/2 ;STARTING PIXEL
    CALL FAR PTR DrawTrack

    MOV DI, 32000 + 320/2 - TRACK_IMAGE_WIDTH/2 ;STARTING PIXEL
    CALL FAR PTR DrawTrack

    MOV DI, 12800 + 320/2 - TRACK_IMAGE_WIDTH/2 ;STARTING PIXEL
    CALL FAR PTR DrawTrack




    HLT
    RET
START ENDP
END START
