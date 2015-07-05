%{
#include <stdio.h>
#include <string.h>

#define SYMBOL_TABLE_SIZE 50

extern int yylex();

//symbol table entry
typedef struct{
	char*  sval;
	double   tval;
}ident_t;

ident_t sym[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);
%}


%union
{
	long  tval;
	double fval;
	char* sval;
}

%destructor { free ($$); } <sval>

%type  <tval>	stateformula;
%type  <tval>   automata;
%type  <tval>   ltlformula;

%token <tval>	INTEGER
%token <fval>   REAL
%token <sval>	IDENTIFIER
%token <sval> 	COMPARATOR
%token DATA

%precedence  	UNTIL  
%right  	IMPLIES 
%precedence	OR 
%precedence 	AND
%precedence  	NEXT GLOBAL FUTURE
%precedence  	NOT

%% 

ltl_parser:
	ltl_parser statement  			
	| %empty  
	;

statement:
	automata	 			{ 
						printf("'automata' returns %ld \"%s\"\n\n",
							$1,
							$1 == 0 ? "false" : "true"); 
					}

	| IDENTIFIER '=' REAL ';'	{ 
						printf("set %s to %.2lf \n", $1, $3); 

						//update or add IDENTIFIER to symbol table 
						if( sym_lookup($1) == 0 ) {
							sym[ sym_index ].sval = $1;
							sym[ sym_index ].tval = $3;
							sym_index++;
						} else {	
							sym[ sym_lookup($1) ].tval = $3; 
						}
					}
	//accept token //pass off automata
	| DATA				{ 	
						int i;
						for(i = 1; i < sym_index; i++)
							free(sym[i].sval);
						YYACCEPT; 
					} 
	| ';'				{ ; }
	;

automata:
	ltlformula             {$$ = $1;}
	| automata AND automata { $$ = $1 && $3; }
	| automata OR automata { $$ = $1 || $3;}
	;

ltlformula:
	stateformula        { $$ = $1;}
	| NEXT ltlformula { $$ = $2;}
	| GLOBAL ltlformula { $$ = $2;}
	| FUTURE ltlformula { $$ = $2;}
	| ltlformula UNTIL ltlformula { $$ = $3;}
	| '(' ltlformula ')' {$$ = $2;}
	;

stateformula:
	IDENTIFIER		{	
					//check if identifier is not declared
					if(sym_lookup($1) == 0){
						fprintf(stderr, 
						"Parse error: variable '%s' not defined.\n", $1);
						YYERROR;
					} else { 
						$$ = sym[sym_lookup($1)].tval;
					}
					free($1);
				}
	| NOT stateformula 		{
					$$ = !$2; 
					printf("!%ld returns %ld\n", $2, $$);
				}
	| stateformula OR stateformula 		{
					$$ = $1 || $3; 
					printf("%ld || %ld returns %ld\n", $1, $3, $$);
				}
	| stateformula AND stateformula 	{
					$$ = $1 && $3; 
					printf("%ld && %ld returns %ld\n", $1, $3, $$);
				}
	| stateformula IMPLIES stateformula 	{
					$$ = !$1 || $3;
					printf("%ld -> %ld returns %ld\n", $1, $3, $$);
				}
	| IDENTIFIER COMPARATOR REAL	{

					double ident_val;
					//check if identifier is not declared
					if(sym_lookup($1) == 0){
						fprintf(stderr, 
						"Parse error: variable '%s' not defined.\n", $1);
						YYERROR;
					} else { 
						 ident_val = sym[sym_lookup($1)].tval;
					}

					if( strcmp($2, "<") == 0)
						$$ = ident_val < $3;
					if( strcmp($2, ">") == 0)
						$$ = ident_val > $3;
					if( strcmp($2, "<=") == 0)
						$$ = ident_val <= $3;
					if( strcmp($2, ">=") == 0)
						$$ = ident_val >= $3;
					if( (strcmp($2, "<->") == 0) || (strcmp($2, "==") == 0))
						$$ = ident_val == $3;
					printf("%s %s %.2lf returns %ld\n", $1, $2, $3, $$);

					free($1); 
					free($2);
				}
	| '(' stateformula ')'  	{ $$ = $2; }
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
