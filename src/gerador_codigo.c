#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "gerador_codigo.h"
#include "errs.h"

void cl_insert_formatted(code_list *cl, const char *formatstr, ...);
void cl_assert_not_null(code_list *cl);

code_list_node *cln_malloc(char *code);
void cln_assert_not_null(code_list_node *cln);
void cln_free(code_list_node *cln);
char symbtype_char(symbol_type *tipo);

int labelnum = 0;
char *class_name;

code_list *cl_malloc()
{
    code_list *cl;
    if (!(cl = (code_list *)malloc(sizeof(code_list))))
    {
        fprintf(stderr, ERRMSG_MALLOC_CL);
        exit(1);
    }
    cl->start = NULL;
    cl->end = NULL;
    return cl;
}

code_list_node *cln_malloc(char *code)
{
    code_list_node *cln;
    if (!(cln = (code_list_node *)malloc(sizeof(code_list_node))))
    {
        fprintf(stderr, ERRMSG_MALLOC_CLN);
        exit(1);
    }
    if (!(cln->code_string = (char *)calloc(strlen(code), sizeof(char))))
    {
        fprintf(stderr, ERRMSG_MALLOC_CLN_CODESTRING);
        exit(1);
    }
    strcpy(cln->code_string, code);
    cln->next = NULL;
    return cln;
}

void cl_insert(code_list *cl, char *code)
{
    cl_assert_not_null(cl);

    code_list_node *newcln = cln_malloc(code);
    if (!cl->start)
        cl->start = newcln;

    if (!cl->end)
    {
        cl->end = newcln;
        return;
    }

    cl->end->next = newcln;
    cl->end = newcln;
}

void cln_free(code_list_node *cln)
{
    cln_assert_not_null(cln);

    free(cln->code_string);
    free(cln);
}

void cl_clear(code_list *cl)
{
    cl_assert_not_null(cl);

    code_list_node *tmp, *l = cl->start;
    while (l != NULL)
    {
        tmp = l;
        l = l->next;
        cln_free(tmp);
    }
}

void cl_free(code_list *cl)
{
    cl_assert_not_null(cl);

    cl_clear(cl);
    free(cl);
}

void cl_insert_ldc_float(code_list *cl, float value)
{
    cl_insert_formatted(cl, LDC_F, value);
}

void cl_insert_ldc_string(code_list *cl, char *value)
{
    cl_insert_formatted(cl, LDC_S, value);
}

void cl_insert_header(code_list *cl, char *cn)
{
    class_name = cn;
    cl_insert_formatted(cl, HEADER_CLASS, cn);
    cl_insert_formatted(cl, "%s%s", READ_FUNC, HEADER_AFTER_CLASS);
}

void cl_insert_const(code_list *cl, int value, symbol_type type)
{
    if (value > (type.prim_type == FLUTUANTE ? 3 : 5) || value < 0)
    {
        fprintf(stderr, ERRMSG_ICONST_INVALID);
        return;
    }
    cl_insert_formatted(cl, CONST, symbtype_char(&type), value);
}

void cl_insert_lbl(code_list *cl, int label)
{
    cl_insert_formatted(cl, LABEL, label);
}

void cl_insert_footer(code_list *cl)
{
    cl_insert(cl, FOOTER);
}

void cl_insert_store(code_list *cl, tabelasimbolos *ts, char *var)
{
    simbolo *s;
    if (!(s = ts_find_symbol(ts, var)))
    {
        perr(ERROR_COLOR, ERRMSG_VARIABLE_NOT_DECLARED, var);
        return;
    }
    cl_insert_formatted(cl, STORE, symbtype_char(&s->type), s->id);
}

void cl_insert_bipush(code_list *cl, int value)
{
    cl_insert_formatted(cl, BIPUSH, value);
}

void cl_insert_if(code_list *cl, char *ifcom, int label)
{
    cl_insert_formatted(cl, "%sL%d\n", ifcom, label);
}

simbolo *cl_insert_load(code_list *cl, tabelasimbolos *ts, char *var)
{
    simbolo *s;
    if (!(s = ts_find_symbol(ts, var)))
    {
        perr(ERROR_COLOR, ERRMSG_VARIABLE_NOT_DECLARED, var);
        return NULL;
    }
    cl_insert_formatted(cl, LOAD, symbtype_char(&s->type), s->id);
    return s;
}

