#include "test.h"
#include "ast.h"

int main()
{
    char input[400] = "Match a,b return a.id  UNION"
                      " ~*select * from test*~ ";

    State *state = new_state_from_string(input);

    Filter(state);

    printf("\n--%s\n==%s\n", state->sqlstr, state->cypherstr);
    return 0;
}