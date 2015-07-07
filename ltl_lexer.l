%{
#include "ltl_parser.tab.h"
%}

%option noyywrap
%option nounput
%option noinput

%%

[ \t]			{  }
#.*\n			{  }
"U"		      	{ 					return UNTIL; 		}
"G"		      	{ 					return GLOBAL; 		}
"F"		      	{ 					return FUTURE; 		}
"true"    	      	{ yylval.fval = 1; 			return REAL;	 	}
"false"		      	{ yylval.fval = 0; 			return REAL;		}
-?[0-9]+.[0-9]+		{ yylval.fval = strtod(yytext, NULL);	return REAL;		} //TODO safety 
-?[0-9]+		{ yylval.fval = strtol(yytext, NULL, 10); return REAL;		} //TODO safety 
[a-zA-Z][a-zA-Z0-9_-]* 	{ yylval.sval = strdup(yytext); 	return IDENTIFIER;	}
"->"		      	{   					return IMPLIES;		}
"<"		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
">"		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
">="		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
"<="		      	{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
"=="	 		{ yylval.sval = strdup(yytext); 	return COMPARATOR; 	}
"!="			{ yylval.sval = strdup(yytext);		return COMPARATOR;	}
"+"			{ }
"-"			{ }
"*"			{ }
"\\"			{ }
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
