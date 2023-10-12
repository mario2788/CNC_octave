%clc
tic
close all
pkg load image % carga el toolbox imag
%Ancho de la imagen en mm = long[mm]*10.67pixel/mm

% configuracion
flagContorno = true ;
flagEspesarBlanco = true ;
% Si el orden de las rutas importa.
flagGrabado = true ;

options = {"Abrir PNG","Abrir BMP"};
[seleccion, ok] = listdlg ("ListString", options,"SelectionMode", "Single","ListSize",[300, 100],"Name","Seleccionar Tarea");
if(seleccion == 1)
	% Obtener imagen de rutas
	[archivo,ruta]=uigetfile('*.png','Abrir imagen PNG');
	data_file = horzcat(ruta,archivo) ;
	[X,map,f] = imread(data_file) ;
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

	printf("\n abrir: %s\n\n",archivo)
	[filas_imag_original,colum_imag_original,p]=size(f); % m:filas , n: columnas
else
	% Obtener imagen de rutas
	[archivo,ruta]=uigetfile('*.bmp','Abrir imagen BMP');
	data_file = horzcat(ruta,archivo) ;
	f = imread(data_file) ;
	printf("\n abrir: %s\n\n",archivo)
	[filas_imag_original,colum_imag_original,p]=size(f); % m:filas , n: columnas
endif	
% crea archivo .txt
contenido = fopen('register_char.txt','w'); 



if flagContorno
   % Contorno de imagen
   if(isrgb(f))
     f = rgb2gray(f);
     f = im2bw(f,"mean");
   endif
   
   % f = bwareaopen( f,30); % borra basura
   %imwrite (f,'sin_huecos.bmp') ;
   if flagEspesarBlanco
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
   f = mat2gray(f,[0,1]);
   %f = edge(f,"Canny"); % contorno de la imagen
   f = edge(f,"Lindeberg",1); % contorno de la imagen
   f = bwareaopen( f,2); % borra basura
   f = bwareaopen( f,5); % borra basura : 60 para huecos de taladrado.
   contorno = f ;
   [filas_imag_original,colum_imag_original,p]=size(contorno); % m:filas , n: columnas
else
   
	if(isrgb(f))
		f = rgb2gray(f);
		f = im2bw(f,"mean");
	else
		f = im2bw(f,"mean");
		f = mat2gray(f,[0,1]);
	endif
	
	f = bwareaopen( f,28); % borra huecos
    if  flagEspesarBlanco
	    f = bwmorph (f,"thicken",30) ; % espesa el blanco
	    f = ~f ;
    endif
	%imwrite(f,'thi_1.bmp')
	   
	se = strel ( 'line' , 1,90); % 1,90 para letras
	erosionadaV =  imerode ( f , se) ;
	se = strel ( 'line' , 1,0);
	erosionadaH =  imerode ( f , se ) ;
	se = strel ( 'line' , 1,45);
	erosionadaV =  imerode ( f , se) ;
	se = strel ( 'line' , 1,135);
	erosionadaH =  imerode ( f , se ) ;
	f = erosionadaH + erosionadaV ;

	contorno = f ;
endif
% borrar los bordes
contorno(:,1)=0;
contorno(1,:)=0;
contorno(:,colum_imag_original)=0;
contorno(filas_imag_original,:)=0;
imwrite (contorno,'contorno.bmp') ;

% Ajuste fisico
% 100 DPI ~ 3.937008 pixel/mm
% 200 DPI ~ 7.874000 pixel/mm
% 300 DPI ~ 11.81100 pixel/mm
% 400 DPI ~ 15.74800 pixel/mm
% 500 DPI ~ 19.68500 pixel/mm
% 600 DPI ~ 23.62200 pixel/mm
 DPI = 271 ;% resolucion de la maquina: 271 DPI ~ 10.67 pixel/mm 
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
function [pon,p] = ponderar(matriz,j,i)
% suma 1 por pixel adyacente negro.
% matriz imagen a procesar.
%             1  2  3  4  5  6  7  8 9 
	new_i = [+1,-1, 0, 0,-1,+1,+1,-1,0];
	new_j = [ 0, 0,-1,+1,-1,-1,+1,+1,0];
	ponderacion = zeros([1,8]) ;
	for( b1 = 1 : 1: 8 )
		if( matriz( j+new_j(b1) , i+new_i(b1) ) == 1 )
			for( b2 = 1 : 1 : 8 )
				if( matriz( j+new_j(b2)+new_j(b1) , i+new_i(b2)+new_i(b1) ) == 0 )	
					ponderacion(b1) = ponderacion(b1)  + 1 ;
				endif
			endfor
		endif
	endfor

	[pon,p] = max(ponderacion) ; 
	% p: subindice con mayor valor de ponderacion.
endfunction

