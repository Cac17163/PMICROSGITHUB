;**********************************************************************************************************************************************************
;                                                                              
;    PROYECTO FINAL PROGRAMACION DE MICROCONTROLADORES
;    PROFESOR: José Eduardo Morales
;    ALUMNOS: -Jose Roberto Caceres Garcia	    #17163
;	      -Jose Javier Estrada Quezada	    #17078
;    Description: Mover un brazo robotico de 4 servos mediante comunicacion serial
;
;**********************************************************************************************************************************************************
#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
	
;**********************************************************************************************************************************************************  
; Reset Vector
;**********************************************************************************************************************************************************  

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
;**********************************************************************************************************************************************************  
; Variables
;**********************************************************************************************************************************************************    
GPR_VAR	    UDATA
C1	    RES	    1	    ; Variables para cada uno de los canales
C2	    RES	    1
C3	    RES	    1
C4	    RES	    1
	    
VAR	    RES	    1	    ; Variable que utilizamos para manipular el dato recibido que enviaremos al motor

QMOT	    RES	    1       ; Variable que define que motor se mueve 
DM3	    RES	    1	    ; Variables que imitan el CCPRxL del PIC para poder usar 4 PWM
DM4	    RES	    1
	    
ESTADO	    RES	    1	    ; Variable que define en que modo esta el PIC 
	    
DREC	    RES     1
	    
QMAN	    RES     1	    ; Variables que dictan que datos se envian o reciben
QREC        RES     1
	
MIN	    RES	    1       ; Varianles para valor maximo, minimo e inicial de los servos
MAX	    RES	    1
SM1	    RES	    1
SM2	    RES	    1
SM3	    RES	    1
SM4	    RES	    1
	    
DP1         RES	    1	    ; Variables para generar un "delay" en cada motor par mejorar como se conducen los servos
DP2	    RES     1
DP3         RES	    1
DP4         RES	    1
;**********************************************************************************************************************************************************  
; PROGRAMA
;********************************************************************************************************************************************************** 

MAIN_PROG CODE                      ; let linker place main program
 
;**********************************************************************************************************************************************************  
; CONFIGURACION
;********************************************************************************************************************************************************** 
START    
SETUP
    BANKSEL PORTA
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
    CLRF    DREC
    CLRF    QREC   
    CLRF    QMAN
    CLRF    ESTADO
    CLRF    QMOT
    CLRF    PORTE
    CLRF    PORTC
    CALL    DELAY   
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
    MOVLW   .10
    MOVWF    MIN
    MOVLW   .145
    MOVWF   MAX
    MOVLW   .15
    MOVWF   SM1
    MOVWF   SM2
    MOVWF   SM3
    MOVWF   SM4
    
;**********************************************************************************************************************************************************  
; MAIN LOOP 
;********************************************************************************************************************************************************** 

LOOP
    BTFSS   ESTADO,0
    GOTO    ENADC
    GOTO    SERIAL
    
;**********************************************************************************************************************************************************  
; SUB LOOPS POR ESTADOS
;********************************************************************************************************************************************************** 
ENADC
    BSF	    ADCON0,GO
    BCF	    PORTC,5
SUBL2
    BTFSS   PIR1,4
    GOTO    SUBL3
    MOVF    QMAN,0
    ADDWF   PCL,1
    GOTO    ENV1
    GOTO    ENV2
    GOTO    ENV3
    GOTO    ENV4
    GOTO    EBANDERA
SUBL3
    BTFSS   PIR1,5
    GOTO    SUBL4
    MOVF    RCREG,0
    SUBLW   .200
    BTFSC   STATUS,Z
    BSF	    ESTADO,0
SUBL4
    BTFSS   PIR1,1
    GOTO    SUBL5
    BCF	    PIR1,1
    CALL    ONPWM1
    CALL    ONPWM2
