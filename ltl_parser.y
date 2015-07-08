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
	long  tval;
	double fval;
	char* sval;
	struct Automaton* node;
}

%destructor { free ($$); } <sval>

%type  <node>   automaton;
%type  <node>   ltlformula;

%token <fval>   REAL
%token <sval>	IDENTIFIER
%token <sval> COMPARATOR

%precedence  	UNTIL  
%right  	IMPLIES 
%precedence	OR 
%precedence 	AND
%precedence  	GLOBAL 
%precedence     FUTURE
%precedence  	NOT

%% 

/*ltl_parser:
	ltl_parser statement  			
	| %empty  
	;*/

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
	ltlformula             	{	$$ = $1;
				}
	| automaton AND automaton {	/* generate AND_N node */
					Automaton* AND_node = create_node(AND_N, 0, $1, $3);
					$$ = AND_node;
					print_status("Created AND automaton node");
				}
	| automaton OR automaton { 	/* generate OR_N node */
					Automaton* OR_node = create_node(OR_N, 0, $1, $3);
					$$ = OR_node;
					print_status("Created OR automaton node");
				}
	;

ltlformula:
	
	IDENTIFIER		{	/* check if identifier is symbol table, add it if it isn't */
					if(sym_lookup($1) == 0){
						#ifdef VERBOSE
						 printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
					}
					
					/* generate IDENT_N node */
					Automaton* IDENT_node = create_node(IDENT_N, sym_lookup($1), NULL, NULL);
					IDENT_node->accepting = 1;
					$$ = IDENT_node;
					print_status("Created IDENTIFIER node");				
					free($1);
				}
	| GLOBAL ltlformula 	{ 	/* generate GLOBAL node */
					Automaton* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automaton* GLOBAL_node = create_node(AND_N, 0, TRUE_node, $2);
					TRUE_node->left = GLOBAL_node;
					TRUE_node->accepting = 1;
					GLOBAL_node->accepting = 1;
					$$ = GLOBAL_node;
					print_status("Created GLOBAL node");
				}
	| FUTURE ltlformula 	{ 	/* generate FUTURE node */
					Automaton* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automaton* FUTURE_node = create_node(OR_N, 0, TRUE_node, $2);
					TRUE_node->left = FUTURE_node;
					$$ = FUTURE_node;
					print_status("Created FUTURE ltlformula node");
				}
	| ltlformula UNTIL ltlformula { /* generate UNTIL node */
					Automaton* TRUE_node   = create_node(TRUE_N, 0, NULL, NULL);
					Automaton* UNTILB_node = create_node(AND_N, 0, $1, TRUE_node);
					Automaton* UNTIL_node  = create_node(OR_N, 0, $3, UNTILB_node);
					TRUE_node->left = UNTIL_node;
					UNTIL_node->accepting = 1;
					$$ = UNTIL_node;
					print_status("Created UNTIL ltlformula node");
				}

	| NOT ltlformula 	{	/* generate NOT_n node */
					Automaton* NOT_node = create_node(NOT_N, 0, $2, NULL);
					NOT_node->accepting = 1;
					$$ = NOT_node;
					print_status("Created NOT ltlformula node");
				}
	| ltlformula OR ltlformula {	/* generate OR_N node */ 
					Automaton* OR_node = create_node(OR_N, 0, $1, $3);
					$$ = OR_node;
					print_status("Created OR ltlformula node");
				}
	| ltlformula AND ltlformula {	/* generate AND_N node */ 
					Automaton* AND_node = create_node(AND_N, 0, $1, $3);
					$$ = AND_node;
					print_status("Created AND ltlformula node");
				}
	| ltlformula IMPLIES ltlformula { /* generate IMPLIES node */
					Automaton* IMPLIES_NOT_node = create_node(NOT_N, 0, $1, 0);
					Automaton* IMPLIES_node = create_node(OR_N, 0, IMPLIES_NOT_node, $3);
					$$ = IMPLIES_node;
					print_status("Created IMPLIES ltlformula node");
				}
	| IDENTIFIER COMPARATOR REAL {  /* generate COMPARATOR_N node */

					/* check if identifier is in symbol table, add it if it isn't */
					if(sym_lookup($1) == 0){
						#ifdef VERBOSE
						printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
					}
					
					Automaton* COMPARE_node = create_node(COMPARATOR_N, sym_lookup($1), NULL, NULL);
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
	| '(' ltlformula ')'  	{ 	/* parentheses */
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
