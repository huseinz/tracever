/*
	Parameter Synthesis Trace Verifier
*/

#include "automata.h"
#include "lex.yy.h"

extern int yyparse();
extern int yydebug;
extern int sym_lookup(const char* str);
extern int sym_index;

/* the code in this file is terrible */
int main(int argc, char* argv[]) {

	if(YYDEBUG)
		yydebug = 1;

//	yyin = argc > 1 ? fopen(argv[1], "r") : stdin;
	char ltlbuffer[200];
	ltlbuffer[199] = '\0';
	ltlbuffer[198] = '\0';
	fgets(ltlbuffer, 200, stdin);
	yy_scan_string(ltlbuffer);
	yyparse();
	
	yypop_buffer_state();

	FILE* input = argc > 1 ? fopen(argv[1], "r") : stdin;
	
	int sym_table_indices[10]; //where each var is in sym table
	int i = 0, j;
	char linebuffer[100];
	fgets(linebuffer, 100, input);
	//find index in sym table where each var is defined
	sym_table_indices[i] = sym_lookup(strtok(linebuffer, " "));
	for(i = 1; i < sym_index - 1; i++){
		sym_table_indices[i] = sym_lookup(strtok(NULL, " \n"));
	}
	for(i = 0; fgets(linebuffer, 100, input) != NULL; i++){
		char* ptr = strtok(linebuffer, " \n");
		//puts(ptr);
		if(!ptr) break;

		sym_vals[i][sym_table_indices[0]] = strtod(ptr, NULL);
//		printf("%lf\n", strtod(ptr, NULL));

		for(j = 1; j < sym_index -1; j++){
			ptr = strtok(NULL, " \n");
			if(!ptr) break;
		//	puts(ptr);
			sym_vals[i+1][sym_table_indices[j]] = strtod(ptr, NULL);
//			printf("%lf\n", sym_vals[i+1][sym_table_indices[j]]);
		}
//		puts("");
	}
	
	n_max = i;

	//finally
	printf("Automata returns %s\n", DFS(final_automata, 0) ? "true" : "false");
	
	fclose(input);

	return 0;
}

