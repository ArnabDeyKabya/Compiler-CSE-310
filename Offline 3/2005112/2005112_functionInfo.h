#ifndef FUNCTION_INFO_H
#define FUNCTION_INFO_H
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <vector>
#include "2005112_symbolInfo.h"
using namespace std;
class VarInfo : public SymbolInfo
{
public:
    string dataType;
    VarInfo(string name, string type, int line, string dataType);
    void setDataType(string dataType);
    string getDataType();
};

class FunctionInfo : public SymbolInfo
{
public:
    string returnType;
    vector<VarInfo *> parameterList;
    bool defined;
    FunctionInfo(string name, string type, int line, string returnType);
    void addParameter(VarInfo *varInfo);
    string getReturnType();
    bool isDefined();
    void setDefined(bool defined);
};
#endif