clc
clear all
%  fclose(s1)
tic
iniciar_serial
text_in = fopen('registroComprimido2.txt','r') ; % obtiene un vector de caracteres 
%text_in = fscanf(fopen('register_char.txt','r'),'%s' ); % obtiene un vector de caracteres ;
size_text = length(text_in);

flag_salir = 0 ;

%if( yes_or_no("Realizar nivelaci�n? \n ")  )
%  nivelacion
%else
%  elevacion
%  global l = 100 ;
%  global p1 = [1,1,1] ;
%  global p2 = [100,1,1] ;
%  global p3 = [1,100,1] ;
%  global p4 = [100,100,1] ;
%  global p5 = [50,50,1] ;
%endif

k = 0 ;
x = 0 ;
y = 0 ;
flag_while = true ;
fprintf("\n Eviando caracteres... \n") ;
time_espera = 0 ;
datos_enviados = 1 ;

##% para buscar la linea establecida
##mesag = {"linea: "} ;
##default = {"1"} ;
##rowscols = [1,20] ;
##linea = inputdlg (mesag, "Saltar a la linea", rowscols,default);
##linea = str2num(linea{1,1}) ;
##line_aux = 1 ;
##
##do	
##	k = k + 1 ;
##	if( text_in(1,k)== '.' )
##		line_aux = line_aux + 1 ;
##	endif
##until(line_aux >= linea)	
##k = k - 1 ;

% enviar comandos
[line,state] = fgetl(text_in)  ;
numbLine = 1 ;
do
	printf("Ejecutando linea %d : %s \n",numbLine,line)
	numbLine = numbLine + 1 ;
	%% se envia la linea y se evalua la comunicacion
	if(send_char(line) == 0)
		flagLoop = false ;
		break
	endif
	clear line 
	% espera el ready del pic
	if(readyStop == 0)
		flagLoop = false ;
		break
	endif
	[line,state] = fgetl(text_in)  ;
until(state = 0)

if(flagLoop == false)
    fprintf(" Error en la transmicion\n");
    fprintf("Enviado %s: \n",char);
    fprintf("Recibido %s: \n",data);
else
    fprintf(" Transmicion terminada\n");
endif
printf("Tiempo de ejecucion : %d minutos \n",toc/60)
fclose(s1)
toc