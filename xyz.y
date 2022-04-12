%{
/* Definicoes e declaracoes para analise lexica */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

/* flex */
extern int yylineno;

extern int yyerror (char const *msg, ...);
extern int yylex();

/* 
  To debug, uncomment and run 
  bison --verbose --debug -d file.y 
*/
int yydebug = 1;

%}

/* bison: declaracoes */
%union {
        int num;
        char* id;
}
%token <num> NUMBER
%token <id> IDENTIFIER
%token <id> INCR
%token <id> DECR
%token RETURN FN VAR IF ELSE WHILE
%token EQUAL_GREATER_THAN EQUAL_LESS_THAN EQUAL_THAN DIFFERENT_THAN AND OR
%left   '+' '-'
%left   '*' '/'
%right  NEG


/* Gramatica */
%%

/* Whole Program */
prog        :   func
            |   func prog
            ;

/* Function */            
func        :   FN IDENTIFIER '(' param ')' '{' decl body '}'

/* Return */
return      :   RETURN expr ';'

/* Function Parameters */
param       :   IDENTIFIER ',' param
            |   IDENTIFIER
            |   /* vazio */
            ;

/* Declaration */
decl        :   VAR assign_list
            |   /* vazio */
            ;    


/* Assignment List */
assign_list :   assign assign_list
            |   assign
            ;
/* Assignment */
assign      :   IDENTIFIER '=' expr ';'
            ;

/* Expression */
expr        :   expr '+' expr
            |   expr '-' expr
            |   expr '*' expr
            |   expr '/' expr
            |   '(' expr ')'
            |   '-' expr %prec NEG
            |   NUMBER
            |   IDENTIFIER
            |   called_func
            ;

/* Called Function*/
called_func :   IDENTIFIER '(' call_param ')'
            ;

/* Parameter From Called Function */
call_param  :   expr ',' call_param
            |   expr
            |
            ;

/* Function or Loop/Condition body */
body        :   statem body
            |   statem
            |   /* vazio */
            ;

/* Statement */
statem      :   assign_list
            |   incre
            |   decre
            |   condition
            |   loop
            |   called_func
            |   return    
            ;

/* Condition */
condition   :   IF cond_expr '{' body '}'    
            |   IF cond_expr '{' body '}' ELSE '{' body '}'                                   
            ;
/* Loop */
loop        :   WHILE cond_expr '{' body '}'
            ;

/* Condition Expression */
cond_expr   :   '!' cond_expr
            |   cond_expr OR cond_expr
            |   cond_expr AND cond_expr
            |   expr EQUAL_GREATER_THAN expr
            |   expr EQUAL_LESS_THAN expr
            |   expr DIFFERENT_THAN expr
            |   expr EQUAL_THAN expr
            |   expr '<' expr
            |   expr '>' expr
            ;

/* Increment (++) */
incre       :   INCR ';'
            ;

/* Decrement (--) */
decre       :   DECR ';'
            ;  

%%

#include "lex.yy.c"

int yyerror(const char *msg, ...) {
	va_list args;

	va_start(args, msg);
	vfprintf(stderr, msg, args);
	va_end(args);

	exit(EXIT_FAILURE);
}


int main (int argc, char **argv) {
        FILE *fp;
        int i;
        struct symtab *p;

        if (argc <= 0) //Test args
                yyerror("usage: %s file\n", argv[0]);

        fp = fopen(argv[1], "r");   //Open file
        if (!fp)
                yyerror("error: could not open %s.\n", argv[1]);

        yyin = fp;
        do { //Read file
                yyparse();
        } while(!feof(yyin));      

        return EXIT_SUCCESS;
}