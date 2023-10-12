// #include <QCoreApplication>
#include <termios.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "serial.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <cstring>

using namespace std;
/*  Para obtener el ejecutable:
 g++ -o ejecutable main.cpp
 Y ejecutar con :
 ./ejecutable ó sh send.sh 

*/

/* Conceder permisos para acceder al puerto desde una terminal :
 cd /dev
 sudo chmod ugo+r+w+x /dev/ttyUSB0
*/

int sendWord( int port, char *word ) ;
int readyStop( int port ) ;

int main(int narg, char *arg[] ){
    system("clear") ;
    system("sudo chmod ugo+r+w+x /dev/ttyUSB0") ;
    

    // Iniciar puerto serial
    char namePort[] = "/dev/ttyUSB0" ;
    int serialPort = serial_open(namePort,B38400) ;
    if(serialPort == -1){
        printf("    Error al abrir el puerto \n") ;
        return 0 ;
    }else{
        printf("    Puerto abrierto \n" )   ;
    }
    
    // Abrir archivo de texto plano
    char dir[200] ;
    std::ifstream Tx;
    Tx.open(arg[1]) ;
    if( Tx.is_open() ){
        printf("    Acceso al archivo de texto: \n") ;
        printf("    %s \n",arg[1]) ;
    }else{
        printf("    Sin acceso al archivo de texto. \n") ;
    }
    std::string line ;
    double lineas = 0 ;
    // contar el total de lineas
    while( std::getline(Tx, line) ){
         lineas = lineas + 1 ;
    }
    printf("    Numero total de lineas: %0.0f \n",lineas);
    Tx.close();
    
     // Abrir archivo de texto de nuevo
    std::ifstream Text ;
    Text.open( arg[1] ) ;

    // Enviar comandos
    double lines = 0 ;
    while( std::getline(Text, line) ){
        lines = lines + 1 ;
        char comand[line.length()] ;
        // conversion de string to char : line.c_str()  
        std::strcpy( comand , line.c_str()) ;
        printf("\x1b[6;1H  \x1b[32m \n") ;
        printf("    Linea:%0.0f  ,  Comando :%s    \n",lines,comand ) ;
        printf("    progreso: %0.3f %%    \n",lines/lineas*100 ) ;
        if( sendWord(serialPort, comand )  == 0){
            break ;
        }
        if( readyStop(serialPort) == 0 ){
            break ;
        }
     }
    printf("    Final de rutina \n") ;
    Text.close();
    printf("\x1b[0m \n") ;
    return 0;
}


int sendWord( int port, char *word ){
    char wordIn[2] ; // Dato recibido por serial
    int bytesIn ;
    int flagSend = 1 ;
    int indexWord = -1 ;

    do{
        indexWord = indexWord + 1 ;
        tcflush( port, TCIFLUSH ) ; // Borrar buffer de entrada
        tcflush( port, TCOFLUSH ) ; // Borrar buffer de salida
        serial_send( port, &word[indexWord], 1 ) ;
        //printf( " Caracter enviado: %c \n", word[indexWord] ) ;
        bytesIn = serial_read( port, wordIn, 1, 2000000 ) ;
        if( word[indexWord] != wordIn[0] ){
            printf( "    Fallo en la comunicación! \n" ) ;
            printf( "    Bytes recibidos: %d \n", bytesIn ) ;
            printf( "    Dato enviado: %c", word[indexWord]) ;
            printf(" - caracter recibido: %c", wordIn[0] ) ;
            printf(" - numero recibido: %d \n", wordIn[0] ) ;
            flagSend = 0 ;
            break ;
          }

      }while( word[indexWord] != '.' ) ;
    tcflush( port, TCIFLUSH ) ; // Borrar buffer entrada
    return flagSend ;
}

int readyStop( int port ){
    char word[] = "ok" ;
    char wordIn[6] ;
    int bytesIn = 0 ;
    int flagReady = 1 ;
    int contEspera = 0 ;
    do{
        bytesIn = 0 ;
        tcflush( port, TCIFLUSH ) ; // Borrar buffer entrada
        bytesIn = serial_read( port, wordIn, 6, 9000 ) ; // minutos para time out
        contEspera = contEspera + 1 ;
        if(contEspera > 300 ){
            printf("\x1b[2K    En espera de respuesta... \n") ;
            contEspera = 0 ;
        }
    }while(bytesIn == 0) ;
    for( int index = 0 ; index <= 1 ; index++ ){
        if( wordIn[index] != word[index] ){
            flagReady = 0 ;
            break ;
        }
    }
    return 1 ;
}

