%clc
tic
clc
clear all
% para instalar el paquete: pkg install -forge image
pkg load image % carga el toolbox imag
%Ancho de la imagen en mm = lon[mm]*10.67pixel/mm
global contorno
% configuracion
flagContorno = true ;
flagEspesarBlanco = true ;
flagGrabado = true ;
addpath("/home/mario/Documentos/rutinasCNC_octave/")

% crea archivo .txt
contenido = fopen('register_char.txt','w+') ; 
% opciones de imagen a leer
options = {"Abrir PNG","Abrir BMP"};

% Obtener imagen de rutas
[archivo,ruta]=uigetfile('/home/mario/Documentos/rutinasCNC_octave/bottom.png','Abrir imagen PNG');
data_file = horzcat(ruta,archivo) ;
[X,map,f] = imread(data_file) ;
global image
image = f & 1 ;
printf("\n abrir: %s\n\n",archivo)
[filas_imag_original,colum_imag_original,p]=size(f); % m:filas , n: columnas

% borra el borde de menor intensidad
for k = 1 : 1 : filas_imag_original 
    for l = 1 : 1 :  colum_imag_original
        if f(k,l) <= 100
            f(k,l) = 0 ;
        else
            f(k,l) = 255 ;
        endif
    endfor
endfor

if(isrgb(f))
    f = rgb2gray(f);
    f = im2bw(f,"mean");
else
    f = im2bw(f,"mean");
    f = mat2gray(f,[0,1]);
endif

if(flagContorno)

    if(flagEspesarBlanco)
        f = bwmorph (~f,"thicken",1) ; % espesa el blanco
        f = ~f ;
        er = 4 ;
        se = strel ( 'line' , er,90); % 1,90 para letras
        erosionadaV =  imerode ( f , se) ;
        se = strel ( 'line' , er,0);
        erosionadaH =  imerode ( f , se ) ;
        se = strel ( 'line' , er,45);
        erosionadaV =  imerode ( f , se) ;
        se = strel ( 'line' , er,135);
        erosionadaH =  imerode ( f , se ) ;
        f = erosionadaH + erosionadaV ;
    endif
    f = mat2gray(f,[0,1]);
    %f = edge(f,"Canny");
    f = edge(f,"Lindeberg",1); % contorno de la imagen
    f = bwareaopen( f,2); % borra basura
    f = bwareaopen( f,28); % borra basura : 60 para huecos de taladrado.
    contorno = f ;
    [filas_imag_original,colum_imag_original,p]=size(contorno); % m:filas , n: columnas
else
        
    f = bwareaopen( f,28); % borra huecos
    if(flagEspesarBlanco)
        f = bwmorph (~f,"thicken",1) ; % espesa el blanco
        f = ~f ;
        se = strel ( 'line' , 2,90); % 1,90 para letras
        erosionadaV =  imerode ( f , se) ;
        se = strel ( 'line' , 2,0);
        erosionadaH =  imerode ( f , se ) ;
        se = strel ( 'line' , 2,45);
        erosionadaV =  imerode ( f , se) ;
        se = strel ( 'line' , 2,135);
        erosionadaH =  imerode ( f , se ) ;
        f = erosionadaH + erosionadaV ;
    endif
    contorno = f ;
endif
% borrar los bordes
contorno(:,1)=0;
contorno(1,:)=0;
contorno(:,colum_imag_original)=0;
contorno(filas_imag_original,:)=0;
%
image(:,1)=0;
image(1,:)=0;
image(:,colum_imag_original)=0;
image(filas_imag_original,:)=0;
imwrite (contorno,'contorno.bmp') ;

% para modificar el contorno obtenido o continuar con el obtenido
yes_or_no("\n ¿continuar? \n")
contorno = imread('/home/mario/Documentos/rutinasCNC_octave/contorno.bmp') ;



