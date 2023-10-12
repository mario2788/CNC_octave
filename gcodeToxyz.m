% convierte  archivo de texto .gcode a codificacion XYZ
clc
tic
clear all

% delta de movimiento en x y y
delta_x = 0.09421 ; % mm/paso
delta_y = 0.09421 ; % mm/paso
delta_z = 0.02934 ; % mm/paso
%1988cuellar0307
% lectura del archivo en codigo g .tap
[archivo,ruta] = uigetfile('*.gcode','Abrir un archivo de datos');
data_file = horzcat(ruta,archivo) ; % concatenar  para obtener la ruta
%data_file = "/media/mario/8850B4DC50B4D2641/Users/mario/MPLABXProjects/cnc_16F877A.X/freecad/codigo_g.g" ;
[file,error_mensaje] = fopen(data_file,'r+') ;

% crea archivo
codigo = fopen('register_char.txt','w');

%funcion para convertir mm en pasos
function pasos = mmToPasos(numero,delta)
    pasos = numero / delta;
    pasos = floor(pasos) ;
endfunction
%
##y_alto = input("Altura en milimetros del objeto?  \n");
##y_alto = mmToPasos(y_alto,delta_y);
function Num  = getNum( line , letra  )
  index = 0 ;
  do
    index = index + 1 ;
  until line(index) == letra || index >= length(line)
  if index >= length(line)
    Num = 0 ;
    return
  endif

  index1 = index + 1 ;

  do
    index = index + 1 ;
  until line(index) == " " || index >= length(line)
  index2 = index - 1 ;

  Num = str2num( line([index1:index2]) ) ;

endfunction


% Obtiene los parametros de los comandos G
function [X,Y,Z,I,J,F] = lineToComand(line)
    line_ = [] ;
    X =  0 ;
    Y =  0 ;
    Z =  0 ;
    I =  0 ;
    J =  0 ;
    F =  0 ;

    X = getNum(line,'X') ;
    Y = getNum(line,'Y') ;
    Z = getNum(line,'Z') ;
    I = getNum(line,'I') ;
    J = getNum(line,'J') ;
    F = getNum(line,'F') ;

endfunction


% funcion para hacer y registrar rectas en la matriz rutas
function [archivo_out] = recta(xi,yi,xf,yf,archivo)

	if( sqrt( (xf-xi)^2+(yf-yi)^2 ) != 0)
		lambda = [xf-xi,yf-yi]/( sqrt( (xf-xi)^2+(yf-yi)^2 ) )  ;
		else
			archivo_out = archivo ;
			return
	endif

	t = 0 ;
	x = xi  ;
	y = yi  ;
	do
		punto = lambda*t + [xi,yi]  ;
		x_temp = round( punto(1,1) );
		y_temp = round( punto(1,2) );
		t = t + 0.5  ;
		if( (x_temp > x || x_temp < x) && x != xf )
			x = x_temp ;
			if( lambda(1,1) > 0)
				fprintf(archivo,'X') ;
			else
				fprintf(archivo,'x') ;
			endif
		endif
		if( (y_temp > y || y_temp < y) && y != yf )
			y = y_temp ;
			if( lambda(1,2) > 0)
				fprintf(archivo,'y') ;
			else
				fprintf(archivo,'Y') ;
			endif
		endif
	until( abs(x_temp - round(xf) ) < 0.5 && abs(y_temp - round(yf) ) < 0.5)

	archivo_out = archivo ;
endfunction
% Determina el cuadrante del punto (x,y) con referencia a (cx,cy)
function c = cuadrante(x,y,cx,cy)
	if(x < cx )
		if(y < cy)
			c = 3 ;
		else
			c = 2 ;
		endif
	else
		if(y < cy)
			c = 4 ;
		else
			c = 1 ;
		endif
	endif
endfunction


