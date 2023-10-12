close all;
clear all
clc
 %  fclose(s1) 
 % conceder permisos
 % sudo chmod ugo+r+w+x ttyUSB0
pkg load instrument-control
global s1 ;
list = seriallist() ; % lista de puertos serial disponibles

default = ' ' ;
for(k = 1 : 1: length(list) )
	default = horzcat(default,list{k},', ');
endfor
default(end-1) = ' ' ;
default = {default,"/dev/ttyUSB0"} ;
canales = {"Canales disponibles:","Canal:"} ;
rowscols = [1 20;1 20] ;
canal = inputdlg (canales, "selecionar canal", rowscols,default );
s1 = serial(canal{2},19200) ;
set(s1, "baudrate", 19200); # Change baudrate
set(s1, "bytesize", 8)    ; # Change byte size (config becomes 8-N-1)
set(s1, "parity", "N")    ; # Changes parity checking (config becomes 8-n-1),
                            # possible values [E]ven, [O]dd, [N]one.
set(s1, "stopbits", 1)    ; # Changes stop bits (config becomes 8-n-1), possible
                            # values 1, 2.
set(s1, "dataterminalready", "on")  ;# Enables DTR line
set(s1, "requesttosend", "on")      ;# Enables RTS line
                                    # possible values "on", "off".
# Flush input and output buffers
srl_flush(s1); 


% funcion para control de flujo de datos
function flagState = readyStop(serialPort)
	global s1 ;
	serialPort = s1 ;
	word1 = "ready." ;
	indexWord = 1 ;
	flagState = true ;
	srl_flush(serialPort);
	do
		c = srl_read(serialPort,1) ;
		if( c == word1(indexWord))
			flagState = true ;
##			printf( "%s true \n",char(c) ) ;
		else
			flagState = false ;
			printf( " falla al recibir; %s  \n",char(c) ) ;
			break
		endif
		indexWord = indexWord + 1 ;
		if(indexWord > 7)
			flagState = false ;
			break
		endif
	until( c == '.')
endfunction

% funci�n para enviar caracter a puerto serial y verificar recepci�n
function output = send_char(Char)
    global s1 ;
    n1 = 0 ;
##    fprintf("%s\n",Char);
    do
      n1 = n1 + 1 ;
      intentos  = 2 ;
      do
        srl_flush(s1);
        srl_write(s1,Char(n1)) ;
        data = srl_read(s1,1) ; % leer un byte (puerto,tama�o)
        if(data == Char(n1))
          output = 1 ;
		%printf("recibido : %s \n",char(Char(n1))) ;
        else
          output = 0 ;
          printf("    Comunicacion fallida en %s \n",Char)
          intentos = intentos - 1 ;
        endif
      until(intentos == 0 || output == 1 )
    until(n1 == length(Char) )
    srl_flush(s1);
endfunction




