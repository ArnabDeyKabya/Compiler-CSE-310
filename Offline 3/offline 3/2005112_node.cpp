#include <bits/stdc++.h>
#include "2005112_symbolInfo.h"
#include "2005112_node.h"
using namespace std;

Node::Node(string value, string type, int line, int end)
    : type(type), line(line), end(end)
{
    this->value = value + " \t<Line: " + to_string(line) + "-" + to_string(end) + ">";
}
Node::Node(SymbolInfo *symbolInfo)
{
    string str = symbolInfo->getType();
    if (symbolInfo->getType() == "ID" or symbolInfo->getType() == "ARRAY" or symbolInfo->getType() == "FUNCTION")
    {
        str = "ID";
    }
    type = symbolInfo->getType();
    line = symbolInfo->getLine();
    end = line;
    value = str + " : " + symbolInfo->getName() + "\t<Line: " + to_string(line) + ">";
}
void Node::add(Node *node)
{
    children.push_back(node);
}
vector<Node *> Node::getChildren()
{
    return children;
}
string Node::getType()
{
    return type;
}
string Node::getValue()
{
    return value;
}
int Node::getLine()
{
    return line;
}
int Node::getEnd()
{
    return end;
}

void dfs(Node *node, FILE *fp, int tab)
{
    int size = node->children.size();
    for (int i = 1; i <= tab; i++)
    {
        fprintf(fp, " ");
    }
    fprintf(fp, "%s\n", node->getValue().c_str());
    for (int i = 0; i < size; i++)
    {
        dfs(node->children[i], fp, tab + 1);
    }
    delete node;
}
