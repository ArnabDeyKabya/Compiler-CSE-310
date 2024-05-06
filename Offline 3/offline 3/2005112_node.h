#ifndef NODE_H
#define NODE_H
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include "2005112_symbolInfo.h"
using namespace std;
class Node
{
public:
    Node *parent;
    vector<Node *> children;
    string value;
    string type;
    int line;
    int end;
    bool zero = 0;
    Node(string value, string type, int line, int end);
    Node(SymbolInfo *symbolInfo);
    void add(Node *node);
    vector<Node *> getChildren();
    string getType();
    string getValue();
    int getLine();
    int getEnd();
};
void dfs(Node *node, FILE *fp, int tab);
#endif
