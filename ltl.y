%{
#include <stdio.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;

//#define YYDEBUG 1
void yyerror(const char* s);
int yylex(void);

char sym[50];
%}

%union{
	char  ival;
	char  tval;
	char* sval;
}

%token <ival> IDENTIFIER
%token <tval>  BOOL 
%left  IMPLIES "->"
%left  '&' '|'
%left  '!'

%type  <tval> expr;

%% 

ltl:
	ltl statement  			//{ printf("found statement\n"); }
	|
	;

statement:
	expr	 			{ printf("expression returns %s\n", $1 == 0 ? "false" : "true"); }
	| IDENTIFIER '=' BOOL ';'	{ printf("set %c to %s\n", $1 + 'a', $3 == 0 ? "false" : "true"); sym[$1] = $3;}
	;

expr:
	
	BOOL		{$$ = $1;}
	| IDENTIFIER	{$$ = sym[$1];}
	| '!' expr {$$ = !$2;}
	| expr '&' expr {$$ = $1 && $3;}
	| expr '|' expr {$$ = $1 || $3;}
	| expr IMPLIES expr {$$ = !$1 || $3;}
	| '(' expr ')'  {$$ = $2;}
	;

%%

int main(){

	//yydebug = 1;
	do{
		yyparse();
	} while (!feof(yyin));

	return 0;
}

void yyerror(const char* s){
	printf("Parse error: %s\n", s);
}
