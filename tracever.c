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
extern char* sym_table[];

int main(int argc, char* argv[]) {

	if(argc < 2){
		fprintf(stderr, "Error: Not enough arguments\n");
		fprintf(stderr, "Format is: %s input_file\n", argv[0]);
		return -1;
	}
	FILE* data_file = fopen(argv[1], "r");
	if( !data_file ){
		fprintf(stderr, "Error opening input files\n");
		return -1;
	}

	//read first line of formula_file
	//TODO improve this (doesn't handle multiple lines)
	char linebuffer[BUFFER_SIZE];
	char* ptr = fgets(linebuffer, BUFFER_SIZE, data_file);
	while(*ptr++ != '\0'){
		if(*ptr == '\n'){
			puts("No formula entered.");
			return -1;
		}
		else if(!isspace(*ptr)) break;
	}
	//printf("LTL Formula> %s\n", linebuffer);

	//run parser 
	yy_switch_to_buffer(yy_scan_string(linebuffer));
	if(yyparse()){
		puts("Aborting.");
		return -1;
	}
	yypop_buffer_state();
	
	//read in input data using flex
	//WARNING! the file position indicator must be positioned
	//beyond where the LTL formula is located in the input file
	//this is currently being done by the code above
	//Be sure to change this when necessary
	yy_switch_to_buffer(yy_create_buffer(data_file, YY_BUF_SIZE));

	int sym_table_indices[MAX_PARAMS]; //index where param is in sym table
	int i, j, num_params;
	int yylex_retval = yylex();

	//read parameter names, find their index in the symbol table,
	//and put them in sym_table_indices
	for(num_params = 0; yylex_retval == PARAM && num_params < MAX_PARAMS; num_params++){
		sym_table_indices[num_params] = sym_lookup(yylval.sval);
		free(yylval.sval);
		yylex_retval = yylex();
	}
	
	//read trace values and put them in trace table
	for(i = 0; yylex_retval && i < MAX_INPUT_SIZE; i++){
		for(j = 0; j < num_params && yylex_retval == REAL; j++){
			trace_vals[i][sym_table_indices[j]] = yylval.fval;
			yylex_retval = yylex();
		}
	}

	//set n_max to number of positions
	n_max = i;

	//close data file and free flex stuff since we don't need it anymore
	fclose(data_file);
	yypop_buffer_state();
	yylex_destroy();

	//printf("Input length:   %-d\n", n_max);

	//finally, run DFS
	bool DFS_retval = DFS(final_automaton, 0, INT_MAX); 

	//printf("DFS calls made: %-ld\n\n", DFS_calls_made);
	//printf("Automaton returns ");
	//puts( DFS_retval ? "true" : "false" );

	//clean up
	delete_automaton(final_automaton);
	
	for(i = 1; i < sym_index; i++)
		free(sym_table[i]);


	return DFS_retval;
	//return 0;
}

