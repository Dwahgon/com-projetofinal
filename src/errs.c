#include <stdio.h>
#include "errs.h"

int errcount = 0;

void reset_err_count()
{
    errcount = 0;
}

int get_err_count()
{
    return errcount;
}

void perr(char *errcolor, const char *format, ...)
{
    va_list valist;
    va_start(valist, format);
    fprintf(stderr, errcolor);
    vfprintf(stderr, format, valist);
    fprintf(stderr, COLOR_RESET);
    va_end(valist);
    errcount++;
}