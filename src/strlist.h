#ifndef STRLIST_H
#define STRLIST_H

#define ERRMSG_SL_MALLOC "Houve um erro ao tentar alocar memória para a lista de strings\n"
#define ERRMSG_SL_VAL_MALLOC "Houve um erro ao tentar alocar memória para o valor da lista de strings\n"
#define ERRMSG_SL_NULL "Argumento sl foi passado como nulo\n"

typedef struct _strlist {
    char *val;
    struct _strlist *next;
} strlist;


strlist *sl_insert(strlist *sl, char *val);
void sl_clear(strlist *sl);

#endif