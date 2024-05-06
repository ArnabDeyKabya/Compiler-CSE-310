
#include "2005112_symbolInfo.h"
using namespace std;

SymbolInfo::SymbolInfo(string name, string type, int line)
    : name(name), type(type), line(line)
{
    next = NULL;
}
string SymbolInfo::getName()
{
    return name;
}
string SymbolInfo::getType()
{
    return type;
}
int SymbolInfo::getLine()
{
    return line;
}
void SymbolInfo::setName(string name)
{
    this->name = name;
}
void SymbolInfo::setType(string type)
{
    this->type = type;
}
bool SymbolInfo::operator!=(SymbolInfo symbolInfo)
{
    return name != symbolInfo.name;
}