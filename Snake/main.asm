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
.DEF rDirection    = r23
.DEF rMellan       = r17
.DEF rPORTB        = r18
.DEF rPORTC        = r19
.DEF rPORTD        = r20
// …
// */
// [En lista med konstanter]
/* t ex */
.EQU NUM_COLUMNS   = 8
.EQU NUM_ROWS	   = 8 // Mattias
.EQU MAX_LENGTH    = 25
.EQU LED		   = PB6
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

	ldi r16, 0xff
	out DDRB, r16
	out DDRC, r16
	out DDRD, r16
	cbi DDRC, PC4
	cbi DDRC, PC5 //DDR klar

/* loop:
	// ldi r16, 0x0006
	out PORTB, r16
	//out PORTC, r16
	//out PORTD, r16
	// ldi r16, 0x0001

	sbi PORTC, PC0
	//sbi PORTD, PD6
	sbi PORTD, PD6
	sbi PORTD, PD7

	
	rjmp    loop
	nop */

loop:

	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	st Y, r16

	ld rMellan, Y

	bst rMellan, 7
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
	
	bst rMellan, 0
	bld rPORTB, 5

	out PORTD, RPORTD
	out PORTB, RPORTB

	sbi PORTC, PC0

	rjmp	loop
	nop