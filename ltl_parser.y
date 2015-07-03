%{
#include <stdio.h>
#include <string.h>

#define SYMBOL_TABLE_SIZE 50

extern int yylex();

//symbol table entry
typedef struct{
	char*  sval;
	long   tval;
}ident_t;

ident_t sym[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);
%}


%union
{
	long  tval;
	char* sval;
}

%type  <tval>	expr;

%token <tval>	INTEGER
%token <sval>	IDENTIFIER

%nonassoc  	UNTIL RELEASE 
%right  	IMPLIES 
%precedence	OR 
%precedence 	AND
%right  <sval> 	COMPARATOR
%precedence  	NEXT GLOBAL FUTURE
%precedence  	NOT

%start statement

%% 

/*ltl_parser:
	ltl_parser statement  			
	;*/

statement:
	expr	 			{ 
						printf("expression returns %ld \"%s\"\n\n",
							$1,
							$1 == 0 ? "false" : "true"); 
					}

	| IDENTIFIER '=' expr ';'	{ 
						printf("set %s to %ld \n", $1, $3); 

						//update or add IDENTIFIER to symbol table 
						if( sym_lookup($1) == 0 ) {
							sym[ sym_index ].sval = $1;
							sym[ sym_index ].tval = $3;
							sym_index++;
						} else {	
							sym[ sym_lookup($1) ].tval = $3; 
						}
					}
	| ';'
	;

	//TODO implement LTL ops 	
expr:
	INTEGER 		{$$ = $1;}
	| IDENTIFIER		{	
					//check if identifier is not declared
					if(sym_lookup($1) == 0){
						fprintf(stderr, 
						"Parse error: variable '%s' not defined.\n", $1);
						YYERROR;
					} else { 
						$$ = sym[sym_lookup($1)].tval;
					}
				}
	| NOT expr 		{$$ = !$2; printf("!%ld returns %ld\n", $2, $$);}
	| NEXT expr		{$$ = $2;}
	| GLOBAL expr		{$$ = $2;}
	| FUTURE  expr		{$$ = $2;} 
	| expr OR expr 		{$$ = $1 || $3; printf("%ld || %ld returns %ld\n", $1, $3, $$);}
	| expr AND expr 	{$$ = $1 && $3; printf("%ld && %ld returns %ld\n", $1, $3, $$);}
	| expr UNTIL expr	{$$ = $3;}
	| expr RELEASE expr	{$$ = $3;}
	| expr IMPLIES expr 	{$$ = !$1 || $3;printf("%ld -> %ld returns %ld\n", $1, $3, $$);}
	| expr COMPARATOR expr	{$$ = $3;}
	| '(' expr ')'  	{$$ = $2;}
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
