%{
#include "parser.tab.h"
%}

%option reentrant bison-bridge noyywrap
%option prefix="module_yy"
%option extra-type="module_yy_extra"


id     [a-zA-Z][a-zA-Z_0-9]*
int    [0-9]+
blank  [ \t]
string \"[^\"\n]*\"


%{
static void strbuf_init(strbuf *sb, int capacity);
static void strbuf_cleanup(strbuf *sb);
static void strbuf_append_buf(strbuf *sb, const char *b, const int len);
static void strbuf_append_char(strbuf *sb, const char c);
static void strbuf_ensure_capacity(strbuf *sb, int len);
static const char *strbuf_get_str(strbuf *sb);
static void strbuf_reset(strbuf *sb);

#define scan_errmsg(msg) _scan_errmsg(msg, &yyextra)
static int _scan_errmsg(const char *msg, const module_yy_extra *extra);
#define scan_errposition() _scan_errposition(yyextra.last_loc, &yyextra)
static int _scan_errposition(const int location, const module_yy_extra *extra);
extern int module_scanner_errmsg(const char *msg, core_yyscan_t *scanner);
extern int module_scanner_errposition(const int location, core_yyscan_t *scanner);
%}

%%

{blank}+   ;
[\n]+      ;

"("        return TOK_LPAREN;
")"        return TOK_RPAREN;

{int}      { yylval->NUMBER = atol(yytext); return NUMBER; }
{id}       { yylval->IDENTIFIER = yytext; return IDENTIFIER; }
{string}   { yylval->STRING = yytext; return STRING; }

<<EOF>>    return TOK_EOF;

%%

static void 
strbuf_init(strbuf *sb, int capacity)
{
    sb->buffer = malloc(capacity);
    sb->capacity = capacity;
    sb->length = 0;
}

static void 
strbuf_cleanup(strbuf *sb)
{
    if (sb->buffer)
        free(sb->buffer);
}

static void 
strbuf_append_buf(strbuf *sb, const char *b, const int len)
{
    strbuf_ensure_capacity(sb, sb->length + len);
    memcpy(sb->buffer + sb->length, b, len);
    sb->length += len;
}

static void 
strbuf_append_char(strbuf *sb, const char c)
{
    strbuf_ensure_capacity(sb, sb->length + 1);
    sb->buffer[sb->length] = c;
    sb->length += 1;
}

/*
 * len cannot be greater than MaxAllocSize because ReadCommand() reads
 * a message and places the message body in StringInfo.
 */
static void 
strbuf_ensure_capacity(strbuf *sb, int len)
{
    // consider additional 1 byte for the last '\0' character
    if (len < sb->capacity)
        return;

    do
    {
        sb->capacity *= 2;
    } while (sb->capacity <= len);

    sb->buffer = realloc(sb->buffer, sb->capacity);
}

static const char *
strbuf_get_str(strbuf *sb)
{
    sb->buffer[sb->length] = '\0';
    return sb->buffer;
}

static void 
strbuf_reset(strbuf *sb)
{
    sb->length = 0;
}

static int 
_scan_errmsg(const char *msg, const module_yy_extra *extra)
{
    const char *t = extra->scan_buf + extra->last_loc;

    if (t[0] == YY_END_OF_BUFFER_CHAR)
        return fprintf(stderr, "%s at end of input", msg);
    else
        return fprintf(stderr, "%s at or near \"%s\"", msg, t);
}

static int 
_scan_errposition(const int location, const module_yy_extra *extra)
{
    int pos;

    // no-op if location is unknown
    if (location < 0)
        return 0;

    // convert byte offset to number of characters
    pos = mblen(extra->scan_buf, location) + 1;

    return pos;
}

core_yyscan_t 
module_scanner_create(const char *s)
{
    unsigned long int len;
    char *buf;
    yyscan_t yyscanner;
    module_yy_extra extra;
    int ret;

    // The last two YY_END_OF_BUFFER_CHAR are required by flex.
    len = strlen(s);
    buf = malloc((len + 2) * sizeof(char));
    strncpy(buf, s, len);
    buf[len] = YY_END_OF_BUFFER_CHAR;
    buf[len + 1] = YY_END_OF_BUFFER_CHAR;

    ret = module_yylex_init(&yyscanner);
    if (ret)
        fprintf(stderr, "module_yylex_init() failed: %m");

    strbuf_init(&extra.literal_buf, 1024);
    extra.high_surrogate = 0;
    extra.start_cond = INITIAL;
    extra.scan_buf = buf;
    extra.last_loc = 0;

    module_yyset_extra(extra, yyscanner);
    module_yy_scan_buffer(buf, len + 2, yyscanner);
    return yyscanner;
}

void 
module_scanner_destroy(core_yyscan_t scanner)
{
    module_yy_extra extra;

    extra = module_yyget_extra(scanner);
    strbuf_cleanup(&extra.literal_buf);

    module_yylex_destroy(scanner);
}

int 
module_scanner_errmsg(const char *msg, core_yyscan_t *scanner)
{
    module_yy_extra extra;

    extra = module_yyget_extra(scanner);

    return _scan_errmsg(msg, &extra);
}

int 
module_scanner_errposition(const int location, core_yyscan_t *scanner)
{
    module_yy_extra extra;

    extra = module_yyget_extra(scanner);

    return _scan_errposition(location, &extra);
}
