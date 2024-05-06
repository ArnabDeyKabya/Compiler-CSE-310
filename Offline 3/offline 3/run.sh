flex -o lex.yy.cpp new_scanner.l
echo 'step-3: lex.yy.cpp created'
rm a.out error.txt log.txt parsetree.txt
yacc --yacc -d parser.y -o y.tab.cpp
echo 'step-1: y.tab.cpp and y.tab.hpp created'
yacc --yacc -d parser.y
echo 'step-2: y.tab.c and y.tab.h created'
g++ -w *.cpp
rm lex.yy.cpp y.tab.cpp y.tab.hpp y.tab.h y.tab.c
./a.out in.txt