% registro de rutas en una matriz de registro para un posterior analisis
matrix_registro = [] ; % (filas,columnas) ~ (codificacion,rutas)
filas_registro = 0 ;
rutas_registro = 0 ; 
for j = 1:1:filas_imag_original % desplazamiento en y (filas)
	for i = 1:1:colum_imag_original % desplazamiento en x (columnas)
			
		% Busca pixeles blancos 
		if (contorno(j,i)==1)&&(matrix_check(j,i)==0)
				
			% ahora se recorre el contorno de una ruta cerrada.
			filas_registro = 1 ;
			rutas_registro++ ;
			% registro en matriz
			matrix_registro(filas_registro++, rutas_registro) = j;
			matrix_registro(filas_registro++, rutas_registro) = i;
			% usado para contar los pixeles entorno al pixel de partida.
			i_temp = i ;
			j_temp = j ;
			
			do	
				
				% analiza los pixeles adyacentes al presente 
				[ponderacion,p] = ponderar(contorno,j_temp,i_temp) ;
				
				% Registro en imagenes 
				%matrix_check(j_temp,i_temp) = 1 ;           
				contorno(j_temp,i_temp) = 0 ; 
				
				% Actualizar coodenada en direccion sugeria por "ponderar"
				j_temp = j_temp + new_j(p)  ;
				i_temp = i_temp + new_i(p)  ;
				
				
				
				% construir codificacion
				switch(p)
					case 1
						matrix_registro(filas_registro++, rutas_registro) = 'X'; 
						cont = 0 ;  
					case 2
						matrix_registro(filas_registro++, rutas_registro) = 'x';
						cont = 0 ;  
					case 3
						matrix_registro(filas_registro++, rutas_registro) = 'y';
						cont = 0 ;  
					case 4
						matrix_registro(filas_registro++, rutas_registro) = 'Y';
						cont = 0 ;  
					case 5
						matrix_registro(filas_registro++, rutas_registro) = 'x';
						matrix_registro(filas_registro++, rutas_registro) = 'y';
						cont = 0 ;  
					case 6
						matrix_registro(filas_registro++, rutas_registro) = 'X';
						matrix_registro(filas_registro++, rutas_registro) = 'y';
						cont = 0 ;  
					case 7                            
						matrix_registro(filas_registro++, rutas_registro) = 'X';
						matrix_registro(filas_registro++, rutas_registro) = 'Y';
						cont = 0 ;  
                    case 8
                        matrix_registro(filas_registro++, rutas_registro) = 'x';
						matrix_registro(filas_registro++, rutas_registro) = 'Y';
						cont = 0 ;  
				endswitch
				
			until( ponderacion == 0  )
			%matrix_registro(filas_registro++, rutas_registro) = 'Y' ;
          endif
     endfor
endfor
    
	printf("Analisis de rutas terminado, tiempo : %d segundos\n",toc)
	printf("Numero total de rutas : %d \n",rutas_registro) ;
	tic

% funcion para hacer rectas
function [y_abs,x_abs,texto_out] = recta(yi,xi,yf,xf,texto)
	my = yf - yi ;
	mx = xf - xi ;
	flag = true ;
	while(flag)
		flag = false ;
		
		if(xf != xi)
			flag = true ;
			xi = xi + sign(mx);
			if( mx > 0)
				fprintf(texto,'%s','X');
			endif
			if( mx < 0)
				fprintf(texto,'%s','x');
			endif
		endif
			
		if(yf != yi)
			flag = true ;
			yi = yi + sign(my);
			if( my > 0)
				fprintf(texto,'%s','Y');
			endif
			if( my < 0)
				fprintf(texto,'%s','y');
			endif
		endif
		
	endwhile
	y_abs = yi ;
	x_abs = xi ;
	texto_out = texto ;
endfunction
    
% Optimizacion de rutas
if flagGrabado

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
	matrix_registro(a+1,b) = 0 ;
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
		[y_abs,x_abs,contenido] = recta(y_abs,x_abs,y_nuevo,x_nuevo,contenido) ;
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

		
	else	% exploracion horizontal
		x_abs = 0 ;
		y_abs = 0 ;
		% adicionar una fila para la condicion de '0' al final de cada columna
		[a,b] = size(matrix_registro) ;
		matrix_registro(a+1,b) = 0 ;
		for(col = 1:1: rutas_registro )
			filas = 3 ;
			fprintf(contenido,'\r\nZ\r\n');
			y_nuevo = matrix_registro(1,col) ;
			x_nuevo = matrix_registro(2,col) ;
			[y_abs,x_abs,contenido] = recta(y_abs,x_abs,y_nuevo,x_nuevo,contenido) ;
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
[y_abs,x_abs,contenido] = recta(y_abs,x_abs,0,0,contenido) ;

%imwrite(matrix_check,'image_check.bmp') ;
 fclose(contenido);
printf("Tiempo para codificar imagen : %d segundos \n",toc)
% Efectuar verificacion de la codificacion
printf("Reduccion de instrucciones... \n")
comprimir
printf("Verificando... \n")
verificacionCompresion
printf("Terminado \n")
