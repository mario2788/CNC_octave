% Rutina que segun 5 puntos,define un 4 planos, para hallar 
% la correspondiente z de un punto arbitario (x,y).
% El proposito  es conseguir promediar la altura z, entre 4 planos definidos.
% El codigo parte de la existencia de 5 alturas definidas en un vector
% llamado z y una longitud de cuadrado l.

##    p4______________________ p3
##     |                       |
##     |                       |
##     |                       |
##     |                       | Longitud del cuadrado : l
##     |          p5           |  
##     |                       |
##     |                       |
##     |                       |
##     |0______________________|
##    p1                       p2 

##clear all
%% elemplo de prueba
##global   l = 100 ;
##global   p1 = [0,0,20] ;
##global   p2 = [l,0,22] ;
##global   p3 = [l,l,21] ;
##global   p4 = [0,l,22] ;
##global   p5 = [0.5*l,0.5*l,18] ;
%%
true ; 
function z = elev(x,y,pa,pb,pc)
 pab = [ pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3) ] ;
 pac = [ pc(1)-pa(1),pc(2)-pa(2),pc(3)-pa(3) ] ;
 p = cross(pab,pac); % vector perpendicular al plano.
 z = ( p(3)*pa(3) - p(1)*( x-pa(1) ) - p(2)*( y-pa(2) ) ) / ( p(3) + 0.001 );
endfunction
% Calcula la elevacion respecto a cada plano 
% y realiza un promedio ponderado 
function zout = elev_pond(x,y)
  global l  ;
  global p1 ;
  global p2 ;
  global p3 ;
  global p4 ;
  global p5 ;
  z1 = elev(x,y,p1,p2,p5) ;
  d1 = (l / ( norm(p1 - [x,y,p1(3)]) + 0.001)) ;
  z2 = elev(x,y,p2,p3,p5) ;
  d2 = (l / (norm(p2 - [x,y,p2(3)]) + 0.0001)) ;
  z3 = elev(x,y,p3,p4,p5) ;
  d3 = (l / (norm(p3 - [x,y,p3(3)]) + 0.0001)) ;
  z4 = elev(x,y,p4,p1,p5) ;
  d4 = (l / (norm(p4 - [x,y,p4(3)]) + 0.0001)) ;
  n =  2 ;
  zout = (z1*d1^n + z2*d2^n + z3*d3^n + z4*d4^n)/(d1^n + d2^n + d3^n + d4^n) ;
endfunction
%

##% visualizar superficie
##X = linspace(0,l) ;
##Y = linspace(0,l) ;
##for k = 1:1:l
##  for l = 1:1:l
##    Z(k,l) = elev_ponderada(k,l);
##  endfor
##endfor
##
##surf(X,Y,Z)
##

