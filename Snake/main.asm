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
.DEF rDirection    = r23 ; Anv�nds inte
.DEF rMellan       = r17 ; Anv�nds f�r mellanlagring
.DEF rPORTB        = r18
.DEF rPORTC        = r19
.DEF rPORTD        = r20
.DEF rNoll		   = r22
.DEF rmp		   = r24
.DEF RenderctrlA   = r25
// �
// */
// [En lista med konstanter]
/* t ex */
//.EQU rmp		   = r24
.EQU NUM_COLUMNS   = 8
.EQU NUM_ROWS	   = 8 // Mattias
.EQU MAX_LENGTH    = 25
.EQU LED		   = PB6
// �
// */
// [Datasegmentet]
/* t ex */
.DSEG
matrix:   .BYTE 8
snake:    .BYTE MAX_LENGTH+1
// �
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
     // S�tt stackpekaren till h�gsta minnesadressen
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
	ldi r16, 0xff ; S�tt r16 (rTemp) till 11111111 (255)
	out DDRB, r16 ; S�tt alla I/O-portar till output? (ettor p� allt)
	out DDRC, r16
	out DDRD, r16

	

	

	; S�tter joystickar till input!
	cbi DDRC, PC4 ; 
	cbi DDRC, PC5 //DDR klar


	out PORTB, rNoll
	out PORTC, rNoll
	out PORTD, rNoll

main:
	/* ATMEGA BEGINNERS sida 62 */
	ldi rmp, 1<<TOIE0
	sts TIMSK0, rmp		; out-instruktion fast f�r icke extendat I/O-space. Eller kanske tv�rtom?
	ldi rTemp,(1<<CS00)|(1<<CS02) ;prescales to 1024
	sts TCCR0B, rTemp	; --|--
	sei
Render:

	; F� �versta raden att lysa genom bitmanipulering, bst / bld
	
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
	ldi r16, 0xff
	/*

	st Y, r16 ; Y = 11111111 ; Speca vilka lampor som skall lysa (alla)
	sbi PORTC, PC0	; Aktivera PORTC, bit 1 (index 0)
	rcall Laddarad		; K�r subrutin
	st Y, r22			; Speca igen vilka lampor som skall lysa (00000000, inga)
	rcall Laddarad		; K�r subrutin
	cbi PORTC, PC0		; Avaktivera PORTC, bit 1 (index 0)

	st Y, r21			; Speca igen vilka lampor som skall lysa (00000001)
	sbi PORTC, PC1		; Aktivera PORTC
	rcall Laddarad		; K�r subrutin
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
	sbi PORTC, PC0		; aktiverar raden
	st Y, r16			; laddar r16 till Y(ska �ndras till att l�sa fr�n matrix)
	rcall Laddarad		; k�r subrutinen Laddarad
	cbi PORTC, PC0		; avaktiverar raden

	sbi PORTC, PC1
	st Y, r16
	rcall Laddarad
	cbi PORTC, PC1
	
	sbi PORTC, PC2
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
	cbi PORTD, PD5



	;equal: ret

	rjmp	Render
	nop

	; Subrutin f�r att t�nda specade lampor
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

	; Outputta den manipulerade bitstr�ngen?
	out PORTD, rPORTD
	out PORTB, rPORTB

	ret