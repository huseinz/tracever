%{

typedef struct{
	char* sval;
	char  tval;
}ident_t;

#include "ltl_parser.tab.h"

#define YY_DECL extern int yylex()

%}

%option noyywrap

%%

[ \t\n] 	      { ; } 
"X"		      { ; }
"U"		      { ; }
"G"		      { ; }
"F"		      { ; }
"R"		      { ; }
"W"		      { ; }
"true"    	      {   yylval.tval = 1; 			return BOOL; 		}
"false"		      {   yylval.tval = 0; 			return BOOL;		}
[a-zA-Z][a-zA-Z0-9_]* {   yylval.data.sval = strdup(yytext); 	return IDENTIFIER;	}
"->"|"=>"	      {   yylval.data.sval = strdup(yytext); 	return IMPLIES;		}
"<->"		      { ; }
"|"|"||"	      {   yylval.data.sval = strdup(yytext); 	return OR;		} 
"&"|"&&"	      {   yylval.data.sval = strdup(yytext); 	return AND;		}
"!"		      {   				 	return *yytext;		}
"("		      {   					return *yytext;		}
")"		      {   					return *yytext;		}
"="		      {   					return *yytext;		}
";"		      {   					return *yytext;		}
.		      { ; }

%%
