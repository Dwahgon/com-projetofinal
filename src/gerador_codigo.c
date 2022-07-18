#include "gerador_codigo.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

code_list *cl_malloc(char *code);
void cl_free(code_list *cl);

code_list *clist = NULL;

code_list *cl_malloc(char *code)
{
    code_list *cl = (code_list *)malloc(sizeof(code_list));
    if (!(cl = (code_list *)malloc(sizeof(code_list)))){
        fprintf(stderr, ERRMSG_MALLOC_CL);
        exit(1);
    }
    cl->code_string = (char *)calloc(strlen(code), sizeof(char));
    cl->next = NULL;
    strcpy(cl->code_string, code);
    return cl;
}

void cl_insert(char *code)
{
    code_list *cl = cl_malloc(code);
    if (!clist)
    {
        clist = cl;
        return;
    }

    code_list *l;
    for (l = clist; l->next != NULL; l = l->next)
        ;
    l->next = cl;
}

void cl_free(code_list *cl)
{
    free(cl->code_string);
    free(cl);
}

void cl_clear()
{
    code_list *tmp;
    while (clist != NULL)
    {
        tmp = clist;
        clist = clist->next;
        cl_free(tmp);
    }
}

void cl_insert_header(char *classname)
{
    char class[] = HEADER_CLASS;
    char after_class[] = HEADER_AFTER_CLASS;
    char *header;

    if (!(header = (char *)calloc(strlen(class) + strlen(classname) + strlen(after_class), sizeof(char)))){
        fprintf(stderr, ERRMSG_MALLOC_HEADER);
        exit(1);
    }

    strcat(header, class);
    strcat(header, classname);
    strcat(header, after_class);
    
    // printf("%s", header);
    
    cl_insert(header);
    
    free(header);
}

void cl_insert_footer(){
    cl_insert(FOOTER);
}

void cl_write(char *filename)
{

    FILE *file;
    if(!(file = fopen(filename, "w"))){
        fprintf(stderr, ERRMSG_FOPEN_OUTFILE);
        return;
    }

    for (code_list *l = clist; l; l=l->next){
        fprintf(file, "%s", l->code_string);
    }

    if (fclose(file)){
        fprintf(stderr, ERRMSG_FCLOSE_OUTFILE);
    }
}