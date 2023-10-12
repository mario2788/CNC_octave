/*
Este programa obtiene un codigo de movimientos incrementales
de maquina expresado en terminos de :x, X, y, Y z, Z.
Con el siguiente formato : numeroLetras.
El punto define el final del comando de movimiento.
x: movimiento negativo en la direccion horizontal del plano.
X: movimiento positivo en la direccion horizontal del plano.
y: movimiento negativo en la direccion vertical del plano.
Y: movimiento positivo en la direccion vertical del plano.
z: movimiento negativo en la direccion normal al plano.
Z: movimiento positivo en la direccion normal al plano.
Ejemplo: Diez movimientos positivos en la direccion horizontal del
plano seguido de diez movimientos positivos en la direccion vertical
del plano: 10XY.

El texto de configuracion debe tener este formato:
* Dirección del código g a procesar:
/home/mario/Documentos/rutinasCNC_octave/output_0001.gcode
* Delta en mm  en la dirección horizontal del plano:
0.09421
* Delta en mm  en la dirección vertical del plano:
0.09421
* Delta en mm  en la dirección normal al plano:
0.02934
* Formato instrucciones:
G00
G01
G02
G03

18 de Marzo del 2021
Mario Cuellar
*/

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>
#include <string>
#include <math.h>
#include "serial.h"

using namespace std ;
//Type TabNine::sem to enable semantic completion for C/C++.


string stringNum( string, char );
void solicitarXY( double*, string ) ;
void solicitarZ( double*, string )  ;
void solicitarIJ( double*, string ) ;
string rectaXY( double*, double* ) ;
string rectaZ( double*, double* ) ;
string circHor( double* , double*, double* ) ;
string circAntiHor( double*, double*, double* )  ;
int initSerial( string, speed_t ) ;
bool sendWord( int, string ) ;
void estadoPosicion( double*, double*);
bool sendComand( string, int ) ;
string roundPoint( short int, short int, double* );

// variables globales :
double deltaX = 0 ;
double deltaY = 0 ;
double deltaZ = 0 ;
double pi = 3.14159265 ;
double pointAbs[3] = {0,0,0} ; // Coordenadas absolutas {x,y,z}
double pointTemp[3] = {0,0,0} ; // Coordenadas temporales {x,y,z}
double centroCir[2] = {0,0} ; // Centro del circulo {I,J}

int main(){

    system("clear");

    // Texto que contiene parametros de configuracion
    ifstream textoPlantilla ;
    textoPlantilla.open("config_gcode2xyz.txt") ;
    if( !textoPlantilla.is_open() ){
        cout<<"    Sin acceso al archivo de texto. \n" ;
        cout<<"    config_gcode2xyz.txt \n" ;
        return 0 ;
    }
    string line ;
    unsigned char indexText = 1 ;
    string dirIn ; // direccion de entrada
    string dirOut ; // direccion de salida
    string baud ;
    string dirPort ;
    speed_t baudios ;
    while( getline( textoPlantilla , line ) ){
        switch ( int(indexText) ){
            case 2:
                dirIn = line ;
            break ;
            case 4:
                deltaX =  stod( stringNum( line, '*' ) ) ;
            break ;
            case 6:
                deltaY =  stod( stringNum( line, '*' ) ) ;
            break ;
            case 8:
                deltaZ =  stod( stringNum( line, '*' ) ) ;
            break ;
            case 10:
                dirPort = line ;
            break ;
            case 12:
                baud = stringNum( line, '*' ) ;
                if( baud.compare("9600") == 0 ){
                    baudios = B9600 ;
                }
                if( baud.compare("19200") == 0 ){
                    baudios = B19200 ;
                }
                if( baud.compare("38400") == 0 ){
                    baudios = B38400 ;
                }
                if( baud.compare("115200") == 0 ){
                    baudios = B115200 ;
                }
            break ;
            // default:
            //     cout<< line <<endl ;
        }
        indexText = indexText + 1 ;
    }
    cout<<"Dirección del codigo G:\x1b[32m "<<endl<<dirIn<<"\x1b[0m"<<endl;
    cout<<"DeltaX : \x1b[32m"<<deltaX<<"\x1b[0m"<<endl ;
    cout<<"DeltaY : \x1b[32m"<<deltaY<<"\x1b[0m"<<endl ;
    cout<<"DeltaZ : \x1b[32m"<<deltaZ<<"\x1b[0m"<<endl ;
    cout<<"Dirección del puerto serial: \x1b[32m"<<dirPort<<"\x1b[0m"<<endl;
    cout<<"Velocidad del serial: \x1b[32m"<<baud<<"\x1b[0m"<<endl;
    // Abrir puerto serial:
    int serialPort = initSerial( dirPort, baudios );
    // Abrir el codigo g :
    ifstream codeG ;
    codeG.open(dirIn);
    if ( !codeG.is_open() ){
        cout<<"Sin acceso al archivo : \n";
        cout<<dirIn<<endl ;
        return 0 ;
    }

    long int lineas = 1 ; // Contador de lineas

    // Examinar para convertir el codigo g a XYZ :
    while( getline( codeG, line )){
        system("clear");
        if( line[0] == 'G' ){
            if( sendComand( line, serialPort ) ){
                cout<<"\x1b[1;1H\x1b[0J\x1b[1;1H" ; // posicionar, borrar y posicionar
                cout<<"Movimiento:\x1b[32m "<<lineas<<":"<<line<<"\x1b[0m"<<endl ;
                lineas = lineas + 1 ;
            }else{
                cout<<line<<endl ;
                break ;
            }
        }
    }
    return 0 ;
}

