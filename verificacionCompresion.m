clear all
text_in = fopen('registroComprimido2.txt','r') ; % obtiene un vector de caracteres ;
image_out_Trace = [1];
image_out = [1];
x = 1 ;
y = 1 ;
x_ = 1 ; % para incrementar el punto inicial
y_ = 1 ;

while(1)
    try
        flag_marcar = false ;
        historialVertical = [0,0] ;
        indexVertical = 2 ;
        [comandos,b] = fgetl(text_in) ;
        while b != 0
          
            % Buscar numeros
            num = 0;
            n = 1 ;
            if( length(comandos)>0 )
                % obtiene dato numerico
                while( comandos(1,n) >= 47 && comandos(1,n) <= 58 && n<length(comandos) )
                    num = num*10;
                    num = num + hex2dec(comandos(n));
                    n = n + 1 ;
                endwhile
            endif
            % identificar comando
            comando = ' ' ;
            if( length(comandos)>0 )
                m = 1 ;
                % obtiene dato alfabetico
                while( ( comandos(1,n) <= 47 || comandos(1,n) >= 58 && n<length(comandos) )&& comandos(1,n)!='.')
                    comando(1,m) = comandos(1,n);
                    m = m + 1 ;
                    n = n + 1 ;
                endwhile
            endif
            % ejecutar comando
            for( k = 1 :1: num)
                n = 1 ;
                while(n <= length(comando))
                    Char = comando(n) ;
                    switch Char
                        case 'Z'
                            flag_marcar = false ;
                            historialVertical(indexVertical) = historialVertical(indexVertical-1) + 1 ;
                            indexVertical = indexVertical + 1 ;
                        case 'z'
                            flag_marcar = true ;
                            historialVertical(indexVertical) = historialVertical(indexVertical-1) - 1 ;
                            indexVertical = indexVertical + 1 ;
                        case 'X'
                            x = x + 1 ;
                        case 'x'
                            x = x - 1 ;
                        case 'Y'
                            y = y + 1 ;
                        case 'y'
                            y = y - 1 ;
                    endswitch
                    if(flag_marcar)
                        image_out(y,x) = 1 ;
                        image_out_Exp(y,x) = 1 ;
                    endif
                    if(!flag_marcar)
                        image_out_Exp(y,x) = 1 ;
                    endif
                    n = n + 1 ;
                endwhile
            endfor
            [comandos,b] = fgetl(text_in) ;
        endwhile
        
        % rompe el while externo
        if( b == 0 )
            break
        endif
        
    catch
        fclose( text_in )
        text_in = fopen('registroComprimido2.txt','r') ; % obtiene un vector de caracteres ;
        clc
        printf("incrementando punto inicial: \n")
        x_ = x_ + 100 ;
        y_ = y_ + 100 ;
        x = x_
        y = y_
        clear image_out
        clear image_out_Exp 
        image_out = [1] ;
        image_out_Exp = [0] ;
    end_try_catch  
    
endwhile
fclose( text_in )
plot( historialVertical ) 
ylabel("Altura durante el desarrollo del ploteo (PasosMachine)")
xlabel("Historico del movimiento en Z")
grid on
imwrite(image_out,'imageCompTrace.bmp')
imwrite(image_out_Exp,'imageCompExp.bmp')