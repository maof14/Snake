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
.DEF RenderctrlA   = r25
// …
// */
// [En lista med konstanter]
/* t ex */
//.EQU rmp		   = r24
.EQU NUM_COLUMNS   = 8
.EQU NUM_ROWS	   = 8 // Mattias
.EQU MAX_LENGTH    = 25

; Mattias i farten nu igen
; Definera namn för alla kolumner för att dessa ska bli enkelt att referera till
.EQU COL0_DDR = DDRD
.EQU COL0_PORT = PORTD
.EQU COL0_PINOUT = PD6

.EQU COL1_DDR = DDRD
.EQU COL1_PORT = PORTD
.EQU COL1_PINOUT = PD7

.EQU COL2_DDR = DDRB
.EQU COL2_PORT = PORTB
.EQU COL2_PINOUT = PB0

.EQU COL3_DDR = DDRB
.EQU COL3_PORT = PORTB
.EQU COL3_PINOUT = PB1

.EQU COL4_DDR = DDRB
.EQU COL4_PORT = PORTB
.EQU COL4_PINOUT = PB2

.EQU COL5_DDR = DDRB
.EQU COL5_PORT = PORTB
.EQU COL5_PINOUT = PB3

.EQU COL6_DDR = DDRB
.EQU COL6_PORT = PORTB
.EQU COL6_PINOUT = PB4

.EQU COL7_DDR = DDRB
.EQU COL7_PORT = PORTB
.EQU COL7_PINOUT = PB5

// COL

; Definera namn för alla rader. 
.EQU ROW0_DDR = DDRC
.EQU ROW0_PORT =  PORTC
.EQU ROW0_PINOUT = PC0

.EQU ROW1_DDR = DDRC
.EQU ROW1_PORT = PORTC
.EQU ROW1_PINOUT = PC1

.EQU ROW2_DDR = DDRC
.EQU ROW2_PORT = PORTC
.EQU ROW2_PINOUT = PC2

.EQU ROW3_DDR = DDRC
.EQU ROW3_PORT = PORTC
.EQU ROW3_PINOUT = PC3

.EQU ROW4_DDR = DDRD
.EQU ROW4_PORT = PORTD
.EQU ROW4_PINOUT = PD2

.EQU ROW5_DDR = DDRD
.EQU ROW5_PORT = PORTD
.EQU ROW5_PINOUT = PD3

.EQU ROW6_DDR = DDRD
.EQU ROW6_PORT = PORTD
.EQU ROW6_PINOUT = PD4

.EQU ROW7_DDR = DDRD
.EQU ROW7_PORT = PORTD
.EQU ROW7_PINOUT = PD5

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
Render:

	; Få översta raden att lysa genom bitmanipulering, bst / bld
	
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ldi r16, 0x6e
	/*

	st Y, r16 ; Y = 11111111 ; Speca vilka lampor som skall lysa (alla)
	sbi PORTC, PC0	; Aktivera PORTC, bit 1 (index 0)
	rcall Laddarad		; Kör subrutin
	st Y, r22			; Speca igen vilka lampor som skall lysa (00000000, inga)
	rcall Laddarad		; Kör subrutin
	cbi PORTC, PC0		; Avaktivera PORTC, bit 1 (index 0)

	st Y, r21			; Speca igen vilka lampor som skall lysa (00000001)
	sbi PORTC, PC1		; Aktivera PORTC
	rcall Laddarad		; Kör subrutin
	st Y, r22			; 00000000
	rcall Laddarad		; 
	cbi PORTC, PC1	; Avaktivera

	st Y, r16			; 
	sbi PORTD, PD2		; 
	rcall Laddarad		; 

	cbi PORTD, PD2		; 
	st Y, r22			; 
	rcall Laddarad		; 
	*/
	/*ldi rTemp, 0x07
	cp RenderctrlA, rTemp
	breq equal
*/	
	sbi ROW0_PORT, ROW0_PINOUT	; Aktivera rad 0
	st y, r16					; Sätt vilka lampor ska lysa
	rcall Laddarad				; Ladda raden
	cbi ROW0_PORT, ROW0_PINOUT	; Rensa raden

	sbi ROW6_PORT, ROW6_PINOUT
	st y, r16
	rcall Laddarad
	cbi ROW6_PORT, ROW6_PINOUT
	
	/*sbi PORTC, PC2
	st Y, r16
	rcall Laddarad
	cbi PORTC, PC2
	
	sbi PORTC, PC3
	st Y, r16
	rcall Laddarad
	cbi PORTC, PC3
	
	sbi PORTD, PD2
	st Y, r16
	rcall Laddarad
	cbi PORTD, PD2
	
	sbi PORTD, PD3
	st Y, r16
	rcall Laddarad
	cbi PORTD, PD3
	
	sbi PORTD, PD4
	st Y, r16
	rcall Laddarad
	cbi PORTD, PD4
	
	sbi PORTD, PD5
	st Y, r16
	rcall Laddarad
	cbi PORTD, PD5 */



	;equal: ret

	rjmp	Render
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