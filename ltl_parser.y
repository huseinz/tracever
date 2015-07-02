%{
#include <stdio.h>
#include <string.h>

extern int   yylex();
extern int   yyparse();
extern FILE* yyin;

//#define YYDEBUG 1
#define SYMBOL_TABLE_SIZE 50

//symbol table entry
typedef struct{
	char* sval;
	char  tval;
}ident_t;

ident_t sym[SYMBOL_TABLE_SIZE];
int sym_index = 0;

void yyerror(const char* s);
int yylex(void);
int sym_lookup(const char* str);
%}


%union
{
	char tval;
	ident_t data;
}

%type  <tval> expr;

%token <data>  IDENTIFIER
%token <tval>  BOOL 
%left  IMPLIES 
%left  AND OR
%left  NOT '!'

%% 

ltl_parser:
	ltl_parser statement  			
	|
	;

statement:
	expr	 			{ 
					printf("expression returns %s\n", 
					$1 == 0 ? "false" : "true"); 
					}

	| IDENTIFIER '=' expr ';'	{ 
					printf("set %s to %s\n", 
					$1.sval, 
					$3 == 0 ? "false" : "true"); 
					$1.tval = $3; 
					sym[ sym_index++ ] = $1;
					}
	| ';'
	;

expr:
	
	BOOL				{$$ = $1;}
	| IDENTIFIER			{$$ = sym[ sym_lookup($1.sval) ].tval;}
	| '!' expr 			{$$ = !$2;}
	| expr AND expr 		{$$ = $1 && $3;}
	| expr OR expr 			{$$ = $1 || $3;}
	| expr IMPLIES expr 		{$$ = !$1 || $3;}
	| '(' expr ')'  		{$$ = $2;}
	;

%%

void yyerror(const char* s){
	printf("Parse error: %s\n", s);
}

int sym_lookup(const char* str){
	int i;
	for( i = 0; i < SYMBOL_TABLE_SIZE; i++){
		if( strcmp(sym[i].sval, str) == 0 )
			return i;
	}
	return 0;
}
