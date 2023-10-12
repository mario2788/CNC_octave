% pruebas de envio de comando
	
	clc
	value = '150'; 
	srl_flush(s1);
	for(i=0:1:6)
		
		if(readyStop == 0)
			break
		endif
		send_char( horzcat(value,'x.') );
		printf("	Moviendo -x \n")
		if(readyStop == 0)
			break
		endif
		send_char(horzcat(value,'y.'));
		printf("	Moviendo -y \n")
		if(readyStop == 0)
			break
		endif
		send_char(horzcat(value,'z.'));
		printf("	Moviendo -z \n")
		if(readyStop == 0)
			break
		endif
		send_char(horzcat(value,'X.'));
		printf("	Moviendo +x \n")
		if(readyStop == 0)
			break
		endif
		send_char(horzcat(value,'Y.'));
		printf("	Moviendo +y \n")
		if(readyStop == 0)
			break
		endif
		send_char(horzcat(value,'Z.'));
		printf("	Moviendo +z \n")
	end
	
	printf("terminado \n")