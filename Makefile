all:
	bison --language=c -W -d -g parser_ltl.y
	flex  -Cem --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l 
	gcc -Wall -o tracever *.c -O3  
debug:
	bison --language=c -W -v -t -d parser_ltl.y
	flex  -Cem -p -v --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l
	gcc -g -o tracever *.c -DYYDEBUG -DVERBOSE
verbose:
	bison --language=c -W -d -f parser_ltl.y
	flex -Cem -v --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l
	gcc -Wall -o tracever *.c -O3 -DVERBOSE
fast:
	bison --language=c -d parser_ltl.y
	flex  -Cfr -v --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l
	gcc -o tracever -O3 *.c 
graph:  
	bison --language=c -d -g parser_ltl.y
	dot -Tps parser_ltl.dot -o graph.pdf
clean:
	rm -f *.o *.dot lex_ltl.yy.* parser_ltl.tab.* *.pdf parser_ltl.output tracever *~


