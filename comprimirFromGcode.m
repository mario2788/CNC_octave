% Rutina para comprimir la codificacion
% abre archivo .txt
tic

clear all
% abrir texto fuente
textIn = fopen('register_char.txt','r') ; % obtiene un vector de caracteres ;

%crea archivo .txt de salida
textOut = fopen('registroComprimido2.txt','w') ;

%identificar secuencias
function [clv,repet,cadena] = secuencia_2(text, len)
    clv = text(1:len) ;
    repet = 1 ;
    n = 1 ;
    if(  (n*(len) + len) <= length(text) )
        while text(1:len) == text( 1 + n*(len) :  n*(len) + len  )   
            repet = repet + 1 ;
            n = n + 1 ;
            if( len + n*len+1 > length(text) +1)
                break
            endif
        endwhile
        clv_ = 0 ;
        repet_= 0 ;
        cadena_ = 0 ;
        if( (repet <= 2) && (len+1)<5 && (len+1) < length(text) )
            len = len + 1 ;
            [clv_,repet_,cadena_] = secuencia_2(text,len) ;
            if( repet*length(clv) < repet_*length(clv_) )
                repet = repet_ ;
                clv = clv_ ;
            endif
        endif
    endif
    len = length(clv) ;
    cadena = text( len*repet+1 : end )  ;
endfunction

tic
l = 1
do
    clear line b text
    b = 0 ;
    for (k=1:1:10 )
        [line,b] = fgetl(textIn) ;
        if(b != 0)
            break
        endif
    endfor
    printf("linea:%d \n",l)
    l = l + 1 ;
    
    do  
        [clv,repet,line] = secuencia_2(line, 1 )  ;      
            fprintf(textOut,"%d",repet)
            fprintf(textOut,"%s.\r\n",clv)
    until length(line) < 1
  
until ( b == 0 )

fclose(textOut) ;

