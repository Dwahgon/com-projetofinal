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
    char* idval;
    simbolo *symbolval;
}

%token T_ATRIBUICAO
%token<idval> T_ID
%token T_OP_ADD
%token T_OP_MULT
%token T_OP_REL
%token<bval> T_BOOL_LIT
%token<ival> T_INT_LIT
%token<fval> T_FLOAT_LIT
%token T_INI_PARENTESES
%token T_FIM_PARENTESES
%token T_CONDICIONAL_INI
%token T_CONDICIONAL_FIM
%token T_CONDICIONAL_ELSE
/* %token T_FUNC */
/* %token T_PROC */
%token T_DEF_TIPO
%token T_FIM_INSTRUCAO
%token T_DEF_VAR
%token T_DEF_ARRAY
%token T_DEF_ARRAY_TIPO
%token T_SELETOR_INI
%token T_SELETOR_FIM
%token T_COMCOMP_INI
%token T_COMCOMP_FIM
%token T_FIM_PROG
%token T_STRING_LIT
%token T_SIMPLES
%token T_FOR
%token T_WHILE
%token T_LOOP_END
%token T_SEPARADOR_INSTRUCAO
/* %token T_RETORNO */
%token T_INI_ARRAY_LIT
%token T_FIM_ARRAY_LIT
%token T_PROG
%token T_INTERVALO
%right T_CONDICIONAL_FIM T_CONDICIONAL_ELSE

%type <symbolval> variavel

%start prog;

%%

atribuicao: variavel T_ATRIBUICAO expressao  {
    if ($1) 
        cl_insert_istore(cl, $1->id);
}

array_lit: T_INI_ARRAY_LIT lista_de_expressoes T_FIM_ARRAY_LIT  //{printf("Array lit\n");}

/* chamada: T_ID T_INI_PARENTESES lista_de_expressoes T_FIM_PARENTESES  //{printf("Chamada\n");} */

comando: atribuicao  //{printf("Comando\n");}
    | condicional  //{printf("Comando\n");}
    | iterativo  //{printf("Comando\n");}
    /* | chamada  //{printf("Comando\n");} */
    | comando_composto  //{printf("Comando\n");}
    /* | retorno  //{printf("Comando\n");} */

comando_composto: T_COMCOMP_INI lista_de_comandos T_COMCOMP_FIM  //{printf("Comando composto\n");}

condicional: T_CONDICIONAL_INI expressao T_CONDICIONAL_FIM comando T_CONDICIONAL_ELSE comando //{printf("Condicional\n");}
    | T_CONDICIONAL_INI expressao T_CONDICIONAL_FIM comando //{printf("Condicional\n");} 

corpo: declaracoes comando_composto  //{printf("Corpo\n");}

declaracao: declaracao_de_variavel  //{printf("Declaração\n");}
    /* | declaracao_de_funcao  //{printf("Declaração\n");} */
    /* | declaracao_de_procedimento  //{printf("Declaração\n");} */

/* declaracao_de_funcao: T_FUNC T_ID T_INI_PARENTESES lista_de_parametros T_FIM_PARENTESES T_DEF_TIPO T_SIMPLES T_FIM_INSTRUCAO corpo  //{printf("Declaração de função\n");} */

/* declaracao_de_procedimento: T_PROC T_ID T_INI_PARENTESES lista_de_parametros T_FIM_PARENTESES T_FIM_INSTRUCAO corpo  //{printf("Declaração de procedimento\n");} */

declaracao_de_variavel: T_DEF_VAR lista_de_ids T_DEF_TIPO tipo  //{printf("Declaração de variável\n");}

declaracoes: %empty //{printf("Declarações\n");}
    | declaracao T_FIM_INSTRUCAO declaracoes  //{printf("Declarações\n");}

expressao: expressao_simples  //{printf("Expressão\n");}
    | expressao_simples T_OP_REL expressao_simples //{printf("Expressão\n");}

