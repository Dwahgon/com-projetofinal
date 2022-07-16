#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

typedef enum _funcao_simbolo
{
    VARIAVEL,
    FUNCAO,
    PROCEDIMENTO
} funcao_simbolo;

enum tipo_simbolo
{
    INTEIRO,
    FLUTUANTE,
    BOOLEANA,
    VAZIO
};

typedef struct _simbolo
{
    char *nome;
    funcao_simbolo funcao;
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
void ts_inserir(tabelasimbolos *tabela, char *nome);
void ts_free(tabelasimbolos *tabela);

#endif