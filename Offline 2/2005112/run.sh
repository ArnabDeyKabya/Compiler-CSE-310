rm log.txt
rm temp.cpp
rm temp.o
rm token.txt
flex -o temp.cpp new_scanner.l
g++ temp.cpp -o -lfl -o temp.o
./temp.o input.txt 