string stringNum( string str , char letra){
    unsigned char len = str.length() ;
    unsigned char index = 0 ;
    unsigned char index1 = 0 ;
    unsigned char index2 = 0 ;

    if( letra != '*' ){
        while( str[index] != letra && index < len){
            index = index + 1 ;
        }
        index1 = index + 1 ;

        if( index >= len){
            return "null" ;
        }
    }

    do{
    index = index + 1 ;
    }while( str[index] != ' ' && index < len && str[index] != '(' ) ;
    index2 = index  ;

    string numberString( str.begin() + index1, str.begin() + index2 ) ;
    return numberString ;
}

void solicitarXY( double *vector, string line ){
    if( stringNum( line, 'X' ) != "null" ){
        vector[0] = stod( stringNum( line, 'X' ) ) ;
    }

    if( stringNum( line, 'Y' ) != "null" ){
        vector[1] = stod( stringNum( line, 'Y' ) ) ;
    }
}
void solicitarZ( double *vector, string line){
    if( stringNum( line, 'Z' ) != "null" ){
        vector[2] = stod( stringNum( line, 'Z' ) );
    }
}
void solicitarIJ( double *centroCir , string  line){
    if( stringNum( line, 'I' ) != "null" ){
        centroCir[0] = stod( stringNum( line, 'I' ) ) ;
    }

    if( stringNum( line, 'J' ) != "null" ){
        centroCir[1] = stod( stringNum( line, 'J' ) ) ;
    }
}
string rectaXY( double *vector1, double *vector2 ){
    vector2[0] = vector2[0]/deltaX ;
    vector2[1] = vector2[1]/deltaY ;
    if( vector1[0] == vector2[0] && vector1[1] == vector2[1]){
        return "\n";
    }

    short int ty = vector2[1] - vector1[1] ;
    short int tx = vector2[0] - vector1[0] ;

    string comando ;
    short int numX = vector1[0] ;
    short int numY = vector1[1] ;
    short int x,y ;
    double tf = hypot( ty, tx ) ; // calculo de la hipotenusa
    for( double t=0 ; t <= tf ; t = t + 0.2){
        x = ceil( tx*t/tf + vector1[0] );
        if( numX != x ){
            if( numX < x ){
                    comando = comando + 'X' ;
                    //comando = comando + string( x-numX, 'X' ) ;
            }else{
                comando = comando + 'x' ;
                // comando = comando + string( numX-x, 'x' ) ;
            }
            numX = x ;
        }
        y = ceil( ty*t/tf + vector1[1] );
        if( numY != y ){
            if( numY < y ){
                comando = comando + 'Y' ;
                // comando = comando + string( y-numY, 'Y' ) ;
            }else{
                comando = comando + 'y' ;
                // comando = comando + string( numY-y, 'y' ) ;
            }
            numY = y ;
        }
    }
    comando = comando + roundPoint( x, y, vector2 ) ;
    vector1[0] = vector2[0] ;
    vector1[1] = vector2[1] ;
    return comando ;
}
string roundPoint( short int x, short int y, double *vector2){
    char xx ;
    char yy ;
    if( x < vector2[0]){
        xx = 'X';
    }else{
        xx = 'x';
    }
    if( y < vector2[1]){
        yy = 'Y';
    }else{
        yy = 'y';
    }
    string word( round(abs(vector2[0]-x)), xx ) ;
    return word + string( round(abs(vector2[1]-y)),yy ) ;
}
string rectaZ( double *vector1, double *vector2 ){
    vector2[2] = vector2[2]/deltaZ ;
    if( vector1[2] == vector2[2] ){
        return "\n";
    }

    char z ;
    if( vector2[2] > vector1[2]){
        z = 'Z' ;
    }else{
        z = 'z' ;
    }
    short int z1 = int( vector1[2] );
    short int z2 = int( vector2[2] );

    vector1[2] = vector2[2] ;

    return string( abs( z2-z1 ), z ) ;
}
string circHor( double *vector1, double *vector2, double *centro ) {
    double x1 = vector1[0] ;
    double y1 = vector1[1] ;
    double x2 = vector2[0]/deltaX ;
    double y2 = vector2[1]/deltaY ;
    double i = centro[0]/deltaX  ;
    double j = centro[1]/deltaY  ;
    double cx = i + x1 ;
    double cy = j + y1 ;

    // radio del circulo:
    double r = hypot( i , j );
    // Angulo entre la horizontal sobre el centro y radio inicial:
    double teta1 ;
    if( i != 0 ){
        teta1 = atan( j / i ) ;
        if( i > 0 ){
            teta1 = teta1 + pi ;
        }else if( j > 0 ){
            teta1 = teta1 + 2*pi ;
        }
    }else{
        if( j > 0){
            teta1 = 3*pi/2 ;
        }else{
            teta1 = pi/2 ;
        }

    }
    // Angulo entre la horizontal sobre el centro y radio final:
    double teta2 = atan( ( y2-cy ) / ( x2-cx ) ) ;
    if( x2 < cx ){
        teta2 = teta2 + pi ;
    }else if( y2 < cy ){
        teta2 = teta2 + 2*pi ;
    }
    // construccion del arco :
    if( teta1 < teta2 ){
        teta1 = teta1 + 2*pi ;
    }
    string tempString ;
    double numx = round( x1 );
    double numy = round( y1 ) ;
    double x, y ;

    cout<<" teta1:"<<teta1*180/pi<<" teta2: "<<teta2*180/pi<<" c:"<<(x2-cx)<<endl ;
    for( double k = teta1 ; k >= teta2 ; k = k-2*asin( hypot(deltaX,deltaY)/(2*r))  ){
        x = floor( r*cos(k) + cx ) ;
        if( numx != x ){
            if( numx < x ){
                tempString = tempString + 'X' ;
            }else{
                tempString = tempString + 'x' ;
            }
            numx = x ;
        }

        y = floor( r*sin(k) + cy ) ;
        if( numy != y ){
            if( numy < y ){
                tempString = tempString + 'Y' ;
            }else{
                tempString = tempString + 'y' ;
            }
            numy = y ;
        }
    }
    // tempString = tempString + roundPoint( x, y, vector2 ) ;
    vector1[0] = x2 ;
    vector1[1] = y2 ;
    return tempString ;
}
string circAntiHor( double *vector1, double *vector2, double *centro ) {
    double x1 = vector1[0] ;
    double y1 = vector1[1] ;
    double x2 = vector2[0]/deltaX ;
    double y2 = vector2[1]/deltaY ;
    double i = centro[0]/deltaX  ;
    double j = centro[1]/deltaY  ;
    double cx = i + x1 ;
    double cy = j + y1 ;

    // radio del circulo:
    double r = hypot( i , j );
    // Angulo entre la horizontal sobre el centro y radio inicial:
    double teta1 ;
    if( i != 0 ){
        teta1 = atan( j / i ) ;
        if( i > 0  ){
            teta1 = teta1 + pi ;
        }else if( j > 0 ){
            teta1 = teta1 + 2*pi ;
        }
    }else{
        if( j > 0){
            teta1 = 3*pi/2 ;
        }else{
            teta1 = pi/2 ;
        }

    }

    // Angulo entre la horizontal sobre el centro y radio final:
    double teta2 = atan( ( y2-cy ) / ( x2-cx ) ) ;
    if( x2 < cx ){
        teta2 = teta2 + pi ;
    }else if( y2 < cy ){
        teta2 = teta2 + 2*pi ;
    }
    // construccion del arco :
    if( teta1 > teta2 ){
        teta1 = teta1 - 2*pi ;
    }

    string tempString ;
    double numx = round( x1 );
    double numy = round( y1 ) ;
    double x, y ;

    cout<<" teta1:"<<teta1*180/pi<<" teta2: "<<teta2*180/pi<<" c1:"<<cx<<":"<<cy<<endl ;
    for( double k = teta1 ; k <= teta2 ; k = k+2*asin( hypot(deltaX,deltaY)/(2*r))  ){
        x = floor( r*cos(k) + cx ) ;
        if( numx != x ){
            if( numx < x ){
                tempString = tempString + 'X' ;
            }else{
                tempString = tempString + 'x' ;
            }
            numx = x ;
        }

        y = floor( r*sin(k) + cy ) ;
        if( numy != y ){
            if( numy < y ){
                tempString = tempString + 'Y' ;
            }else{
                tempString = tempString + 'y' ;
            }
            numy = y ;
        }
    }
    // tempString = tempString + roundPoint( x, y, vector2 ) ;
    vector1[0] = x2 ;
    vector1[1] = y2 ;
    return tempString ;
}
int initSerial( string dirPort, speed_t baudios){
    string comdString = "sudo chmod ugo+r+w+x " + dirPort ;
    char *comdChar = new char [ comdString.length()+1 ] ;
    strcpy ( comdChar, comdString.c_str() );
    system( comdChar ) ; // conceder permisos

    char *dir = new char [ dirPort.length()+1 ] ;
    strcpy ( dir, dirPort.c_str() );
    int serialPort = serial_open( dir, baudios ) ;
    if( serialPort == -1 ){
        cout<<"\x1b[31m"<<"Error al abrir el puerto"<<"\x1b[0m"<<endl ;
        return 0;
    }
    cout<<"Puerto: \x1b[32m"<<dirPort<<" \x1b[0m"<<"abierto."<<endl ;
    return serialPort ;
}

