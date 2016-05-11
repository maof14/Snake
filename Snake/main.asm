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
	 jmp isr_timerOF ; Interrupt subroutine
	 nop
// ... fler interrupts
.ORG INT_VECTORS_SIZE
init: ; Initiering av värden, och vad som ska hända med timern. 
     // Sätt stackpekaren till högsta minnesadressen
    ldi rTemp, HIGH(RAMEND)
    out SPH, rTemp
    ldi rTemp, LOW(RAMEND)
    out SPL, rTemp
	// Stackpekare slut

	; Initiera lite värden
	ldi rNoll, 0b00000000
	ldi r21, 0b00000001
	ldi rTemp, 0b11111111

	out DDRB, rTemp ; Sätt alla I/O-portar till output? (ettor på allt)
	out DDRC, rTemp
	out DDRD, rTemp

	; Sätter joystickar till input!
	cbi DDRC, PC4 ; 
	cbi DDRC, PC5 //DDR klar

	; Sätter LED-portar till output. 
	out PORTB, rNoll
	out PORTC, rNoll
	out PORTD, rNoll

	; ATMEGA BEGINNERS sida 62 
	; (Man kan kolla vad rmp och rTemp är genom att belysa dem på en rad)

	; 1. Konfigurera pre-scaling genom att sätta bit 0-2 i TCCR0B
	ldi rmp, 0x00					; reset
	ldi rmp,(1<<CS00)|(1<<CS02)		; prescales to 1024. rmp = 0b00000101
	sts TCCR0B, rmp	
	; 2. Aktivera globala avbrott genom instruktionen sei
	sei
	; 3. Aktivera overflow-avbrottet för Timer0 genom att sätta bit 0 i TIMSK0 till 1.
	ldi rmp, 0x00
	ldi rmp, 1<<TOIE0				; Vad gör denna? rmp = 0b00000001
	sts TIMSK0, rmp					; sts = out-instruktion fast för icke extendat I/O-space

	// Konfiguration av A/D-omvandlaren
	ldi rTemp, 0x00
	ldi rTemp,(1<<REFS0)|(0<<REFS1)|(1<<ADLAR) ; ADLAR ändrar till 8-bitarsläge för input. (mndre precision)
	sts ADMUX, rTemp

	ldi rTemp, 0x00
	ldi rTemp,(1<<ADPS0)|(1<<ADPS1)|(1<<ADPS2)|(1<<ADEN)
	sts ADCSRA, rTemp
	// Konfiguration av A/D-omvandlaren slut. 

main:
	; Vad ska den göra här egentligen?

	ldi XH, HIGH(matrix)
	ldi XL, LOW(matrix)

	// Välj källa (Y-axel)
	ldi rTemp, 0x00
	ldi rTemp,(0<<MUX3)|(1<<MUX2)|(0<<MUX1)|(0<<MUX0) ; (0b0100)
	sts ADMUX, rTemp
	// Välj källa slut

	ldi rTemp, 0x00		; Reset rTemp
	ldi rTemp,(1<<ADSC) ; Starta konvertering ---> ADSC = 1
	sts ADCSRA, rTemp	; Ladda in
	
iterate:
	ldi rTemp, 0x00
	lds rTemp, ADCSRA	; Ta nuvarande ADCSRA för att jämföra
	sbrc rTemp, 6		; Kolla om bit 6 är 0 i rTemp (ADCSRA) (Skip next instruction if bit in register is cleared)
	jmp iterate			; Iterera
	nop

	; om biten är skippad kommer vi hit... 

	; Läsa bit från den utökade I/O-rymden...
	ldi rTemp, 0x00		; Nollställ rTemp
	lds rTemp, ADCL		; Kopiera resultatet från ADCL. Vad ska vi göra med detta?
	; Endast ADCL behöver läsas då dessa är de lägre 8 bitarna. 

	// Testa att skicka ut datat. 
	st X+, rTemp ; X+ ?

	rcall render

	rjmp main

render:

	ldi XH, HIGH(matrix)
	ldi XL, LOW(matrix)

	; Få översta raden att lysa genom bitmanipulering, bst / bld
	sbi ROW0_PORT, ROW0_PINOUT	; Aktivera rad 0
	ld rTemp, X+
	st Y, rTemp					; Sätt vilka lampor ska lysa ()
	rcall Laddarad				; Ladda raden genom subrutin
	cbi ROW0_PORT, ROW0_PINOUT	; Avaktivera raden

	sbi ROW1_PORT, ROW1_PINOUT
	ld rTemp, X+	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW1_PORT, ROW1_PINOUT

	sbi ROW2_PORT, ROW2_PINOUT
	ld rTemp, X+	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW2_PORT, ROW2_PINOUT

	sbi ROW3_PORT, ROW3_PINOUT
	ld rTemp, X+	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW3_PORT, ROW3_PINOUT

	sbi ROW4_PORT, ROW4_PINOUT
	ld rTemp, X+	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW4_PORT, ROW4_PINOUT

	sbi ROW5_PORT, ROW5_PINOUT
	ld rTemp, X+	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW5_PORT, ROW5_PINOUT
	
	sbi ROW6_PORT, ROW6_PINOUT
	ld rTemp, X+	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW6_PORT, ROW6_PINOUT

	sbi ROW7_PORT, ROW7_PINOUT
	ld rTemp, X	
	st Y, rTemp					
	rcall Laddarad				
	cbi ROW7_PORT, ROW7_PINOUT 

	ret

; Subrutin för att tända specade lampor
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

	; Outputta den manipulerade bitsträngen?
	out PORTD, rPORTD
	out PORTB, rPORTB

	ret

isr_timerOF: ; Hantera timer-interupt

	; Sätt rTemp till något nytt. 
	/*ldi rTemp, 0b11001011

	sbi ROW1_PORT, ROW1_PINOUT	; Aktivera rad 1
	st Y, rTemp
	rcall Laddarad
	cbi ROW1_PORT, ROW1_PINOUT */

	reti ; (Return from interrupt)