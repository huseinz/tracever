%{
#include "automaton.h"


#define SYMBOL_TABLE_SIZE 200 //arbitrary

extern int yylex();

char* sym_table[SYMBOL_TABLE_SIZE];
int sym_index = 1;

void yyerror(const char* s);
int sym_lookup(const char* str);
void print_status(const char* str);
void automaton_to_dot(Automaton* a, const char* fn);
void automaton_to_dot_aux(Automaton* a, FILE* out);

%}


%union
{
	double 	fval;
	char* 	sval;
	struct 	Automaton* node;
}

%destructor { free ($$); } <sval>

%type  <node>   automaton
%type  <node>	term

%token <fval>   REAL
%token <sval>	PARAM

%right  	IMP 
%right		OR
%right		AND
%token  	UNTIL  
%token	  	GLOBAL 
%token   	FUTURE
%precedence  	NOT
%right <sval>   COMP
%right 		ADD_TOK SUB_TOK
%right		MUL_TOK DIV_TOK

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


	term			{
					$$ = $1;			
				}
	| NOT automaton	{	/* generate NOT_n node */
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
	| GLOBAL ':' REAL '(' automaton ')' 	{ 	/* generate GLOBAL node */
					if($3 < 0){
						yyerror("Negative number in bound");
						YYABORT;
					}

					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* GLOBAL_node = create_node(AND_N, TRUE_node, $5);
					TRUE_node->left = GLOBAL_node;
					TRUE_node->accepting = true;
					GLOBAL_node->bound = $3 ? $3 : INT_MAX;
					$$ = GLOBAL_node;
					print_status("Created GLOBAL node");
				}

	| FUTURE ':' REAL '(' automaton ')' 	{ 	/* generate FUTURE node */
					if($3 < 0){
						yyerror("Negative number in bound");
						YYABORT;
					}

					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* FUTURE_node = create_node(OR_N, TRUE_node, $5);
					TRUE_node->left = FUTURE_node;
					FUTURE_node->bound = $3 ? $3 : INT_MAX;
					$$ = FUTURE_node;
					print_status("Created FUTURE automaton node");
				}

	| '(' automaton ')' UNTIL ':' REAL '(' automaton ')' { /* generate UNTIL node */
					if($6 < 0){
						yyerror("Negative number in bound");
						YYABORT;
					}

					Automaton* TRUE_node   = create_node(TRUE_N, NULL, NULL);
					Automaton* UNTILB_node = create_node(AND_N, $2, TRUE_node);
					Automaton* UNTIL_node  = create_node(OR_N, $8, UNTILB_node);
					TRUE_node->left = UNTIL_node;
					UNTIL_node->bound = $6 ? $6 : INT_MAX;
					$$ = UNTIL_node;
					print_status("Created UNTIL automaton node");
				}

	| '(' automaton ')'  	{ 	/* parentheses */
					$$ = $2; 
				}
	;

term:
	PARAM		{		/* check if identifier is symbol table, add it if it isn't */
					if(sym_lookup($1) == 0){
						#ifdef VERBOSE
						 printf("Adding %s to symbol table at position %d\n", $1, sym_index);
						#endif
						sym_table[ sym_index++ ] = strdup($1);
					}
					
					/* generate PARAM_N node */
					Automaton* PARAM_node = create_node(PARAM_N, NULL, NULL);
					PARAM_node->var = sym_lookup($1);
					PARAM_node->accepting = true;
					$$ = PARAM_node;
					print_status("Created PARAM node");				
					free($1);
				}
	| REAL		{
					Automaton* CONST_node = create_node(CONST_N, NULL, NULL);

					CONST_node->constant = $1;

					$$ = CONST_node;
			}
	| term COMP term {
					Automaton* OPER_node = create_operator_node($2, $1, $3);
					$$ = OPER_node;
					free($2);
			}
	| term ADD_TOK term {
					Automaton* OPER_node = create_operator_node("+", $1, $3);
					$$ = OPER_node;
			}
	| term SUB_TOK term {
					Automaton* OPER_node = create_operator_node("-", $1, $3);
					$$ = OPER_node;
			}
	| term MUL_TOK term {
					Automaton* OPER_node = create_operator_node("*", $1, $3);
					$$ = OPER_node;
			}
	| term DIV_TOK term {
					Automaton* OPER_node = create_operator_node("/", $1, $3);
					$$ = OPER_node;
			}
	| '(' term ')' {
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
		if( sym_table[i] != NULL && strcmp(sym_table[i], str) == 0 )
			return i;
	}
	return 0;
}

