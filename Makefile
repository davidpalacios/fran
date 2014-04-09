BFLAGS = -d -t -y

fran: y.tab.o lex.yy.o f_semantics.o
	gcc lex.yy.o y.tab.o f_semantics.o -o fran `pkg-config --libs glib-2.0` -lfl

y.tab.o: f_parser.y
	bison ${BFLAGS} f_parser.y
	gcc y.tab.c -c

lex.yy.o: f_scanner.lex
	flex f_scanner.lex
	gcc lex.yy.c -c

f_semantics.o: f_semantics.c
	gcc f_semantics.c -c `pkg-config --cflags glib-2.0`

clean: 
	rm -f -v lex.yy.* y.tab.* *.o fran