#include <stdlib.h>
#include <string.h>
#include "strlist.h"
#include "errs.h"

strlist *sl_malloc();
void sl_free(strlist *sl);
void assert_sl_not_null(strlist *sl);


strlist *sl_malloc(){
    strlist *new_strlist;
    if (!(new_strlist = (strlist *)malloc(sizeof(strlist)))){
        perr(ERROR_COLOR, ERRMSG_SL_MALLOC);
        exit(EXIT_FAILURE);
    }
    new_strlist->next = NULL;
    new_strlist->val = NULL;
    return new_strlist;
}


void sl_free(strlist* sl){
    assert_sl_not_null(sl);
    free(sl->val);
    free(sl);
}

void assert_sl_not_null(strlist *sl){
    if (!sl){
        perr(ERROR_COLOR, ERRMSG_SL_NULL);
        exit(EXIT_FAILURE);
    }
}

strlist *sl_insert(strlist *sl, char *val){
    strlist *new_strlist = sl_malloc();
    if (!(new_strlist->val = (char*)calloc(strlen(val), sizeof(char)))){
        perr(ERROR_COLOR, ERRMSG_SL_VAL_MALLOC);
        exit(EXIT_FAILURE);
    }
    strcpy(new_strlist->val, val);
    
    if (sl == NULL)
        return new_strlist;
    
    strlist *l = sl;
    while (l->next) l = l->next;
    l->next = new_strlist;
    return sl;
}

void sl_clear(strlist *sl){
    strlist *l = sl, *tmp;
    while(l){
        tmp = l;
        l = l->next;
        sl_free(tmp);
    }
}