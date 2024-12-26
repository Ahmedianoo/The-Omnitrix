	AREA MY_SNAKE_DATA, DATA, READONLY
	
BLACK	EQU   	0x0000
BLUE 	EQU  	0x001F
RED  	EQU  	0xF800
RED2   	EQU 	0x4000
GREEN 	EQU  	0x07E0  
CYAN  	EQU  	0x07FF
MAGENTA EQU 	0xF81F
YELLOW	EQU  	0xFFE0
WHITE 	EQU  	0xFFFF 
GREEN2 	EQU 	0x2FA4
CYAN2 	EQU  	0x07FF
BEN     EQU		0xaff7

;-----Hamburger Colors-----
BUN_COLOR EQU 0xFFE0
BURGER_COLOR EQU 0xc2a0
LETTUCE_COLOR EQU 0x07e0
TOMATO_COLOR EQU 0x4000
;--------------------------

;-----Snake Dimensions-----
SNAKE_LENGTH EQU 30
SNAKE_WIDTH EQU 3
;--------------------------

	
	AREA SNAKE_CODE, CODE, READONLY
	EXPORT SNAKE_GAME
	IMPORT DRAW_RECTANGLE_FILLED
	IMPORT READ_BUTTONS
	IMPORT delay_1_second
	IMPORT delay_half_second
		
SNAKE_GAME FUNCTION
	PUSH{R0-R12, LR}
	LDR R8, =SNAKE_LENGTH
	LDR R9, =SNAKE_WIDTH
	;Setting Up Enviroment
	;1) Draw the background (Black)
	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #240
	LDR R10, =BLACK
    BL DRAW_RECTANGLE_FILLED
	
	;2) Draw CRABBY_PATTY (to be eaten by snake)
	MOV R0, #200
	MOV R1, #200
	BL DRAW_CRABBY_PATY
	
	;3) Draw Intial Snake (Blue)
	;intial orientation is towards left
	;snake is a rectangle of height 7 and width 30
	MOV R0, #100
    MOV R1, #100
    ADD R3, R0, R8
    ADD R4, R1, R9
	LDR R10, =BLUE
    BL DRAW_RECTANGLE_FILLED
	
	
	MOV R5, #0
GAME_LOOP
	CMP R5, #16					; 16 = OK, OK = EXIT GAME
	BEQ EXIT_SNAKE_GAME

	BL DRAW_NEW_SNAKE
	BL delay_half_second
	MOV R5, #0
	BL READ_BUTTONS
	
	;CHECK FOR SNAKE HEAD INSIDE CRABBY PATTY BOUNDARIES
	;CRABBY BOUNDARIES (200,200) --> (212,214)
	;WIN CONDITION
	CMP R0, #200
	BLE NO_WIN
	CMP R0, #212
	BGE NO_WIN
	CMP R1, #200
	BLE NO_WIN
	CMP R1, #214
	BGE NO_WIN

WIN_GAME
	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #240
	LDR R10, =CYAN
    BL DRAW_RECTANGLE_FILLED
	;keep win screen for 6 seconds
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	B SNAKE_GAME
NO_WIN

	;Check for Losing condition
	;X of head outside (0,320)
	CMP R0, #320
	BHS LOSE
;	CMP R0, #0
;	BLT LOSE
	;Y of head outside (0,240)
	CMP R1, #240
	BHS LOSE
;	CMP R1, #0
;	BLT LOSE
	B NO_LOSE
LOSE

	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #240
	LDR R10, =RED
    BL DRAW_RECTANGLE_FILLED
	;keep lose screen for 6 seconds
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	BL delay_1_second
	B SNAKE_GAME
NO_LOSE
	
	
	B GAME_LOOP
	
EXIT_SNAKE_GAME	
	
	MOV R0, #0
    MOV R1, #0
    MOV R3, #320
    MOV R4, #240
	LDR R10, =BLACK
    BL DRAW_RECTANGLE_FILLED
	POP{R0-R12, PC}
	ENDFUNC



