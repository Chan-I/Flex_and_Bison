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
;               {strcat(yyextra->cypherstr,yytext); return 0;}
.               {strcat(yyextra->cypherstr,yytext);} 
%%