%option noyywrap

%%

[ \t\n] 		;
"true"    	       printf("Found operator   '%s'\n", yytext);
"false"		       printf("Found operator   '%s'\n", yytext);
"|"		       printf("Found operator   '%s'\n", yytext);
[a-zA-Z_][a-zA-Z0-9_]* printf("Found identifier '%s'\n", yytext);
"->"		       printf("Found operator   '%s'\n", yytext);
"<->"		       printf("Found operator   '%s'\n", yytext);
"&"		       printf("Found operator   '%s'\n", yytext);
"[X]"		       printf("Found operator   '%s'\n", yytext);
"[U]"		       printf("Found operator   '%s'\n", yytext);
"[G]"		       printf("Found operator   '%s'\n", yytext);
"[F]"		       printf("Found operator   '%s'\n", yytext);
"[R]"		       printf("Found operator   '%s'\n", yytext);
"[W]"		       printf("Found operator   '%s'\n", yytext);
"[!]"		       printf("Found operator   '%s'\n", yytext);
"("		       printf("Found operator   '%s'\n", yytext);
")"		       printf("Found operator   '%s'\n", yytext);
.		       printf("Unknown token    '%s'\n", yytext);

%%

main(){
	yylex();
}

