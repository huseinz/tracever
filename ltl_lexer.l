%{
#include "ltl_parser.tab.h"
%}

%option noyywrap
%option nounput
%option noinput

%%

[ \t]			{  }
#.*\n			{  }
"X"		      	{ 					return NEXT; 		}
"U"		      	{ 					return UNTIL; 		}
"G"		      	{ 					return GLOBAL; 		}
"F"		      	{ 					return FUTURE; 		}
"true"    	      	{ yylval.tval = 1; 			return INTEGER; 	}
"false"		      	{ yylval.tval = 0; 			return INTEGER;		}
[0-9]+.[0-9]+		{ yylval.fval = strtod(yytext, NULL);	return REAL;		} //TODO safety
[0-9]+			{ yylval.fval = strtol(yytext, NULL, 10); return REAL;		} //TODO safety
[a-zA-Z][a-zA-Z0-9_]* 	{ yylval.sval = strdup(yytext); 	return IDENTIFIER;	}
"->"		      	{   					return IMPLIES;		}
"<"		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
">"		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
">="		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
"<="		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
"=="|"<->" 		{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
"||"		    	{					return OR;		} 
"&&"	      		{   					return AND;		}
"!"		      	{   					return NOT;		}
"("		      	{   					return *yytext;		}
")"		      	{   					return *yytext;		}
"="		      	{   					return *yytext;		}
";"		      	{   					return *yytext;		}
\n 	      	      	{  } 
.		      	{  }

%%