%funcion para hacer circulos en sentido horario G02
function [archivo_out] = circ_hor(xi,yi,xf,yf,I,J,archivo)
	x = xi ;
	y = yi ;
	% Centro
	h = xi + I ;
	k = yi + J ;
	% Radio
	r = sqrt( I^2 + J^2 ) ;
	angulo_i = atand( (yi-k) / (xi-h+0.001) ) ;
	angulo_f = atand( (yf-k) / (xf-h+0.001) ) ;

	% Los angulos se mediran positivamente desde x positivo
	%correccion angulo inicial
	c = cuadrante(xi,yi,h,k);
	switch c
		case 1
			angulo_i = angulo_i ;
		case 2
			angulo_i = angulo_i + 180 ;
		case 3
			angulo_i = angulo_i + 180 ;
		case 4
			angulo_i = angulo_i + 360 ;
	endswitch
	%correccion angulo final
	c = cuadrante(xf,yf,h,k) ;
	switch c
		case 1
			angulo_f = angulo_f ;
		case 2
			angulo_f = angulo_f + 180 ;
		case 3
			angulo_f = angulo_f + 180 ;
		case 4
			angulo_f = angulo_f + 360 ;
	endswitch

	do
		x_temp = round( r*cosd(angulo_i) + h );
		y_temp = round( r*sind(angulo_i) + k );
		angulo_i = angulo_i - 0.5 ;

		if( xi != x_temp  || yi != y_temp)
			archivo = recta(xi,yi,x_temp,y_temp,archivo) ;
			xi = x_temp ;
			yi = y_temp ;
		endif

	until( abs( cosd(angulo_i) - cosd(angulo_f) ) < 0.05 && abs( sind(angulo_i) - sind(angulo_f) ) < 0.05 )
	archivo = recta(x_temp,y_temp,xf,yf,archivo) ;
	archivo_out = archivo ;
endfunction

%funcion para hacer circulos en sentido antihorario
function [archivo]=circ_antihor(xi,yi,xf,yf,I,J,archivo)
	x = xi ;
	y = yi ;
	% Centro
	h = xi + I ;
	k = yi + J ;
	% Radio
	r = sqrt( I^2 + J^2 ) ;
	angulo_i = atand( (yi-k) / (xi-h+0.001) ) ;
	angulo_f = atand( (yf-k) / (xf-h+0.001) ) ;

	% Los angulos se mediran positivamente desde x positivo
	%correccion angulo inicial
	c = cuadrante(xi,yi,h,k);
	switch c
		case 1
			angulo_i = angulo_i ;
		case 2
			angulo_i = angulo_i + 180 ;
		case 3
			angulo_i = angulo_i + 180 ;
		case 4
			angulo_i = angulo_i + 360 ;
	endswitch
	%correccion angulo final
	c = cuadrante(xf,yf,h,k);
	switch c
		case 1
			angulo_f = angulo_f ;
		case 2
			angulo_f = angulo_f + 180 ;
		case 3
			angulo_f = angulo_f + 180 ;
		case 4
			angulo_f = angulo_f + 360 ;
	end

	do
		x_temp = round( r*cosd(angulo_i) + h );
		y_temp = round( r*sind(angulo_i) + k );
		angulo_i = angulo_i + 0.5 ;

		if( xi != x_temp  || yi != y_temp)
			archivo = recta(xi,yi,x_temp,y_temp,archivo) ;
			xi = x_temp ;
			yi = y_temp ;
		endif

	until(  abs( cosd(angulo_i) - cosd(angulo_f) ) < 0.05 && abs( sind(angulo_i) - sind(angulo_f) ) < 0.05 )
	archivo = recta(x_temp,y_temp,xf,yf,archivo) ;
	archivo_out = archivo ;
endfunction
% Funcion para hacer rectas  sobre Z
function [archivo_out] = recta_z(zi,zf,archivo)
	dir = sign(zf - zi) ;
  if(dir == -1)
			letra = 'z' ;
		else
			letra = 'Z' ;
		endif
	for(k = 1 :1: abs(zf-zi))
		  fprintf(archivo,"%s", letra);
	endfor
	archivo_out = archivo ;
endfunction

