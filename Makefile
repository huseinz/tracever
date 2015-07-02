all:
	bison -d -g ltl_parser.y
	flex -Cem -v --header-file=lex.yy.h ltl_lexer.l 
	gcc -o tracever *.c -O2
# gcc -o tracever ltl_parser.tab.c lex.yy.c tracever.c -O2
	dot -Tps ltl_parser.dot -o graph.pdf
	strip -s tracever