bool sendWord( int port, string word ){
    if( word == "\n"){
        return true ;
    }
    char charIn[1] = {' '} ; // Dato recibido por serial
    int bytesIn = 0 ;
    int flagSend = true ;
    char *wordChar = new char[word.length()+1] ;
    strcpy( wordChar, word.c_str() ) ;

    cout<<"Enviando: \x1b[32m"<<endl ;
    // cout<<"\x1b[11;1H"<<endl ;
    cout<<wordChar<<"\x1b[0m"<<endl ;
    // cout<<"\x1b[11;1H"<<endl ;
    cout<<"\x1b[34m"; // color azul
    sleep(0.020) ;// segundos

    for(int index = 0; index < word.length(); index++ ){
        tcflush( port, TCIFLUSH ) ; // Borrar buffer de entrada
        tcflush( port, TCOFLUSH ) ; // Borrar buffer de salida
        serial_send( port, &wordChar[index], 1 ) ;

        printf( "%c", wordChar[index] ) ;

        serial_read( port, charIn, 1, 100000 ) ; // ms

        if( word[index] != charIn[0] ){
            printf( "\x1b[15;1H\x1b[31m¡Fallo en la comunicación! \n") ;
            printf( "   Caracter enviado: %c\n", word[index]) ;
            printf( "   Caracter recibido: %c \x1b[0m \n", charIn[0] ) ;
            flagSend = false ;
            break ;
        }
    }
    tcflush( port, TCIFLUSH ) ; // Borrar buffer entrada
    printf( "\x1b[0m" ) ;

    return flagSend ;
}

