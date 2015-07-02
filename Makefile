all:
	bison -d -g ltl_parser.y
	flex  -d -Cem -v --header-file=lex.yy.h ltl_lexer.l 
	gcc -o tracever *.c -O2 
debug:
	bison --debug -d -g ltl_parser.y
	flex -d -Cem -v --header-file=lex.yy.h ltl_lexer.l
	gcc -g -o tracever *.c 
graph:  
	bison -d -g ltl_parser.y
	dot -Tps ltl_parser.dot -o graph.pdf
