#ifndef ERRS_H
#define ERRS_H

#include <stdarg.h>

#define PRINT_BUFF_SIZE 2048

#define NORMAL_COLOR "\033[0m"
#define ERROR_COLOR "\033[0;31m"
#define WARNING_COLOR "\033[0;33m"
#define COLOR_RESET "\033[0m"

#define MSG_ONLY "%s\n"
#define MSG_SOURCE "%s: %s\n"
#define MSG_LINE_NUMB "%s\n" \
                      "\tLinha: %d\tColuna: %d\n"
#define MSG_SOURCE_LINE_NUM "%s: %s\n" \
                            "\tLinha: %d\tColuna: %d\n"

void reset_err_count();
int get_err_count();
void perr(char *errcolor, const char *format, ...);

#endif