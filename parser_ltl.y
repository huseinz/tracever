%{
#include "automaton.h"


#define SYMBOL_TABLE_SIZE 50

extern int yylex();

char* sym[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);
void print_status(const char* str);
void automaton_to_dot(Automaton* a, const char* fn);
void automaton_to_dot_aux(Automaton* a, FILE* out);

Automaton* generate_comparator_node(int var_a, 
				    const char* comp, 
				    int var_b, 
				    double val, 
				    bool invert);
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
%token <sval>	IDENT
%token <sval>	COMP

%right  	IMP 
%right		OR
%right		AND
%right  	UNTIL  
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
					automaton_to_dot(final_automaton, "automaton.dot");
					
					YYACCEPT;
				}
	;

automaton:
	
	IDENT		{	/* check if identifier is symbol table, add it if it isn't */
					if(sym_lookup($1) == 0){
						#ifdef VERBOSE
						 printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
					}
					
					/* generate IDENT_N node */
					Automaton* IDENT_node = create_node(IDENT_N, NULL, NULL);
					IDENT_node->var = sym_lookup($1);
					IDENT_node->accepting = true;
					$$ = IDENT_node;
					print_status("Created IDENT node");				
					free($1);
				}
	| GLOBAL automaton 	{ 	/* generate GLOBAL node */
					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* GLOBAL_node = create_node(AND_N, TRUE_node, $2);
					TRUE_node->left = GLOBAL_node;
					TRUE_node->accepting = true;
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
					Automaton* UNTILB_node = create_node(AND_N, $1, TRUE_node);
					Automaton* UNTIL_node  = create_node(OR_N, $3, UNTILB_node);
					TRUE_node->left = UNTIL_node;
					$$ = UNTIL_node;
					print_status("Created UNTIL automaton node");
				}

	| NOT automaton 	{	/* generate NOT_n node */
					Automaton* NOT_node = create_node(NOT_N, $2, NULL);
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
	| automaton IMP automaton { /* generate IMP node */
					Automaton* IMP_NOT_node = create_node(NOT_N, $1, NULL);
					Automaton* IMP_node = create_node(OR_N, IMP_NOT_node, $3);
					$$ = IMP_node;
					print_status("Created IMP automaton node");
				}
	| IDENT COMP REAL {  /* generate COMP_N node */
					
					/* check if identifier is in symbol table, add it if it isn't */
					int var_a = sym_lookup($1);
					if( var_a == 0){
						#ifdef VERBOSE
						printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
						var_a = sym_index - 1;
					}

					$$ = generate_comparator_node(var_a, $2, 0, $3, false);
					free($1);
					free($2);
				}
	| REAL COMP IDENT {  /* generate COMP_N node */
					
					/* check if identifier is in symbol table, add it if it isn't */
					int var_a = sym_lookup($3);
					if( var_a == 0){
						#ifdef VERBOSE
						printf("Adding %s to symbol table at position %d\n", $3, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($3);
						var_a = sym_index - 1;
					}

					$$ = generate_comparator_node(var_a, $2, 0, $1, true);
					free($2);
					free($3);
				}
	| IDENT COMP IDENT {  /* generate COMP_N node */
					
					/* check if identifier is in symbol table, add it if it isn't */
					int var_a = sym_lookup($1);
					if( var_a == 0){
						#ifdef VERBOSE
						printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($1);
						var_a = sym_index - 1;
					}

					int var_b = sym_lookup($3);
					if( var_b == 0){
						#ifdef VERBOSE
						printf("Adding %s to symbol table at position %d\n", $3, sym_index);
						#endif
						sym[ sym_index++ ] = strdup($3);
						var_b = sym_index - 1;
					}

					$$ = generate_comparator_node(var_a, $2, var_b, 0, false);
					free($1);
					free($2);
					free($3);
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

Automaton* generate_comparator_node(int var_a, const char* comp, int var_b, double val, bool invert){

	
	Automaton* COMPARE_node = create_node(COMP_N, NULL, NULL);
	COMPARE_node->var = var_a;
	COMPARE_node->var_b = var_b; 
	COMPARE_node->comparison_val = val;
	COMPARE_node->accepting = true;
	
	/* parse comparator */
	comparator_t comparator = EQUAL;
	
	if( strcmp(comp, "<") == 0)
		comparator = invert ? GTR_THAN : LESS_THAN;	
	else if( strcmp(comp, ">") == 0)
		comparator = invert ? LESS_THAN : GTR_THAN;	
	else if( strcmp(comp, "<=") == 0)
		comparator = invert ? GTR_OR_EQ : LESS_OR_EQ;	
	else if( strcmp(comp, ">=") == 0)
		comparator = invert ? LESS_OR_EQ : GTR_OR_EQ;	
	else if( strcmp(comp, "==") == 0)
		comparator = EQUAL;	
	else if( strcmp(comp, "!=") == 0)
		comparator = NOT_EQUAL;
	
	COMPARE_node->comparator = comparator;
	
	print_status("Created COMPARE node");
	return COMPARE_node;
}

void automaton_to_dot(Automaton* a, const char* fn){
	
	FILE* out = fopen(fn, "w");
	fprintf(out, "digraph Automaton{\n");
	
	automaton_to_dot_aux(a, out);

	fprintf(out, "}\n");
	fclose(out);
}

void automaton_to_dot_aux(Automaton* a, FILE* out){

	if(a->left){
		
		//arrow
		fprintf(out, "%d -> %d;\n", a->num, a->left->num);

		//label
		char buf[100];
		char* ptr = buf;

		ptr += sprintf(ptr, "%d [label=\"%s ", a->num, get_nodetype_literal(a));
		if(a->nodetype == IDENT_N)
			ptr += sprintf(ptr, "%s ", sym[a->var]);
		if(a->nodetype == COMP_N){
			ptr += sprintf(ptr, "%s ", sym[a->var]);
			ptr += a->var_b ? sprintf(ptr, "%s ", sym[a->var_b]) : sprintf(ptr, "%.2lf", a->comparison_val);
		}
		if(a->accepting)
			ptr += sprintf(ptr, "(*) "); 
		ptr += sprintf(ptr, "\"];\n");

		fprintf(out, "%s", buf);


		if(a->nodetype != TRUE_N){
			char buf[100];
			char* ptr = buf;

			ptr += sprintf(ptr, "%d [label=\"%s ", a->left->num, get_nodetype_literal(a->left));
			if(a->left->nodetype == IDENT_N)
				ptr += sprintf(ptr, "%s ", sym[a->left->var]);
			if(a->left->nodetype == COMP_N){
				ptr += sprintf(ptr, "%s ", sym[a->left->var]);
				ptr += a->left->var_b ? sprintf(ptr, "%s ", sym[a->left->var_b]) : sprintf(ptr, "%.2lf", a->left->comparison_val);
			}
			if(a->left->accepting)
				ptr += sprintf(ptr, "(*) "); 
			ptr += sprintf(ptr, "\"];\n");
	
			fprintf(out, "%s", buf);

			//recurse
			automaton_to_dot_aux(a->left, out);
		}
	}
	if(a->right){
		
		//arrow
		fprintf(out, "%d -> %d;\n", a->num, a->right->num);

		//label
		char buf[100];
		char* ptr = buf;

		ptr += sprintf(ptr, "%d [label=\"%s ", a->num, get_nodetype_literal(a));
		if(a->nodetype == IDENT_N)
			ptr += sprintf(ptr, "%s ", sym[a->var]);
		if(a->nodetype == COMP_N){
			ptr += sprintf(ptr, "%s ", sym[a->var]);
			ptr += a->var_b ? sprintf(ptr, "%s ", sym[a->var_b]) : sprintf(ptr, "%.2lf", a->comparison_val);
		}
		if(a->accepting)
			ptr += sprintf(ptr, "(*) "); 
		ptr += sprintf(ptr, "\"];\n");

		fprintf(out, "%s", buf);


		if(a->nodetype != TRUE_N){
			char buf[100];
			char* ptr = buf;

			ptr += sprintf(ptr, "%d [label=\"%s ", a->right->num, get_nodetype_literal(a->right));
			if(a->right->nodetype == IDENT_N)
				ptr += sprintf(ptr, "%s ", sym[a->right->var]);
			if(a->right->nodetype == COMP_N){
				ptr += sprintf(ptr, "%s ", sym[a->right->var]);
				ptr += a->right->var_b ? sprintf(ptr, "%s ", sym[a->right->var_b]) : sprintf(ptr, "%.2lf", a->right->comparison_val);
			}
			if(a->right->accepting)
				ptr += sprintf(ptr, "(*) "); 
			ptr += sprintf(ptr, "\"];\n");
	
			fprintf(out, "%s", buf);

			//recurse
			automaton_to_dot_aux(a->right, out);
		}
	}
}

