#include <string.h>
#include <stdio.h>

int linha = 1;
int coluna = 1;

void nova_linha()
{
    ++linha;
    coluna = 1;
}

void avancar_coluna(char *token)
{
    // printf("%s\n", token);
    coluna += strlen(token);
}