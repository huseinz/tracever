all: 	parser_ltl.tab.o lex_ltl.yy.o tracever.o automaton.o 	
	gcc -Wall -o tracever *.o -O3  
debug:
	bison --language=c -W -v -t -d parser_ltl.y
	flex  -Cem -p -v --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l
	gcc -g -o tracever *.c -DYYDEBUG -DVERBOSE
verbose:
	bison --language=c -W -d -f parser_ltl.y
	flex -Cem -v --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l
	gcc -Wall -o tracever *.c -O3 -DVERBOSE
graph:  
	bison --language=c -d -g parser_ltl.y
	dot -Tps parser_ltl.dot -o graph.pdf
clean:
	rm -f *.o *.dot lex_ltl.yy.* parser_ltl.tab.* *.pdf parser_ltl.output tracever *~

tracever.o: tracever.c
	gcc -Wall -c tracever.c -O3

automaton.o: automaton.c
	gcc -Wall -c automaton.c -O3
	
lex_ltl.yy.o:  lexer_ltl.l
	gcc -Wall -c lex_ltl.yy.c -O3

parser_ltl.tab.o: parser_ltl.y
	gcc -Wall -c parser_ltl.tab.c -O3

lexer_ltl.l:
	flex  -Cfr -v --header-file=lex_ltl.yy.h -o lex_ltl.yy.c lexer_ltl.l

parser_ltl.y:
	bison --language=c -d -g parser_ltl.y
