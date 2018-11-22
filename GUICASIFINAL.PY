from Tkinter import *
import serial
import time
import sys

#definimos variables
Activo= True
Grabador=False
Servo1 = ''
Servo2 = ''
Servo3 = ''
Servo4 = ''
EnvioServo1 = 0
EnvioServo2 = 0
EnvioServo3 = 0
EnvioServo4 = 0

i=0
lista=[]

ser= serial.Serial(port='COM3',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
#---------------------------------------------------------------------------------Rutina para enviar cuando presiono el boton enviar---------------------------------------------------------------------------------------
def Envio():
	global ser
	comandos = open("Bodega1.txt").readlines()
	comandos = map(str.strip, comandos)
	comandos = map(lambda x: x.split(","), comandos)
	for comando in comandos:
		ser.write(chr(int(comando[0])))
		time.sleep(0.005)
		ser.write(chr(int(comando[1])))
		time.sleep(0.005)
		ser.write(chr(int(comando[2])))
		time.sleep(0.005)
		ser.write(chr(int(comando[3])))
		time.sleep(0.005)
		ser.write(chr(03))
		ser.flushOutput()



#---------------------------------------------------------------limpia archivos----------------------------------------------------------------------------------------


#--------------------------------------------------------------- Empezar a recibir datos -------------------------------------------------------------------------------
def DesactivoS():
	global Activo
	print("Modo2")
	Activo = False
def ActivoS():
	global Activo
	Activo = True
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------- Darle Play a grabar ---------------------------------------------------------------------------           
def EnciendeG1():
	global Grabador
	Grabador = True
	Grabar1()

def Grabar1():
	global Grabador
	if(Grabador):
		almacenar1()
	else:
		return
	Final.after(5, Grabar1)

def almacenar1():
	global Servo1
	global Servo2
	global Servo3
	global Servo4
	global Grabador
	if Grabador == True :
            archivo = open('Bodega1.txt','a')
            archivo.write(str(Servo1)+',')
            archivo.write(str(Servo2)+',')
            archivo.write(str(Servo3)+',')
            archivo.write(str(Servo4)+'\n')
            archivo.close()
        else:
        	print('Grabando')
        	pass

def P1():
	global Grabando
	print("PAUSAMOS")
	Grabando = False

#-------------------------------------------------------------------------Aca comienza la interfaz grafica--------------------------------------------------------------------------
Final = Tk()
fondo = PhotoImage(file="redV.gif")
playI = PhotoImage(file="y2F.gif")
pausa = PhotoImage(file="paus.gif")
lblfondo = Label(Final, image= fondo).place(x=0,y=0)

Play1 = Button(Final, image=playI, command = EnciendeG1,  height=50,width=60).place(x=300, y=70)
Play2= Button(Final, image=playI,  height=50,width=60).place(x=300, y=160)
Play3= Button(Final, image=playI,  height=50,width=60).place(x=300, y=250)

Pause1 = Button(Final, image=pausa, command = P1, height=50,width=60).place(x=400, y=70)
Pause2 = Button(Final, image=pausa,  height=50,width=60).place(x=400, y=160)
Pause3 = Button(Final, image=pausa,  height=50,width=60).place(x=400, y=250)

Enviamos1 = Button(Final,  text="Enviar", command=Envio, font =("Agency FB","14"), height=1, width=10, bg="red" ).place(x=190, y=80)
Enviamos2 = Button(Final,  text="Enviar",  font =("Agency FB","14"), height=1, width=10, bg="red").place(x=190, y=170)
Enviamos3 = Button(Final,  text="Enviar",  font =("Agency FB","14"), height=1, width=10, bg="red").place(x=190, y=260)

ModoEnviar  = Button(Final, text="", command= DesactivoS, height=2, width=5, bg="purple").place(x=100, y=300)
ModoRecibir  = Button(Final, text="", command= ActivoS, height=2, width=5, bg="blue").place(x=50, y=300)
voltaje_Str = StringVar()

Final.title("Proyecto Final")
Final.iconbitmap("lambo.ico")
Final.geometry("596x380+0+0")
Final.configure(bg="black") 
#textbix para ingresar un valor 
LBANGULO =Label (text="Roberto Caceres #17163", bg="yellow").place(x=5, y=20)
LBANGULO2 =Label (text="Jose Javier Estrada #17078", bg="yellow").place(x=5, y=40)
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------- Estados con los que manejaremos envio y recepcion------------------------------------------------------


while 1:
	while Activo == True:
		entrada = (str(ser.read()))
		print("entrada", entrada)
		if entrada == b'':
			continue
		if ord(entrada) == 3:
			Final.update()
			Servo1=ord(ser.read())
			Servo2=ord(ser.read())
			Servo3=ord(ser.read())
			Servo4=ord(ser.read())
			ser.flushInput()
			# try:
			# except:
			# 	print("modo1")

	while Activo == False:
		Final.update()
		pass
		# Final.update()
		# ser.write(chr(int(EnvioServo1)))
		# time.sleep(0.005)
		# ser.write(chr(int(EnvioServo2)))
		# time.sleep(0.005)
		# ser.write(chr(int(EnvioServo3)))
		# time.sleep(0.005)
		# ser.write(chr(int(EnvioServo4)))
		# time.sleep(0.005)
		# ser.write(chr(03))
		# ser.flushOutput()


#---------------------------------------------------------------------------------final del programa-------------------------------------------------------------------