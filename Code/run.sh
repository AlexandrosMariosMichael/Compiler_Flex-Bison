#!/bin/bash

echo -n "Please give the name of the example you want to run(etc sample001) : "
read answer
echo -n ""
example=sampleFiles/$answer


#example=sampleFiles/sample001
#example=sampleFiles/bad005	

bison -d -v -r all myanalyzer.y
flex mylexer.l
gcc -o mycompiler lex.yy.c myanalyzer.tab.c cgen.c -lfl
echo -n "-------------Lexer - Analyzer ----------------"
echo ""
./mycompiler < $example.fl 
echo -n "-----------------------------------------------"
echo ""

./mycompiler < $example.fl > CcodeSample.c
echo -n ""
gcc -std=c11 -o CcodeSample CcodeSample.c
echo -n "Analyzed Program compiled and run: "
echo -n ""
./CcodeSample
echo -n ""

rm lex.yy.c myanalyzer.tab.c  myanalyzer.tab.h 
rm mycompiler
#rm myanalyzer.output
#rm CcodeSample.c
#rm CcodeSample