expressao_simples: termo expressao_simples_2  //{printf("Expressão simples\n");}

expressao_simples_2: %empty
    | T_OP_ADD termo {cl_insert(cl, IADD);} expressao_simples_2

fator: variavel {if ($1) cl_insert_iload(cl, $1->id);}
    | literal  //{printf("Fator\n");}
    | T_INI_PARENTESES expressao T_FIM_PARENTESES  //{printf("Fator\n");}
    /* | chamada  //{printf("Fator\n");} */

iterativo: T_WHILE expressao T_LOOP_END comando  //{printf("Iterativo\n");}
    | T_FOR atribuicao T_FIM_INSTRUCAO expressao T_FIM_INSTRUCAO atribuicao T_LOOP_END comando  //{printf("Iterativo\n");}

lista_de_comandos: %empty //{printf("Lista de comandos\n");}
    | comando T_FIM_INSTRUCAO lista_de_comandos  //{printf("Lista de comandos\n");}

lista_de_expressoes: %empty //{printf("Lista de expressões\n");}
    | expressao lista_de_expressoes_2  //{printf("Lista de expressões\n");}

lista_de_expressoes_2: %empty
    | T_SEPARADOR_INSTRUCAO expressao lista_de_expressoes_2

lista_de_ids: T_ID {
    if(!ts_find_symbol(ts, $1))
        ts_inserir(ts, $1, VAZIO);
    } 
    lista_de_ids_2 //{printf("Lista de ids\n");}

lista_de_ids_2: %empty
    | T_SEPARADOR_INSTRUCAO lista_de_ids

/* lista_de_parametros: parametro lista_de_parametros_2  //{printf("Lista de parâmetos\n");} */
    /* | lista_de_parametros_2  //{printf("Lista de parâmetos\n");} */

/* lista_de_parametros_2: %empty */
    /* | T_FIM_INSTRUCAO parametro lista_de_parametros_2 */

literal: T_BOOL_LIT  //{printf("Literal\n");}
    | T_INT_LIT  {cl_insert_bipush(cl, $1);}
    | T_FLOAT_LIT  //{printf("Literal\n");}
    | T_STRING_LIT  //{printf("Literal\n");}
    | array_lit  //{printf("Literal\n");}

/* parametro: T_DEF_VAR lista_de_ids T_DEF_TIPO T_SIMPLES  //{printf("Parâmetro\n");} */
    /* | lista_de_ids T_DEF_TIPO T_SIMPLES  //{printf("Parâmetro\n");} */

prog: T_PROG T_ID {cl_insert_header(cl, $2);} 
    T_FIM_INSTRUCAO corpo T_FIM_PROG {cl_insert_footer(cl);}


/* retorno: T_RETORNO expressao  //{printf("Retorno\n");} */

seletor: %empty //{printf("Seletor\n");}
    | T_SELETOR_INI expressao T_SELETOR_FIM seletor  //{printf("Seletor\n");}

termo: fator termo_2  //{printf("Termo\n");}

termo_2: %empty
    | T_OP_MULT fator {cl_insert(cl, IMUL);} termo_2

tipo: T_SIMPLES  //{printf("Tipo\n");}
    | tipo_agregado

tipo_agregado: T_DEF_ARRAY T_DEF_ARRAY_TIPO tipo  //{printf("Tipo agregado\n");}
    | T_DEF_ARRAY T_SELETOR_INI T_INT_LIT T_INTERVALO T_INT_LIT T_SELETOR_FIM T_DEF_ARRAY_TIPO tipo  //{printf("Tipo agregado\n");}

variavel: T_ID seletor {
    simbolo *s;
    if ((s = ts_find_symbol(ts, $1))) 
        $$ = s;
    else
        $$ = NULL;
    }



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
    
    setlocale (LC_ALL, "");

    /* tabela = ts_malloc(); */
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