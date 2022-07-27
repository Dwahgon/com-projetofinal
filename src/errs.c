#include <stdio.h>
#include "errs.h"
#include "contador_linha.h"

extern int linha;
extern int coluna;
int errcount = 0;

void reset_err_count()
{
    errcount = 0;
}

int get_err_count()
{
    return errcount;
}

void pformatted(char *errcolor, const char *format, ...)
{
    va_list valist;
    va_start(valist, format);
    fprintf(stderr, errcolor);
    vfprintf(stderr, format, valist);
    fprintf(stderr, COLOR_RESET);
    va_end(valist);
}

void pwarn(char *errcolor, const char *format, ...)
{
    va_list valist;
    va_start(valist, format);
    pformatted(errcolor, format, valist);
    va_end(valist);
    pformatted(LOCATION_COLOR, MSG_LOCATION, linha, coluna);
}

void perr(char *errcolor, const char *format, ...)
{
    va_list valist;
    va_start(valist, format);
    pformatted(errcolor, format, valist);
    va_end(valist);
    pformatted(LOCATION_COLOR, MSG_LOCATION, linha, coluna);
    errcount++;
}