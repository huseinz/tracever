%{

#include "ltl.tab.h"

#define YY_DECL extern int yylex()

int numvars = 0;
%}

%option noyywrap

%%

[ \t\n\\] 	      { /*printf("lex found tab or newline\n");*/; } 
"true"    	      { /*printf("lex found boolean   '%s'\n", yytext);*/;   yylval.tval = 1; return BOOL; 	}
"false"		      { /*printf("lex found boolean   '%s'\n", yytext);*/;   yylval.tval = 0; return BOOL;	}
[a-zA-Z][a-zA-Z0-9_]* { /*printf("lex found identifier '%s'\n", yytext);*/;  yylval.ival = *yytext - 'a';return IDENTIFIER;}
"->"		      { /*printf("lex found operator   '%s'\n", yytext);*/;  yylval.sval = strdup(yytext); return IMPLIES;}
"<->"		      { /*printf("lex found operator   '%s'\n", yytext);*/;  }
"|"		      { /*printf("lex found operator   '%s'\n", yytext);*/;  return *yytext;} 
"&"		      { /*printf("lex found operator   '%s'\n", yytext);*/;  return *yytext;}
"[X]"		      { /*printf("lex found operator   '%s'\n", yytext);*/; }
"[U]"		      { /*printf("lex found operator   '%s'\n", yytext);*/; }
"[G]"		      { /*printf("lex found operator   '%s'\n", yytext);*/; }
"[F]"		      { /*printf("lex found operator   '%s'\n", yytext);*/; }
"[R]"		      { /*printf("lex found operator   '%s'\n", yytext);*/; }
"[W]"		      { /*printf("lex found operator   '%s'\n", yytext);*/; }
"!"		      { /*printf("lex found operator   '%s'\n", yytext);*/;   return *yytext;}
"("		      { /*printf("lex found operator   '%s'\n", yytext);*/;   return *yytext;}
")"		      { /*printf("lex found operator   '%s'\n", yytext);*/;   return *yytext;}
"="		      { /*printf("lex found operator   '%s'\n", yytext);*/;   return *yytext;}
";"		      { /*printf("lex found operator   '%s'\n", yytext);*/;   return *yytext;}
.		      { /*printf("Unknown token    '%s'\n", yytext);*/; }

%%
