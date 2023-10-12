%% verificacion
% Se busca determinar si la codificaci�n recrea correctamente la imagen de
% interes. Se generan dos imagenes: image_plotter y image_trace. La primera
% debe recrear la imagen de interes y la segunda mostrar� los
% desplazamientos de la herramienta.
tic
text_in = fscanf(fopen('register_char.txt','r'),'%s' ); % obtiene un vector  ;
image_plotter = []; %zeros(100,100); %  imagen  a plotear
image_trace   = []; %zeros(100,100); %  exploracion en el plano
size_text = length(text_in);
flag1 = false; % Usado para se�alar sobre que imagen escribir.
  i = 1;   % Columnas, movimiento en el eje X.
  j = 1;   % Filas, movimiento en el eje Y
##imwrite(image_plotter,"ploteado.gif", 'gif' , 'LoopCount' ,Inf, 'DelayTime' ,0.2);
x = 0 ;
deltax = 1 ;
deltay = 1 ;
visualizar = 0 ;
while(x < size_text)
    x = x + 1 ;
    char_ = text_in(1,x) ;
 % para determinar imagen a escribir
    if(char_ == 'z')
        flag1 = true; % Dibujar en image_plotter
##        imwrite(image_plotter,"ploteado.gif", 'gif' , 'WriteMode' , 'append' ,'DelayTime' ,0.2);
    end
    
    if(char_ == 'Z')
        flag1 = false; % dibujar en image_trace
        
    end
  
    if(char_ == 'Y')
        j = j + deltay;
    end

    if(char_ == 'y')
        j = j - deltay;
    end

    if(char_ == 'X')
        i = i + deltax;
    end

    if(char_ == 'x')
        i = i - deltax ;
    end
##    visualizar = visualizar+1;
    if(flag1)
        image_plotter(j,i) = 1;
        image_trace(j,i) = 1;
##        if(visualizar >= 90)
##          imwrite(image_trace,'image_trace.bmp')
##          visualizar   = 0 ;
##          pause(0.4)
##        endif
    end

    if(~flag1)
        image_trace(j,i) = 1;
##        if(visualizar == 5)
##            imwrite(image_trace,"ploteado.gif", 'gif' , 'WriteMode' , 'append' ,'DelayTime' ,0.2);
##            visualizar = 0 ;
##        endif
    end
       
end

imwrite(image_plotter,'image_plotter.bmp')
imwrite(image_trace,'image_trace.bmp')
fprintf("\n Tiempo para decodificar imagen : \n ")
toc 
fprintf("\n Tiempo estimado de ejecucion : %0.2f minutos\n",size_text*0.011395/60);