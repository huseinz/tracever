%{
#include "automaton.h"

#define SYMBOL_TABLE_SIZE 50

extern int yylex();

char* sym[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);
void print_status(const char* str);

%}


%union
{
	double 	fval;
	char* 	sval;
	struct 	Automaton* node;
}

%destructor { free ($$); } <sval>

%type  <node>   automaton;

%token <fval>   REAL
%token <sval>	IDENTIFIER
%token <sval>	COMPARATOR

%precedence  	UNTIL  
%precedence	OR 
%precedence 	AND
%right  	IMPLIES 
%precedence  	GLOBAL 
%precedence     FUTURE
%precedence  	NOT

%% 

ltl_parser:
	automaton 	 	{
					/* automaton completed - set global pointer */
					final_automaton = $1;

				#ifdef VERBOSE
					puts("Created final automaton\n");
					puts("Printing automaton");
					print_automaton(final_automaton);
					puts("");
				#endif
					//delete_automaton(final_automaton);
				}
	;

automaton:
	
	IDENTIFIER		{	/* check if identifier is symbol table, add it if it isn't */
					if(sym_lookup($1) == 0){
						#ifdef VERBOSE
						 printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
					}
					
					/* generate IDENT_N node */
					Automaton* IDENT_node = create_node(IDENT_N, NULL, NULL);
					IDENT_node->var = sym_lookup($1);
					IDENT_node->accepting = 1;
					$$ = IDENT_node;
					print_status("Created IDENTIFIER node");				
					free($1);
				}
	| GLOBAL automaton 	{ 	/* generate GLOBAL node */
					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* GLOBAL_node = create_node(AND_N, TRUE_node, $2);
					TRUE_node->left = GLOBAL_node;
					TRUE_node->accepting = 1;
					GLOBAL_node->accepting = 1;
					$$ = GLOBAL_node;
					print_status("Created GLOBAL node");
				}
	| FUTURE automaton 	{ 	/* generate FUTURE node */
					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* FUTURE_node = create_node(OR_N, TRUE_node, $2);
					TRUE_node->left = FUTURE_node;
					$$ = FUTURE_node;
					print_status("Created FUTURE automaton node");
				}
	| automaton UNTIL automaton { /* generate UNTIL node */
					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* UNTILB_node = create_node(AND_N, TRUE_node, $1);
					Automaton* UNTIL_node  = create_node(OR_N, UNTILB_node, $3);
					TRUE_node->left = UNTIL_node;
					UNTIL_node->accepting = 1;
					$$ = UNTIL_node;
					print_status("Created UNTIL automaton node");
				}

	| NOT automaton 	{	/* generate NOT_n node */
					Automaton* NOT_node = create_node(NOT_N, $2, NULL);
					NOT_node->accepting = 1;
					$$ = NOT_node;
					print_status("Created NOT automaton node");
				}
	| automaton OR automaton {	/* generate OR_N node */ 
					Automaton* OR_node = create_node(OR_N, $1, $3);
					$$ = OR_node;
					print_status("Created OR automaton node");
				}
	| automaton AND automaton {	/* generate AND_N node */ 
					Automaton* AND_node = create_node(AND_N, $1, $3);
					$$ = AND_node;
					print_status("Created AND automaton node");
				}
	| automaton IMPLIES automaton { /* generate IMPLIES node */
					Automaton* IMPLIES_NOT_node = create_node(NOT_N, $1, NULL);
					Automaton* IMPLIES_node = create_node(OR_N, IMPLIES_NOT_node, $3);
					$$ = IMPLIES_node;
					print_status("Created IMPLIES automaton node");
				}
	| IDENTIFIER COMPARATOR REAL {  /* generate COMPARATOR_N node */

					/* check if identifier is in symbol table, add it if it isn't */
					if(sym_lookup($1) == 0){
						#ifdef VERBOSE
						printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
					}
					
					Automaton* COMPARE_node = create_node(COMPARATOR_N, NULL, NULL);
					COMPARE_node->var = sym_lookup($1);
					COMPARE_node->accepting = 1;
					COMPARE_node->comparison_val = $3;
					
					/* parse comparator */
					comparator_t comparator = EQUAL;

					if( strcmp($2, "<") == 0)
						comparator = LESS_THAN;	
					if( strcmp($2, ">") == 0)
						comparator = GTR_THAN;	
					if( strcmp($2, "<=") == 0)
						comparator = LESS_OR_EQ;	
					if( strcmp($2, ">=") == 0)
						comparator = GTR_OR_EQ;	
					if( strcmp($2, "==") == 0)
						comparator = EQUAL;	
					if( strcmp($2, "!=") == 0)
						comparator = NOT_EQUAL;
					
					COMPARE_node->comparator = comparator;

					$$ = COMPARE_node;
					print_status("Created COMPARE node");
					free($1);
					free($2);
				}
	| '(' automaton ')'  	{ 	/* parentheses */
					$$ = $2; 
				}
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

void print_status(const char* str){
#ifdef VERBOSE
	puts(str);
#endif
}
