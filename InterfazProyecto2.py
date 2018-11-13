from Tkinter import *
import serial
import time
import sys

def almacenar(voltaje):
	archivo = open("Bodega.txt","a")
	archivo.write(str(voltaje) + '\n')
	archivo.close()
    
def ingreso ():
	archivo = open("Bodega.txt")
	print archivo.read()


Final = Tk()

voltaje_Str = StringVar()
voltaje_Str.set('')

fondo = PhotoImage(file="redV.gif")
playI = PhotoImage(file="y2F.gif")
pausa = PhotoImage(file="paus.gif")
lblfondo = Label(Final, image= fondo).place(x=0,y=0)

Play1 = Button(Final, image=playI, height=50,width=60).place(x=300, y=70)
Play2= Button(Final, image=playI,  height=50,width=60).place(x=300, y=160)
Play3= Button(Final, image=playI, height=50,width=60).place(x=300, y=250)

Pause1 = Button(Final, image=pausa,  height=50,width=60).place(x=400, y=70)
Pause2 = Button(Final, image=pausa, height=50,width=60).place(x=400, y=160)
Pause3 = Button(Final, image=pausa, height=50,width=60).place(x=400, y=250)

voltaje_Str = StringVar()
voltaje_Str.set('')
Final.title("Proyecto Final")
Final.iconbitmap("lambo.ico")
Final.geometry("596x380+0+0")
Final.configure(bg="black") 
#textbix para ingresar un valor 
LBANGULO =Label (text="Roberto Caceres #17163", bg="yellow").place(x=5, y=20)
LBANGULO2 =Label (text="Jose Javier Estrada #17078", bg="yellow").place(x=5, y=40)

ser= serial.Serial(port='COM3',baudrate=9600, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE,bytesize=serial.EIGHTBITS, timeout=0)
while 1:
    recibido1= ser.read()
    #ser.write(caracter)
    if recibido1 == "":
        pass
    else:
        Final.update()
        ser.flushInput()
        time.sleep(.2)
        ser.flushOutput()
        numero = ord(recibido1)
        voltaje = float ((numero*2.0)/100)
        voltaje_Str.set(str(voltaje))
        almacenar(voltaje)
        ingreso()
        
    




