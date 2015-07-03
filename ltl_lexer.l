%{
typedef struct{
	char* sval;
	long  tval;
}ident_t;

#include "ltl_parser.tab.h"
%}

%option noyywrap

%%

[ \t]			{ ; }
"X"		      	{ 					return NEXT; 		}
"U"		      	{ 					return UNTIL; 		}
"G"		      	{ 					return GLOBAL; 		}
"F"		      	{ 					return FUTURE; 		}
"true"    	      	{   yylval.tval = 1; 			return INTEGER; 	}
"false"		      	{   yylval.tval = 0; 			return INTEGER;		}
[a-zA-Z][a-zA-Z0-9_]* 	{   yylval.data.sval = strdup(yytext); 	return IDENTIFIER;	}
[0-9]*			{   yylval.tval      = strtol(yytext, NULL, 10); return INTEGER;} //make this safer
"->"		      	{   					return IMPLIES;		}
"<"		      	{ 					return LESS_THAN; 	}
">"		      	{ 					return GTR_THAN; 	}
">="		      	{ 					return GTR_OR_EQ; 	}
"<="		      	{ 					return LESS_OR_EQ; 	}
"|"|"||"	      	{    					return OR;		} 
"&"|"&&"	      	{   					return AND;		}
"!"		      	{   					return NOT;		}
"("		      	{   					return *yytext;		}
")"		      	{   					return *yytext;		}
"="		      	{   					return *yytext;		}
";"		      	{   					return *yytext;		}
\n 	      	      	{ ; } 
.		      	{ ; }

%%
