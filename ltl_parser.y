%{
#include <stdio.h>
#include <string.h>

//#define YYDEBUG 1
#define SYMBOL_TABLE_SIZE 50

extern int yylex();

//symbol table entry
typedef struct{
	char* sval;
	long   tval;
}ident_t;

ident_t sym[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);
%}


%union
{
	long tval;
	ident_t data;
}

%type  <tval> expr;

%token <data>  IDENTIFIER
%token <tval>  INTEGER

%left  IMPLIES 
%left  NEXT UNTIL GLOBAL FUTURE
%left  AND OR
%left  LESS_THAN GTR_THAN GTR_OR_EQ LESS_OR_EQ EQUALS
%left  NOT

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
					//update or add IDENTIFIER to symbol table 
					$1.tval = $3; 
					if( sym_lookup($1.sval) == 0 ) 
						sym[ sym_index++ ] = $1;
					else	
						sym[ sym_lookup($1.sval) ].tval = $3; 
					}
	| ';'
	;

expr:
	
	INTEGER 			{$$ = $1;}
	| IDENTIFIER			{$$ = sym[ sym_lookup($1.sval) ].tval;}
	| NOT expr 			{$$ = !$2;}
	| NEXT expr			{$$ = $2;}
	| UNTIL expr			{$$ = $2;}
	| GLOBAL expr			{$$ = $2;}
	| FUTURE  expr			{$$ = $2;} 
	| expr IMPLIES expr 		{$$ = !$1 || $3;}
	| expr AND expr 		{$$ = $1 && $3;}
	| expr OR expr 			{$$ = $1 || $3;}
	| '(' expr ')'  		{$$ = $2;}
	;

%%

void yyerror(const char* s){
	printf("Parse error: %s\n", s);
}

//TODO implement this as a hash table or something better
int sym_lookup(const char* str){
	int i;
	if( str == NULL )
		return 0;
	for( i = 1; i < SYMBOL_TABLE_SIZE; i++){
		if( sym[i].sval != NULL && strcmp(sym[i].sval, str) == 0 )
			return i;
	}
	return 0;
}
