%{

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#include <string.h>
#include "strlist.h"
#include "errs.h"
#include "gerador_codigo.h"
#include "tabela_simbolos.h"

#define YY_DECL int yylex()
#define DEFAULT_OUT_FILE "a.j"
#define WARNING_NO_OUT_FILE "Caminho de arquivo de saída não foi especificada. Usando arquivo padrão " \
                            DEFAULT_OUT_FILE \
                            "\n"
#define MSG_COMPILE_SUCCESS "Analisado sem erros\n"
#define ERRMSG_COMPILE "Erro sintático: %s\n"
#define ERRMSG_MALLOC_OUTFILENAME "Houve um erro ao tentar alocar memória para o nome do arquivo de saída\n"

extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);

extern int linha;
extern int coluna;

code_list *cl;
tabelasimbolos *ts;



%}

%union {
	int ival;
	float fval;
    unsigned char bval;
    char* cptrval;
    simbolo *symbolval;
    symbol_type symboltypeval;
    primitive_type primtypeval;
    strlist *slval;
}

%token<ival> T_FOR T_WHILE T_LOOP_END
%token<ival> T_INT_LIT
%token<ival> T_CONDICIONAL_INI T_CONDICIONAL_ELSE
%token<bval> T_BOOL_LIT
%token<fval> T_FLOAT_LIT
%token<cptrval> T_ID
%token<cptrval> T_OP_ADD T_OP_MULT T_OP_REL
%token<cptrval> T_STRING_LIT
%token<primtypeval> T_SIMPLES
%token T_DEF_ARRAY T_DEF_ARRAY_TIPO
%token T_INI_PARENTESES T_FIM_PARENTESES
%token T_ATRIBUICAO
%token T_CONDICIONAL_FIM
%token T_PROG T_FIM_PROG
%token T_DEF_TIPO
%token T_FIM_INSTRUCAO
%token T_DEF_VAR
%token T_SELETOR_INI T_SELETOR_FIM T_INTERVALO
%token T_COMCOMP_INI T_COMCOMP_FIM
%token T_SEPARADOR_INSTRUCAO
%token T_PRINT T_PRINTLN 
%token T_READ
/* %token T_FUNC */
/* %token T_PROC */
/* %token T_DEF_ARRAY
%token T_DEF_ARRAY_TIPO */
/* %token T_RETORNO */
/* %token T_INI_ARRAY_LIT */
/* %token T_FIM_ARRAY_LIT */
/* %token T_INTERVALO */
/* %right T_CONDICIONAL_FIM T_CONDICIONAL_ELSE */

%type <cptrval> variavel
%type <symboltypeval> tipo expressao expressao_simples fator termo literal tipo_agregado
%type <ival> condicional_ini 
%type <ival> printtype
%type <slval> lista_de_ids lista_de_ids_2
%type <ival> for_attrib_label for_condition for_goto_body
/* %type <ival> label */

%start prog;

%%

atribuicao: variavel T_ATRIBUICAO expressao  {cl_insert_assigment(cl, ts, $1, $3);}
    ;


comando: atribuicao  //{printf("Comando\n");}
    | condicional  //{printf("Comando\n");}
    | iterativo  //{printf("Comando\n");}
    | print
    | read
    | comando_composto  //{printf("Comando\n");}
    ;
    /* | chamada  //{printf("Comando\n");} */
    /* | retorno  //{printf("Comando\n");} */

comando_composto: T_COMCOMP_INI lista_de_comandos T_COMCOMP_FIM  //{printf("Comando composto\n");}
    ;

condicional: condicional_ini {cl_insert_lbl(cl, $1);} 
    | condicional_ini T_CONDICIONAL_ELSE {cl_insert_goto(cl, $2);cl_insert_lbl(cl, $1);} comando T_FIM_INSTRUCAO {cl_insert_lbl(cl, $2);}
    ;

condicional_ini: T_CONDICIONAL_INI expressao T_CONDICIONAL_FIM {cl_insert_if(cl, IFEQ, $1);} comando T_FIM_INSTRUCAO {$$ = $1;}
    ;

corpo: declaracoes comando_composto  //{printf("Corpo\n");}
    ;

declaracao: declaracao_de_variavel  //{printf("Declaração\n");}
    ;
    /* | declaracao_de_funcao  //{printf("Declaração\n");} */
    /* | declaracao_de_procedimento  //{printf("Declaração\n");} */

