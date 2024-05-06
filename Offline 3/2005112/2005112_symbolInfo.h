#ifndef SYMBOL_INFO_H
#define SYMBOL_INFO_H
#include<iostream>
#include<stdlib.h>
#include<string.h>
#include<vector>
using namespace std;

class SymbolInfo
{
private:
    string name;
    string type;
    int line;
public:
    SymbolInfo* next;
    SymbolInfo(string name, string type, int line);
    string getName();
    string getType();
    int getLine();
    void setName(string name);
    void setType(string type);
    bool operator !=(SymbolInfo symbolInfo);
};
#endif