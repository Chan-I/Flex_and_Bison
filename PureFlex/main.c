#include "test.h"
#include "ast.h"

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
    state->f = fmemopen(src, strlen(src) + 1, "r");
    return state;
}

int main(int argc, char **argv)
{
    char input[400] = "This is my input string"
                      " ~*jalskdjflsdjf*~ slelect l;";

    State *state = new_state_from_string(input);

    if (shabi_yylex_init_extra(state, &state->scanner))
    {
        fprintf(stderr, "init alloc failed");
        fflush(stderr);
        return 1;
    }

    shabi_yyset_in(state->f, state->scanner);
    shabi_yylex(state->scanner);
    shabi_yylex_destroy(state->scanner);

    printf("\n--%s\n==%s\n", state->sqlstr, state->cypherstr);
    return 0;
}