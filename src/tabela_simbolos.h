#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

#define ERRMSG_MALLOC_TS_NAME "Houve um erro ao tentar alocar memória para o nome do símbolo\n"
#define ERRMSG_MALLOC_TS "Houve um erro ao tentar alocar memória para a tabela de símbolos\n"
#define ERRMSG_MALLOC_LTS "Houve um erro ao tentar alocar memória para uma entrada para a tabela de símbolos\n"
#define ERRMSG_TS_NULL "Argumento ts é um ponteiro nulo"
#define ERRMSG_LTS_NULL "Argumento lts é um ponteiro nulo"

typedef enum _tipo_simbolo
{
    INTEIRO,
    FLUTUANTE,
    BOOLEANA,
    STRING,
    VAZIO
} tipo_simbolo;

typedef struct _simbolo
{
    char *nome;
    int id;
    tipo_simbolo tipo;
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
int ts_inserir(tabelasimbolos *ts, char *nome, tipo_simbolo tipo);
simbolo *ts_find_symbol(tabelasimbolos *ts, char *name);
void ts_clear(tabelasimbolos *ts);
void ts_free(tabelasimbolos *ts);

#endif