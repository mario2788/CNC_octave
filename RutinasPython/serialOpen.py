# This Python file uses the following encoding: utf-8
# informacion impoetante
# https://maker.pro/pic/tutorial/introduction-to-python-serial-ports

# conceder permisos para acceder al puerto
# sudo chmod ugo+r+w+x ttyUSB0
# luego de instalar pip en terminal e instalar la libreria:
# pypy -m ensurepip
# pypy -mpip install <libreria_name>



 # inicializacion del puerto
from os  import system
system("cd /dev")
system("sudo chmod ugo+r+w+x ttyUSB0")
import serial
# Iniciando conexión serial
port = serial.Serial('/dev/ttyUSB0', 9600, timeout=1)
flagCharacter = 'k'
    # lectura de puerto
#serialPort.write(b"")


    # funcion para esperar el pic
def readyStop(port):
    flagReady = True
    while True :
        if port.read(6) == "ready." :
            break
        else :
            flagReady = False
            break
    return flagReady

    # funcion que envia el comando
def sendWord(port,word) :
    flagSend = True
    port.reset_input_buffer()
    for indexWord in range(0,len(word)) :
        port.write( word[indexWord] )
        if port.read(1) != word[indexWord] :
            print ("Fallo en la comunicación.")
            flagSend = False
            break
    return flagSend





#import sys
#sys.path.append("/home/mario/.local/lib/pypy2.7/site-packages/")

#import serial
#import serial.serialutil
#s1 = serial.serialutil.SerialBase()

#ser = serial.Serial()
#ser.baudrate = 19200
#ser.port = '/dev/ttyUSB0'
#ser
#Serial<id=0xa81c10, open=False>(port='COM1', baudrate=19200, bytesize=8, parity='N', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
#ser.open()
#ser.is_open
#True
#ser.close()
#ser.is_open
#False
