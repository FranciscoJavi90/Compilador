%{
#include <string.h>
#include "gramatica.tab.h"
%}

%%
"="      { return IGUAL; }
"+"      { return SUMA; }
"-"      { return RESTA; }
"*"      { return MULTI; }
"/"      { return DIV; }
"{"      { return CI; }
"}"      { return CF; }
"("      { return PI; }
")"      { return PF; }
"if"     { return IF; }
"else"   { return ELSE; }
"=="     { return IGUALDAD; }
"<>"     { return DIFERENTE; }
"<"      { return MENOR; }
">"      { return MAYOR; }
"<="     { return MENORIGUAL; }
">="     { return MAYORIGUAL; }
"&&"     { return AND; }
"||"     { return OR; }
";"      { return PCOMA; }
","      { return COMA; }
"MAIN"   { return MAIN; }
"DEC"   { return DEC; }
"INPUT"  { return INPUT; }
"OUTPUT" { return OUTPUT; }
"/*"[a-zA-Z0-9_ ][a-zA-Z0-9_ ]*"*/"     { /* Ignorar comentarios */ }
[a-zA-Z_][a-zA-Z0-9_]* {strcpy(yylval.cadena,yytext); return IDENTIFICADOR; }
[0-9]+   {strcpy(yylval.cadena,yytext); return NUMERO; }
\n  {}
.        { /* Ignorar cualquier otro carácter inválido */ }

%%