#ifndef GERADOR_CODIGO_H
#define GERADOR_CODIGO_H

#define ERRMSG_MALLOC_HEADER "Houve um erro ao tentar alocar memória para o código do header\n"
#define ERRMSG_MALLOC_CMDSTR "Houve um erro ao tentar alocar memória para um código\n"
#define ERRMSG_MALLOC_CL "Houve um erro ao tentar alocar espaço na memória para a lista de comandos\n"
#define ERRMSG_MALLOC_CLN "Houve um erro ao tentar alocar espaço na memória para um nó da lista de comandos"
#define ERRMSG_MALLOC_CLN_CODESTRING "Houve um erro ao tentar alocar espaço na memória para o texto de um comando"
#define ERRMSG_FOPEN_OUTFILE "Houve um erro ao tentar abrir o arquivo\n"
#define ERRMSG_FCLOSE_OUTFILE "Houve um erro ao fechar o arquivo de saída\n"
#define ERRMSG_INVOKEPRINT_INVALIDTYPE "cl_insert_invokeprint: argumento inválido para tipo. Valor passado: %d\n"
#define ERRMSG_CL_NULL "Argumento cl é um ponteiro nulo\n"
#define ERRMSG_CLN_NULL "Argumento cln é um ponteiro nulo\n"

#define CMD_BUFF_SIZE 4096

#define HEADER_AFTER_CLASS ".method public <init>()V\n"                         \
                           "aload_0\n"                                          \
                           "invokenonvirtual java/lang/Object/<init>()V\n"      \
                           "return\n"                                           \
                           ".end method\n"                                      \
                           ".method public static main([Ljava/lang/String;)V\n" \
                           ".limit locals 100\n"                                \
                           ".limit stack 100\n"
#define READ_FUNC ".method public static read()I\n"                       \
                  ".limit locals 10\n"                                    \
                  ".limit stack 10\n"                                     \
                  "ldc 0\n"                                               \
                  "istore 1\n"                                            \
                  "RFL1:\n"                                               \
                  "getstatic java/lang/System/in Ljava/io/InputStream;\n" \
                  "invokevirtual java/io/InputStream/read()I\n"           \
                  "istore 2\n"                                            \
                  "iload 2\n"                                             \
                  "ldc 10\n"                                              \
                  "isub\n"                                                \
                  "ifeq RFL2\n"                                           \
                  "iload 2\n"                                             \
                  "ldc 32\n"                                              \
                  "isub\n"                                                \
                  "ifeq RFL2\n"                                           \
                  "iload 2\n"                                             \
                  "ldc 48\n"                                              \
                  "isub\n"                                                \
                  "ldc 10\n"                                              \
                  "iload 1\n"                                             \
                  "imul\n"                                                \
                  "iadd\n"                                                \
                  "istore 1\n"                                            \
                  "goto RFL1\n"                                           \
                  "RFL2:\n"                                               \
                  "iload 1\n"                                             \
                  "ireturn\n"                                             \
                  ".end method\n"
#define HEADER_CLASS ".class public %s\n" \
                     ".super java/lang/Object\n"
#define FOOTER "return\n" \
               ".end method"
#define BIPUSH "bipush "
#define LDC_S "ldc %s\n"
#define ISTORE "istore "
#define ICONST "iconst_%d\n"
#define ILOAD "iload "
#define IADD "iadd\n"
#define IMUL "imul\n"
#define IDIV "idiv\n"
#define ISUB "isub\n"
#define IOR "ior\n"
#define IAND "iand\n"
#define IFGT "ifgt "
#define IFLT "iflt "
#define IFGE "ifge "
#define IFLE "ifle "
#define IFNE "ifne "
#define IFEQ "ifeq "
#define IFCMPGT "if_icmpgt "
#define IFCMPLT "if_icmplt "
#define IFCMPGE "if_icmpge "
#define IFCMPLE "if_icmple "
#define IFCMPNE "if_icmpne "
#define IFCMPEQ "if_icmpeq "
#define GET_PRINT "getstatic java/lang/System/out Ljava/io/PrintStream;\n"
#define PRINT_STRING_ARG "Ljava/lang/String;"
#define PRINT_INT_ARG "I"
#define INVOKE_PRINT "invokevirtual java/io/PrintStream/print%s(%s)V\n"
#define INVOKE_READ "invokestatic %s.read()I \n"

#include "tabela_simbolos.h"

typedef enum _relops
{
    EQ,
    NEQ,
    LSS,
    GRT,
    LEQ,
    GEQ
} relops;

typedef struct _code_list_node
{
    char *code_string;
    struct _code_list_node *next;
} code_list_node;

typedef struct _code_list
{
    code_list_node *start;
    code_list_node *end;
} code_list;

code_list *cl_malloc();
void cl_insert_header(code_list *cl, char *classname);
void cl_insert_footer(code_list *cl);
void cl_insert_istore(code_list *cl, int var_id);
void cl_insert_bipush(code_list *cl, int value);
void cl_insert_ldc_string(code_list *cl, char *value);
void cl_insert_invokeprint(code_list *cl, tipo_simbolo tipo, int newline);
void cl_insert_invokeread(code_list *cl, char *class);
void cl_insert_iconst(code_list *cl, int value);
void cl_insert_iload(code_list *cl, int var_id);
void cl_insert_goto(code_list *cl, int label);
void cl_insert_lbl(code_list *cl, int label);
void cl_insert_if(code_list *cl, char *ifcom, int labelnum);
void cl_insert_oprel(code_list *cl, relops op);
void cl_insert(code_list *cl, char *code);
void cl_clear(code_list *cl);
void cl_free(code_list *cl);
void cl_write(code_list *cl, char *filename);
int generate_label();

#endif