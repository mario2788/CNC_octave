# This Python file uses the following encoding: utf-8
    # Abrir puerto serial y cargar funciones de comunicacion
import serialOpen    
from serialOpen import initSerial
from serialOpen import readyStop
from serialOpen import sendWord

s1 = initSerial()

import Tkinter
    # paquetes para abrir explorador
from Tkinter import Tk
from tkinter.filedialog import askopenfilename
Tk().withdraw() # we don't want a full GUI, so keep the root window from appearing
rutaTxt = askopenfilename()
# Lectura de texto
txt = open(rutaTxt,'r')

    # Paquete para timer
import time

    # Lectura en bucle y linea por linea:
for linea in txt.readlines():
    print linea
    send
    for indexLinea in  range( 0,len(linea) ) :
        print linea[indexLinea]
    time.sleep(0.6) # espera en segundos
    # Envio de datos


    # Leer todo el archivo
#txt.read()

    #Cerrar el archivo
#txt.close()



