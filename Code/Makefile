############################
#	     Date: 05/2018     #
############################


all: mycompiler


mycompiler: myanalyzer.tab.c lex.yy.c
	gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl

myanalyzer.tab.c: 
	bison -d -v -r all myanalyzer.y

lex.yy.c: 
	flex mylexer.l


clean:
	rm lex.yy.c myanalyzer.tab.c myanalyzer.tab.h
	rm myanalyzer.output mycompiler CcodeSample CcodeSample.c