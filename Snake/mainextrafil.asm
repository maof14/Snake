;
; Snake.asm
;
; Created: 2016-04-26 10:34:11
; Author : Mattias
;

; Replace with your application code
// [En lista med registerdefinitioner]
/* t ex */
.DEF rTemp         = r16 ; Se f�rel�sning atmega sid 17 - anv�nds denna p� r�tt s�tt?
.DEF rDirection    = r23 ; Anv�nds inte
.DEF rMellan       = r17 ; Anv�nds f�r mellanlagring
.DEF rPORTB        = r18
.DEF rPORTC        = r19
.DEF rPORTD        = r20
.DEF rSettings	   = r21 ; Att anv�nda
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

; Mattias i farten nu igen
; Definera namn f�r alla kolumner f�r att dessa ska bli enkelt att referera till
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

; Definera namn f�r alla rader. 
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
	 jmp isr_timerOF ; Interrupt subroutine
	 nop
// ... fler interrupts
.ORG INT_VECTORS_SIZE
init: ; Initiering av v�rden, och vad som ska h�nda med timern. 
     // S�tt stackpekaren till h�gsta minnesadressen
    ldi rTemp, HIGH(RAMEND)
    out SPH, rTemp
    ldi rTemp, LOW(RAMEND)
    out SPL, rTemp
	// Stackpekare slut
/*
	; Konfigurera high resp. low f�r Y-registret. 
	ldi YH, HIGH(matrix)
	ldi YL, LOW(matrix)
*/

	; Initiera lite v�rden
	ldi rNoll, 0b00000000
	ldi r21, 0b00000001
	ldi rTemp, 0b11111111

	out DDRB, rTemp ; S�tt alla I/O-portar till output? (ettor p� allt)
	out DDRC, rTemp
	out DDRD, rTemp

	; S�tter joystickar till input!
	cbi DDRC, PC4 ; 
	cbi DDRC, PC5 ;DDR klar

	; Avaktiverar alla lampor 
	out PORTB, rNoll
	out PORTC, rNoll
	out PORTD, rNoll

	; ATMEGA BEGINNERS sida 62 
	; (Man kan kolla vad rmp och rTemp �r genom att belysa dem p� en rad)
	; Timer-konfiguration start

	; 1. Konfigurera pre-scaling genom att s�tta bit 0-2 i TCCR0B
	ldi rSettings, 0x00					; reset
	ldi rSettings,(1<<CS00)|(1<<CS02)		; prescales to 1024. rmp = 0b00000101
	sts TCCR0B, rSettings	
	; 2. Aktivera globala avbrott genom instruktionen sei
	sei
	; 3. Aktivera overflow-avbrottet f�r Timer0 genom att s�tta bit 0 i TIMSK0 till 1.
	ldi rSettings, 0x00
	ldi rSettings, 1<<TOIE0				; Vad g�r denna? rmp = 0b00000001
	sts TIMSK0, rSettings					; sts = out-instruktion fast f�r icke extendat I/O-space
	; Timer-konfiguration slut. 

	// Konfiguration av A/D-omvandlaren
	ldi rSettings, 0x00
	ldi rSettings,(1<<REFS0)|(0<<REFS1)|(1<<ADLAR) ; ADLAR �ndrar till 8-bitarsl�ge f�r input. (mndre precision)
	sts ADMUX, rSettings

	ldi rSettings, 0x00
	ldi rSettings,(1<<ADPS0)|(1<<ADPS1)|(1<<ADPS2)|(1<<ADEN)
	sts ADCSRA, rSettings
	// Konfiguration av A/D-omvandlaren slut. 

main:
	rcall render
	rjmp main
	render:
	ldi rTemp, 0b00000000
	sbi ROW0_PORT, ROW0_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW0_PORT, ROW0_PINOUT
	sbi ROW1_PORT, ROW1_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW1_PORT, ROW1_PINOUT
	sbi ROW2_PORT, ROW2_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW2_PORT, ROW2_PINOUT
	sbi ROW3_PORT, ROW3_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW3_PORT, ROW3_PINOUT
	sbi ROW4_PORT, ROW4_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW4_PORT, ROW4_PINOUT
	sbi ROW5_PORT, ROW5_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW5_PORT, ROW5_PINOUT
	sbi ROW6_PORT, ROW6_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW6_PORT, ROW6_PINOUT
	sbi ROW7_PORT, ROW7_PINOUT
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW7_PORT, ROW7_PINOUT
	ret

	// V�lj k�lla f�r joystick (Y-axel)
	ldi rSettings, 0x00
	ldi rSettings,(0<<MUX3)|(1<<MUX2)|(0<<MUX1)|(0<<MUX0) ; (0b0100)
	sts ADMUX, rSettings
	// V�lj k�lla f�r joystick, Y-axel, slut

	ldi rSettings, 0x00		; Reset rTemp
	ldi rSettings,(1<<ADSC) ; Starta konvertering ---> ADSC = 1 (bit 6)
	sts ADCSRA, rSettings	; Ladda in
	
iterate:
	ldi rSettings, 0x00
	lds rSettings, ADCSRA	; Ta nuvarande ADCSRA f�r att j�mf�ra
	sbrc rSettings, 6		; Kolla om bit 6 (ADSC) �r 0 i rTemp (reflekterar ADCSRA) (instruktion = Skip next instruction if bit in register is cleared)
	jmp iterate			; Iterera
	nop

	; om biten �r skippad kommer vi hit... 

	; L�sa bit fr�n den ut�kade I/O-rymden...
	ldi rSettings, 0x00		; Nollst�ll rTemp
	lds rSettings, ADCL		; Kopiera resultatet fr�n ADCL. Vad ska vi g�ra med detta?
	; Endast ADCL beh�ver l�sas, tack vare A/D-omvandlaren. 

	// Testa att skicka ut datat. 
	; st X+, rTemp ; X+ ?

	rcall render

	rjmp main

	

; Subrutin f�r att t�nda specade lampor
Laddarad:

	ld rMellan, Y ; rMellan = Y

	bst rMellan, 7 ; MSB ; bst - stores bit b from the Rd (rMellan) to the T flag in SREG (status register)
	bld rPORTD, 6 ; bld - copies the T flag in the SREG (status register) to bit b in register Rd (rMellan)

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

isr_timerOF: ; Hantera timer-interupt

	; S�tt rTemp till n�got nytt. 
	/*ldi rTemp, 0b11001011

	sbi ROW1_PORT, ROW1_PINOUT	; Aktivera rad 1
	st Y, rTemp
	rcall Laddarad
	cbi ROW1_PORT, ROW1_PINOUT */

	reti ; (Return from interrupt)