all:
	bison --language=c -W -d -g ltl_parser.y
	flex  -Cem -v --header-file=lex.yy.h ltl_lexer.l 
	gcc -Wall -o tracever *.c -O3 -DYYDEBUG=0 
debug:
	bison --language=c -W -v -t -d ltl_parser.y
	flex  -Cem -p -v --header-file=lex.yy.h ltl_lexer.l
	gcc -g -o tracever *.c -DYYDEBUG=1
fast:
	bison --language=c -d ltl_parser.y
	flex  -Cfr -v --header-file=lex.yy.h ltl_lexer.l
	gcc -o tracever -O3 *.c -DYYDEBUG=0
graph:  
	bison --language=c -d -g ltl_parser.y
	dot -Tps ltl_parser.dot -o graph.pdf
clean:
	rm -f *.o *.dot lex.yy.* ltl_parser.tab.* *.pdf ltl_parser.output
