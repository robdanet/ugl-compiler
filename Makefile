#	$Id: Makefile,v 1.8 2008/07/10 16:44:14 dvermeir Exp $
#
CFLAGS=		-Wall -g
CC=		gcc
#
SOURCE=		uglyc.sh ugly.y ugly.l symbol.c symbol.h Makefile *.mi
#
all:		ugly uglyc demo
ugly:		ugly.tab.o lex.yy.o symbol.o
		gcc $(CFLAGS) -o $@ $^

lex.yy.c:	ugly.l ugly.tab.h
		flex ugly.l
#
#	Bison options:
#
#	-v	Generate ugly.output showing states of LALR parser
#	-d	Generate ugly.tab.h containing token type definitions
#
ugly.tab.h\
ugly.tab.c:	ugly.y
		bison -v -d $^
##
demo:		uglyc ugly demo.ug
		./uglyc demo.ug
#
CFILES=	$(filter %.c, $(SOURCE)) ugly.tab.c lex.yy.c
HFILES=	$(filter %.h, $(SOURCE)) ugly.tab.h
include make.depend
make.depend: 	$(CFILES) $(HFILES)
		gcc -M $(CFILES) >$@

clean:
		rm -f ugly.yy.c ugly.tab.[hc] *.o uglyc ugly ugly.output *.s test?
#
tar:
		tar cvf ugly.tar $(SOURCE)