;------------------------------------------Draw Crabby Patty Function------------------------------------------
DRAW_CRABBY_PATY FUNCTION
	;This function takes X , Y and draws a crabby paty
	;R0 --> Starting X
	;R1 --> Starting Y
	;(X1,Y1) --> (X1+7,Y1+7)
	;Starting y for each rectangle will change, but starting X will be the same
	PUSH{R0-R12, LR}
	
    ADD R3, R0, #12 ;set ending X
    ADD R4, R1, #4 ;set ending Y
	LDR R10, =BUN_COLOR
    BL DRAW_RECTANGLE_FILLED
	
	MOV R7, R1 ;save starting Y
	
    ADD R1, R1, #4 ;change starting Y
    ADD R3, R0, #12 ;set ending X
    ADD R4, R1, #2 ;set ending Y
	LDR R10, =BURGER_COLOR
    BL DRAW_RECTANGLE_FILLED
	
	ADD R1, R1, #2 ;change starting Y
    ADD R3, R0, #12 ;set ending X
    ADD R4, R1, #2 ;set ending Y
	LDR R10, =LETTUCE_COLOR
    BL DRAW_RECTANGLE_FILLED
	
	ADD R1, R1, #2 ;change starting Y
    ADD R3, R0, #12 ;set ending X
    ADD R4, R1, #2 ;set ending Y
	LDR R10, =TOMATO_COLOR
    BL DRAW_RECTANGLE_FILLED
	
	ADD R1, R1, #2 ;change starting Y
    ADD R3, R0, #12 ;set ending X
    ADD R4, R1, #4 ;set ending Y
	LDR R10, =BUN_COLOR
    BL DRAW_RECTANGLE_FILLED
	
	POP{R0-R12, PC}
	ENDFUNC
;###############################################################################################################
	


;------------------------------------------Draw New Snake------------------------------------------
DRAW_NEW_SNAKE FUNCTION
	;R0 --> X of Head
	;R1 --> Y of Head  
	;R5 --> state/direction (L:1 R:2 UP:4 DOWN:8)

	PUSH{R10-R11, LR}
	LDR R10, =SNAKE_LENGTH ;(30)
	LDR R11, =SNAKE_WIDTH  ;(7)
	
	;;;Draw another Snake to the left
	CMP R5, #1 ;LEFT_VALUE_DECIMAL
	BNE SKIP_DRAW_SNAKE_LEFT
	
	MOV R3, R0      ;X2 is the same as previous starting X
	ADD R3, R3, R11 ;allows overlapping of snake to happen
	SUB R0, R0, R10
    ADD R4, R1, R11
	
	CMP R0, #0
	BLT LOSE
	
	LDR R10, =BLUE
    BL DRAW_RECTANGLE_FILLED
	
	;;Modify Snake Head (Automatically Logically Done)
	
SKIP_DRAW_SNAKE_LEFT


	;;;Draw another Snake to the right
	CMP R5, #2 ;RIGHT_VALUE_DECIMAL
	BNE SKIP_DRAW_SNAKE_RIGHT
	
	ADD R3, R0, R10
	ADD R4, R1, R11
	LDR R10, =BLUE
    BL DRAW_RECTANGLE_FILLED
	
	;;Modify Snake Head
	ADD R0, R0, R10 
	
SKIP_DRAW_SNAKE_RIGHT


	;;;Draw another Snake UPWARDS
	CMP R5, #4 ;UP_VALUE_DECIMAL
	BNE SKIP_DRAW_SNAKE_UP
	
	ADD R3, R0, R11
	ADD R4, R1, R11 
	SUB R1, R1, R10
	ADD R1, R1, R11
	
	CMP R1, #0
	BLT LOSE

	LDR R10, =BLUE
    BL DRAW_RECTANGLE_FILLED
	
	;;Modify Snake Head (Automatically Logically Done)
	
SKIP_DRAW_SNAKE_UP


	;;;Draw another Snake DOWNWARDS
	CMP R5, #8 ;DOWN_VALUE_DECIMAL
	BNE SKIP_DRAW_SNAKE_DOWN
	
	ADD R3, R0, R11
	ADD R4, R1, R10
	LDR R10, =BLUE
    BL DRAW_RECTANGLE_FILLED
	
	;;Modify Snake Head
	ADD R1, R1, R10
	
SKIP_DRAW_SNAKE_DOWN

	POP{R10-R11, PC}
	ENDFUNC
;###############################################################################################################
	
		
	END
		
		