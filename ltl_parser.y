%{
#include <stdio.h>
#include <string.h>
#include "automata.h"

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

Automata* final_automata;
%}


%union
{
	long  tval;
	double fval;
	char* sval;
	struct Automata* node;
}

%destructor { free ($$); } <sval>

%type  <node>	stateformula;
%type  <node>   automata;
%type  <node>   ltlformula;

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
	automata	 	{ 
				/*	printf("'automata' returns %ld \"%s\"\n\n",
						$1,
						$1 == 0 ? "false" : "true"); */
					final_automata = $1;
					puts("Created final automata");
					puts("\n");
					print_automata(final_automata);
					puts("\n");
				}

	| IDENTIFIER '=' REAL ';'{ 
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
	| DATA			{ 	
					int i;
					for(i = 1; i < sym_index; i++)
						free(sym[i].sval);
					YYACCEPT; 
				} 
	| ';'			{ ; }
	;

automata:
	ltlformula             	{	$$ = $1;
				}
	| automata AND automata { /*$$ = $1 && $3;*/
					Automata* AND_node = create_node(AND_N, 0, $1, $3);
					$$ = AND_node;
					puts("Created AND Automata node");
				}
	| automata OR automata 	{ /*$$ = $1 || $3;*/
					Automata* OR_node = create_node(OR_N, 0, $1, $3);
					$$ = OR_node;
					puts("Created OR Automata node");
				}

	;

ltlformula:
	stateformula        	{ 	$$ = $1;
				}
	| NEXT ltlformula 	{ 	$$ = $2;
				}
	| GLOBAL ltlformula 	{ /*$$ = $2;*/
					Automata* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automata* GLOBAL_node = create_node(GLOBAL_N, 0, TRUE_node, $2);
					TRUE_node->left = GLOBAL_node;
					$$ = GLOBAL_node;
					puts("Created GLOBAL node");
				}
	| FUTURE ltlformula 	{ /*$$ = $2;*/
					Automata* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automata* FUTURE_node = create_node(FUTURE_N, 0, TRUE_node, $2);
					TRUE_node->left = FUTURE_node;
					$$ = FUTURE_node;
					puts("Created FUTURE node");
				}
	| ltlformula UNTIL ltlformula { /*$$ = $3;*/
					Automata* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automata* UNTILB_node = create_node(UNTILB_N, 0, TRUE_node, $1);
					Automata* UNTIL_node  = create_node(UNTILA_N, 0, $3, UNTILB_node);
					TRUE_node->left = UNTIL_node;
					$$ = UNTIL_node;
					puts("Created UNTIL node");
				}
	| '(' ltlformula ')' 	{	$$ = $2;
				}
	| '(' stateformula ')'  {	$$ = $2;
				}
	;

stateformula:
	IDENTIFIER		{	
					//check if identifier is not declared
					if(sym_lookup($1) == 0){
						fprintf(stderr, 
						"Parse error: variable '%s' not defined.\n", $1);
						YYERROR;
					} else { 
						Automata* IDENT_node = 
						create_node(IDENT_N, sym_lookup($1), NULL, NULL);
						$$ = IDENT_node;
						puts("Created IDENTIFIER node");
					}
					free($1);
				}
	| NOT stateformula 	{
					$$ = $2; 
//					printf("!%ld returns %ld\n", $2, $$);
				}
	| stateformula OR stateformula 		{
//					$$ = $1 || $3; 
//					printf("%ld || %ld returns %ld\n", $1, $3, $$);
					Automata* OR_node = create_node(OR_N, 0, $1, $3);
					$$ = OR_node;
					puts("Created OR stateformula node");
				}
	| stateformula AND stateformula 	{
//					$$ = $1 && $3; 
//					printf("%ld && %ld returns %ld\n", $1, $3, $$);
					Automata* AND_node = create_node(AND_N, 0, $1, $3);
					$$ = AND_node;
					puts("Created AND stateformula node");
				}
	| stateformula IMPLIES stateformula 	{
//					$$ = !$1 || $3;
//					printf("%ld -> %ld returns %ld\n", $1, $3, $$);
				}
	| IDENTIFIER COMPARATOR REAL	{

/*					double ident_val;
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
					printf("%s %s %.2lf returns %ld\n", $1, $2, $3, $$);*/

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
