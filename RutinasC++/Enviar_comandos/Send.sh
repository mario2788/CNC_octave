#!/bin/bash

echo
echo

#Compilar el archivo por posibles modificaciones.
g++ -o SendCode main.cpp
#Ejecutar el script para enviar las ordenes al pic.
./SendCode /home/mario/Documentos/rutinasCNC_octave/registroComprimido2.txt

echo
echo
