%option warn noyywrap reentrant prefix="shabi_yy"
%x COMMENT
%{
    #include "ast.h"
    #define YY_EXTRA_TYPE struct _State *
%}
%option outfile="test.c" header-file="test.h"
%%
"~*"            {BEGIN COMMENT;}
<COMMENT>"*~"   {BEGIN INITIAL;}
<COMMENT>.      {strcat(yyextra->sqlstr,yytext);}
.               {strcat(yyextra->cypherstr,yytext);}
%%

State *
new_state_from_stdin()
{
    State *state = (State *)malloc(sizeof(State));
    state->f = stdin;
    return state;
}

State *
new_state_from_file(const char *filename)
{
    State *state = (State *)malloc(sizeof(State));
    state->f = fopen(filename, "r");
    return state;
}

State *
new_state_from_string(char *src)
{
    State *state = (State *)malloc(sizeof(State));
    memset(state, 0, sizeof(State));
    state->f = fmemopen(src, strlen(src) + 1, "r");
    return state;
}

void Clean(State *state)
{
    if (state->f)
        fclose(state->f);
    if (state)
        free(state);
}

void Filter(State *state)
{
    if (shabi_yylex_init_extra(state, &state->scanner))
    {
        fprintf(stderr, "init alloc failed");
        fflush(stderr);
        exit(0);
    }

    shabi_yyset_in(state->f, state->scanner);
    shabi_yylex(state->scanner);
    shabi_yylex_destroy(state->scanner);
}
