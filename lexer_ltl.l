%{
#include "parser_ltl.tab.h"
#include <limits.h>
%}

%option noyywrap
%option nounput
%option noinput

%%

[ \t,]			{  }
#.*\n			{  }
"U"		      	{ 					return UNTIL; 		}
"G"		      	{ 					return GLOBAL; 		}
"F"		      	{ 					return FUTURE; 		}
"true"    	      	{ yylval.fval = 1; 			return REAL;	 	}
"false"		      	{ yylval.fval = 0; 			return REAL;		}
[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)? { 	
								//TODO safety
								yylval.fval = strtod(yytext, NULL);	
								return REAL;		} 
[a-zA-Z][a-zA-Z0-9_-]* 	{ yylval.sval = strdup(yytext); 	return PARAM;		}
":"			{ 					return *yytext;		}
"->"		      	{   					return IMP;		}
"<"		      	{ yylval.sval = strdup(yytext); 	return COMP; 		}
">"		      	{ yylval.sval = strdup(yytext); 	return COMP; 		}
">="		      	{ yylval.sval = strdup(yytext); 	return COMP; 		}
"<="		      	{ yylval.sval = strdup(yytext); 	return COMP; 		}
"=="	 		{ yylval.sval = strdup(yytext); 	return COMP; 		}
"!="			{ yylval.sval = strdup(yytext);		return COMP;		}
"+"			{ }
"-"			{ }
"*"			{ }
"\\"			{ }
"||"		    	{					return OR;		} 
"&&"	      		{   					return AND;		}
"!"		      	{   					return NOT;		}
"("		      	{   					return *yytext;		}
")"		      	{   					return *yytext;		}
\n 	      	      	{  } 
.		      	{ printf("UNRECOGNIZED TOKEN %s\n", yytext); }

%%
