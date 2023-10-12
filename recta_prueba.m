clc
close all
matriz = zeros(100,100);
function [matriz_out] = recta(xi,yi,xf,yf,matriz)
    
    if( sqrt( (xf-xi)^2+(yf-yi)^2 ) != 0)
      lambda = [xf-xi,yf-yi]/( sqrt( (xf-xi)^2+(yf-yi)^2 ) )  ;
    else
      matriz_out = matriz ;
      filas_out = filas ;
      returnimshow(recta(1,1,20,20,matriz)) ;
    endif
    t = 0 ;
    x = xi  ; 
    y = yi  ;
    do
		punto = lambda*t + [xi,yi]  ;
		x_temp = round( punto(1,1) );
		y_temp = round( punto(1,2) );
		t = t + 0.3  ;
		if( (x_temp > x || x_temp < x) && x != xf )
			x = x_temp ;
			matriz(y,x) = 1 ;
		endif
		if( (y_temp > y || y_temp < y) && y != yf )
			y = y_temp ;
			matriz(y,x) = 1 ;
		endif
    until (  x == xf && y == yf )
    matriz_out = matriz ;
endfunction

imshow(recta(20,10,30,10,matriz)) ;
