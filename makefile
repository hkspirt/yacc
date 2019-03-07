LEX=flex
YACC=bison
CC=g++

a:pb.tab.h pb.tab.c lex.yy.c 
	$(CC) pb.tab.h pb.tab.c lex.yy.c -o a

pb.tab.h:pb.y
	$(YACC) -d pb.y

lex.yy.c:pb.l
	$(LEX) pb.l

clean:
	rm -rf *.o *.c *.h *.html a