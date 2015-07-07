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

	if(argc < 3){
		fprintf(stderr, "Error: Not enough arguments\n");
		fprintf(stderr, "Format is: %s formula_file data_file\n", argv[0]);
		return 1;
	}
	FILE* formula_file = fopen(argv[1], "r");
	FILE* data_file   = fopen(argv[2], "r");
	if( !formula_file || !data_file ){
		fprintf(stderr, "Error opening input files\n");
		return 1;
	}

	//read first line of formula_file
	char ltlbuffer[BUFFER_SIZE];
	ltlbuffer[BUFFER_SIZE-1] = '\0';
	ltlbuffer[BUFFER_SIZE-2] = '\0';
	char* ptr = fgets(ltlbuffer, BUFFER_SIZE, formula_file);

	/* run parser */
	printf("LTL Formula: %s\n", ltlbuffer);
	yy_scan_string(ltlbuffer);
	yyparse();
	yypop_buffer_state();

	/* warning */
	/* no error checking from this point on */

	int sym_table_indices[BUFFER_SIZE]; //where each var is in sym table
	int i = 0, j;
	char linebuffer[BUFFER_SIZE];
	ptr = fgets(linebuffer, BUFFER_SIZE, data_file);

	//find index in sym table where each var is defined
	ptr = strtok(linebuffer, " ,\t\n");
	sym_table_indices[i] = sym_lookup(ptr);
#ifdef VERBOSE
	puts("\nBegin reading input");
	printf("Found %s at position %d in symbol table\n", ptr, sym_table_indices[i]);
#endif
	for(i = 1; i < sym_index - 1; i++){
		ptr = strtok(NULL, " ,\t\n");
		sym_table_indices[i] = sym_lookup(ptr);
#ifdef VERBOSE
		printf("Found %s at position %d in symbol table\n", ptr, sym_table_indices[i]);
#endif
	}
	for(i = 0; fgets(linebuffer, BUFFER_SIZE, data_file) != NULL; i++){
		ptr = strtok(linebuffer, " ,\t\n");

		if(!ptr) 
			break;

		sym_vals[i][sym_table_indices[0]] = strtod(ptr, NULL);

#ifdef VERBOSE
		printf("%12.3lf", sym_vals[i][sym_table_indices[0]]);
#endif
		for(j = 1; j < sym_index -1; j++){
			ptr = strtok(NULL, " ,\t\n");
			if(!ptr) 
				break;
			sym_vals[i][sym_table_indices[j]] = strtod(ptr, NULL);
#ifdef VERBOSE
			printf("%12.3lf", sym_vals[i][sym_table_indices[j]]);
#endif

		}
#ifdef VERBOSE
		puts("");
#endif
	}
	
	//important, set nmax to number of input traces + 1
	n_max = i;

#ifdef VERBOSE
	printf("n_max is %d\n", n_max);
	puts("\nBegin DFS");
#endif
	//finally
	printf("\nAutomata returns %s\n", DFS(final_automata, 0) ? "true" : "false");
	
	delete_automata(final_automata);

	fclose(formula_file);
	fclose(data_file);

	return 0;
}

