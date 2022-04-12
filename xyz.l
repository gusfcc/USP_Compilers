%{
#include <stdlib.h>
#include "xyz.tab.h" 

extern int yyerror (char const *msg, ...);
%}
INCR                        [a-zA-Z][a-zA-Z_]*[\+][\+]
DECR                        [a-zA-Z][a-zA-Z_]*[\-][\-]
IDENTIFIER                  [a-zA-Z][a-zA-Z_]*
NUMBER                      [0-9]+
BLANK                       [ \t\r\n]

%option noyywrap nodefault yylineno

%%
{BLANK}                     { ; }
"return"                    { return RETURN; }
"fn"                        { return FN; }
"var"                       { return VAR; }
"if"                        { return IF; }
"else"                      { return ELSE; }
"while"                     { return WHILE; }
">="                        { return EQUAL_GREATER_THAN; }
"<="                        { return EQUAL_LESS_THAN; }
"=="                        { return EQUAL_THAN;}
"!="                        { return DIFFERENT_THAN;}
"&&"                        { return AND;}
"||"                        { return OR;}
[!\+*/%><(){}=;-]           { return yytext[0]; }
{DECR}                      { yylval.id = strdup(yytext); return DECR; }
{INCR}                      { yylval.id = strdup(yytext); return INCR; }
{IDENTIFIER}                { yylval.id = strdup(yytext); return IDENTIFIER; }
{NUMBER}                    { yylval.num = atoi(yytext); return NUMBER; }
.                           { yyerror("unknown token %s\n", yytext); }

%%