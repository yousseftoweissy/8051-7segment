  ORG		0H
		LJMP	MAIN
		
		
		ORG		3H
		LJMP	EXT_INT0
			
			
	   ORG		13H
	   LJMP	EXT_INT1	
		
		ORG		1BH
		LJMP	TIMER1_INT
		
	    ORG		30H
     MAIN:	
	        MOV		SP,#2FH ;moves stack pointer to scratch pad
			MOV     TMOD,#00010001B ;sets mode one
            MOV		DPTR,   #CC_PATTERNS ;7-segment pattern
            MOV     A,#0X-1	;initial value for acc
			MOV 	B,A
			MOV 	R0,#02H ;r0 register responsible for toggling between 7 segments
			MOV     R3,#00H ;responsible for incrementing tens value
			MOV     R4,#0XC0 ;responsible for tens value as well as initial value
			MOV     IE,#10001111B ;enabling interrupts
			setb IT0 ;enabling falling edge interrupts
			setb IT1
THERE:      SJMP THERE ;keeps jumping
	
	
EXT_INT0:

  
	    MOV		TL1,	#0X00 ;initial value of timer 1 20ms
		MOV		TH1,	#0X4C
		SETB P1.0 ;to allow only one 7-segment to be turned on
		CLR P1.1
		MOV A,B
		INC A ;responsible for counting up
        MOV B,A
    	MOVC A,@A+DPTR
		MOV    R0,#02H ;to ensure first value loaded up is to specific 7-segment
        SETB TR1 ;turn on timer 1
		RETI


		
			
EXT_INT1:

MOV R1,B 
MOV R4,B
CJNE R1,#0H,ABOUT2 ;makes sure tens not over while decrementing
       DEC R3
       MOV     A,R3
	   MOVC    A,@A+DPTR
	   MOV     R4,A ;to decrement the tens value
MOV B,#0AH ;to start decrementing from 9
MOV A,B
DEC A
MOV B,A
MOVC A,@A+DPTR ;to decrement units value from the start

RETI	
ABOUT2:
       MOV     A,R3
	   MOVC    A,@A+DPTR
	   MOV     R4,A ;to control tens value
       MOV A,B
       DEC A ;to decrement units value
       MOV B,A
       MOVC A,@A+DPTR
       RETI

	

			

TIMER1_INT:
        MOV		TL1,	#0X00 ;reinitialise value of timer 1 after overflow
		MOV		TH1,	#0X4C
		ACALL   DELAY1 ;to adjust refresh rate to 120 ms
	    CPL     p1.0 ;to ensure only 1 7-segment operates
		CPL     P1.1
        DJNZ    R0,LOOP ;to control which 7-segment is on
		CJNE    A,#0XFF,ABOUT ;checks if tens is over or not
		MOV     A,R3
		MOVC    A,@A+DPTR
		MOV     P2,#0XC0 ;as first value in new units
		INC     R3 ;responsible for incrementing tens value
		MOV     A,R3
	 	MOVC    A,@A+DPTR
		MOV     R4,A ;to control and keep value of new tens constant
		MOV     A,#0XC0 ;to keep value of new units constant if increment button not pushed
		MOV     R0,#02H ;reloads r2 register
		MOV     B,#0H ;to start over in incrementing when button pushed
		
		RETI
ABOUT:
;if tens still not over
        MOV     P2,A ;increment units normally
		MOV     R0,#02H ;reload r0 value for next overflow
		
		RETI
 
LOOP:   MOV    P2,R4 ;responsible for tens
        
		RETI
 
			
			
			
DELAY1:
;100ms delay
		MOV		R5, #25D
LABEL:	 
			ACALL   DELAY	
			ACALL   DELAY			   
			ACALL   DELAY      
			ACALL   DELAY		   
			DJNZ    R5,LABEL		   
			RET

;makes 1msec delay crystal 11.0592 MHz
DELAY:
			MOV     R6,#10D		  
			MOV     R7,#250D
LABEL1:		DJNZ    R6,LABEL1
LABEL2:		DJNZ    R7,LABEL2
		RET
			
			CC_PATTERNS: 
			DB 	0C0H, 0F9H, 0A4H, 0B0H, 99H, 92H, 82H, 0F8H, 80H, 90H,0FFH
	END