SUBL5
    CALL    MOTA
    CALL    MOTB
    CALL    MOTC
    CALL    MOTD
    CALL    SERVO_1
    CALL    SERVO_2
    CALL    SERVO_3
    CALL    SERVO_4
    BTFSC   ADCON0,GO
    GOTO    SUBL2
    MOVF    QMOT,0
    ADDWF   PCL,1
    GOTO    OPCION1
    GOTO    OPCION2
    GOTO    OPCION3
    GOTO    OPCION4
    GOTO    LOOP    
    
SERIAL
    CALL    SERVO_1
    CALL    SERVO_2
    CALL    SERVO_3
    CALL    SERVO_4
    BTFSS   PIR1,1
    GOTO    LOOP2
    BCF	    PIR1,1
    CALL    ONPWM1
    CALL    ONPWM2
LOOP2
    BTFSS   PIR1,5
    GOTO    LOOP
    MOVF    RCREG,0
    MOVWF   DREC
    SUBLW   .220
    BTFSS   STATUS,Z
    GOTO    CUALTOC
    BSF	    PORTC,5
    BCF	    ESTADO,0
    GOTO    LOOP
;**********************************************************************************************************************************************************  
; Seleciona el motor
; Segun la posicion valor que recibimos entre los datos obtenidos se selecciona una funcion por motor o terminar de recibir. 
;**********************************************************************************************************************************************************
CUALTOC
    MOVF    QREC,0
    ADDWF   PCL,1
    GOTO    REC1
    GOTO    REC2
    GOTO    REC3
    GOTO    REC4
    GOTO    RBANDERA
    GOTO    LOOP
    BSF	    PORTC,5
;**********************************************************************************************************************************************************  
; Lectura
; Se lee en el pin configurado, se aumenta el contador que determina el motor y el valor leido se le asigna a los motores. 
;**********************************************************************************************************************************************************   
OPCION1
    INCF    QMOT,1
    MOVF    ADRESH,0
    MOVWF   C3
    CALL    CAMBIO1
    GOTO    LOOP 
OPCION2
    MOVF    ADRESH,0
    MOVWF   C1
    CALL    CAMBIO4
    INCF    QMOT,1
    GOTO    LOOP
OPCION3
    INCF    QMOT,1
    MOVF    ADRESH,0
    MOVWF   C4
    CALL    CAMBIO2
    GOTO    LOOP
OPCION4
    CLRF    QMOT
    MOVF    ADRESH,0
    MOVWF   C2
    CALL    CAMBIO3
    GOTO LOOP     
;**********************************************************************************************************************************************************  
; Cambio de pin ADC
; Se configura en que pin ADC se lee el valor para poder leer cada valor de potenciometro en joysticks. 
;**********************************************************************************************************************************************************
CAMBIO1
    BCF	    ADCON0,5
    BSF	    ADCON0,4
    BCF	    ADCON0,3
    BSF	    ADCON0,2
    CALL    DELAY
    RETURN
CAMBIO2
    BCF	    ADCON0,5
    BSF	    ADCON0,4
    BSF	    ADCON0,3
    BCF	    ADCON0,2
    CALL    DELAY
    RETURN
CAMBIO3
    BCF	    ADCON0,5
    BCF	    ADCON0,4
    BSF	    ADCON0,3
    BCF	    ADCON0,2
    CALL    DELAY
    RETURN
CAMBIO4
    BCF	    ADCON0,5
    BCF	    ADCON0,4
    BSF	    ADCON0,3
    BSF	    ADCON0,2
    CALL    DELAY
    RETURN
;**********************************************************************************************************************************************************  
; Limites de motores 1
; Se revisan los valores de motores para limitarlos al rengo entre 10-145 que asignamos a su movimiento. Ya que 220 es para cambiar de modo y restringir el 
; movimiento del brazo sin que se trabe. Aqui vemos si esta en caso de riezgo para alguno de los limites. 
;**********************************************************************************************************************************************************   
MOTA
    MOVF    C1,0
    SUBLW   .220
    BTFSS   STATUS,C
    GOTO    LIM1A
    MOVF    C1,0
    SUBLW   .50
    BTFSC   STATUS,C
    GOTO    LIM1B
    RETURN