void print_status(const char* str){
#ifdef VERBOSE
	puts(str);
#endif
}


void automaton_to_dot(Automaton* a, const char* fn){
	
	FILE* out = fopen(fn, "w");
	fprintf(out, "digraph Automaton{\n");
	
	automaton_to_dot_aux(a, out);

	fprintf(out, "}\n");
	fclose(out);
}

void automaton_to_dot_aux(Automaton* a, FILE* out){

/*	if(a->left){
		
		//arrow
		fprintf(out, "%d -> %d;\n", a->num, a->left->num);

		//label
		char buf[100];
		char* ptr = buf;

		ptr += sprintf(ptr, "%d [label=\"%s ", a->num, get_nodetype_literal(a));
		if(a->nodetype == PARAM_N)
			ptr += sprintf(ptr, "%s ", sym_table[a->var]);
		if(a->nodetype == COMP_N){
			ptr += sprintf(ptr, "%s ", sym_table[a->var]);
			ptr += a->var_b ? sprintf(ptr, "%s ", sym_table[a->var_b]) : sprintf(ptr, "%.2lf", a->comparison_val);
		}
		if(a->accepting)
			ptr += sprintf(ptr, "(*) "); 
		ptr += sprintf(ptr, "\"];\n");

		fprintf(out, "%s", buf);


		if(a->nodetype != TRUE_N){
			char buf[100];
			char* ptr = buf;

			ptr += sprintf(ptr, "%d [label=\"%s ", a->left->num, get_nodetype_literal(a->left));
			if(a->left->nodetype == PARAM_N)
				ptr += sprintf(ptr, "%s ", sym_table[a->left->var]);
			if(a->left->nodetype == COMP_N){
				ptr += sprintf(ptr, "%s ", sym_table[a->left->var]);
				ptr += a->left->var_b ? sprintf(ptr, "%s ", sym_table[a->left->var_b]) : sprintf(ptr, "%.2lf", a->left->comparison_val);
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
		if(a->nodetype == PARAM_N)
			ptr += sprintf(ptr, "%s ", sym_table[a->var]);
		if(a->nodetype == COMP_N){
			ptr += sprintf(ptr, "%s ", sym_table[a->var]);
			ptr += a->var_b ? sprintf(ptr, "%s ", sym_table[a->var_b]) : sprintf(ptr, "%.2lf", a->comparison_val);
		}
		if(a->accepting)
			ptr += sprintf(ptr, "(*) "); 
		ptr += sprintf(ptr, "\"];\n");

		fprintf(out, "%s", buf);


		if(a->nodetype != TRUE_N){
			char buf[100];
			char* ptr = buf;

			ptr += sprintf(ptr, "%d [label=\"%s ", a->right->num, get_nodetype_literal(a->right));
			if(a->right->nodetype == PARAM_N)
				ptr += sprintf(ptr, "%s ", sym_table[a->right->var]);
			if(a->right->nodetype == COMP_N){
				ptr += sprintf(ptr, "%s ", sym_table[a->right->var]);
				ptr += a->right->var_b ? sprintf(ptr, "%s ", sym_table[a->right->var_b]) : sprintf(ptr, "%.2lf", a->right->comparison_val);
			}
			if(a->right->accepting)
				ptr += sprintf(ptr, "(*) "); 
			ptr += sprintf(ptr, "\"];\n");
	
			fprintf(out, "%s", buf);

			//recurse
			automaton_to_dot_aux(a->right, out);
		}
	}*/
}

