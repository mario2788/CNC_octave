% Posicionamiento de la Herramienta
clc
printf("\n Para mover la herramienta se escribe los milimetros \n y acontinuacion la direccion. ") ;
printf("Para terminar oprima t. \n") ;
letra = '0' ;
delta_xy = 0.094 ;
delta_z  = 0.005 ;
while(letra != 't' || letra != 'T')
	n = 1 ;
  clear comando
  letra = '0' ;
	while( letra <= 0x39 && letra >= 0x30 ) % Mientras letra sea un numero
		letra = kbhit();
    printf("%s",letra)
		comando(n) = letra ;
		n = n + 1 ;
	endwhile
	numb = str2num(comando(1:length(comando)-1)) ;
	switch letra
		case 'x'
			numb = numb / delta_xy ;
			numb = num2str(numb) ;
			send_char( horzcat(numb),'x.' );
		case 'X'
			numb = numb / delta_xy ;
			numb = num2str(numb) ;
			send_char( horzcat(numb),'X.' );
		case 'y'
			numb = numb / delta_xy ;
			numb = num2str(numb) ;
			send_char( horzcat(numb),'y.' );
		case 'Y'
			numb = numb / delta_xy ;
			numb = num2str(numb) ;
			send_char( horzcat(numb),'y.' );
		case 'z'
			numb = numb / delta_z ;
			numb = num2str(numb) ;
			send_char( horzcat(numb),'z.' );
		case 'Z'
			numb = numb / delta_z ;
			numb = num2str(numb) ;
			send_char( horzcat(numb),'Z.' );
		otherwise
			printf("\n Direccion no  valida \n ")
	endswitch
endwhile