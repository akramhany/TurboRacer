;*****************************
;   General Constants
;*****************************
BUFFER_SIZE equ 2000            ;Size of buffer that would contain the image (in bytes)
TRACK_IMAGE_HEIGHT equ 32   ;Minus 1 to fix some bugs in drawing (even though image height is 20)
TRACK_IMAGE_WIDTH equ 60
SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200
OPEN_ATTRIBUTE equ 0    ;0 is read only


;***************************
;   Directions Constants
;***************************
UP equ 0       ;Up direction
LEFT equ 1     ;Left direction
RIGHT equ 2    ;Right direction
DOWN equ 3     ;Down direction


;***************************************************************
;   Generating Track Constants (Used to update the value of DI)
;***************************************************************
RIGHT_UP  equ (TRACK_IMAGE_HEIGHT - 1) * 320                                                        ;Means we move right then up
RIGHT_DOWN  equ (TRACK_IMAGE_WIDTH - 1) * 320                                                       ;Means we move right then down
UP_RIGHT    equ -(TRACK_IMAGE_HEIGHT - 2) * 320                                                     ;Means we move up then right 
UP_LEFT     equ -((TRACK_IMAGE_WIDTH - TRACK_IMAGE_HEIGHT - 1) + (TRACK_IMAGE_HEIGHT - 1) * 320)    ;Means we move up then left
LEFT_UP     equ (TRACK_IMAGE_HEIGHT - 2) * 320 + (320 - TRACK_IMAGE_HEIGHT)                         ;Means we move left then up
LEFT_DOWN   equ ((TRACK_IMAGE_WIDTH - 1) * 320 - TRACK_IMAGE_HEIGHT)                                ;Means we move left then down
DOWN_RIGHT  equ 320                                                                                 ;Means we move down then right
DOWN_LEFT   equ -(TRACK_IMAGE_WIDTH - TRACK_IMAGE_HEIGHT - 1)                                       ;Means we move down then left