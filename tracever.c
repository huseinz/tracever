/*
	Parameter Synthesis Trace Verifier

	the code in this file is atrocious
*/

#include "automaton.h"
#include "lex_ltl.yy.h"
#include "parser_ltl.tab.h"
#include <ctype.h>

#define BUFFER_SIZE 1000

extern int yyparse();
extern void yyless(int n);
extern YYSTYPE yylval;
extern int sym_lookup(const char* str);
extern int sym_index;
extern char* sym[];

int main(int argc, char* argv[]) {

	if(argc < 2){
		fprintf(stderr, "Error: Not enough arguments\n");
		fprintf(stderr, "Format is: %s input_file\n", argv[0]);
		return 1;
	}
	FILE* data_file = fopen(argv[1], "r");
	if( !data_file ){
		fprintf(stderr, "Error opening input files\n");
		return 1;
	}

	//read first line of formula_file
	char linebuffer[BUFFER_SIZE];
	char* ptr = fgets(linebuffer, BUFFER_SIZE, data_file);
	while(*ptr != '\0'){
		if(*ptr == '\n'){
			puts("No formula entered.");
			return -1;
		}
		else if(!isspace(*ptr)) break;
		ptr++;
	}
	printf("LTL Formula: %s\n", linebuffer);

	/* run parser */
	yy_switch_to_buffer(yy_scan_string(linebuffer));
	if(yyparse() != 0){
		puts("Aborting.");
		return -1;
	}
	yypop_buffer_state();
	
	//read in input data using flex
	yy_switch_to_buffer(yy_create_buffer(data_file, YY_BUF_SIZE));

	int sym_table_indices[MAX_PARAMS]; //where each var is in sym table
	int i, j, num_params, yylex_retval = yylex();

	for(num_params = 0; yylex_retval == IDENTIFIER && num_params < MAX_PARAMS; num_params++){
		sym_table_indices[num_params] = sym_lookup(yylval.sval);
		yylex_retval = yylex();
	}
	
	for(i = 0; yylex_retval && i < MAX_INPUT_SIZE; i++){
		for(j = 0; j < num_params && yylex_retval == REAL; j++){
			sym_vals[i][sym_table_indices[j]] = yylval.fval;
			yylex_retval = yylex();
		}
	}

	//important, set nmax to number of positions
	n_max = i;

	printf("Input length:   %-d\n", n_max);

	//finally
	bool DFS_retval = DFS(final_automaton, 0); 

	printf("DFS calls made: %-ld\n\n", DFS_calls_made);
	printf("Automaton returns ");
	puts( DFS_retval ? "true" : "false" );

	//clean up
	delete_automaton(final_automaton);
	
	for(i = 1; i < sym_index; i++)
		free(sym[i]);

	fclose(data_file);
	yypop_buffer_state();
	yylex_destroy();

	return 0;
}

