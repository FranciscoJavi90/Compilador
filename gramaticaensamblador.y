%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *mensaje);
int yylex();
void nuevaTemp(char *s);
int nuevaLabel();
int nueva();
%}

%union {
    char cadena[50];
}

%token <cadena> NUMERO IDENTIFICADOR
%token MAIN DEC INPUT OUTPUT
%token CI CF COMA PI PF PCOMA
%token IGUAL SUMA RESTA MULTI DIV
%token COMENTARIO
%token IGUALDAD DIFERENTE MENOR MAYOR MENORIGUAL MAYORIGUAL AND OR
%token IF ELSE
%type <cadena> expresion termino factor asignacion condition comparacion if_stmt escritura if 


%%

programa: MAIN CI bloque CF
        ;

bloque: declara sentencia PCOMA otra_sentencia
        ;

declara: DEC lista_factors PCOMA
        | vacio
        ;

lista_factors: factor otra_factors
        ;

otra_factors: COMA factor otra_factors
        | vacio
        ;

otra_sentencia: sentencia PCOMA otra_sentencia
        | vacio
        ;

if_stmt: if CI else CF sentencia
        ;

if: IF PI condition PF
        {
            printf("ifZ %s goto #l%i\n", $3, nuevaLabel());
        }
        ;

else: otra_sentencia CF ELSE CI otra_sentencia
        {
            printf("#l%i:", nueva());
        }
        ;

sentencia: asignacion
        | lectura
        | COMENTARIO
        | if_stmt
        | escritura
        ;

condition: expresion comparacion expresion
        {
            nuevaTemp($$);
            printf("%s = %s %s %s\n", $$, $1, $2, $3);
        }
        ;

comparacion: IGUALDAD
        {
            strcpy($$, "==");
        }
        | DIFERENTE
        {
            strcpy($$, "<>");
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
            printf("mov eax, %s\n", $3);
            printf("mov dword [%s], eax\n", $1);
            strcpy($$, $1);
        }
        ;

expresion: expresion SUMA termino
        {
            nuevaTemp($$);
            printf("mov eax, %s\n", $1);
            printf("add eax, %s\n", $3);
            printf("mov %s, eax\n", $$);
            strcpy($$, $$);
        }
        | expresion RESTA termino
        {
            nuevaTemp($$);
            printf("mov eax, %s\n", $1);
            printf("sub eax, %s\n", $3);
            printf("mov %s, eax\n", $$);
            strcpy($$, $$);
        }
        | termino
        {
            strcpy($$, $1);
        }
        ;

termino: termino MULTI factor
        {
            nuevaTemp($$);
            printf("mov eax, %s\n", $1);
            printf("imul eax, %s\n", $3);
            printf("mov %s, eax\n", $$);
            strcpy($$, $$);
        }
        | termino DIV factor
        {
            nuevaTemp($$);
            printf("mov eax, %s\n", $1);
            printf("idiv %s\n", $3);
            printf("mov %s, eax\n", $$);
            strcpy($$, $$);
        }
        | factor
        {
            strcpy($$, $1);
        }
        ;

factor: NUMERO
        {
            strcpy($$, $1);
        }
        | IDENTIFICADOR
        {
            strcpy($$, $1);
        }
        ;

lectura: INPUT factor
        {
            printf("push dword formatIn\n");
            printf("push dword %s\n", $2);
            printf("call scanf\n");
            printf("add esp, 8\n");
        }
        ;

escritura: OUTPUT factor
        {
            printf("push dword formatOut\n");
            printf("push dword [%s]\n", $2);
            printf("call printf\n");
            printf("add esp, 8\n");
        }
        ;

vacio:
        ;

%%

void nuevaTemp(char *s)
{
    static int actual = 1;
    sprintf(s, "#T%d", actual++);
}

int nuevaLabel()
{
    static int actual = 1;
    return actual++;
}

int nueva()
{
    static int actual = 1;
    return actual++;
}

int main(int argc, char **argv)
{
    printf("section .data\n");
    printf("    formatIn db \"%%d\", 0\n");
    printf("    formatOut db \"%%d\", 10, 0\n");
    printf("\n");
    printf("section .bss\n");
    yyparse();
    printf("\n");
    printf("section .text\n");
    printf("    extern printf\n");
    printf("    extern scanf\n");
    printf("\n");
    printf("global main\n");
    printf("main:\n");
    printf("    ; Declaración de variables\n");
    printf("    sub esp, 12\n");
    printf("\n");
    printf("    ; Lectura de x\n");
    printf("    push dword formatIn\n");
    printf("    push dword x\n");
    printf("    call scanf\n");
    printf("    add esp, 8\n");
    printf("\n");
    printf("    ; Lectura de y\n");
    printf("    push dword formatIn\n");
    printf("    push dword y\n");
    printf("    call scanf\n");
    printf("    add esp, 8\n");
    printf("\n");
    yyparse();
    printf("\n");
    printf("    Terminación del programa\n");
    printf("    mov eax, 0\n");
}

void yyerror(char *mensaje)
{
    fprintf(stderr, "Error de sintaxis: %s\n", mensaje);
}
