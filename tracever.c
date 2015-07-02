#include "lex.yy.h"

int main(int argc, char* argv[]) {
	
	yyin = argc > 1 ? fopen(argv[1], "r") : stdin;

//	do {
		yyparse();
//	} while (!feof(yyin));

	fclose(yyin);

	return 0;
}

