#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "tabela_simbolos.h"

tabelasimbolos *tabela;

void ts_inserir_simbolo(tabelasimbolos *tabela, simbolo *dados);

tabelasimbolos *ts_malloc()
{
    tabelasimbolos *novatabela = (tabelasimbolos *)malloc(sizeof(tabelasimbolos));
    novatabela->prim = NULL;
    novatabela->ult = NULL;
    return novatabela;
}

void ts_inserir(tabelasimbolos *tabela, char *nome)
{
    char *nomecp = (char *)malloc(sizeof(char) * strlen(nome));
    strcpy(nomecp, nome);

    ts_inserir_simbolo(tabela, &(simbolo){nomecp});
}

void ts_inserir_simbolo(tabelasimbolos *tabela, simbolo *simb)
{
    if (tabela == NULL)
        return;

    linhatabelasimbolos *novalinha;

    novalinha = (linhatabelasimbolos *)malloc(sizeof(linhatabelasimbolos));
    novalinha->simb = *simb;
    novalinha->prox = NULL;
    novalinha->ant = NULL;

    if (tabela->prim == NULL)
    {
        tabela->prim = novalinha;
        tabela->ult = novalinha;
        return;
    }

    tabela->ult->prox = novalinha;
    novalinha->ant = tabela->ult;
    tabela->ult = novalinha;
}

void ts_free(tabelasimbolos *tabela)
{
    if (tabela == NULL)
        return;

    linhatabelasimbolos *linha = tabela->prim, *del;
    while (linha != NULL)
    {
        del = linha;
        linha = linha->prox;
        free(del->simb.nome);
        free(del);
    }
    free(tabela);
}
