#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

#define ERRMSG_MALLOC_TS_NAME "Houve um erro ao tentar alocar memória para o nome do símbolo\n"
#define ERRMSG_MALLOC_TS "Houve um erro ao tentar alocar memória para a tabela de símbolos\n"
#define ERRMSG_MALLOC_LTS "Houve um erro ao tentar alocar memória para uma entrada para a tabela de símbolos\n"
#define ERRMSG_TS_NULL "Argumento ts é um ponteiro nulo\n"
#define ERRMSG_LTS_NULL "Argumento lts é um ponteiro nulo\n"
#define ERRMSG_VAR_ALREADY_DECLARED "Variável %s já foi declarada\n"

typedef enum _primitive_type
{
    INTEIRO,
    FLUTUANTE,
    BOOLEANA,
    STRING,
    VAZIO
} primitive_type;

typedef struct _symbol_type
{
    primitive_type prim_type;
    int isarray;
} symbol_type;

typedef struct _simbolo
{
    char *nome;
    int id;
    symbol_type type;
} simbolo;

typedef struct _linhatabelasimbolos
{
    simbolo simb;
    struct _linhatabelasimbolos *prox;
    struct _linhatabelasimbolos *ant;
} linhatabelasimbolos;

typedef struct _tabelasimbolos
{
    linhatabelasimbolos *prim;
    linhatabelasimbolos *ult;
} tabelasimbolos;

tabelasimbolos *ts_malloc();
simbolo *ts_declare(tabelasimbolos *ts, char *name, symbol_type type);
simbolo *ts_find_symbol(tabelasimbolos *ts, char *name);
void ts_clear(tabelasimbolos *ts);
void ts_free(tabelasimbolos *ts);

#endif