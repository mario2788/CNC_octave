clear all
seleccion = 0
while(seleccion != 5)
	clear all
	options = {"Convertir Imagen a XYZ","Convertir de codigo G a XYZ","Posicionar Herramienta","Ejecutar en maquina","Terminar y cerrar"};
	[seleccion, ok] = listdlg ("ListString", options,"SelectionMode", "Single","ListSize",[300, 200],"Name","Seleccionar Tarea");
	if(ok == true)
		switch seleccion
			case 1
				clear all
				contornoToXYZ_3_ponderado ;
			case 2
				clear all
				gcodeToxyz ;
			case 3
				clear all
				iniciar_serial ;
				Posicionar ;
				fclose(s1)
			case 4
				clear all
				iniciar_serial ;
				Enviar_codigo ;
				fclose(s1)
		endswitch
	endif
endwhile
