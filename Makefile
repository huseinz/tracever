all:
	flex tokens.l
	gcc -o tracever lex.yy.c -O2
