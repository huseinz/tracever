/*
	Parameter Synthesis Trace Verifier

	Currently parses LTL formulas but will ignore LTL 
	operators and only evaluate the state portion.
*/

#include "lex.yy.h"

int main(int argc, char* argv[]) {
	
	yyin = argc > 1 ? fopen(argv[1], "r") : stdin;
	
	yyparse();

	fclose(yyin);

	return 0;
}

