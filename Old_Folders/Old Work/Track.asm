EXTRN GenerateTrack:FAR
EXTRN DrawTrackHorizontal:FAR
EXTRN DrawTrackVertical:FAR
EXTRN FillScreen:FAR
PUBLIC upDist, downDist, leftDist, rightDist

Include Macros.inc
Include Const.inc

.MODEL SMALL
.STACK 64

;-----------------------------------------

;*************************************
;   Data Section
;*************************************
.DATA

fileName db 'TrackN.bin'         ;image file name (image is in binary)

buffer db BUFFER_SIZE dup(?)    ;allocate 1000 byte

emptyByte db 0

upDist dw 0
downDist dw (TRACK_IMAGE_WIDTH * 320)
leftDist dw -(TRACK_IMAGE_WIDTH)
rightDist dw 0

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


;*****************************************************
;   Generate A Track with a set of specific commands
;*****************************************************
    ChangeVideoMode 13H

    MOV AX, 0A000h      ;the start of the screen in memory
    MOV ES, AX          ;set the ES to point at the start of the screen
    MOV AL, 00H         ;set the color in al to black
    CALL FillScreen     ;fill the screen with black

    MOV SI, OFFSET buffer       ;Make SI point to the start of the buffer (which stores the image)
    MOV DI, 100 * 320 + 100      ;The starting pixel to Generate the track from
    
    PUSH LEFT
    PUSH UP
    PUSH RIGHT
    PUSH DOWN

    CALL FAR PTR GenerateTrack




    MOV AH, 00H     
    INT 16H         ;wait for user input to prevent the program from ending

    MOV AH,4CH
    INT 21H
    
START ENDP

END START


;;TODO: 1- make a variable to store the last direction, 2- put images for corners and handle them