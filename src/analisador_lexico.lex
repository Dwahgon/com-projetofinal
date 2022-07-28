%option noyywrap
%option nounput
%option noinput

%{
#include <string.h>
#include "gerador_codigo.h"
#include "tabela_simbolos.h"
#include "analisador_sintatico.tab.h"
#include "contador_linha.h"
#include "errs.h"

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

"print" {
    avancar_coluna(yytext);
    return T_PRINT;
}

"println" {
    avancar_coluna(yytext);
    return T_PRINTLN;
}

"read" {
    avancar_coluna(yytext);
    return T_READ;
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
        yylval.cptrval = ADD;
    else if(strcmp("-", yytext) == 0)
        yylval.cptrval = SUB;
    else if(strcmp("or", yytext) == 0)
        yylval.cptrval = OR;
    return T_OP_ADD;
}

"*"|"/"|"and"   {
    avancar_coluna(yytext);
    if(strcmp("*", yytext) == 0)
        yylval.cptrval = MUL;
    else if(strcmp("/", yytext) == 0)
        yylval.cptrval = DIV;
    else if(strcmp("and", yytext) == 0)
        yylval.cptrval = AND;
    return T_OP_MULT;
}

"<"|">"|"<="|">="|"="|"<>" {
    avancar_coluna(yytext);
    if(strcmp("<", yytext) == 0)
        yylval.cptrval = IFCMPLT;
    else if(strcmp(">", yytext) == 0)
        yylval.cptrval = IFCMPGT;
    else if(strcmp("<=", yytext) == 0)
        yylval.cptrval = IFCMPLE;
    else if(strcmp(">=", yytext) == 0)
        yylval.cptrval = IFCMPGE;
    else if(strcmp("=", yytext) == 0)
        yylval.cptrval = IFCMPEQ;
    else if(strcmp("<>", yytext) == 0)
        yylval.cptrval = IFCMPNE;
    return T_OP_REL;
}

"{" {
    avancar_coluna(yytext);
    // return T_INI_ARRAY_LIT;
}

"}" {
    avancar_coluna(yytext);
    // return T_FIM_ARRAY_LIT;
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
    yylval.ival = generate_label();
    return T_FOR;
}

"while" {
    avancar_coluna(yytext);
    yylval.ival = generate_label();
    return T_WHILE;
}

"do"    {
    avancar_coluna(yytext);
    yylval.ival = generate_label();
    return T_LOOP_END;
}

"if"    {
    avancar_coluna(yytext);
    yylval.ival = generate_label();
    return T_CONDICIONAL_INI;
}

"then"  {
    avancar_coluna(yytext);
    return T_CONDICIONAL_FIM;
}

"else"  {
    avancar_coluna(yytext);
    yylval.ival = generate_label();
    return T_CONDICIONAL_ELSE;
}

"return"    {
    avancar_coluna(yytext);
    // return T_RETORNO;
}

\"([^\\\"]|\\.)*\"   {
    avancar_coluna(yytext);
    // printf("String: %s\n", yytext);
    yylval.cptrval = yytext;
    return T_STRING_LIT;
}

"integer"|"real"|"boolean"  {
    avancar_coluna(yytext);
    if (strcmp(yytext, "integer") == 0)
        yylval.symboltypeval = (symbol_type){INTEIRO, 0};
    else if (strcmp(yytext, "real") == 0)
        yylval.symboltypeval = (symbol_type){FLUTUANTE, 0};
    else 
        yylval.symboltypeval = (symbol_type){BOOLEANA, 0};
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
    yylval.cptrval = strdup(yytext);
    return T_ID;
}

[ \t]+ {
    avancar_coluna(yytext);
}

\n  {
    nova_linha();
}

. {
    perr(ERROR_COLOR, "Símbolo não reconhecido: %s\n", yytext);
    return yytext[0];
}

%%