bool sendComand( string line, int serialPort ){
    cout<<"\nSend Comand :"<<line<<endl ;
    double value ;
    value =  stod( stringNum( line, 'G' ) );

    switch( int( value ) ){
        case 0:
            if( stringNum( line, 'Z' ) != "null" ){
                solicitarZ( pointTemp, line );
                if( !sendWord( serialPort, rectaZ(pointAbs, pointTemp) )  ){
                    return 0 ;
                }
            }else{
                solicitarXY( pointTemp, line );
                if( !sendWord( serialPort, rectaXY(pointAbs, pointTemp) )  ){
                    return 0 ;
                }
            }
        break ;
        case 1: // solicitar a Z,X,Y :
            if( stringNum( line, 'X' ) != "null" ){
                solicitarXY( pointTemp, line );
                if( !sendWord( serialPort, rectaXY( pointAbs, pointTemp) )  ){
                    return 0 ;
                }
            }
            if( stringNum( line, 'Z' ) != "null" ){
                solicitarZ( pointTemp, line );
                if( !sendWord( serialPort, rectaZ(pointAbs, pointTemp) )  ){
                    return 0 ;
                }
            }

        break ;
        case 2:
            solicitarXY( pointTemp, line );
            solicitarIJ( centroCir, line );
            if( !sendWord( serialPort, circHor( pointAbs, pointTemp, centroCir ) )  ){
                return 0 ;
            }
        break ;
        case 3:
            solicitarXY( pointTemp, line );
            solicitarIJ( centroCir, line );
            if( !sendWord( serialPort, circAntiHor(pointAbs, pointTemp, centroCir) )  ){
                return 0 ;
            }
        break ;
        // default:
    }
    return 1 ;
}
