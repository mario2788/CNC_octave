% Rutina encargada de obtener los 5 puntos de referencia tras
% la operacion de nivelacion.
global pasos ;
pasos = 30 ;
elevacion ; %Ejecucion del script para posterior uso de funciones.
flag_send = 1 ;
 function z_out = posicion_vertical(z_actual)
    global pasos ;
    flag_send =  1 ;
    tecla = 0 ;
    z = z_actual ;
    while( tecla != 'y' && tecla != 'Y' )
      clc
      printf("  Posicionar herramienta sobre el plano \n")
      printf("         ********************************       \n")
      printf("         *                              *       \n")
      printf("         *        arriba (q)            *       \n")
      printf("         *         abajo (a)            *       \n")
      printf("         *    Para salir (y)            *       \n")
      printf("         * Mayusculas para 10 pasos.    *       \n")
      printf("         *                              *       \n")
      printf("         ********************************       \n")
      tecla = kbhit() 
      pause(0.1)
      switch tecla
        case 'q'
          z = z + 1 ;
          flag_send = send_char('1Z.') ;
        case 'a'
          z = z - 1 ;
          flag_send = send_char('1z.') ;
        case 'Q'
          z = z + 10 ;
          flag_send = send_char('10Z.') ;
        case 'A'
          z = z - 10 ;
          flag_send = send_char('10z.') ;
      endswitch
      if(flag_send == 0)
        return
      endif
    endwhile
    printf("Altura establecida en z = %i \n",z) ;
    z_out = z ;
  endfunction
%

% Realizar nivelación.
  global l ;
  l = input("   Digite la longitud en mm : ")  ;
  step = 0.09421 ; % (mm/paso en el plano xy) informacion fisica de la maquina.
  l = round( l/step ) ; % pasos de motor
  
  tecla = 0 ;
  
  while(tecla != 'y' && tecla != 'Y')
  
    % Posicionar herramienta en punto de referencia.
    clc
    printf("\n   Posicionar la herramienta en el vertice mas alto. \n\n")
    printf("         ********************************       \n")
    printf("         *                              *       \n")
    printf("         *     frente    (t)            *       \n")
    printf("         *  izquierda  (f) (h) derecha  *       \n")
    printf("         *      atras    (g)            *       \n")
    printf("         *                              *       \n")
    printf("         *        arriba (q)            *       \n")
    printf("         *         abajo (a)            *       \n")
    printf("         *    Para salir (y)            *       \n")
    printf("         * Mayusculas para 10 pasos.    *       \n")
    printf("         *                              *       \n")
    printf("         ********************************       \n")
    tecla = kbhit() 
    pause(0.1)
    switch tecla
      case 't'
        flag_send = send_char('1Y.') ;
      case 'g'
        flag_send = send_char('1y.') ;
      case 'h' 
        flag_send = send_char('1X.') ;
      case 'f'
        flag_send = send_char('1x.') ;
      case 'q'
        flag_send = send_char('1Z.') ;
      case 'a'
        flag_send = send_char('1z.') ;
      case 'T'
        flag_send = send_char('30Y.') ;
      case 'G'
        flag_send = send_char('30y.') ;
      case 'F'
        flag_send = send_char('30x.') ;
      case 'H'
        flag_send = send_char('30X.') ;
      case 'Q'
        flag_send = send_char('30Z.') ;
      case 'A'        
        flag_send = send_char('30z.') ;
    endswitch
    if(flag_send == 0)
      return
    endif
  endwhile
  %
  printf("Primer vertice establecido \n")
  x = 0 ;
  y = 0 ;
  z = 0 ;
  global p1 = [0,0,0] ; % Punto de referencia.
  % funcion para altura de seguridad
  function z_safe(D)
    if(D == '+')
      send_char('100Z.') ;
    else
      send_char('100z.') ;
    endif
  endfunction
  % En direccion "x" positiva.
  printf("Buscando segundo vertice. \n")
  z_safe('+') ;
  send_char(horzcat(num2str(l),'X.')) ;

  z_safe('-') ;
  z = posicion_vertical(z) ;
  global p2 ;
  p2 = [l,0,z] ;

  % En direccion "y" positiva.
  printf("Buscando Tercer vertice. \n")
  z_safe('+') ;
  send_char(horzcat(num2str(l),'Y.')) ;
  z_safe('-') ;
  z = posicion_vertical(z) ;
  global p3  ;
  p3 = [l,l,z] ;
  
  % En direccion "x" negativa.
  printf("Buscando cuarto vertice. \n")
  z_safe('+') ;
  send_char(horzcat(num2str(l),'x.') ) ;
  z_safe('-') ;
  z = posicion_vertical(z) ;
  global p4 ;
  p4 = [0,l,z] ;
  
  % En direccion al centro del cuadrado.
  printf("Buscando centro de cuadrado. \n")
  z_safe('+') ;
  % Para "x"
  send_char(horzcat(num2str(l/2),'X.')) ;
  
  % Para "y"
  send_char(horzcat(num2str(l/2),'y.')) ;
  z_safe('-') ;
  z = posicion_vertical(z) ;
  global p5 ;
  p5 = [l/2,l/2,z] ;
  
  %Retornando al origen de referencia
  z_safe('+') ;
  % Para "x"
  send_char(horzcat(num2str(l/2),'x.')) ;

  % Para "y"
  send_char(horzcat(num2str(l/2),'y.')) ;
  z_safe('-') ;

  
  
  
  
  
  