% Ajuste fisico
% 100 DPI ~ 3.937008 pixel/mm
% 200 DPI ~ 7.874000 pixel/mm
% 300 DPI ~ 11.81100 pixel/mm
% 400 DPI ~ 15.74800 pixel/mm
% 500 DPI ~ 19.68500 pixel/mm
% 600 DPI ~ 23.62200 pixel/mm
 Dherramienta = 1.3 ; % mm
 deltaXY = 0.0946 ; % mm
 DPI = 271 ; % resolucion de la maquina: 271 DPI ~ 10.67 pixel/mm 
 px = DPI/25.4 ; % 10.67 dot/mm  (convirtiendo de plg a mm) 
 step = 0.09421;  % (mm)informacion fisica de la maquina.
 fprintf('\n Resolucion de la maquina: 271 DPI \n')
 fprintf(' Pixeles verticales  = %i \n',filas_imag_original);
 fprintf(' Pixeles horizontales  = %i \n',colum_imag_original);
 fprintf(' ancho de la imagen = %i mm\n',round ( colum_imag_original/px )); % (mm) Ancho de la imagen
 fprintf(' alto de la imagen = %i mm\n',round ( filas_imag_original/px )); % (mm) Alto de la imagen
 fprintf(' avance minimo de la maquina en el plano = %i mm\n',step);% (mm)informacion fisica de la maquina.
 fprintf(' Pixeles horizontales por paso del motor = %i \n',step*colum_imag_original/round ( colum_imag_original/px ));
 fprintf(' Pixeles verticales por paso del motor = %i \n\n',step*filas_imag_original/round ( filas_imag_original/px ));
 
% Analisis de rutas
matrix_check = zeros(filas_imag_original,colum_imag_original); % conforma imagen de verificacion

% Se recorrera del lado derecho o del lado izquierdo, entorno al pixel de entrada.
% Recorrido probable de la ruta :

%             1  2  3  4  5  6  7  8 9 
	new_i = [+1,-1, 0, 0,-1,+1,+1,-1,0];
	new_j = [ 0, 0,-1,+1,-1,-1,+1,+1,0];

% orden de posicion a explorar
%     
%       678             
%       5P1    % P : como punto de partida
%       432   


% funcion que determina que direccion seguir.
function [p,index] = ponderar(i,j)
% suma el numero de pixeles en interferencia
% matriz imagen a procesar.
    global contorno
%             1  2  3  4  5  6  7  8 9 
	new_i = [+1,-1, 0, 0,-1,+1,+1,-1,0];
	new_j = [ 0, 0,-1,+1,-1,-1,+1,+1,0];

	ponderacion = zeros([1,8]) ;
	for( b1 = 1 : 1: 8 )
		if( contorno( j+new_j(b1) , i+new_i(b1) ) == 1 )
			for( b2 = 1 : 1 : 8 )
				if( contorno( j+new_j(b2)+new_j(b1) , i+new_i(b2)+new_i(b1) ) == 0 )	
					ponderacion(b1) = ponderacion(b1)  + 1 ;
				endif
			endfor
		endif
	endfor
    % para obtener el indice de menor ponderacion.
	[p,index] = max(ponderacion) ;
endfunction

% Calcular la derivada progresiva
function [x,y] = dProgresiva( i,j,ii,jj,dim )
    global image
    if ii != i
        teta = atand(( jj-j )/( ii-i ) ) ;
         if  ii<i 
            teta =  teta + 180 ;
        endif
    else
        if jj < j
            teta = -90 ;
        else
            teta = +90 ;
        endif
    endif
    

    x = 4*cosd( teta-90 ) + i ;
    y = 4*sind( teta-90 ) + j ;
    x = round(x) ;
    y = round(y) ;
        
##    if image(y,x) == 1
##        x = dim/2*cosd( teta + 90 ) + i ;
##        y = dim/2*sind( teta + 90 ) + j ;
##        x = round(x) ;
##        y = round(y) ;
##    else
##        x = dim/2*cosd( teta - 90 ) + i ;
##        y = dim/2*sind( teta - 90 ) + j ;
##        x = round(x) ;
##        y = round(y) ;
##    endif
##    
endfunction
    
