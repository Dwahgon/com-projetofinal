#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "tabela_simbolos.h"

int symbol_id = 0;

void ts_inserir_simbolo(tabelasimbolos *ts, simbolo *dados);
void ts_assert_not_null(tabelasimbolos *ts);
void lts_assert_not_null(linhatabelasimbolos *lts);
void lts_free(linhatabelasimbolos *lts);

tabelasimbolos *ts_malloc()
{
    tabelasimbolos *novatabela;
    if (!(novatabela = (tabelasimbolos *)malloc(sizeof(tabelasimbolos))))
    {
        fprintf(stderr, ERRMSG_MALLOC_TS);
        exit(EXIT_FAILURE);
    }
    novatabela->prim = NULL;
    novatabela->ult = NULL;
    return novatabela;
}

int ts_inserir(tabelasimbolos *ts, char *nome, tipo_simbolo tipo, funcao_simbolo funcao)
{
    ts_assert_not_null(ts);

    char *nomecp;
    int newsymbol_id = symbol_id++;
    if (!(nomecp = (char *)malloc(sizeof(char) * strlen(nome))))
    {
        fprintf(stderr, ERRMSG_MALLOC_TS_NAME);
        exit(EXIT_FAILURE);
    }
    strcpy(nomecp, nome);

    ts_inserir_simbolo(ts, &(simbolo){nomecp, newsymbol_id, tipo, funcao});

    return newsymbol_id;
}

simbolo *ts_find_symbol(tabelasimbolos *ts, char *name, funcao_simbolo funcao)
{
    ts_assert_not_null(ts);

    for (linhatabelasimbolos *lts = ts->prim; lts; lts = lts->prox)
    {
        if (strcmp(lts->simb.nome, name) == 0 && lts->simb.funcao == funcao)
            return &lts->simb;
    }
    return NULL;
}

void ts_inserir_simbolo(tabelasimbolos *ts, simbolo *simb)
{
    ts_assert_not_null(ts);

    linhatabelasimbolos *lts;
    if (!(lts = (linhatabelasimbolos *)malloc(sizeof(linhatabelasimbolos))))
    {
        fprintf(stderr, ERRMSG_MALLOC_LTS);
        exit(EXIT_FAILURE);
    }

    lts->simb = *simb;
    lts->prox = NULL;
    lts->ant = NULL;

    if (ts->prim == NULL)
    {
        ts->prim = lts;
        ts->ult = lts;
        return;
    }

    ts->ult->prox = lts;
    lts->ant = ts->ult;
    ts->ult = lts;
}

void lts_free(linhatabelasimbolos *lts)
{
    lts_assert_not_null(lts);
    free(lts->simb.nome);
    free(lts);
}

void ts_clear(tabelasimbolos *ts)
{
    ts_assert_not_null(ts);
    linhatabelasimbolos *linha = ts->prim, *del;
    while (linha != NULL)
    {
        del = linha;
        linha = linha->prox;
        lts_free(del);
    }
}

void ts_free(tabelasimbolos *ts)
{
    ts_assert_not_null(ts);
    ts_clear(ts);
    free(ts);
}

void ts_assert_not_null(tabelasimbolos *ts)
{
    if (!ts)
    {
        fprintf(stderr, ERRMSG_TS_NULL);
        exit(EXIT_FAILURE);
    }
}

void lts_assert_not_null(linhatabelasimbolos *lts)
{
    if (!lts)
    {
        fprintf(stderr, ERRMSG_LTS_NULL);
        exit(EXIT_FAILURE);
    }
}