%  lectura y conversion
x_abs = 0 ; % pasos de maquina
y_abs = 0 ; % pasos de maquina
z_abs = 0 ; % pasos de maquina
contador_lineas = 0 ;
intentos = 2 ;
tic
do
	contador_lineas = contador_lineas + 1 ;
	[line,b] =  fgetl(file) ;

    fprintf("%d %s\n",contador_lineas,line) ;

	if(b > 4)
        intentos = 10 ;
		switch   line(1,[1:5])
			case 'G00 Z'
				[X,Y,Z,I,J,F] = lineToComand(line) ;
				Z = mmToPasos(Z,delta_z) ;
				codigo = recta_z(z_abs,Z,codigo) ;
				z_abs = Z ;
            case 'G01 Z'
				[X,Y,Z,I,J,F] = lineToComand(line) ;
				Z = mmToPasos(Z,delta_z) ;
				%X = mmToPasos(X,delta_x) ;
				%Y = mmToPasos(Y,delta_y) ;
				%codigo = recta(x_abs,y_abs,X,Y,codigo) ;
                 %fprintf(codigo,"\r\n")
				codigo = recta_z(z_abs,Z,codigo) ;
				%x_abs = X ;
				%y_abs = Y ;
				z_abs = Z ;
			case 'G00 X'
				[X,Y,Z,I,J,F] = lineToComand(line) ;
				%Z = mmToPasos(Z,delta_z) ;
				X = mmToPasos(X,delta_x) ;
				Y = mmToPasos(Y,delta_y) ;
				codigo = recta(x_abs,y_abs,X,Y,codigo) ;
                %fprintf(codigo,"\r\n")
				%codigo = recta_z(z_abs,Z,codigo) ;
				x_abs = X ;
				y_abs = Y ;
				%z_abs = Z ;
			case 'G01 X'
				[X,Y,Z,I,J,F] = lineToComand(line) ;
				%Z = mmToPasos(Z,delta_z) ;
				X = mmToPasos(X,delta_x) ;
				Y = mmToPasos(Y,delta_y) ;
				codigo = recta(x_abs,y_abs,X,Y,codigo) ;
                %fprintf(codigo,"\r\n")
				%codigo = recta_z(z_abs,Z,codigo) ;
				x_abs = X ;
				y_abs = Y ;
				%z_abs = Z ;
			case 'G02 X'
				[X,Y,Z,I,J,F] = lineToComand(line) ;
				%Z = mmToPasos(Z,delta_z) ;
				X = mmToPasos(X,delta_x) ;
				Y = mmToPasos(Y,delta_y) ;
				I = mmToPasos(I,delta_x) ;
				J = mmToPasos(J,delta_y) ;
				codigo = circ_hor(x_abs,y_abs,X,Y,I,J,codigo)  ;
                %fprintf(codigo,"\r\n")
        %codigo = recta_z(z_abs,Z,codigo) ;
				x_abs = X ;
				y_abs = Y ;
				%z_abs = Z ;
			case 'G03 X'
				[X,Y,Z,I,J,F] = lineToComand(line) ;
				%Z = mmToPasos(Z,delta_z) ;
				X = mmToPasos(X,delta_x) ;
				Y = mmToPasos(Y,delta_y) ;
				I = mmToPasos(I,delta_x) ;
				J = mmToPasos(J,delta_y) ;
				codigo = circ_antihor(x_abs,y_abs,X,Y,I,J,codigo)  ;
                %fprintf(codigo,"\r\n")
        %codigo = recta_z(z_abs,Z,codigo) ;
				x_abs = X ;
				y_abs = Y ;
				%z_abs = Z ;
      otherwise
        printf("%s \n",line)
		endswitch
	endif
  if(b == 0)
    intentos = intentos - 1 ;
  endif
until( intentos == 0 )
fclose(codigo)
Tconv = toc;
printf("fin de conversion desde codigo G \n tiempo : %f \n",Tconv)

## Efectuar verificacion de la codificacion
##verificacion2
tic
printf("Reduccion del instrucciones... \n")
comprimirFromGcode
##printf("Verificacion... \n ")
##verificacionCompresion
##printf("fin de compresion de codigo y verificacion \n tiempo : %f segundos\n",toc)