declaracao_de_variavel: T_DEF_VAR lista_de_ids T_DEF_TIPO tipo {cl_declarations(cl, ts, $2, $4);}
    ;

declaracoes: %empty //{printf("Declarações\n");}
    | declaracao T_FIM_INSTRUCAO declaracoes  //{printf("Declarações\n");}
    ;

expressao: expressao_simples                        {$$ = $1;}
    | expressao_simples T_OP_REL expressao_simples  {cl_insert_oprel(cl, $2); $$ = (symbol_type){BOOLEANA, 0};}
    ;

expressao_simples: termo                            {$$ = $1;}
    | expressao_simples T_OP_ADD termo  {cl_insert_op(cl, $1.prim_type, $3.prim_type, $2); $$ = $1;} 
    ;

fator: variavel                                     {simbolo* s; $$ = (s = cl_insert_load(cl, ts, $1)) ? s->type : (symbol_type){INTEIRO, 0};}
    | literal                                       {$$ = $1;}
    | T_INI_PARENTESES expressao T_FIM_PARENTESES   {$$ = $2;}
    ;
    /* | chamada  //{printf("Fator\n");} */

iterativo: while  //{printf("Iterativo\n");}
    | for  //{printf("Iterativo\n");}
    ;

while: T_WHILE  {cl_insert_lbl(cl, $1);} 
    expressao 
    T_LOOP_END {cl_insert_if(cl, IFEQ, $4);}
    comando 
    T_FIM_INSTRUCAO 
    {
        cl_insert_goto(cl, $1);
        cl_insert_lbl(cl, $4);
    }
    ;

for: T_FOR 
    atribuicao 
    T_FIM_INSTRUCAO
    {cl_insert_lbl(cl, $1);}  // Label for the condition check
    expressao
    for_condition
    for_goto_body
    T_FIM_INSTRUCAO
    for_attrib_label
    atribuicao
    {
        cl_insert_goto(cl, $1); // Goto condition check after doing the attribution
        cl_insert_lbl(cl, $7);  // Add label for the body
    }
    T_LOOP_END 
    comando
    {
        cl_insert_goto(cl, $9); // Goto attibution
        cl_insert_lbl(cl, $6); // Add label for the loop end
    }
    T_FIM_INSTRUCAO
    ;

for_condition: %empty { $$ = generate_label(); cl_insert_if(cl, IFEQ, $$);}
    ;
for_goto_body: %empty {$$ = generate_label(); cl_insert_goto(cl, $$);}
    ;
for_attrib_label: %empty {$$ = generate_label(); cl_insert_lbl(cl, $$);}
    ;

/* label: %empty {$$ = generate_label(); cl_insert_lbl($$);} */

lista_de_comandos: %empty //{printf("Lista de comandos\n");}
    | comando T_FIM_INSTRUCAO lista_de_comandos  //{printf("Lista de comandos\n");}
    ;


lista_de_ids: T_ID lista_de_ids_2 {$$ = sl_insert($2, $1);}
    ;

lista_de_ids_2: %empty {$$ = NULL;}
    | T_SEPARADOR_INSTRUCAO lista_de_ids {$$ = $2;}
    ;

literal: T_BOOL_LIT {cl_insert_ldc_int(cl, (int)$1); $$ = (symbol_type){BOOLEANA, 0};}
    | T_INT_LIT     {cl_insert_ldc_int(cl, $1); $$ = (symbol_type){INTEIRO, 0};}
    | T_FLOAT_LIT   {cl_insert_ldc_float(cl, $1); $$ = (symbol_type){FLUTUANTE, 0};}//{printf("Literal\n");}
    | T_STRING_LIT  {cl_insert_ldc_string(cl, $1); $$ = (symbol_type){STRING, 0};}
    ;
    /* | array_lit  //{printf("Literal\n");} */

printtype: T_PRINT  {$$ = 0;}
    | T_PRINTLN     {$$ = 1;}
    ;

print: printtype
    {cl_insert(cl, GET_PRINT);}
    T_INI_PARENTESES
    expressao
    T_FIM_PARENTESES
    {cl_insert_invokeprint(cl, $4.prim_type, $1);}
    ;

prog: T_PROG T_ID {cl_insert_header(cl, $2);} 
    T_FIM_INSTRUCAO corpo T_FIM_PROG {cl_insert_footer(cl);}
    ;

read: T_READ
    {cl_insert_invokeread(cl);}
    T_INI_PARENTESES
    variavel
    {cl_insert_store(cl, ts, $4);}
    T_FIM_PARENTESES
    ;

