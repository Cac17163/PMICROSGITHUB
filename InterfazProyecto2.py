from Tkinter import *
import serial
import time
import sys

global guardando1
global guardando2
global guardando3
global caracter
global Volt
global voltaje

caracter =0
Volt = []

guardando1 = False
guardando2 = False
guardando3 = False

def almacenar(voltaje, filename):
	archivo = open(filename,"a")
	archivo.write(str(voltaje) + '\n')
	archivo.close()


ser= serial.Serial(port='COM3',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
def Leer():
	global voltaje
	voltaje = 0
	while 1:
	    recibido1= ser.read()
	    if recibido1 == "":
	        pass
	    else:
	        Final.update()
	        ser.flushInput()
	        time.sleep(.2)
	        ser.flushOutput()
	        numero = ord(recibido1)
	        voltaje = float ((numero*2.0)/100)
	        IniciarGuardar1()
	        


def Escribir():
	Final.update()
	for caracter in Volt:
		print(caracter)
		ser.write(caracter)

 
#--------------------------------------------------------- Rutinas de Envio --------------------------------------------------------------------

def Envio1():
	global Volt
	VoltTemp = []
	with open ("Bodega1.txt","r") as Lee:
		VoltTemp = Lee.read().splitlines()
	for l in VoltTemp :
		var = chr(int(float(l)*(255.0/180.0)))
		Volt.append(var)
	Escribir()

		
	"""global caracter
	EC = int(float(Volt)*(255.0/180.0))
	caracter = chr(EC)"""

def Envio2():
	global Volt
	VoltTemp = []
	with open ("Bodega1.txt","r") as Lee:
		VoltTemp = Lee.read().splitlines()
	for l in VoltTemp :
		var = chr(int(float(l)*(255.0/180.0)))
		Volt.append(var)
	Escribir()
	
	
"""def Envio3():
	global Volt
	VoltTemp = []
	with open ("Bodega1.txt","r") as Lee:
		VoltTemp = Lee.read().splitlines()
	for l in VoltTemp :
		var = chr(int(float(l)*(255.0/180.0)))
		Volt.append(var)
	Escribir()"""


# -------------------------------------------------------- Rutinas de Inicio de guardar ---------------------------------------------------------
def IniciarGuardar1():
	global voltaje
	global guardando1
	guardando1 = True
	Guardar1()

def IniciarGuardar2():
	global guardando2
	guardando2 = True
	Guardar2()

def IniciarGuardar3():
	global guardando3
	guardando3 = True
	Guardar3()


#----------------------------------------------------------- Rutinas que Guardan -----------------------------------------------------------------
def Guardar1():
	global voltaje
	global guardando
	if(guardando1):
		almacenar(voltaje, "Bodega1.txt")
	else:
		return
	Final.after(500, Guardar1)

def Guardar2():
	global guardando
	if(guardando2):
		almacenar(voltaje, "Bodega2.txt")
	else:
		return
	Final.after(500, Guardar2)

def Guardar3():
	global voltaje
	global guardando3
	if(guardando3):
		almacenar(voltaje, "bodega3.txt")
	else:
		return
	Final.after(500, Guardar3)


#------------------------------------------------------------------ Pausas ----------------------------------------------------------------------
def Pausa1():
	global guardando1
	print("PAUSAMOS")
	guardando1 = False

def Pausa2():
	global guardando2
	print("PAUSAMOS")
	guardando2 = False

def Pausa3():
	global guardando3
	print("PAUSAMOS")
	guardando3 = False

Final = Tk()

voltaje_Str = StringVar()
voltaje_Str.set('')

fondo = PhotoImage(file="redV.gif")
playI = PhotoImage(file="y2F.gif")
pausa = PhotoImage(file="paus.gif")
lblfondo = Label(Final, image= fondo).place(x=0,y=0)

Play1 = Button(Final, image=playI, command=Leer, height=50,width=60).place(x=300, y=70)
Play2= Button(Final, image=playI, command=Leer, height=50,width=60).place(x=300, y=160)
Play3= Button(Final, image=playI, command=Leer, height=50,width=60).place(x=300, y=250)

Pause1 = Button(Final, image=pausa, command=Pausa1, height=50,width=60).place(x=400, y=70)
Pause2 = Button(Final, image=pausa, command=Pausa2, height=50,width=60).place(x=400, y=160)
Pause3 = Button(Final, image=pausa, command=Pausa3, height=50,width=60).place(x=400, y=250)

Enviamos1 = Button(Final,  text="Enviar", command= Envio1, font =("Agency FB","14"), height=1, width=10, bg="red" ).place(x=190, y=80)
#Enviamos2 = Button(Final,  text="Enviar", command= Envio2, font =("Agency FB","14"), height=1, width=10, bg="red").place(x=190, y=170)
#Enviamos3 = Button(Final,  text="Enviar", command= Envio3, font =("Agency FB","14"), height=1, width=10, bg="red").place(x=190, y=260)


voltaje_Str = StringVar()
voltaje_Str.set('')
Final.title("Proyecto Final")
Final.iconbitmap("lambo.ico")
Final.geometry("596x380+0+0")
Final.configure(bg="black") 
#textbix para ingresar un valor 
LBANGULO =Label (text="Roberto Caceres #17163", bg="yellow").place(x=5, y=20)
LBANGULO2 =Label (text="Jose Javier Estrada #17078", bg="yellow").place(x=5, y=40)
Final.mainloop()


	 
        
        
    




