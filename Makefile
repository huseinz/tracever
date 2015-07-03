all: 
clean:
all:
	bison --language=c -W -d -g ltl_parser.y
	flex  -Cem -v --header-file=lex.yy.h ltl_lexer.l 
	gcc -Wall -o tracever *.c -O2 -DYYDEBUG=0 
debug:
	bison --language=c -W -v -t -d ltl_parser.y
	flex  -Cem -v --header-file=lex.yy.h ltl_lexer.l
	gcc -g -o tracever *.c -DYYDEBUG=1
graph:  
	bison --language=c -d -g ltl_parser.y
	dot -Tps ltl_parser.dot -o graph.pdf
clean:
	rm -f *.o *.dot lex.yy.* ltl_parser.tab.* *.pdf ltl_parser.output
