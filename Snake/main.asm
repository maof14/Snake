;
; Snake.asm
;
; Created: 2016-04-26 10:34:11
; Author : Mattias
;

; Replace with your application code
// [En lista med registerdefinitioner]
/* t ex */
.DEF rTemp         = r16
.DEF rDirection    = r23 ; Används inte
.DEF rMellan       = r17 ; Används för mellanlagring
.DEF rPORTB        = r18
.DEF rPORTC        = r19
.DEF rPORTD        = r20
.DEF rNoll		   = r22
.DEF rmp		   = r24
// …
// */
// [En lista med konstanter]
/* t ex */
//.EQU rmp		   = r24
.EQU NUM_COLUMNS   = 8
.EQU NUM_ROWS	   = 8 // Mattias
.EQU MAX_LENGTH    = 25

; Mattias nu igen
.EQU COL0_DDR = DDRC
.EQU COL0_PORT = PORTC
.EQU COL0_PINOUT = PC0

.EQU COL1_DDR = DDRC
.EQU COL1_PORT = PORTC
.EQU COL1_PINOUT = PC1

.EQU COL2_DDR = DDRC
.EQU COL2_PORT = PORTC
.EQU COL2_PINOUT = PC2

.EQU COL3_DDR = DDRC
.EQU COL3_PORT = PORTC
.EQU COL3_PINOUT = PC3

.EQU COL4_DDR = DDRC
.EQU COL4_PORT = PORTC
.EQU COL4_PINOUT = PC4

.EQU COL5_DDR = DDRD
.EQU COL5_PORT = PORTD
.EQU COL5_PINOUT = PC5

.EQU COL6_DDR = DDRD
.EQU COL6_PORT = PORTD
.EQU COL6_PINOUT = PB1

.EQU COL7_DDR = DDRD
.EQU COL7_PORT = PORTD
.EQU COL7_PINOUT = PB2

// COL

.EQU ROW0_DDR = DDRD
.EQU ROW0_PORT =  PORTD
.EQU ROW0_PINOUT = PD0

.EQU ROW1_DDR = DDRD
.EQU ROW1_PORT = PORTD
.EQU ROW1_PINOUT = PD2

.EQU ROW2_DDR = DDRD
.EQU ROW2_PORT = PORTD
.EQU ROW2_PINOUT = PD3

.EQU ROW3_DDR = DDRD
.EQU ROW3_PORT = PORTD
.EQU ROW3_PINOUT = PD4

.EQU ROW4_DDR = DDRD
.EQU ROW4_PORT = PORTD
.EQU ROW4_PINOUT = PD5

.EQU ROW5_DDR = DDRD
.EQU ROW5_PORT = PORTD
.EQU ROW5_PINOUT = PD6

.EQU ROW6_DDR = DDRD
.EQU ROW6_PORT = PORTD
.EQU ROW6_PINOUT = PD7

.EQU ROW7_DDR = DDRB
.EQU ROW7_PORT = PORTB
.EQU ROW7_PINOUT = PB0

// …
// */
// [Datasegmentet]
/* t ex */
.DSEG
matrix:   .BYTE 8
snake:    .BYTE MAX_LENGTH+1
// …
// */
// [Kodsegmentet]
/* t ex */
.CSEG
// Interrupt vector table
.ORG 0x0000
     jmp init // Reset vector
	 nop
.ORG 0x0020
	 // jmp isr_timerOF // ska vara med enligt referensmanual.. ?
	 // nop
//... fler interrupts
.ORG INT_VECTORS_SIZE
init:
     // Sätt stackpekaren till högsta minnesadressen
     ldi rTemp, HIGH(RAMEND)
     out SPH, rTemp
     ldi rTemp, LOW(RAMEND)
     out SPL, rTemp
// */

/* ATMEGA BEGINNERS sida 62*/ /*
	ldi rTemp, 1<<TOIE0
	out TIMSK, rTemp
	ldi rTemp,(1<<CS00)|(1<<CS02) ;prescales to 1024
	out TCCR0, rTemp

	*/

	
	ldi rNoll, 0x00
	ldi r21, 0x01
	ldi r16, 0xff ; Sätt r16 (rTemp) till 11111111 (255)
	out DDRB, r16 ; Sätt alla I/O-portar till output? (ettor på allt)
	out DDRC, r16
	out DDRD, r16

	

	

	; Sätter joystickar till input!
	cbi DDRC, PC4 ; 
	cbi DDRC, PC5 //DDR klar


	out PORTB, rNoll
	out PORTC, rNoll
	out PORTD, rNoll

main:
	/* ATMEGA BEGINNERS sida 62 */
	ldi rmp, 1<<TOIE0
	sts TIMSK0, rmp		; out-instruktion fast för icke extendat I/O-space. Eller kanske tvärtom?
	ldi rTemp,(1<<CS00)|(1<<CS02) ;prescales to 1024
	sts TCCR0B, rTemp	; --|--
	sei
loop:

	; Få översta raden att lysa genom bitmanipulering, bst / bld

	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)

	st Y, r16 ; Y = 11111111 ; Speca vilka lampor som skall lysa (alla)
	/*sbi PORTC, PC0	; Aktivera PORTC, bit 1 (index 0)
	rcall Laddarad		; Kör subrutin
	st Y, r22			; Speca igen vilka lampor som skall lysa (00000000, inga)
	rcall Laddarad		; Kör subrutin
	cbi PORTC, PC0		; Avaktivera PORTC, bit 1 (index 0)

	st Y, r21			; Speca igen vilka lampor som skall lysa (00000001)
	sbi PORTC, PC1		; Aktivera PORTC
	rcall Laddarad		; Kör subrutin
	st Y, r22			; 00000000
	rcall Laddarad		; 
	cbi PORTC, PC1*/	; Avaktivera

	st Y, r16			; 
	sbi PORTD, PD2		; 
	rcall Laddarad		; 

	cbi PORTD, PD2		; 
	st Y, r22			; 
	rcall Laddarad		; 

	rjmp	loop
	nop

	; Subrutin för att tända specade lampor
Laddarad:
	ld rMellan, Y ; rMellan = Y

	; bst - stores bit b from the Rd (rMellan) to the T flag in SREG (status register)
	; bld - copies the T flag in the SREG (status register) to bit b in register Rd (rMellan)

	bst rMellan, 7 ; MSB
	bld rPORTD, 6

	bst rMellan, 6
	bld rPORTD, 7
	
	bst rMellan, 5
	bld rPORTB, 0
	
	bst rMellan, 4
	bld rPORTB, 1
	
	bst rMellan, 3
	bld rPORTB, 2
	
	bst rMellan, 2
	bld rPORTB, 3
	
	bst rMellan, 1
	bld rPORTB, 4
	
	bst rMellan, 0 ; LSB
	bld rPORTB, 5

	; Outputta den manipulerade bitsträngen?
	out PORTD, rPORTD
	out PORTB, rPORTB

	ret