MOTB
    MOVF    C2,0
    SUBLW   .220
    BTFSS   STATUS,C
    GOTO    LIM2A
    MOVF    C2,0
    SUBLW   .50
    BTFSC   STATUS,C
    GOTO    LIM2B
    RETURN
MOTC
    MOVF    C3,0
    SUBLW   .220
    BTFSS   STATUS,C
    GOTO    LIM3A
    MOVF    C3,0
    SUBLW   .50
    BTFSC   STATUS,C
    GOTO    LIM3B
    RETURN
MOTD
    MOVF    C4,0
    SUBLW   .220
    BTFSS   STATUS,C
    GOTO    LIM4A
    MOVF    C4,0
    SUBLW   .50
    BTFSC   STATUS,C
    GOTO    LIM4B
    RETURN
;**********************************************************************************************************************************************************  
; Limites de motores 2
; Se revisan los valores de motores para limitarlos al rengo entre 10-145 que asignamos a su movimiento. Ya que 220 es para cambiar de modo y restringir el 
; movimiento del brazo sin que se trabe. Aqui se determina si es menor o mayor que los limites. 
;**********************************************************************************************************************************************************
LIM1A
    INCF    DP1,1
    MOVF    DP1,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP1
    MOVF    MIN,0
    SUBWF   SM1,0
    BTFSC   STATUS,C	    ;MENOR QUE EL MINIMO
    DECF    SM1,1
    RETURN
LIM1B
    INCF    DP1,1
    MOVF    DP1,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP1
    MOVF    MAX,0
    SUBWF   SM1,0
    BTFSS   STATUS,C	    ;MAYOR QUE EL MAXIMO
    INCF    SM1,1
    RETURN
LIM2A
    INCF    DP2,1
    MOVF    DP2,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP2
    MOVF    MIN,0
    SUBWF   SM2,0
    BTFSC   STATUS,C	    ;MENOR QUE EL MINIMO
    DECF    SM2,1
    RETURN
LIM2B
    INCF    DP2,1
    MOVF    DP2,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP2
    MOVF    MAX,0
    SUBWF   SM2,0
    BTFSS   STATUS,C	    ;MAYOR QUE EL MAXIMO
    INCF    SM2,1
    RETURN
LIM3A
    INCF    DP3,1
    MOVF    DP3,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP3
    MOVF    MIN,0
    SUBWF   SM3,0
    BTFSC   STATUS,C	    ;MENOR QUE EL MINIMO
    DECF    SM3,1
    RETURN
LIM3B
    INCF    DP3,1
    MOVF    DP3,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP3
    MOVF    MAX,0
    SUBWF   SM3,0
    BTFSS   STATUS,C	    ;MAYOR QUE EL MAXIMO
    INCF    SM3,1
    RETURN
LIM4A
    INCF    DP4,1
    MOVF    DP4,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP4
    MOVF    MIN,0
    SUBWF   SM4,0
    BTFSC   STATUS,C	    ;MENOR QUE EL MINIMO
    DECF    SM4,1
    RETURN
LIM4B
    INCF    DP4,1
    MOVF    DP4,0
    SUBLW   .5
    BTFSS   STATUS,Z
    RETURN
    CLRF    DP4
    MOVF    MAX,0
    SUBWF   SM4,0
    BTFSS   STATUS,C	    ;MAYOR QUE EL MAXIMO
    INCF    SM4,1
    RETURN
;**********************************************************************************************************************************************************  
; ASIGNAR LOS VALORES RECIBIDOS A CADA SERVO
; Se le asigna a cada motor el valor correspodiente
;**********************************************************************************************************************************************************    
SERVO_1
    RRF	    SM1,0
    MOVWF   VAR
    RRF	    VAR,0
    ANDLW   B'00111111'
    MOVWF   CCPR1L
    RETURN  