% funcion para hacer rectas
function [y_abs,x_abs,texto_out] = recta(yi,xi,yf,xf,texto,flag1)
	my = yf - yi ;
	mx = xf - xi ;
	flag = true ;
	while(flag)
		flag = false ;
		
		if(xf != xi)
			flag = true ;
			xi = xi + sign(mx);
			if( mx > 0)
                if flag1
				    fprintf(texto,'%s','X');
                else
                    texto(end+1) = 'X' ;
                endif
			endif
			if( mx < 0)
				if flag1
				    fprintf(texto,'%s','x');
                else
                    texto(end+1) = 'x' ;
                endif
			endif
		endif
			
		if(yf != yi)
			flag = true ;
			yi = yi + sign(my);
			if( my > 0)
				if flag1
				    fprintf(texto,'%s','Y');
                else
                    texto(end+1) = 'Y' ;
                endif
			endif
			if( my < 0)
				if flag1
				    fprintf(texto,'%s','y');
                else
                    texto(end+1) = 'y' ;
                endif
			endif
		endif
		
	endwhile
	y_abs = yi ;
	x_abs = xi ;
	texto_out = texto ;
endfunction
% registro de rutas en una matriz de registro para un posterior analisis
matrix_registro = [] ; % (filas,columnas) ~ (codificacion,rutas)
filas_registro = 0 ;
rutas_registro = 0 ; 
 
dim =  round( Dherramienta/deltaXY ) ;
% hacer impar dim
if mod(dim,2) == 0
    dim = dim + 1 ;
endif

for j = 1:1:filas_imag_original % desplazamiento en y (filas)
	for i = 1:1:colum_imag_original % desplazamiento en x (columnas)
			
		% Busca pixeles blancos en una matrix de contorno
            
		if ( contorno(j,i) ==  1 ) 
		    
			% ahora se recorre el contorno de una ruta cerrada.
			filas_registro = 1 ;
			rutas_registro++ ;
			% registro en matriz
			matrix_registro(filas_registro++ , rutas_registro) = j;
			matrix_registro(filas_registro++ , rutas_registro) = i;
            % coordenadas para seguir contorno
            i_temp = i ; 
            j_temp = j ;
            id1 = 0 ;
            jd1 = 0 ;
			do	
				% analiza los pixeles adyacentes al presente 
				[ponderacion,index] = ponderar(i_temp,j_temp) ;
                % calcular posicion con direccion normal al punto de interferencia
                % y a distancia de un radio de herramienta.
                %                          p1(x1,y1) : p2(x2,y2)
                i2 = i_temp + new_i(index) ;
                j2 = j_temp + new_j(index) ;
                [~,index2] = ponderar(i_temp + new_i(index),j_temp + new_j(index))  ;
                i2 = i2 + new_i(index2) ;
                j2 = j2 + new_j(index2) ;
                [id2,jd2] = dProgresiva(i_temp,j_temp,i2,j2,dim );
                % iniciar punto
                if( id1 == 0 && jd1 == 0 )
                    id1 = id2 ;
                    jd1 = jd2 ;
                endif
                
                % Actualizar coodenada en direccion sugeria por "ponderar"
				j_temp = j_temp + new_j(index)  ;
				i_temp = i_temp + new_i(index)  ;
                
                % borrrar para no repetir
                contorno(j_temp,i_temp) = 0;
                % construir codificacion
                texto = [] ; %              p1(x1,y1) : p2(x2,y2)
				[y_abs,x_abs,texto] = recta(jd1,id1,jd2,id2,texto,0) ;
                % actualizar posicion
                id1 = id2 ;
                jd1 = jd2 ;
               
                % registrar movmientos
                for n =1 :1 :length(texto)
                    matrix_registro(filas_registro++, rutas_registro) = texto(n) ;
                endfor
                clear texto 
			until( ponderacion == 0   )
            % cierra la ruta.
			matrix_registro(filas_registro++, rutas_registro) = 'Y' ;
            matrix_registro(filas_registro++, rutas_registro) = 'Y' ;
        endif
    endfor
endfor
    
	printf("Analisis de rutas terminado, tiempo : %d segundos\n",toc)
	printf("Numero total de rutas : %d \n",rutas_registro) ;
	tic

    
