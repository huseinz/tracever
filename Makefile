all:
	bison -d -g ltl.y
	flex ltl.l
	gcc -o tracever ltl.tab.c lex.yy.c -O2
