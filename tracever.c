/*
	Parameter Synthesis Trace Verifier

	the code in this file is atrocious
*/

#include "automata.h"
#include "lex.yy.h"

#define BUFFER_SIZE 1000

extern int yyparse();
extern int yydebug;
extern int sym_lookup(const char* str);
extern int sym_index;

int main(int argc, char* argv[]) {

#ifdef YYDEBUG
	yydebug = 1;
#endif
//	yyin = argc > 1 ? fopen(argv[1], "r") : stdin;

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
	char ltlbuffer[BUFFER_SIZE];
	ltlbuffer[BUFFER_SIZE-1] = '\0';
	ltlbuffer[BUFFER_SIZE-2] = '\0';
	char* ptr = fgets(ltlbuffer, BUFFER_SIZE, data_file);

	/* run parser */
	printf("LTL Formula: %s\n", ltlbuffer);
	yy_scan_string(ltlbuffer);
	yyparse();
	yypop_buffer_state();

	/* warning */
	/* no error checking from this point on */

	int sym_table_indices[MAX_PARAMS]; //where each var is in sym table
	int i = 0, j;
	char linebuffer[BUFFER_SIZE];
	ptr = fgets(linebuffer, BUFFER_SIZE, data_file);

	//find index in sym table where each var is defined
	ptr = strtok(linebuffer, " ,\t\n");
	sym_table_indices[0] = sym_lookup(ptr);
#ifdef VERBOSE
	puts("\nBegin reading input");
	printf("Found %s at position %d in symbol table\n", ptr, sym_table_indices[i]);
#endif
	for(i = 1; i < MAX_PARAMS; i++){
		ptr = strtok(NULL, " ,\t\n");
		if(!ptr)
			break;
		sym_table_indices[i] = sym_lookup(ptr);
#ifdef VERBOSE
		printf("Found %s at position %d in symbol table\n", ptr, sym_table_indices[i]);
#endif
	}
	int read_params = i;
	for(i = 0; i < MAX_INPUT_SIZE && !feof(data_file) && !ferror(data_file); i++){
		int fscanf_retval = 0;
		for(j = 0; j < read_params ; j++){
			fscanf_retval = fscanf(data_file, "%lG", &sym_vals[i][sym_table_indices[j]]);
			if(fscanf_retval != 1)
				break;
#ifdef VERBOSE
			printf("%20.10lf", sym_vals[i][sym_table_indices[j]]);
#endif
		}
		if(fscanf_retval != 1)
			break;
#ifdef VERBOSE
		puts("");
#endif
	}
	
	//important, set nmax to number of input traces + 1
	n_max = i ;

#ifdef VERBOSE
	printf("n_max is %d\n", n_max);
	puts("\nBegin DFS");
#endif
	//finally
	printf("Automata returns %s\n", DFS(final_automata, 0) ? "true" : "false");

#ifdef VERBOSE
	printf("DFS calls made: %ld\n", DFS_calls_made);
#endif
	delete_automata(final_automata);

	fclose(data_file);

	return 0;
}