seletor: %empty //{printf("Seletor\n");}
    | T_SELETOR_INI expressao T_SELETOR_FIM seletor {cl_insert_pop(cl, 0);}
    ;

termo: fator                {$$ = $1;}
    | termo T_OP_MULT fator {cl_insert_op(cl, $1.prim_type, $3.prim_type, $2); $$ = $1;}
    ;

tipo: T_SIMPLES         {$$ = (symbol_type){$1, 0};}
    | tipo_agregado     {$$ = $1;}
    ;

tipo_agregado: T_DEF_ARRAY T_SELETOR_INI expressao T_INTERVALO expressao T_SELETOR_FIM T_DEF_ARRAY_TIPO tipo  { cl_insert_pop(cl, 1); $$ = $8;}
    | T_DEF_ARRAY T_DEF_ARRAY_TIPO tipo  { $$ = $3;}
    ;

variavel: T_ID seletor {$$ = $1;}
    ;

/* lista_de_expressoes: %empty //{printf("Lista de expressões\n");}
    | expressao lista_de_expressoes_2  //{printf("Lista de expressões\n");} */

/* lista_de_expressoes_2: %empty
    | T_SEPARADOR_INSTRUCAO expressao lista_de_expressoes_2 */

/* array_lit: T_INI_ARRAY_LIT lista_de_expressoes T_FIM_ARRAY_LIT  //{printf("Array lit\n");} */

/* retorno: T_RETORNO expressao  //{printf("Retorno\n");} */

/* chamada: T_ID T_INI_PARENTESES lista_de_expressoes T_FIM_PARENTESES  //{printf("Chamada\n");} */

/* lista_de_parametros: parametro lista_de_parametros_2  //{printf("Lista de parâmetos\n");} */
    /* | lista_de_parametros_2  //{printf("Lista de parâmetos\n");} */

/* lista_de_parametros_2: %empty */
    /* | T_FIM_INSTRUCAO parametro lista_de_parametros_2 */

/* parametro: T_DEF_VAR lista_de_ids T_DEF_TIPO T_SIMPLES  //{printf("Parâmetro\n");} */
    /* | lista_de_ids T_DEF_TIPO T_SIMPLES  //{printf("Parâmetro\n");} */

/* declaracao_de_funcao: T_FUNC T_ID T_INI_PARENTESES lista_de_parametros T_FIM_PARENTESES T_DEF_TIPO T_SIMPLES T_FIM_INSTRUCAO corpo  //{printf("Declaração de função\n");} */

/* declaracao_de_procedimento: T_PROC T_ID T_INI_PARENTESES lista_de_parametros T_FIM_PARENTESES T_FIM_INSTRUCAO corpo  //{printf("Declaração de procedimento\n");} */


%%

char *outfilename_new(char* filename);
char *outfilename_new(char* filename){
    char *newout;
    if (!(newout  = (char*) calloc(strlen(filename), sizeof(char)))){
        fprintf(stderr, ERRMSG_MALLOC_OUTFILENAME);
        exit(1);
    }
    strcpy(newout, filename);
    return newout;
}

int main(int argc, char* argv[]){
    char *outfilename;

    cl = cl_malloc();
    ts = ts_malloc();
    
    //setlocale (LC_ALL, "");

    ++argv, --argc; // Ignore first argument
    switch(argc){
        case 0:
            printf(WARNING_NO_OUT_FILE);
            outfilename = outfilename_new(DEFAULT_OUT_FILE);
            yyin = stdin;
            break;
        case 1:
            printf(WARNING_NO_OUT_FILE);
            outfilename = outfilename_new(DEFAULT_OUT_FILE);
            yyin = fopen(argv[0], "r");
            break;
        default:
            outfilename = outfilename_new(argv[1]);
            yyin = fopen(argv[0], "r");
    }

    do {
        yyparse();
    } while(!feof(yyin));

    if (get_err_count() > 0){
        fprintf(stderr, "Houve %d erros de compilação. Arquivo não foi compilado\n", get_err_count());
    }else{
        cl_write(cl, outfilename);
        printf(MSG_COMPILE_SUCCESS);
    }
    /* ts_print(tabela); */

    cl_free(cl);
    ts_free(ts);
    free(outfilename);

    return get_err_count() > 0;
}

void yyerror(const char* s) {
	perr(ERROR_COLOR, ERRMSG_COMPILE, s);
    /* ts_mostrar_erros(tabela); */
	exit(1);
}