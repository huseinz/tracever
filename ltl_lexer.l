%{
typedef struct{
	char* sval;
	char  tval;
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
"true"    	      	{   yylval.tval = 1; 			return VALUE; 		}
"false"		      	{   yylval.tval = 0; 			return VALUE;		}
[a-zA-Z][a-zA-Z0-9_]* 	{   yylval.data.sval = strdup(yytext); 	return IDENTIFIER;	}
[0-9]*			{   yylval.tval	     = strtol(yytext, NULL, 10); return VALUE;  }
"->"|"=>"	      	{   yylval.data.sval = strdup(yytext); 	return IMPLIES;		}
"|"|"||"|"+"	      	{    					return OR;		} 
"&"|"&&"|"*"	      	{   					return AND;		}
"!"|"-"		      	{   					return NOT;		}
"("		      	{   					return *yytext;		}
")"		      	{   					return *yytext;		}
"="		      	{   					return *yytext;		}
";"		      	{   					return *yytext;		}
\n 	      	      	{ ; } 
.		      	{ ; }

%%
