#ifndef GERADOR_CODIGO_H
#define GERADOR_CODIGO_H

#define ERRMSG_MALLOC_HEADER "Houve um erro ao tentar alocar memória para o código do header\n"
#define ERRMSG_MALLOC_CL "Não foi possível alocar espaço na memória para a lista de comandos\n"
#define ERRMSG_FOPEN_OUTFILE "Houve um erro ao tentar abrir o arquivo\n"
#define ERRMSG_FCLOSE_OUTFILE "Houve um erro ao fechar o arquivo de saída\n"

#define HEADER_AFTER_CLASS "\n.super java/lang/Object\n"                   \
                           ".method public <init>()V\n"                    \
                           "aload_0\n"                                     \
                           "invokenonvirtual java/lang/Object/<init>()V\n" \
                           "return\n"                                      \
                           ".end method\n"                                 \
                           ".method public static main([Ljava/lang/String;)V\n"
#define HEADER_CLASS ".class public "
#define FOOTER "return\n" \
               ".end method"

typedef struct _code_list
{
    char *code_string;
    struct _code_list *next;
} code_list;

void cl_insert_header(char *classname);
void cl_insert_footer();
void cl_insert(char *code);
void cl_clear();
void cl_write(char *filename);

#endif