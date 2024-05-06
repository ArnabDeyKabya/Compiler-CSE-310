#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include "2005112_symbolInfo.h"
using namespace std;

class ScopeTable
{
private:
    int num_buckets, scope_table_no;
    SymbolInfo **table;

public:
    string id;
    int scope_count;
    ScopeTable *parent_scope;
    ScopeTable(int num_buckets, int scope_table_no, ScopeTable *parent_scope = NULL);
    ~ScopeTable();
    SymbolInfo *lookUp(string name);
    bool insert(string name, string type, int line);
    bool insert(SymbolInfo *a);
    bool Delete(string name);
    string print();
    int getScopeTableNo();
};

class SymbolTable
{
    ScopeTable *current_scope;
    int scope_table_no;

public:
    SymbolTable();
    ~SymbolTable();
    void enterScope();
    void exitScope();
    bool insert(string name, string type, int line);
    bool insert(SymbolInfo *s);
    bool remove(string name);
    SymbolInfo *lookUp(string name);
    SymbolInfo *lookUpCurrent(string name);
    void printCurrentScope();
    string printAllScope();
};
#endif