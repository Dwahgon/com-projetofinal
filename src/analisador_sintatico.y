%{

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#include <string.h>
#include "gerador_codigo.h"
#include "tabela_simbolos.h"

#define YY_DECL int yylex()
#define DEFAULT_OUT_FILE "a.j"
#define WARNING_NO_OUT_FILE "Caminho de arquivo de saída não foi especificada. Usando arquivo padrão " \
                            DEFAULT_OUT_FILE \
                            "\n"
#define MSG_COMPILE_SUCCESS "Analisado sem erros\n"
#define ERRMSG_COMPILE "Erro sintático na linha %d e coluna %d: %s\n"
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
    tipo_simbolo symboltypeval;
}

%token<ival> T_FOR T_WHILE T_LOOP_END
%token<ival> T_INT_LIT
%token<ival> T_CONDICIONAL_INI T_CONDICIONAL_ELSE
%token<bval> T_BOOL_LIT
%token<fval> T_FLOAT_LIT
%token<cptrval> T_ID
%token<cptrval> T_OP_ADD T_OP_MULT T_OP_REL
%token<cptrval> T_STRING_LIT
%token<symboltypeval> T_SIMPLES
%token T_INI_PARENTESES T_FIM_PARENTESES
%token T_ATRIBUICAO
%token T_CONDICIONAL_FIM
%token T_PROG T_FIM_PROG
%token T_DEF_TIPO
%token T_FIM_INSTRUCAO
%token T_DEF_VAR
%token T_SELETOR_INI T_SELETOR_FIM
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

%type <symbolval> variavel
%type <symboltypeval> tipo expressao expressao_simples fator termo literal
%type <ival> condicional_ini 
%type <ival> printtype
%type <ival> lista_de_ids lista_de_ids_2 declare_id
%type <ival> for_attrib_label for_condition for_goto_body

%start prog;

%%

atribuicao: variavel T_ATRIBUICAO expressao  {if ($1) cl_insert_store(cl, $1);}
    ;

/* array_lit: T_INI_ARRAY_LIT lista_de_expressoes T_FIM_ARRAY_LIT  //{printf("Array lit\n");} */

/* chamada: T_ID T_INI_PARENTESES lista_de_expressoes T_FIM_PARENTESES  //{printf("Chamada\n");} */

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

/* declaracao_de_funcao: T_FUNC T_ID T_INI_PARENTESES lista_de_parametros T_FIM_PARENTESES T_DEF_TIPO T_SIMPLES T_FIM_INSTRUCAO corpo  //{printf("Declaração de função\n");} */

/* declaracao_de_procedimento: T_PROC T_ID T_INI_PARENTESES lista_de_parametros T_FIM_PARENTESES T_FIM_INSTRUCAO corpo  //{printf("Declaração de procedimento\n");} */

declaracao_de_variavel: T_DEF_VAR lista_de_ids T_DEF_TIPO tipo  {
        linhatabelasimbolos *lts = ts->ult;
        for (int i = 0; i < $2; i++){
            lts->simb.tipo = $4;
            cl_insert_const(cl, 0, $4);
            cl_insert_store(cl, &lts->simb);
            // printf("(%d)%s : %d\n", lts->simb.id, lts->simb.nome, lts->simb.tipo);
            lts = lts->ant;
        }
    }
    ;

declaracoes: %empty //{printf("Declarações\n");}
    | declaracao T_FIM_INSTRUCAO declaracoes  //{printf("Declarações\n");}
    ;

expressao: expressao_simples                        {$$ = $1;}
    | expressao_simples T_OP_REL expressao_simples  {cl_insert_oprel(cl, $2); $$ = BOOLEANA;}
    ;

expressao_simples: termo                            {$$ = $1;}
    | expressao_simples T_OP_ADD expressao_simples  {cl_insert_op(cl, $1, $3, $2); $$ = $1;} 
    ;

/* expressao_simples_2: %empty
    | T_OP_ADD termo {cl_insert_op(cl, $1);} expressao_simples_2
    ; */

fator: variavel                                     {if ($1) {cl_insert_load(cl, $1); $$=$1->tipo;}}
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

lista_de_comandos: %empty //{printf("Lista de comandos\n");}
    | comando T_FIM_INSTRUCAO lista_de_comandos  //{printf("Lista de comandos\n");}
    ;