SERVO_2
    RRF	    SM2,0
    MOVWF   VAR
    RRF	    VAR,0
    ANDLW   B'00111111'
    MOVWF   CCPR2L
    RETURN
SERVO_3
    MOVF    SM3,0
    MOVWF   VAR
    ANDLW   B'11111111'
    MOVWF   DM3  
    RETURN
SERVO_4
    MOVF    SM4,0
    MOVWF   VAR
    ANDLW   B'11111111'
    MOVWF   DM4
    RETURN
;**********************************************************************************************************************************************************  
; FUNCIONES PARA CONFIGURAR EL CICLO DE TRABAJO DE LOS PWM HECHOS
; Se enciente el pin de salida por el tiempo determinado por DMx que es el valor de cada uno
;**********************************************************************************************************************************************************     
ONPWM1
    MOVF    DM3,0
    MOVWF   VAR
    BSF	    PORTC,0
    DECFSZ  VAR, 1
    GOTO    $-1
    CALL    DELAY2
    BCF	    PORTC,0
    RETURN
    
ONPWM2
    MOVF    DM4,0
    MOVWF   VAR
    BSF	    PORTC,3
    DECFSZ  VAR, 1
    GOTO    $-1
    CALL    DELAY2
    BCF	    PORTC,3
    RETURN
;**********************************************************************************************************************************************************  
; DELAYS
;**********************************************************************************************************************************************************    
DELAY
    MOVLW   .100
    MOVWF   VAR
    DECFSZ  VAR,1
    GOTO    $-1
    RETURN

DELAY2
    MOVLW   .45                                    
    MOVWF   VAR
    DECFSZ  VAR,1 
    GOTO    $-1
    RETURN
;**********************************************************************************************************************************************************  
; ENVIAR DATOS UART
; Un arreglo de datos en los que recivimos 4 datos luego se recibe el valor de un enter para saber que ya se termino de recivir 
;**********************************************************************************************************************************************************    
ENV1
    MOVF    SM1,0
    MOVWF   TXREG
    INCF    QMAN,1
    GOTO    SUBL3
ENV2
    MOVF    SM2,0
    MOVWF   TXREG
    INCF    QMAN,1
    GOTO    SUBL3
ENV3
    MOVF    SM3,0
    MOVWF   TXREG
    INCF    QMAN,1
    GOTO    SUBL3
ENV4
    MOVF    SM4,0
    MOVWF   TXREG
    INCF    QMAN,1
    GOTO    SUBL3
EBANDERA
    MOVLW   .03
    MOVWF   TXREG
    CLRF    QMAN
    GOTO    SUBL3 
;**********************************************************************************************************************************************************  
; RECIBIENDO DATOS UART
; Un arreglo de datos en los que recivimos 4 datos luego se recibe el valor de un enter para saber que ya se termino de recivir y se envia un enter 
; para notificar que se termino la comunicacion.
;**********************************************************************************************************************************************************     
REC1
    MOVF    DREC,0
    MOVWF   SM1
    INCF    QREC,1
    GOTO    LOOP
REC2
    MOVF    DREC,0
    MOVWF   SM2
    INCF    QREC,1
    GOTO    LOOP
REC3
    MOVF    DREC,0
    MOVWF   SM3
    INCF    QREC,1
    GOTO    LOOP
REC4
    MOVF    DREC,0
    MOVWF   SM4
    INCF    QREC,1
    GOTO    LOOP
RBANDERA
    CLRF    QREC
    MOVLW   .03
    MOVWF   TXREG		    ;BUENA ONDA MANO MANDAME LOS OTRO CUATRO SERVOS
    GOTO    LOOP
;********************************************************************************************************************************************************** 
    END		; Fin jeje
