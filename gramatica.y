%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *mensaje);
int yylex();
void nuevaTemp(char *s);
int nuevaLabel();  // Declaración del prototipo de nuevaLabel()
int nueva();
%}
%union{
	char cadena[50];
}
%token <cadena>NUMERO IDENTIFICADOR
%token MAIN DEC INPUT OUTPUT
%token CI CF COMA PI PF PCOMA
%token IGUAL SUMA RESTA MULTI DIV
%token COMENTARIO
%token IGUALDAD DIFERENTE MENOR MAYOR MENORIGUAL MAYORIGUAL AND OR
%token IF ELSE
%type <cadena> expresion termino factor asignacion condition comparacion if escritura

%%

programa: MAIN CI bloque CF 
        ;

bloque: declara sentencia PCOMA otra_sentencia
        ;

declara: DEC lista_factors PCOMA
        | vacio
        ;
lista_factors: var otra_factors //define una lista de factores separados por comas
        ;

otra_factors: COMA var otra_factors
        |vacio
        ;
otra_sentencia: sentencia PCOMA otra_sentencia
        | vacio
        ;
        
if_stmt: if CI else CF sentencia
;
if:  IF PI condition PF 
        {printf("ifZ %s goto #l%i\n", $3, nuevaLabel());}
;
else: otra_sentencia CF ELSE CI otra_sentencia 
{printf("#l%i:", nueva());}  
;

sentencia:asignacion 
        | lectura
        | COMENTARIO
        | if_stmt 
        | escritura
        ;

condition: expresion comparacion expresion //se crea una nueva variable temporal utilizando la función nuevaTemp() y se imprime el código de tres direcciones correspondiente a la evaluación de la condición
        {
            nuevaTemp($$);
            printf("%s = %s %s %s\n", $$, $1, $2, $3);
        }
        ;

comparacion: IGUALDAD //comparacion define los diferentes operadores de comparación utilizados en las condiciones. 
        {
            strcpy($$, "==");//Cada opción asigna un operador específico a la variable $$ utilizando la función strcpy()
        }
        | DIFERENTE
        {
            strcpy($$, "<>");//La función strcpy se utiliza para copiar una cadena de caracteres en otra cadena de caracteres. 
        }
        | MENOR
        {
            strcpy($$, "<");
        }
        | MAYOR
        {
            strcpy($$, ">");
        }
        | MENORIGUAL
        {
            strcpy($$, "<=");
        }
        | MAYORIGUAL
        {
            strcpy($$, ">=");
        }
        | AND
        {
            strcpy($$, "&&");
        }
        | OR
        {
            strcpy($$, "||");
        }
        ;

asignacion: IDENTIFICADOR IGUAL expresion
        {
        if (strcmp($3, "%i") >= 0) { /*La función strcmp se utiliza para comparar dos cadenas de caracteres. 
        Devuelve un valor entero que indica si las cadenas son iguales, si una es mayor que la otra o si una es menor que la otra*/
                printf("goto #l%i;\n", nuevaLabel());
                printf("#l%i:", nueva());
        }
        printf("%s = %s;\n", $1, $3);
        strcpy($$, $1); //La función strcpy se utiliza para copiar una cadena de caracteres en otra cadena de caracteres. 
        }
        ;


expresion: expresion SUMA termino {
        nuevaTemp($$);
        printf("%s = %s + %s\n", $$, $1, $3);
        strcpy($$, $$);  // Si no hay un operador adicional, simplemente se copia el valor del término al símbolo $$
        }
        | expresion RESTA termino {
            nuevaTemp($$);
            printf("%s = %s - %s\n", $$, $1, $3);
            strcpy($$, $$);  // Si no hay un operador adicional, simplemente se copia el valor del término al símbolo $$
        }
        | termino {
            strcpy($$, $1);
             // Si no hay un operador adicional, simplemente se copia el valor del término al símbolo $$
        }
        ;

termino: termino MULTI factor {
                nuevaTemp($$);
                printf("%s = %s * %s\n", $$, $1, $3);
                strcpy($$, $$); //La función strcpy se utiliza para copiar una cadena de caracteres en otra cadena de caracteres. 
        }
        | termino DIV factor {
                nuevaTemp($$);
                printf("%s = %s / %s\n", $$, $1, $3);
                strcpy($$, $$);//La función strcpy se utiliza para copiar una cadena de caracteres en otra cadena de caracteres. 
        }
        | factor {
                
             strcpy($$, $1);  //La función strcpy se utiliza para copiar una cadena de caracteres en otra cadena de caracteres. 

        }
        ;

var:  IDENTIFICADOR;

factor: NUMERO {
            strcpy($$, $1);  // Copia el valor del número al símbolo $$
        }
        | IDENTIFICADOR {
            strcpy($$, $1);  // Copia el valor del identificador al símbolo $$
        }
        ;
lectura: INPUT factor { printf("call imput;\npop %s;\n", $2); }
        ;
escritura:OUTPUT factor {
        printf("push %s;\ncall output;\n", $2); }   
        ;
vacio:
        ;

%%
void nuevaTemp(char *s){
	static int actual=1;
	sprintf(s,"#T%d",actual++); // Genera un nuevo nombre de variable temporal incrementando el contador actual
}
int nuevaLabel() {
    static int actual = 1;
	return actual++; // Retorna el valor actual del contador y luego lo incrementa
}
int nueva() {
    static int actual = 1;
	return actual++; // Retorna el valor actual del contador y luego lo incrementa
}
int main(int argc, char **argv) {
        printf("main:\n");
        yyparse(); // Llama a la función `yyparse` para iniciar el análisis sintáctico
        return 0; // Retorna 0 para indicar que el programa ha finalizado exitosamente
}
void yyerror(char *mensaje) {
        fprintf(stderr,"Error de sintaxis: %s\n", mensaje); // Imprime un mensaje de error de sintaxis en la consola de error estándar
}