% Optimizacion de rutas
if( flagGrabado )

	% analisis de rutas y contruccion del .txt
	filas = 1;
	columnas = 1 ;
	y_nuevo  = 0 ;
	x_nuevo  = 0 ;
	x_abs = 0 ;
	y_abs = 0 ;

	numero_rutas = rutas_registro ;

	% adicionar una fila para la condicion de '0' al final de cada columna
	[a,b] = size(matrix_registro) ;
	matrix_registro(a+2,b) = 0 ;
	while(numero_rutas >= 0)
			
		numero_rutas = numero_rutas - 1 ;
		distancia = Inf ; 
		columnas_temp = columnas;
		for (k = -rutas_registro:1:rutas_registro)
		% revisar entre todas las rutas y escoger la mas cercana al punto actual
			if( columnas+k >= 1  &&  columnas+k <= rutas_registro )
				if( matrix_registro(1,columnas+k) !=0 && matrix_registro(2,columnas+k) !=0 )
					y_temp = matrix_registro(1,columnas + k) ;
					x_temp = matrix_registro(2,columnas + k );
					d_temp = sqrt( (y_abs-y_temp)^2  + (x_abs-x_temp)^2) ;
					if( d_temp < distancia )
						y_nuevo = y_temp ;
						x_nuevo = x_temp ;
						distancia = d_temp ;
						columnas_temp = columnas + k ;
					endif
				endif
			endif
		endfor
		columnas = columnas_temp ;
		fprintf(contenido,'\r\nZ\r\n') ;
		[y_abs,x_abs,contenido] = recta(y_abs,x_abs,y_nuevo,x_nuevo,contenido,1) ;
		fprintf(contenido,'\r\nz\r\n') ;
		matrix_registro (1, columnas ) = 0 ;
		matrix_registro (2, columnas ) = 0 ;
	  
		filas = 3 ;
		do  % escribe rutas
			k = char(matrix_registro(filas++,columnas)) ;
			switch k
				case 'x'
					x_abs = x_abs - 1 ;
				case 'X'
					x_abs = x_abs + 1 ;
				case 'Y'
					y_abs = y_abs + 1 ;
				case 'y'
					y_abs = y_abs -1 ;
				otherwise
					;
			endswitch
			fprintf(contenido,'%s',k) ;
		until( matrix_registro(filas+1,columnas) == 0)
	endwhile
else	
    % exploracion horizontal
        
    x_abs = 0 ;
    y_abs = 0 ;
    % adicionar una fila para la condicion de '0' al final de cada columna
    [a,b] = size(matrix_registro) ;
    matrix_registro(a+2,b) = 0 ;
    for(col = 1:1: rutas_registro )
        filas = 3 ;
        fprintf(contenido,'\r\nZ\r\n');
        y_nuevo = matrix_registro(1,col) ;
        x_nuevo = matrix_registro(2,col) ;
        [y_abs,x_abs,contenido] = recta(y_abs,x_abs,y_nuevo,x_nuevo,contenido,1) ;
        fprintf(contenido,'\r\nz\r\n');
        do  % escribe rutas
            k = char(matrix_registro(filas++,col) );
            switch k
                case 'x'
                    x_abs = x_abs - 1 ;
                case 'X'
                    x_abs = x_abs + 1 ;
                case 'Y'
                    y_abs = y_abs + 1 ;
                case 'y'
                    y_abs = y_abs -1 ;
                otherwise
                    ;
            endswitch
            fprintf(contenido,'%s',k) ;
        until( matrix_registro(filas+1,col) == 0)
    endfor
endif
	
% para llevar al lugar (1,1) del plano
fprintf(contenido,'\r\nZ\r\n');
[y_abs,x_abs,contenido] = recta(y_abs,x_abs,0,0,contenido,1) ;
%imwrite(matrix_check,'image_check.bmp') ;
 fclose(contenido);
printf("Tiempo para codificar imagen : %d segundos \n",toc)
% Efectuar verificacion de la codificacion
printf("Reduccion de instrucciones... \n")
comprimir
printf("Verificando... \n")
verificacionCompresion
printf("Terminado \n")