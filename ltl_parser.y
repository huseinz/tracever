%{
#include "automata.h"

#define SYMBOL_TABLE_SIZE 50

extern int yylex();

char* sym[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);

%}


%union
{
	long  tval;
	double fval;
	char* sval;
	struct Automata* node;
}

%destructor { free ($$); } <sval>

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
	automata ';'	 	{ 
					final_automata = $1;
					puts("Created final automata\n");
					print_automata(final_automata);
					puts("\n");
					//delete_automata(final_automata);
				}
	| DATA			{ 	
					//pass off automata to something else
					YYACCEPT; 
				} 
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
	
	IDENTIFIER		{	
					//check if identifier is not declared
					//add if it is
					if(sym_lookup($1) == 0){
						printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						sym[ sym_index++ ] = strdup($1);
					}
					
					Automata* IDENT_node = create_node(IDENT_N, sym_lookup($1), NULL, NULL);
					IDENT_node->accepting = 1;
					$$ = IDENT_node;
					puts("Created IDENTIFIER node");				
					free($1);
				}
	| NEXT ltlformula 	{ 	$$ = $2;
					puts("'Created' NEXT node");
				}
	| GLOBAL ltlformula 	{ /*$$ = $2;*/
					Automata* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automata* GLOBAL_node = create_node(AND_N, 0, TRUE_node, $2);
					TRUE_node->left = GLOBAL_node;
					TRUE_node->accepting = 1;
					GLOBAL_node->accepting = 1;
					$$ = GLOBAL_node;
					puts("Created GLOBAL node");
				}
	| FUTURE ltlformula 	{ /*$$ = $2;*/
					Automata* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automata* FUTURE_node = create_node(OR_N, 0, TRUE_node, $2);
					TRUE_node->left = FUTURE_node;
					$$ = FUTURE_node;
					puts("Created FUTURE node");
				}
	| ltlformula UNTIL ltlformula { /*$$ = $3;*/
					Automata* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automata* UNTILB_node = create_node(AND_N, 0, TRUE_node, $1);
					Automata* UNTIL_node  = create_node(OR, 0, $3, UNTILB_node);
					TRUE_node->left = UNTIL_node;
					UNTIL_node->accepting = 1;
					$$ = UNTIL_node;
					puts("Created UNTIL node");
				}

	| NOT ltlformula 	{
					Automata* NOT_node = create_node(NOT_N, 0, $2, NULL);
					NOT_node->accepting = 1;
					$$ = NOT_node;
					puts("Created NOT node");
				}
	| ltlformula OR ltlformula 		{
					Automata* OR_node = create_node(OR_N, 0, $1, $3);
					$$ = OR_node;
					puts("Created OR ltlformula node");
				}
	| ltlformula AND ltlformula 	{
					Automata* AND_node = create_node(AND_N, 0, $1, $3);
					$$ = AND_node;
					puts("Created AND ltlformula node");
				}
	| ltlformula IMPLIES ltlformula 	{
					Automata* IMPLIES_NOT_node = create_node(NOT_N, 0, $1, 0);
					Automata* IMPLIES_node = create_node(OR_N, 0, IMPLIES_NOT_node, $3);
					$$ = IMPLIES_node;
					puts("Created IMPLIES ltlformula node");
				}
	| IDENTIFIER COMPARATOR REAL	{

					//check if identifier is not declared
					//add if it is
					if(sym_lookup($1) == 0){
						printf("Adding %s to symbol table\n", $1);
						sym[ sym_index++ ] = strdup($1);
					}
					
					Automata* COMPARE_node = create_node(COMPARATOR_N, sym_lookup($1), NULL, NULL);
					COMPARE_node->accepting = 1;
					COMPARE_node->comparison_val = $3;

					comparator_t comparator = EQUAL;

					if( strcmp($2, "<") == 0)
						comparator = LESS_THAN;	
					if( strcmp($2, ">") == 0)
						comparator = GTR_THAN;	
					if( strcmp($2, "<=") == 0)
						comparator = LESS_OR_EQ;	
					if( strcmp($2, ">=") == 0)
						comparator = GTR_OR_EQ;	
					if( (strcmp($2, "<->") == 0) || (strcmp($2, "==") == 0))
						comparator = EQUAL;	
					
					COMPARE_node->comparator = comparator;

					$$ = COMPARE_node;
					puts("Created COMPARE node");
					free($1);
					free($2);
				}
	| '(' ltlformula ')'  	{ $$ = $2; }
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
		if( sym[i] != NULL && strcmp(sym[i], str) == 0 )
			return i;
	}
	return 0;
}
