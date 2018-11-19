;*******************************************************************************                                                                    *
;    Filename:   A
;    Autor: 17078 					
;    Description: Proyecto final prueba A                                     *
;*******************************************************************************#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
	
;***************************
; Reset Vector
;***************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
GPR_VAR	    UDATA
CHAN_5	    RES	    1
CHAN_6	    RES	    1
CHAN_2	    RES	    1
CHAN_3	    RES	    1
PROBAR	    RES	    1
W_TEMP	    RES	    1
STATUS_TEMP RES	    1
ESTADO	    RES	    1
CCPR3L	    RES	    1
CCPR4L	    RES	    1
ESTADO2	    RES	    1
CAMBIO_MANDAR	RES 1
CAMBIO_RECIBIR	RES 1
CONTADOR_INTERRUPCION	RES 1
CONTADOR_WASALIR	RES 1
MINIMO	    RES	    1
MAXIMO	    RES	    1
MOTOR1	    RES	    1
MOTOR2	    RES	    1
MOTOR3	    RES	    1
MOTOR4	    RES	    1
PERIODO1    RES	    1
PERIODO4    RES	    1
PERIODO3    RES	    1
    
;***************************
; MAIN PROGRAM
;***************************

MAIN_PROG CODE                    

START    
SETUP
    BANKSEL PORTA	 ;CONFIG TOMADA DEL CODIGO SUBIDO POR TOTO
    MOVLW   D'255'
    MOVWF   PR2
    CLRF    CCPR1L
    MOVLW   B'00111100'
    MOVWF   CCP1CON
    CLRF    CCPR2L
    MOVLW   B'00001111'
    MOVWF   CCP2CON
    CLRF    PORTE
    CLRF    PORTC
    MOVLW   B'01010101'
    MOVWF   ADCON0
    ;MOVLW   B'11000000'
    ;MOVWF   INTCON
    
    BANKSEL TRISA
    CLRF    TRISE
    BSF	    TRISE,0
    BSF	    TRISE,1
    CLRF    TRISC
    CLRF    ADCON1
    MOVLW   B'01001100'
    MOVWF   OSCCON	    ;1000 kHz
    BCF	    PIE1,1
    BCF	    PIE1,2
    ;
    
    BANKSEL PORTC
    MOVLW   B'00000110'
    MOVWF   T2CON
    
    BANKSEL ANSEL
    CLRF    ANSEL
    BSF	    ANSEL,5
    BSF	    ANSEL,6
    BSF	    ANSEL,2
    BSF	    ANSEL,3
    
    BANKSEL PORTA
    CLRF    CONTADOR_INTERRUPCION
    CLRF    CONTADOR_WASALIR
    CLRF    CAMBIO_RECIBIR
    CLRF    CAMBIO_MANDAR
    CLRF    ESTADO2
    CLRF    ESTADO
    CLRF    PORTE
    CLRF    PORTC
    CALL    DELAY
    CALL    UART
    MOVLW   .5
    MOVWF    MINIMO
    MOVLW   .150
    MOVWF   MAXIMO
    MOVLW   .85
    MOVWF   MOTOR1
    MOVWF   MOTOR2
    MOVWF   MOTOR3
    MOVWF   MOTOR4

LOOP
    BTFSS   ESTADO2,0
    GOTO    LOOP_ADC
    GOTO    LOOP_SERIAL
    

LOOP_ADC		
    BSF	    ADCON0,GO
    BCF	    PORTC,5
LOOP2
    BTFSS   PIR1,4
    GOTO    LOOP3
    MOVF    CAMBIO_MANDAR,0
    ADDWF   PCL,1
    GOTO    MANDAR_1
    GOTO    MANDAR_2
    GOTO    MANDAR_3
    GOTO    MANDAR_4
    GOTO    MANDAR_ENTER
LOOP3
    BTFSS   PIR1,5
    GOTO    LOOP4
    MOVF    RCREG,0
    SUBLW   .200
    BTFSC   STATUS,Z
    BSF	    ESTADO2,0
LOOP4
    BTFSS   PIR1,1
    GOTO    LOOP5
    BCF	    PIR1,1
    CALL    HIGH_SERVO3
    CALL    HIGH_SERVO4
LOOP5
    CALL    MOTOR_1
    CALL    MOTOR_2
    CALL    MOTOR_3
    CALL    MOTOR_4
    CALL    SERVO_1
    CALL    SERVO_2
    CALL    SERVO_3
    CALL    SERVO_4
    BTFSC   ADCON0,GO
    GOTO    LOOP2
    MOVF    ESTADO,0
    ADDWF   PCL,1
    GOTO    CANAL2
    GOTO    CANAL5
    GOTO    CANAL3
    GOTO    CANAL6
    GOTO    LOOP    
    
LOOP_SERIAL
    RETURN	;AUN NO ENVIO NI RECIBO BIEN DATOS 
    
DELAY:
    MOVLW   .100
    MOVWF   PROBAR
    DECFSZ  PROBAR,1
    GOTO    $-1
    RETURN

DELAYSITO:
    MOVLW   .45                                    
    MOVWF   PROBAR
    DECFSZ  PROBAR,1
    GOTO    $-1
    RETURN
   
    
UART    
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC		    ; ASINCRÓNO
    BSF	    TXSTA, BRGH		    ; HIGH SPEED
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16		    ; 16 BITS BAURD RATE GENERATOR
    BANKSEL SPBRG
    MOVLW   .25	    
    MOVWF   SPBRG			    ; CARGAMOS EL VALOR DE BAUDRATE CALCULADO
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN		    ; HABILITAR SERIAL PORT
    BCF	    RCSTA, RX9		    ; SOLO MANEJAREMOS 8BITS DE DATOS
    BSF	    RCSTA, CREN		    ; HABILITAMOS LA RECEPCIÓN 
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN		    ; HABILITO LA TRANSMISION
    
    
    BCF STATUS, RP0
    BCF STATUS, RP1		    ; BANCO 0
    RETURN
    END
