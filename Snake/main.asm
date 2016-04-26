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

	//sbi LED, (1<<)

	// ldi r16, 0x0006
	out PORTB, r16
	out PORTC, r16
	out PORTD, r16
	// ldi r16, 0x0001
	


//loop:
  //  rjmp    loop
	//nop