void cl_insert_pop(code_list *cl, int pop2)
{
    cl_insert_formatted(cl, POP, (pop2) ? "2" : "");
}

void cl_insert_goto(code_list *cl, int label)
{
    cl_insert_formatted(cl, GOTO, label);
}

void cl_insert_invokeprint(code_list *cl, primitive_type tipo, int newline)
{
    cl_assert_not_null(cl);

    switch (tipo)
    {
    case STRING:
        cl_insert_formatted(cl, INVOKE_PRINT, newline ? "ln" : "", PRINT_STRING_ARG);
        break;
    case BOOLEANA:
    case INTEIRO:
        cl_insert_formatted(cl, INVOKE_PRINT, newline ? "ln" : "", PRINT_INT_ARG);
        break;
    case FLUTUANTE:
        cl_insert_formatted(cl, INVOKE_PRINT, newline ? "ln" : "", PRINT_FLOAT_ARG);
        break;
    default:
        fprintf(stderr, ERRMSG_INVOKEPRINT_INVALIDTYPE, tipo);
        break; // TODO: print error
    }
}

void cl_insert_invokeread(code_list *cl)
{
    cl_insert_formatted(cl, INVOKE_READ, class_name);
}

void cl_insert_op(code_list *cl, primitive_type type1, primitive_type type2, char *op)
{
    if (type1 == type2)
        cl_insert_formatted(cl, "%c%s", symbtype_char(&(symbol_type){type1, 0}), op);
}

void cl_insert_oprel(code_list *cl, char *ifop)
{
    cl_assert_not_null(cl);

    int lbl1 = generate_label();
    int lbl2 = generate_label();
    cl_insert_formatted(cl, OPRELBODY, ifop, lbl1, lbl2, lbl1, lbl2);
}

void cl_declarations(code_list *cl, tabelasimbolos *ts, strlist *sl, symbol_type type)
{
    for (strlist *l = sl; l; l = l->next)
    {
        if (!ts_declare(ts, l->val, type))
            continue;

        cl_insert_const(cl, 0, type);
        cl_insert_store(cl, ts, l->val);
    }
    sl_clear(sl);
}

// void cl_insert_newarray(code_list *cl, primitive_type type){
//     switch(type){
//         case BOOLEANA:
//             cl_insert_formatted(cl, NEWARRAY, "boolean");
//             break;
//         case INTEIRO:
//             cl_insert_formatted(cl, NEWARRAY, "int");
//             break;
//         case FLUTUANTE:
//             cl_insert_formatted(cl, NEWARRAY, "float");
//             break;
//         default:
//             perr(ERROR_COLOR, ERRMSG_INVALID_TYPE, type);
//             break;
//     }
// }

void cl_write(code_list *cl, char *filename)
{
    cl_assert_not_null(cl);

    FILE *file;
    if (!(file = fopen(filename, "w")))
    {
        fprintf(stderr, ERRMSG_FOPEN_OUTFILE);
        return;
    }

    for (code_list_node *cln = cl->start; cln; cln = cln->next)
    {
        fprintf(file, "%s", cln->code_string);
    }

    if (fclose(file))
    {
        fprintf(stderr, ERRMSG_FCLOSE_OUTFILE);
    }
}

void cl_assert_not_null(code_list *cl)
{
    if (!cl)
    {
        fprintf(stderr, ERRMSG_CL_NULL);
        exit(1);
    }
}
void cln_assert_not_null(code_list_node *cln)
{
    if (!cln)
    {
        fprintf(stderr, ERRMSG_CLN_NULL);
        exit(1);
    }
}

void cl_insert_formatted(code_list *cl, const char *formatstr, ...)
{
    cl_assert_not_null(cl);

    char buff[CMD_BUFF_SIZE];
    va_list valist;

    va_start(valist, formatstr);
    vsnprintf(buff, CMD_BUFF_SIZE, formatstr, valist);
    va_end(valist);

    cl_insert(cl, buff);
}

char symbtype_char(symbol_type *tipo)
{
    if (tipo->isarray > 0)
        return 'i';

    switch (tipo->prim_type)
    {
    case BOOLEANA:
    case INTEIRO:
        return 'i';
    case FLUTUANTE:
        return 'f';
    default:
        fprintf(stderr, ERRMSG_INVALID_TYPE, tipo->prim_type);
        break;
    }
    return 'i';
}

int generate_label()
{
    return labelnum++;
}