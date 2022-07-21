%option noyywrap

%{
#include <string.h>
#include "gerador_codigo.h"
#include "tabela_simbolos.h"
#include "analisador_sintatico.tab.h"
#include "contador_linha.h"

extern int linha;
extern int coluna;

%}

LETRA   [a-zA-Z_]
DIGITO  [0-9]

%%

"//"[^\n]*"\n"   {
    yytext[strlen(yytext)-1] = '\0';
    // printf("Comentário: %s\n", yytext);
    nova_linha();
}

"program"   {
    avancar_coluna(yytext);
    return T_PROG;
}

":="    {
    avancar_coluna(yytext);
    return T_ATRIBUICAO;
}

"true" {
    avancar_coluna(yytext);
    yylval.bval = 1;
    return T_BOOL_LIT;
}

"false" {
    avancar_coluna(yytext);
    yylval.bval = 0;
    return T_BOOL_LIT;
}

"+"|"-"|"or"    {
    avancar_coluna(yytext);
    if(strcmp("+", yytext) == 0)
        yylval.opcommand = IADD;
    else if(strcmp("-", yytext) == 0)
        yylval.opcommand = ISUB;
    else if(strcmp("or", yytext) == 0)
        yylval.opcommand = IOR;
    return T_OP_ADD;
}

"*"|"/"|"and"   {
    avancar_coluna(yytext);
    if(strcmp("*", yytext) == 0)
        yylval.opcommand = IMUL;
    else if(strcmp("/", yytext) == 0)
        yylval.opcommand = IDIV;
    else if(strcmp("and", yytext) == 0)
        yylval.opcommand = IAND;
    return T_OP_MULT;
}

"<"|">"|"<="|">="|"="|"<>" {
    avancar_coluna(yytext);
    if(strcmp("<", yytext) == 0)
        yylval.relval = LSS;
    else if(strcmp(">", yytext) == 0)
        yylval.relval = GRT;
    else if(strcmp("<=", yytext) == 0)
        yylval.relval = LEQ;
    else if(strcmp(">=", yytext) == 0)
        yylval.relval = GEQ;
    else if(strcmp("=", yytext) == 0)
        yylval.relval = EQ;
    else if(strcmp("<>", yytext) == 0)
        yylval.relval = NEQ;
    return T_OP_REL;
}

"{" {
    avancar_coluna(yytext);
    return T_INI_ARRAY_LIT;
}

"}" {
    avancar_coluna(yytext);
    return T_FIM_ARRAY_LIT;
}

"(" {
    avancar_coluna(yytext);
    return T_INI_PARENTESES;
}

")" {
    avancar_coluna(yytext);
    return T_FIM_PARENTESES;
}

"function"  {
    avancar_coluna(yytext);
    // return T_FUNC;
}

"procedure" {
    avancar_coluna(yytext);
    // return T_PROC;
}

":" {
    avancar_coluna(yytext);
    return T_DEF_TIPO;
}

";" {
    avancar_coluna(yytext);
    return T_FIM_INSTRUCAO;
}

"var"   {
    avancar_coluna(yytext);
    return T_DEF_VAR;
}

"array" {
    avancar_coluna(yytext);
    return T_DEF_ARRAY;
}

"of"    {
    avancar_coluna(yytext);
    return T_DEF_ARRAY_TIPO;
}

"[" {
    avancar_coluna(yytext);
    return T_SELETOR_INI;
}

"]" {
    avancar_coluna(yytext);
    return T_SELETOR_FIM;
}

"begin" {
    avancar_coluna(yytext);
    return T_COMCOMP_INI;
}

"end"   {
    avancar_coluna(yytext);
    return T_COMCOMP_FIM;
}

"." {
    avancar_coluna(yytext);
    return T_FIM_PROG;
}

"," {
    avancar_coluna(yytext);
    return T_SEPARADOR_INSTRUCAO;
}

"for"   {
    avancar_coluna(yytext);
    return T_FOR;
}

"while" {
    avancar_coluna(yytext);
    return T_WHILE;
}

"do"    {
    avancar_coluna(yytext);
    return T_LOOP_END;
}

"if"    {
    avancar_coluna(yytext);
    return T_CONDICIONAL_INI;
}

"then"  {
    avancar_coluna(yytext);
    return T_CONDICIONAL_FIM;
}

"else"  {
    avancar_coluna(yytext);
    return T_CONDICIONAL_ELSE;
}

"return"    {
    avancar_coluna(yytext);
    // return T_RETORNO;
}

\"([^\\\"]|\\.)*\"   {
    avancar_coluna(yytext);
    // printf("%s\n", yytext);
    return T_STRING_LIT;
}

"integer"|"real"|"boolean"  {
    avancar_coluna(yytext);
    return T_SIMPLES;
}

{DIGITO}+"."{DIGITO}+|{DIGITO}+"."|"."{DIGITO}+ {
    avancar_coluna(yytext);
    yylval.fval = atof(yytext);
    return T_FLOAT_LIT;
}

" .. "    {
    avancar_coluna(yytext);
    return T_INTERVALO;
}

{DIGITO}+  {
    avancar_coluna(yytext);
    yylval.ival = atoi( yytext );
    return T_INT_LIT;
}

{LETRA}({LETRA}|{DIGITO})*  {
    avancar_coluna(yytext);
    yylval.tokenval = strdup(yytext);
    return T_ID;
}

[ \t]+ {
    avancar_coluna(yytext);
}

\n  {
    nova_linha();
}

. {
    fprintf(stderr, "Erro léxico na linha %d e coluna %d: %s\n", linha, coluna, yytext);
    return yytext[0];
}

%%
