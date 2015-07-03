/*
	Parameter Synthesis Trace Verifier

	Currently parses LTL formulas but will ignore LTL 
	operators and only evaluate the state portion.
*/

#include "lex.yy.h"

extern int yyparse();
extern int yydebug;

int main(int argc, char* argv[]) {

	if(YYDEBUG)
		yydebug = 1;

	yyin = argc > 1 ? fopen(argv[1], "r") : stdin;

	yyparse();

	fclose(yyin);

	return 0;
}

