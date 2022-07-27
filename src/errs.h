#ifndef ERRS_H
#define ERRS_H

#include <stdarg.h>

#define PRINT_BUFF_SIZE 2048

#define NORMAL_COLOR "\033[0m"
#define ERROR_COLOR "\033[0;31m"
#define LOCATION_COLOR "\033[0;36m"
#define WARNING_COLOR "\033[0;33m"
#define COLOR_RESET "\033[0m"

#define MSG_ONLY "%s\n"
#define MSG_SOURCE "%s: %s\n"
#define MSG_LOCATION "\tLinha: %d; Coluna: %d\n"

void reset_err_count();
int get_err_count();
void perr(char *errcolor, const char *format, ...);
void pwarn(char *errcolor, const char *format, ...);

#endif