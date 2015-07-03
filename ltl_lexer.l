%{
#include "ltl_parser.tab.h"
%}

%option noyywrap

%%

[ \t]			{  }
#.*\n			{  }
"X"		      	{ 					return NEXT; 		}
"U"		      	{ 					return UNTIL; 		}
"G"		      	{ 					return GLOBAL; 		}
"F"		      	{ 					return FUTURE; 		}
"R"		      	{ 					return RELEASE; 	}
"true"    	      	{ yylval.tval = 1; 			return INTEGER; 	}
"false"		      	{ yylval.tval = 0; 			return INTEGER;		}
[0-9]*			{ yylval.tval = strtol(yytext, NULL, 10); return INTEGER;} //make this safer
[a-zA-Z][a-zA-Z0-9_]* 	{ yylval.sval = strdup(yytext); 	return IDENTIFIER;	}
"->"		      	{   					return IMPLIES;		}
"<"		      	{ 					return COMPARATOR; 	}
">"		      	{ 					return COMPARATOR; 	}
">="		      	{ 					return COMPARATOR; 	}
"<="		      	{ 					return COMPARATOR; 	}
"=="|"<->" 		{					return COMPARATOR; 	}
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