/* lista_de_expressoes: %empty //{printf("Lista de expressões\n");}
    | expressao lista_de_expressoes_2  //{printf("Lista de expressões\n");} */

/* lista_de_expressoes_2: %empty
    | T_SEPARADOR_INSTRUCAO expressao lista_de_expressoes_2 */

lista_de_ids: declare_id lista_de_ids_2 {$$ = $1 + $2;}
    ;

lista_de_ids_2: %empty {$$ = 0;}
    | T_SEPARADOR_INSTRUCAO lista_de_ids {$$ = $2;}
    ;

declare_id: T_ID 
    {
        $$ = 0;
        if(!ts_find_symbol(ts, $1, VARIAVEL)){
            ts_inserir(ts, $1, VAZIO, VARIAVEL);
            $$ = 1;
        }
    }
    ;


/* lista_de_parametros: parametro lista_de_parametros_2  //{printf("Lista de parâmetos\n");} */
    /* | lista_de_parametros_2  //{printf("Lista de parâmetos\n");} */

/* lista_de_parametros_2: %empty */
    /* | T_FIM_INSTRUCAO parametro lista_de_parametros_2 */

literal: T_BOOL_LIT {cl_insert_bipush(cl, (int)$1); $$ = BOOLEANA;}
    | T_INT_LIT     {cl_insert_bipush(cl, $1); $$ = INTEIRO;}
    | T_FLOAT_LIT   {cl_insert_ldc_float(cl, $1); $$ = FLUTUANTE;}//{printf("Literal\n");}
    | T_STRING_LIT  {cl_insert_ldc_string(cl, $1); $$ = STRING;}
    ;
    /* | array_lit  //{printf("Literal\n");} */

/* parametro: T_DEF_VAR lista_de_ids T_DEF_TIPO T_SIMPLES  //{printf("Parâmetro\n");} */
    /* | lista_de_ids T_DEF_TIPO T_SIMPLES  //{printf("Parâmetro\n");} */

printtype: T_PRINT  {$$ = 0;}
    | T_PRINTLN     {$$ = 1;}
    ;

print: printtype
    {cl_insert(cl, GET_PRINT);}
    T_INI_PARENTESES
    expressao
    T_FIM_PARENTESES
    {cl_insert_invokeprint(cl, $4, $1);}
    ;

prog: T_PROG T_ID {cl_insert_header(cl, $2); ts_inserir(ts, $2, VAZIO, PROGRAMA);} 
    T_FIM_INSTRUCAO corpo T_FIM_PROG {cl_insert_footer(cl);}
    ;


/* retorno: T_RETORNO expressao  //{printf("Retorno\n");} */

read: T_READ
    {cl_insert_invokeread(cl, ts->prim->simb.nome);}
    T_INI_PARENTESES
    variavel
    {if ($4) cl_insert_store(cl, $4);}
    T_FIM_PARENTESES
    ;

seletor: %empty //{printf("Seletor\n");}
    | T_SELETOR_INI expressao T_SELETOR_FIM seletor  //{printf("Seletor\n");}
    ;

termo: fator                {$$ = $1;}
    | termo T_OP_MULT termo {cl_insert_op(cl, $1, $3, $2); $$ = $1;}
    ;

/* termo_2: %empty
    | T_OP_MULT fator {cl_insert(cl, $1);} termo_2 */
    ;

tipo: T_SIMPLES 
    ;
    /* | tipo_agregado */

/* tipo_agregado: T_DEF_ARRAY T_DEF_ARRAY_TIPO tipo  //{printf("Tipo agregado\n");}
    | T_DEF_ARRAY T_SELETOR_INI T_INT_LIT T_INTERVALO T_INT_LIT T_SELETOR_FIM T_DEF_ARRAY_TIPO tipo  //{printf("Tipo agregado\n");} */

variavel: T_ID seletor {$$ = ts_find_symbol(ts, $1, VARIAVEL);}
    ;



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

    printf(MSG_COMPILE_SUCCESS);
    cl_write(cl, outfilename);
    /* ts_print(tabela); */

    cl_free(cl);
    ts_free(ts);
    free(outfilename);
    return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, ERRMSG_COMPILE, linha, coluna, s);
    /* ts_mostrar_erros(tabela); */
	exit(1);
}