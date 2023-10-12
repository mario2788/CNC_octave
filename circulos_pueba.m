clc
close all
%matriz = zeros(100,100);
%%funcion para hacer circulos 
%xi = 91.721	;
%yi = 110.379	;
%xf = 90.24	;
%yf = 47.205	;
%I  = -0.741	;
%J  = -31.587	;

function circ_G03(xi,yi,xf,yf,I,J) ;
	close all
	matriz = zeros(100,100);
	y_temp = yi ;
	x_temp = xi ;
	% Centro
	h = xi + I ;
	k = yi + J ;
	% Radio
	r = sqrt( I^2 + J^2 ) ;
	angulo_i = atand( (yi-k) / (xi-h) ) ;
	if(xi < h)
		angulo_i = angulo_i + 180 ;
	endif

	do
		x_temp = round( r*cosd(angulo_i) + h );
		y_temp = round( r*sind(angulo_i) + k );
		matriz( round(y_temp)+100 , round(x_temp) +100) = 1 ;
		angulo_i = angulo_i + 1 ; % '+':G03 , '-':G02
		
	until( abs(x_temp - xf) < 1.5 && abs(y_temp - yf) < 1.5 )
	imshow(matriz) ;
endfunction

