#ifndef AST_H
#define AST_H
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdint.h>

typedef struct _State
{
    char sqlstr[8192];
    char cypherstr[8192];
    FILE *f;
    yyscan_t scanner; /* flex instance data */
} State;

extern State *new_state_from_stdin();
extern State *new_state_from_file(const char *filename);
extern State *new_state_from_string(char *src);
extern void Filter(State *state);

#endif /*STATE_H */