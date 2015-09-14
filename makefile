LEX = flex
YACC = yacc -d
CC = gcc


all: langage

langage: y.tab.o lex.yy.o 
	$(CC) -o langage lex.yy.o y.tab.o -lfl 

lex.yy.o: lex.yy.c define.h
	$(CC) -c lex.yy.c

y.tab.o: y.tab.c y.tab.h 
	$(CC) -c y.tab.c 

lex.yy.c: langage.lex
	$(LEX) langage.lex

y.tab.c y.tab.h: langage.yacc
	$(YACC) -v langage.yacc

clean:
	rm -f *.o lex.yy.c *.tab.*

mrproper: clean
	rm -f langage







